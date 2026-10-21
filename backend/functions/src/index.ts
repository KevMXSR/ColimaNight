import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { CONFIG } from './config';
import { IncidentCategory, VenueDocument, DonationTier, DonationRecordDocument } from './types';
import { validateProximity80m } from './utils/geo';
import { getNightlySaltDate, hashDeviceIdWithDailySalt, hashDeviceForReputation } from './utils/crypto';
import { sanitizeAndModerate } from './utils/moderation';
import { PresenceService } from './services/presenceService';
import { ConsensusService } from './services/consensusService';
import { SocialIngestService } from './services/socialIngestService';

// Inicialización de Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const presenceService = new PresenceService(db);
const consensusService = new ConsensusService(db);
const socialIngestService = new SocialIngestService(db);

// ============================================================================
// 1. TELEMETRÍA DE AFORO EN VIVO: PRESENCE HEARTBEAT (Geocerca 80m, TTL 45 min)
// ============================================================================
export const submitPresenceHeartbeat = functions.https.onCall(
  async (data, context) => {
    const {
      venueId,
      latitude,
      longitude,
      accuracyMeters,
      deviceFingerprint,
      sessionToken,
    } = data;

    if (!venueId || latitude == null || longitude == null || !deviceFingerprint) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Faltan parámetros obligatorios de geolocalización o identificación de sesión.'
      );
    }

    // 1. Obtener coordenadas del establecimiento
    const venueDoc = await db.collection('venues').doc(venueId).get();
    if (!venueDoc.exists) {
      throw new functions.https.HttpsError('not-found', `El establecimiento ${venueId} no existe.`);
    }
    const venue = venueDoc.data() as VenueDocument;

    // 2. Validación estricta de Proof of Proximity a 80 metros exactos
    const proximity = validateProximity80m(
      venue.location.latitude,
      venue.location.longitude,
      latitude,
      longitude,
      accuracyMeters || 10
    );

    if (!proximity.isValid) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        proximity.reason || `Debes estar a menos de ${CONFIG.PROOF_OF_PROXIMITY_RADIUS_METERS}m del establecimiento para validar presencia in situ.`
      );
    }

    // 3. Anonimato criptográfico con salt nocturno rotativo
    const saltDate = getNightlySaltDate();
    const hashedDeviceId = hashDeviceIdWithDailySalt(deviceFingerprint, saltDate);
    const userId = context.auth ? context.auth.uid : null;
    const finalSessionToken = sessionToken || `guest_${hashedDeviceId.substring(0, 16)}`;

    // 4. Registrar heartbeat y actualizar contador en tiempo real
    const result = await presenceService.recordHeartbeat(
      venueId,
      new admin.firestore.GeoPoint(latitude, longitude),
      proximity.distanceMeters,
      accuracyMeters || 10,
      userId,
      finalSessionToken,
      hashedDeviceId
    );

    return {
      success: true,
      message: 'Presencia verificada in situ en local/terraza (80m).',
      distanceMeters: Math.round(proximity.distanceMeters),
      liveAttendeesCount: result.liveAttendeesCount,
      currentOccupancyPercent: result.currentOccupancyPercent,
      vibeScore: result.vibeScore,
      ttlMinutes: CONFIG.PRESENCE_HEARTBEAT_TTL_MINUTES,
    };
  }
);

