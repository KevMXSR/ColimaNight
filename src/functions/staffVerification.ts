import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { StaffVerifyRequest, ActiveIncidentDocument } from '../types';
import { ReputationService } from '../services/reputationService';

const db = admin.firestore();
const reputationService = new ReputationService(db);

/**
 * Cloud Function HTTPS Callable: Confirmación o desestimación oficial por parte del staff del bar
 */
export const verifyIncidentByStaff = functions.https.onCall(
  async (data: StaffVerifyRequest, context) => {
    // 1. Verificar autenticación y reclamos de rol (Custom Claims)
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Se requiere inicio de sesión administrativo.'
      );
    }

    const { token } = context.auth;
    const isStaffOrAdmin = token.role === 'admin' || token.role === 'venue_staff' || token.isStaff === true;

    if (!isStaffOrAdmin) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'No posees permisos de personal autorizado para este establecimiento.'
      );
    }

    const { venueId, action, notes } = data;
    if (!venueId || !action || !['confirm', 'dismiss'].includes(action)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Parámetros inválidos para resolución de incidente.'
      );
    }

    // Verificar si el staff pertenece a este establecimiento específico (si no es admin global)
    if (token.role !== 'admin' && token.assignedVenueId && token.assignedVenueId !== venueId) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'No tienes autorización para administrar este bar específico.'
      );
    }

    const venueRef = db.collection('venues').doc(venueId);
    const activeIncidentRef = db.collection('active_incidents').doc(venueId);
    const now = admin.firestore.Timestamp.now();

    const activeIncSnap = await activeIncidentRef.get();
    if (!activeIncSnap.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'No hay incidente o reporte activo para este establecimiento.'
      );
    }

    const activeInc = activeIncSnap.data() as ActiveIncidentDocument;

    if (action === 'confirm') {
      // Confirmado por staff -> Elevación inmediata a ALERTA VERIFICADA
      const expiresAt = new admin.firestore.Timestamp(
        now.seconds + (45 * 60),
        now.nanoseconds
      );

      await db.runTransaction(async (t) => {
        t.update(activeIncidentRef, {
          status: 'active_alert',
          confirmedByStaff: true,
          staffUserId: context.auth!.uid,
          staffResolutionNotes: notes || 'Confirmado por personal in situ',
          alertTriggeredAt: now,
          expiresAt,
          lastReportAt: now,
        });

        t.update(venueRef, {
          'securityStatus.level': 'alert_verified',
          'securityStatus.alertExpiresAt': expiresAt,
          'securityStatus.alertConfirmedAt': now,
          'securityStatus.warningMessage': `Confirmado por personal: ${notes || 'Situación de atención en curso'}`,
          updatedAt: now,
        });
      });

      return {
        success: true,
        message: 'Alerta confirmada exitosamente por personal verificado.',
      };
    } else {
      // Desestimado / Desmentido por staff -> Falsa alarma / Situación controlada
      await db.runTransaction(async (t) => {
        t.update(activeIncidentRef, {
          status: 'debunked_by_staff',
          confirmedByStaff: false,
          staffUserId: context.auth!.uid,
          staffResolutionNotes: notes || 'Desmentido por personal del bar (Falsa alarma)',
          expiresAt: now,
        });

        t.update(venueRef, {
          'securityStatus.level': 'normal',
          'securityStatus.activeIncidentId': null,
          'securityStatus.incidentType': null,
          'securityStatus.alertExpiresAt': null,
          'securityStatus.warningMessage': null,
          updatedAt: now,
        });
      });

      // Penalizar a los dispositivos que generaron reportes falsos si fue falsa alarma flagrante
      if (notes?.toLowerCase().includes('falsa alarma') || notes?.toLowerCase().includes('trol')) {
        console.warn(`[StaffVerify] Aplicando penalizaciones por falso reporte en venue ${venueId}`);
        // Procesamos de forma asíncrona para no bloquear
        for (const hash of activeInc.reportingDeviceHashes || []) {
          // Buscamos el reporte para obtener reputación
          const repReports = await db.collection('incident_reports')
            .where('venueId', '==', venueId)
            .where('hashedDeviceId', '==', hash)
            .limit(1)
            .get();

          if (!repReports.empty) {
            // Se penaliza cada reporte falso recurrente
            await reputationService.penalizeDevice(hash, 'Falsa alarma reportada por personal verificado');
          }
        }
      }

      return {
        success: true,
        message: 'Incidente desestimado. El establecimiento ha vuelto al estatus normal.',
      };
    }
  }
);
