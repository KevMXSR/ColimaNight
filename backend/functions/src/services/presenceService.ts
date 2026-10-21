import { firestore } from 'firebase-admin';
import { CONFIG } from '../config';
import { PresenceHeartbeatDocument, VenueDocument, VibeScore } from '../types';

export class PresenceService {
  private db: firestore.Firestore;

  constructor(db: firestore.Firestore) {
    this.db = db;
  }

  /**
   * Registra el latido de presencia (Presence Heartbeat) dentro de los 80 metros del bar.
   * Actualiza en tiempo real `venues/{venueId}.liveAttendeesCount` y el porcentaje de aforo.
   */
  async recordHeartbeat(
    venueId: string,
    clientLocation: firestore.GeoPoint,
    distanceMeters: number,
    accuracyMeters: number,
    userId: string | null,
    sessionToken: string,
    hashedDeviceId: string
  ): Promise<{ liveAttendeesCount: number; currentOccupancyPercent: number; vibeScore: VibeScore }> {
    const venueRef = this.db.collection('venues').doc(venueId);
    const venueSnap = await venueRef.get();

    if (!venueSnap.exists) {
      throw new Error(`El establecimiento ${venueId} no existe.`);
    }

    const venue = venueSnap.data() as VenueDocument;
    const now = firestore.Timestamp.now();
    const expiresAt = new firestore.Timestamp(
      now.seconds + (CONFIG.PRESENCE_HEARTBEAT_TTL_MINUTES * 60),
      now.nanoseconds
    );

    // Guardar o refrescar el latido en la subcolección del bar
    const heartbeatId = `${hashedDeviceId}_${venueId}`;
    const heartbeatRef = venueRef.collection('presence_heartbeats').doc(heartbeatId);

    const heartbeatData: PresenceHeartbeatDocument = {
      venueId,
      userId,
      sessionToken,
      hashedDeviceId,
      clientLocation,
      distanceMeters,
      accuracyMeters,
      isGuest: !userId,
      timestamp: now,
      expiresAt,
    };

    await heartbeatRef.set(heartbeatData, { merge: true });

    // Contar asistentes activos (heartbeats vigentes dentro de la ventana de 45 min)
    const activeHeartbeatsSnap = await venueRef.collection('presence_heartbeats')
      .where('expiresAt', '>', now)
      .get();

    const activeAttendees = activeHeartbeatsSnap.size;
    const capacityThreshold = venue.capacityThreshold || 120; // Default capacity
    const occupancyPercent = Math.min(100, Math.round((activeAttendees / capacityThreshold) * 100));

    // Cálculo dinámico de vibra según aforo
    let dynamicVibe: VibeScore = 'tranquilo';
    if (occupancyPercent >= 95) dynamicVibe = 'saturado';
    else if (occupancyPercent >= 75) dynamicVibe = 'fiesta_total';
    else if (occupancyPercent >= 50) dynamicVibe = 'animado';
    else if (occupancyPercent >= 25) dynamicVibe = 'chill';

    // Actualización atómica en el documento del venue
    await venueRef.update({
      liveAttendeesCount: activeAttendees,
      currentOccupancyPercent: occupancyPercent,
      vibeScore: dynamicVibe,
      'stats.heartbeatsTonight': firestore.FieldValue.increment(1),
      'stats.lastTelemetryUpdate': now,
      updatedAt: now,
    });

    return {
      liveAttendeesCount: activeAttendees,
      currentOccupancyPercent: occupancyPercent,
      vibeScore: dynamicVibe,
    };
  }

  /**
   * Limpia latidos vencidos (> 45 minutos) y recalcula la telemetría del local.
   */
  async cleanupExpiredHeartbeats(venueId: string): Promise<number> {
    const venueRef = this.db.collection('venues').doc(venueId);
    const now = firestore.Timestamp.now();

    const expiredSnap = await venueRef.collection('presence_heartbeats')
      .where('expiresAt', '<=', now)
      .get();

    if (expiredSnap.empty) return 0;

    const batch = this.db.batch();
    expiredSnap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    // Recalcular contador vigente
    const activeSnap = await venueRef.collection('presence_heartbeats')
      .where('expiresAt', '>', now)
      .get();

    const activeAttendees = activeSnap.size;
    const venueSnap = await venueRef.get();
    const capacity = venueSnap.data()?.capacityThreshold || 120;
    const occupancyPercent = Math.min(100, Math.round((activeAttendees / capacity) * 100));

    await venueRef.update({
      liveAttendeesCount: activeAttendees,
      currentOccupancyPercent: occupancyPercent,
      'stats.lastTelemetryUpdate': now,
      updatedAt: now,
    });

    return expiredSnap.size;
  }
}
