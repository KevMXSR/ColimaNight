import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { LiveVibeRequest, LiveVibeCheckinDocument, VenueDocument, VibeScore } from '../types';
import { getNightlySaltDate, hashDeviceIdWithDailySalt } from '../utils/crypto';
import { validateProximity } from '../utils/geo';
import { CONFIG } from '../config';

const db = admin.firestore();

const CROWD_PERCENT_MAP: Record<string, number> = {
  vacio: 20,
  medio: 55,
  lleno: 85,
  sobrecupo: 100,
};

/**
 * Cloud Function HTTPS Callable: Envío de señal de afluencia, ambiente y fila en vivo
 */
export const submitVibe = functions.https.onCall(
  async (data: LiveVibeRequest, context) => {
    const {
      venueId,
      deviceFingerprint,
      latitude,
      longitude,
      accuracyMeters,
      vibe,
      crowdLevel,
      waitMinutes,
    } = data;

    if (!venueId || !deviceFingerprint || latitude == null || longitude == null) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Parámetros insuficientes para registrar señal en vivo.'
      );
    }

    const venueRef = db.collection('venues').doc(venueId);
    const venueSnap = await venueRef.get();
    if (!venueSnap.exists) {
      throw new functions.https.HttpsError('not-found', 'Establecimiento no encontrado.');
    }
    const venue = venueSnap.data() as VenueDocument;

    // Validación de proximidad (Proof of Proximity: 150m estándar)
    const allowedRadius = venue.proximityRadiusMeters || CONFIG.GEOFENCE_MAX_RADIUS_METERS;
    const proximity = validateProximity(
      venue.location.latitude,
      venue.location.longitude,
      latitude,
      longitude,
      accuracyMeters || 10,
      allowedRadius
    );

    if (!proximity.isValid) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        proximity.reason || `Debes estar en el establecimiento (${allowedRadius}m) para calificar el ambiente en vivo.`
      );
    }

    const saltDate = getNightlySaltDate();
    const hashedDeviceId = hashDeviceIdWithDailySalt(deviceFingerprint, saltDate);

    const now = admin.firestore.Timestamp.now();
    const expiresAt = new admin.firestore.Timestamp(
      now.seconds + (CONFIG.VIBE_TTL_MINUTES * 60),
      now.nanoseconds
    );

    const checkinDoc: LiveVibeCheckinDocument = {
      venueId,
      hashedDeviceId,
      vibe,
      crowdLevel,
      waitMinutes: Math.max(0, Math.min(waitMinutes || 0, 180)),
      location: new admin.firestore.GeoPoint(latitude, longitude),
      distanceMeters: proximity.distanceMeters,
      createdAt: now,
      expiresAt,
    };

    await db.collection('live_vibes').add(checkinDoc);

    // Calcular agregados de las últimas 2 horas
    const twoHoursAgo = new admin.firestore.Timestamp(
      now.seconds - (CONFIG.VIBE_TTL_MINUTES * 60),
      now.nanoseconds
    );

    const recentVibesSnap = await db.collection('live_vibes')
      .where('venueId', '==', venueId)
      .where('createdAt', '>=', twoHoursAgo)
      .get();

    let totalOccupancy = 0;
    let totalWait = 0;
    const vibeCounts: Record<string, number> = {};

    recentVibesSnap.forEach((doc) => {
      const v = doc.data() as LiveVibeCheckinDocument;
      totalOccupancy += CROWD_PERCENT_MAP[v.crowdLevel] || 50;
      totalWait += v.waitMinutes;
      vibeCounts[v.vibe] = (vibeCounts[v.vibe] || 0) + 1;
    });

    const count = recentVibesSnap.size || 1;
    const avgOccupancy = Math.round(totalOccupancy / count);
    const avgWait = Math.round(totalWait / count);

    // Vibe predominante
    let dominantVibe: VibeScore = vibe;
    let maxVibeCount = 0;
    for (const [v, c] of Object.entries(vibeCounts)) {
      if (c > maxVibeCount) {
        maxVibeCount = c;
        dominantVibe = v as VibeScore;
      }
    }

    await venueRef.update({
      currentOccupancyPercent: avgOccupancy,
      vibeScore: dominantVibe,
      'stats.checkinsTonight': admin.firestore.FieldValue.increment(1),
      'stats.averageWaitMinutes': avgWait,
      'stats.lastVibeUpdate': now,
      updatedAt: now,
    });

    return {
      success: true,
      message: '¡Gracias por compartir el vibe de la noche en Colima!',
      currentOccupancyPercent: avgOccupancy,
      vibeScore: dominantVibe,
      averageWaitMinutes: avgWait,
    };
  }
);