// ============================================================================
// 2. BLINDAJE REPUTACIONAL: REPORTES DE INCIDENTES (Cuórum de 5 / 3 armas)
// ============================================================================
export const submitIncidentReport = functions.https.onCall(
  async (data, context) => {
    const {
      venueId,
      incidentType,
      latitude,
      longitude,
      accuracyMeters,
      deviceFingerprint,
      comment,
    } = data;

    if (!venueId || !incidentType || latitude == null || longitude == null || !deviceFingerprint) {
      throw new functions.https.HttpsError('invalid-argument', 'Parámetros obligatorios incompletos.');
    }

    // 1. Obtener establecimiento
    const venueDoc = await db.collection('venues').doc(venueId).get();
    if (!venueDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Establecimiento no encontrado.');
    }
    const venue = venueDoc.data() as VenueDocument;

    // 2. Validación estricta de Proof of Proximity a 80 metros exactos
    const proximity = validateProximity80m(
      venue.location.latitude,
      venue.location.longitude,
      latitude,
      longitude,
      accuracyMeters || 10
    );

    if (!proximity.isValid) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        proximity.reason || `Reporte rechazado: Se requiere estar a menos de ${CONFIG.PROOF_OF_PROXIMITY_RADIUS_METERS}m del bar para reportar.`
      );
    }

    // 3. Anonimato y Reputación de Dispositivo
    const saltDate = getNightlySaltDate();
    const hashedDeviceId = hashDeviceIdWithDailySalt(deviceFingerprint, saltDate);
    const reputationId = hashDeviceForReputation(deviceFingerprint);

    // Revisión de shadowban silencioso
    const repSnap = await db.collection('device_reputations').doc(reputationId).get();
    if (repSnap.exists && repSnap.data()?.isShadowbanned) {
      console.warn(`[submitIncidentReport] Dispositivo shadowbanned (${reputationId}). Descartado silenciosamente.`);
      return {
        success: true,
        status: 'internal_audit',
        message: 'Reporte recibido para revisión técnica.',
      };
    }

    // 4. Moderación de texto y blindaje anti-difamación
    const modResult = sanitizeAndModerate(comment);

    // 5. Registro individual con TTL de 45 minutos
    const now = admin.firestore.Timestamp.now();
    const expiresAt = new admin.firestore.Timestamp(
      now.seconds + (CONFIG.INCIDENT_TTL_MINUTES * 60),
      now.nanoseconds
    );

    await db.collection('incident_reports').add({
      venueId,
      incidentType: incidentType as IncidentCategory,
      hashedDeviceId,
      saltDate,
      clientLocation: new admin.firestore.GeoPoint(latitude, longitude),
      distanceMeters: proximity.distanceMeters,
      rawComment: comment ? comment.substring(0, 120) : '',
      sanitizedComment: modResult.sanitizedText,
      moderationResult: modResult,
      status: 'internal_audit',
      createdAt: now,
      expiresAt,
    });

    // 6. Evaluación de cuórum con blindaje reputacional
    const consensus = await consensusService.evaluateReport(
      venueId,
      incidentType as IncidentCategory,
      hashedDeviceId,
      new admin.firestore.GeoPoint(latitude, longitude),
      modResult.sanitizedText
    );

    return {
      success: true,
      status: consensus.status,
      quorumReached: consensus.quorumReached,
      distinctReportsCount: consensus.distinctCount,
      message: consensus.quorumReached
        ? 'Alerta confirmada por cuórum comunitario verificado.'
        : 'Reporte registrado en auditoría interna preventiva. No se altera la imagen pública del local hasta verificar cuórum.',
    };
  }
);

// ============================================================================
// 3. CADUCIDAD AUTOMÁTICA (TTL 45 min): PRESENCIA E INCIDENTES
// ============================================================================
export const cleanupExpiredPresenceAndIncidents = functions.pubsub
  .schedule('every 5 minutes')
  .timeZone('America/Mexico_City')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    console.log('[CleanupCron] Iniciando barrido de telemetría e incidentes expirados (TTL 45m)...');

    // A. Limpieza de Heartbeats de presencia vencidos (> 45 min) en locales activos
    const venuesSnap = await db.collection('venues').where('active', '==', true).get();
    let cleanedHeartbeatsTotal = 0;

    for (const doc of venuesSnap.docs) {
      const cleaned = await presenceService.cleanupExpiredHeartbeats(doc.id);
      cleanedHeartbeatsTotal += cleaned;
    }

    // B. Limpieza de Incidentes vencidos (> 45 min)
    const expiredIncidentsSnap = await db.collection('active_incidents')
      .where('status', 'in', ['active_alert', 'internal_audit'])
      .where('expiresAt', '<=', now)
      .get();

    const batch = db.batch();
    let normalizedVenuesCount = 0;

    expiredIncidentsSnap.forEach((doc) => {
      const data = doc.data();
      const venueRef = db.collection('venues').doc(data.venueId);

      batch.update(doc.ref, {
        status: 'expired',
        resolvedAt: now,
        notes: 'Caducado automáticamente por TTL de 45 minutos sin nuevos reportes.',
      });

      // Restaurar semáforo a normal
      batch.update(venueRef, {
        'securityStatus.level': 'normal',
        'securityStatus.activeIncidentId': null,
        'securityStatus.incidentType': null,
        'securityStatus.alertExpiresAt': null,
        'securityStatus.warningMessage': null,
        updatedAt: now,
      });

      normalizedVenuesCount++;
    });

    await batch.commit();

    console.log(`[CleanupCron] Concluido: ${cleanedHeartbeatsTotal} heartbeats eliminados y ${normalizedVenuesCount} alertas normalizadas.`);
    return null;
  });

