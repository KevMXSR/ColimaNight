import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { IncidentReportRequest, IncidentReportDocument, VenueDocument } from '../types';
import { getNightlySaltDate, hashDeviceIdWithDailySalt, hashDeviceForReputation } from '../utils/crypto';
import { validateProximity } from '../utils/geo';
import { sanitizeAndModerateComment } from '../utils/moderation';
import { ReputationService } from '../services/reputationService';
import { ConsensusService } from '../services/consensusService';
import { CONFIG } from '../config';

const db = admin.firestore();
const reputationService = new ReputationService(db);
const consensusService = new ConsensusService(db);

/**
 * Cloud Function HTTPS Callable: Ingesta segura de incidentes con geocerca, anonimato y cuórum
 */
export const reportIncident = functions.https.onCall(
  async (data: IncidentReportRequest, context) => {
    const {
      venueId,
      incidentType,
      deviceFingerprint,
      latitude,
      longitude,
      accuracyMeters,
      comment,
    } = data;

    // 1. Validaciones básicas de parámetros
    if (!venueId || !incidentType || !deviceFingerprint || latitude == null || longitude == null) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Faltan parámetros obligatorios para registrar el reporte.'
      );
    }

    const validIncidentTypes = [
      'pelea',
      'sobrecupo_critico',
      'altercado_violento',
      'operativo_policial',
      'acoso_inseguridad',
      'conato_bronca',
    ];
    if (!validIncidentTypes.includes(incidentType)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Tipo de incidente no reconocido: ${incidentType}`
      );
    }

    // 2. Obtener datos del establecimiento
    const venueDoc = await db.collection('venues').doc(venueId).get();
    if (!venueDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'El establecimiento especificado no existe en la base de datos.'
      );
    }
    const venue = venueDoc.data() as VenueDocument;

    // 3. Validación de Geocerca (Proof of Proximity: 150m estándar)
    const allowedRadius = venue.proximityRadiusMeters || CONFIG.GEOFENCE_MAX_RADIUS_METERS;
    const proximityResult = validateProximity(
      venue.location.latitude,
      venue.location.longitude,
      latitude,
      longitude,
      accuracyMeters || 10,
      allowedRadius
    );

    if (!proximityResult.isValid) {
      console.warn(`[reportIncident] Proximity failure: ${proximityResult.reason}`);
      throw new functions.https.HttpsError(
        'failed-precondition',
        proximityResult.reason || `No te encuentras dentro del perímetro del bar (${allowedRadius}m).`
      );
    }

    // 4. Anonimato Criptográfico: Hash con Salt Rotativo Nocturno (06:00 AM cut-off)
    const saltDate = getNightlySaltDate();
    const hashedDeviceId = hashDeviceIdWithDailySalt(deviceFingerprint, saltDate);

    // 5. Verificación de Reputación y Shadowban (Seudónimo a largo plazo)
    const reputationId = hashDeviceForReputation(deviceFingerprint);
    const deviceReputation = await reputationService.getOrCreateDeviceReputation(reputationId);

    // SILENT SHADOWBAN: Si el dispositivo está baneado, fingir éxito pero ignorar el reporte
    if (deviceReputation.isShadowbanned) {
      console.warn(`[reportIncident] Dispositivo en SHADOWBAN (${reputationId}). Reporte descartado silenciosamente.`);
      // Guardamos reporte con status 'shadowbanned' para auditoría interna
      const shadowbanDoc: IncidentReportDocument = {
        venueId,
        incidentType,
        hashedDeviceId,
        saltDate,
        clientLocation: new admin.firestore.GeoPoint(latitude, longitude),
        distanceMeters: proximityResult.distanceMeters,
        rawComment: comment ? comment.substring(0, 120) : '',
        sanitizedComment: '[Descartado por filtro de reputación]',
        moderationResult: {
          passed: false,
          flaggedWords: ['SHADOWBANNED_USER'],
          hadNamesOrDefamation: false,
          sanitizedText: '',
          toxicityScore: 1.0,
        },
        status: 'shadowbanned',
        createdAt: admin.firestore.Timestamp.now(),
        expiresAt: new admin.firestore.Timestamp(
          admin.firestore.Timestamp.now().seconds + (CONFIG.INCIDENT_TTL_MINUTES * 60),
          0
        ),
      };
      await db.collection('incident_reports').add(shadowbanDoc);

      return {
        success: true,
        status: 'under_review',
        message: 'Tu reporte ha sido recibido y está en proceso de verificación por la comunidad.',
      };
    }

    // 6. Rate Limiting: Evitar spam del mismo dispositivo
    const rateCheck = await reputationService.checkRateLimit(reputationId, venueId, hashedDeviceId, saltDate);
    if (!rateCheck.allowed) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        rateCheck.reason || 'Has excedido el límite temporal de reportes.'
      );
    }

    // 7. Filtro de Moderación y Blindaje Anti-Difamación
    const moderation = sanitizeAndModerateComment(comment);

    // 8. Crear documento de reporte individual con TTL
    const now = admin.firestore.Timestamp.now();
    const expiresAt = new admin.firestore.Timestamp(
      now.seconds + (CONFIG.INCIDENT_TTL_MINUTES * 60),
      now.nanoseconds
    );

    const reportDoc: IncidentReportDocument = {
      venueId,
      incidentType,
      hashedDeviceId,
      saltDate,
      clientLocation: new admin.firestore.GeoPoint(latitude, longitude),
      distanceMeters: proximityResult.distanceMeters,
      rawComment: comment,
      sanitizedComment: moderation.sanitizedText,
      moderationResult: moderation,
      status: 'counted_in_quorum',
      createdAt: now,
      expiresAt,
    };

    await db.collection('incident_reports').add(reportDoc);

    // 9. Ejecutar Algoritmo de Consenso / Cuórum Mínimo
    const consensusResult = await consensusService.processIncidentReport(
      venueId,
      incidentType,
      hashedDeviceId,
      reportDoc.clientLocation,
      moderation.sanitizedText
    );

    return {
      success: true,
      status: consensusResult.status,
      quorumReached: consensusResult.quorumReached,
      verifiedReportsCount: consensusResult.distinctReportsCount,
      message: consensusResult.quorumReached
        ? 'Alerta confirmada por cuórum comunitario e informada a usuarios cercanos.'
        : 'Reporte registrado. En espera de confirmaciones adicionales para evitar falsas alarmas.',
    };
  }
);
