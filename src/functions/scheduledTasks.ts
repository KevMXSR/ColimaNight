import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { ActiveIncidentDocument } from '../types';

const db = admin.firestore();

/**
 * Tarea programada (Cron cada 5 minutos):
 * Caduca automáticamente incidentes y alertas tras 45 minutos de inactividad,
 * restaurando el estado de seguridad del bar a 'normal'.
 */
export const cleanupExpiredIncidents = functions.pubsub
  .schedule('every 5 minutes')
  .timeZone('America/Mexico_City')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    console.log('[ScheduledTask] Iniciando barrido de caducidad automática de incidentes...');

    // 1. Buscar incidentes activos o en revisión que hayan superado su TTL
    const expiredIncidentsSnap = await db.collection('active_incidents')
      .where('status', 'in', ['active_alert', 'under_review'])
      .where('expiresAt', '<=', now)
      .get();

    if (expiredIncidentsSnap.empty) {
      console.log('[ScheduledTask] No hay incidentes vencidos.');
      return null;
    }

    const batch = db.batch();
    let count = 0;

    for (const doc of expiredIncidentsSnap.docs) {
      const data = doc.data() as ActiveIncidentDocument;
      const venueId = data.venueId;
      const venueRef = db.collection('venues').doc(venueId);

      // Archivar estado del incidente
      batch.update(doc.ref, {
        status: 'expired',
        resolvedAt: now,
        notes: 'Caducado automáticamente por inactividad tras 45 minutos (TTL).',
      });

      // Restaurar estatus de seguridad del bar
      batch.update(venueRef, {
        'securityStatus.level': 'normal',
        'securityStatus.activeIncidentId': null,
        'securityStatus.incidentType': null,
        'securityStatus.alertExpiresAt': null,
        'securityStatus.warningMessage': null,
        updatedAt: now,
      });

      count++;
    }

    await batch.commit();
    console.log(`[ScheduledTask] Se caducaron y normalizaron ${count} incidentes expirados.`);
    return null;
  });

/**
 * Tarea programada (Cron diario a las 06:00 AM hora de Colima):
 * Resetea contadores de afluencia de la noche anterior (checkinsTonight, etc.)
 * para preparar el inicio del nuevo ciclo operativo.
 */
export const resetNightlyCounters = functions.pubsub
  .schedule('0 6 * * *')
  .timeZone('America/Mexico_City')
  .onRun(async (context) => {
    console.log('[ScheduledTask] Reiniciando contadores de asistencia nocturna (06:00 AM)...');

    const venuesSnap = await db.collection('venues').where('active', '==', true).get();
    const batch = db.batch();

    venuesSnap.forEach((doc) => {
      batch.update(doc.ref, {
        'stats.checkinsTonight': 0,
        'stats.averageWaitMinutes': 0,
        currentOccupancyPercent: 0,
        vibeScore: 'tranquilo',
        updatedAt: admin.firestore.Timestamp.now(),
      });
    });

    await batch.commit();
    console.log(`[ScheduledTask] Contadores reseteados para ${venuesSnap.size} establecimientos.`);
    return null;
  });