// ============================================================================
// 4. PIPELINE DE EVENTOS DE INSTAGRAM (11 Canales Oficiales)
// ============================================================================
export const ingestSocialEvents = functions.pubsub
  .schedule('0 19 * * *') // Diario a las 7:00 PM hora de Colima antes del inicio nocturno
  .timeZone('America/Mexico_City')
  .onRun(async (context) => {
    console.log('[InstagramPipeline] Ejecutando sincronización de los 11 canales oficiales...');
    const result = await socialIngestService.syncOfficialInstagramEvents();
    return { success: true, synced: result.syncedCount };
  });

// Función invocable para pruebas o sincronización forzada por administradores
export const triggerSocialIngestManual = functions.https.onCall(
  async (data, context) => {
    if (context.auth && context.auth.token.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Solo administradores pueden forzar la sincronización.');
    }
    const result = await socialIngestService.syncOfficialInstagramEvents();
    return {
      success: true,
      message: `Sincronizados ${result.syncedCount} eventos de los 11 canales de Instagram.`,
      events: result.events,
    };
  }
);

// ============================================================================
// 5. MODELO DE APOYO COMUNITARIO / PATREON (Donativos para Sostenimiento)
// ============================================================================
export const getDonationTiers = functions.https.onCall(async () => {
  return {
    success: true,
    tiers: CONFIG.DONATION_TIERS,
    message: 'Niveles de apoyo comunitario para el sostenimiento de servidores y mapas en vivo de Colima.',
  };
});

export const recordCommunityDonation = functions.https.onCall(
  async (data, context) => {
    const { donorName, amountMxn, tier, paymentProvider, transactionReference, donorEmail } = data;

    if (!donorName || !amountMxn || !tier || !paymentProvider) {
      throw new functions.https.HttpsError('invalid-argument', 'Datos de donación incompletos.');
    }

    const selectedTier = (CONFIG.DONATION_TIERS as Record<string, any>)[tier];
    const badge = selectedTier ? selectedTier.badge : '🌟 Amigo ColimaNight';

    const donationDoc: DonationRecordDocument = {
      id: db.collection('donations').doc().id,
      userId: context.auth ? context.auth.uid : null,
      donorName,
      donorEmail: donorEmail || (context.auth?.token.email ?? null),
      amountMxn: Number(amountMxn),
      tier: tier as DonationTier,
      paymentProvider: paymentProvider as any,
      paymentStatus: 'completed',
      transactionReference: transactionReference || `TX_${Date.now()}`,
      badgeEarned: badge,
      createdAt: admin.firestore.Timestamp.now(),
    };

    await db.collection('donations').doc(donationDoc.id).set(donationDoc);

    // Si el usuario está autenticado, otorgar insignia en su perfil
    if (context.auth) {
      await db.collection('users').doc(context.auth.uid).set(
        {
          isSupporter: true,
          supporterBadge: badge,
          supporterSince: admin.firestore.Timestamp.now(),
        },
        { merge: true }
      );
    }

    return {
      success: true,
      message: `¡Muchas gracias por apoyar a ColimaNight! Tu donación ayuda a mantener la infraestructura comunitaria en tiempo real.`,
      badgeEarned: badge,
    };
  }
);
