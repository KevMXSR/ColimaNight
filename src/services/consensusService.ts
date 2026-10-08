import { firestore } from 'firebase-admin';
import { CONFIG } from '../config';
import {
  ActiveIncidentDocument,
  IncidentType,
  IncidentReportDocument,
} from '../types';
import { calculateHaversineDistanceMeters } from '../utils/geo';

export class ConsensusService {
  private db: firestore.Firestore;

  constructor(db: firestore.Firestore) {
    this.db = db;
  }

  /**
   * Evalúa y actualiza el estado de consenso para un bar tras la llegada de un nuevo reporte legítimo.
   */
  async processIncidentReport(
    venueId: string,
    incidentType: IncidentType,
    hashedDeviceId: string,
    userLocation: firestore.GeoPoint,
    sanitizedComment?: string
  ): Promise<{ status: 'under_review' | 'active_alert'; quorumReached: boolean; distinctReportsCount: number }> {
    const venueRef = this.db.collection('venues').doc(venueId);
    const activeIncidentRef = this.db.collection('active_incidents').doc(venueId);

    const now = firestore.Timestamp.now();
    const windowStartTimestamp = new firestore.Timestamp(
      now.seconds - (CONFIG.QUORUM_WINDOW_MINUTES * 60),
      now.nanoseconds
    );
    const expiresAt = new firestore.Timestamp(
      now.seconds + (CONFIG.INCIDENT_TTL_MINUTES * 60),
      now.nanoseconds
    );

    // Consulta de reportes recientes de este establecimiento dentro de la ventana de 10 min
    const recentReportsSnap = await this.db.collection('incident_reports')
      .where('venueId', '==', venueId)
      .where('status', '==', 'counted_in_quorum')
      .where('createdAt', '>=', windowStartTimestamp)
      .get();

    // Filtro de dispositivos únicos y dispersión espacial
    const uniqueDevices = new Set<string>();
    const validLocations: Array<{ latitude: number; longitude: number }> = [];

    // Añadimos el reporte entrante
    uniqueDevices.add(hashedDeviceId);
    validLocations.push({ latitude: userLocation.latitude, longitude: userLocation.longitude });

    for (const doc of recentReportsSnap.docs) {
      const rep = doc.data() as IncidentReportDocument;
      if (!uniqueDevices.has(rep.hashedDeviceId)) {
        // Validación de dispersión de coordenadas (al menos 2-5m para evitar emulación en el mismo punto)
        let isSpatiallyDistinct = true;
        for (const loc of validLocations) {
          const dist = calculateHaversineDistanceMeters(
            loc.latitude,
            loc.longitude,
            rep.clientLocation.latitude,
            rep.clientLocation.longitude
          );
          if (dist < CONFIG.MIN_COORDINATE_DELTA_METERS) {
            // Mismo punto exacto; posible script de spam con diferentes IDs
            isSpatiallyDistinct = false;
            break;
          }
        }

        if (isSpatiallyDistinct) {
          uniqueDevices.add(rep.hashedDeviceId);
          validLocations.push({
            latitude: rep.clientLocation.latitude,
            longitude: rep.clientLocation.longitude,
          });
        }
      }
    }

    const distinctCount = uniqueDevices.size;
    const quorumReached = distinctCount >= CONFIG.QUORUM_REQUIRED_REPORTS;

    // Transacción atómica en Firestore para garantizar consistencia entre active_incidents y venues
    await this.db.runTransaction(async (transaction) => {
      const activeIncDoc = await transaction.get(activeIncidentRef);
      const venueDoc = await transaction.get(venueRef);

      if (!venueDoc.exists) {
        throw new Error(`El establecimiento con ID ${venueId} no existe.`);
      }

      if (quorumReached) {
        // === CUÓRUM ALCANZADO: ACTIVAR ALERTA GENERAL VERIFICADA ===
        const warningMessage = getWarningMessage(incidentType);

        const activeIncidentData: ActiveIncidentDocument = {
          id: venueId,
          venueId,
          incidentType,
          status: 'active_alert',
          reportCount: (activeIncDoc.exists ? activeIncDoc.data()?.reportCount || 0 : 0) + 1,
          distinctDeviceCount: distinctCount,
          reportingDeviceHashes: Array.from(uniqueDevices),
          reportingCoordinates: validLocations,
          firstReportAt: activeIncDoc.exists ? activeIncDoc.data()?.firstReportAt : now,
          lastReportAt: now,
          alertTriggeredAt: now,
          expiresAt,
          confirmedByStaff: false,
          warningMessage,
        };

        transaction.set(activeIncidentRef, activeIncidentData, { merge: true });

        // Actualizar el estado de seguridad en el documento público del establecimiento
        transaction.update(venueRef, {
          'securityStatus.level': 'alert_verified',
          'securityStatus.activeIncidentId': venueId,
          'securityStatus.incidentType': incidentType,
          'securityStatus.lastReportedAt': now,
          'securityStatus.alertExpiresAt': expiresAt,
          'securityStatus.alertConfirmedAt': now,
          'securityStatus.warningMessage': warningMessage,
          updatedAt: now,
        });

        console.log(`[ConsensusService] ALERTA VERIFICADA activada para venue ${venueId}. Quorum: ${distinctCount}/${CONFIG.QUORUM_REQUIRED_REPORTS}`);
      } else {
        // === CUÓRUM INSUFICIENTE (1 O 2 REPORTES): ESTADO EN REVISIÓN ===
        const activeIncidentData: ActiveIncidentDocument = {
          id: venueId,
          venueId,
          incidentType,
          status: 'under_review',
          reportCount: (activeIncDoc.exists ? activeIncDoc.data()?.reportCount || 0 : 0) + 1,
          distinctDeviceCount: distinctCount,
          reportingDeviceHashes: Array.from(uniqueDevices),
          reportingCoordinates: validLocations,
          firstReportAt: activeIncDoc.exists ? activeIncDoc.data()?.firstReportAt : now,
          lastReportAt: now,
          expiresAt,
          confirmedByStaff: false,
          warningMessage: 'Reporte preventivo en verificación técnica.',
        };

        transaction.set(activeIncidentRef, activeIncidentData, { merge: true });

        // En venues mantenemos el nivel 'under_review' o discreto
        transaction.update(venueRef, {
          'securityStatus.level': 'under_review',
          'securityStatus.activeIncidentId': venueId,
          'securityStatus.incidentType': incidentType,
          'securityStatus.lastReportedAt': now,
          'securityStatus.alertExpiresAt': expiresAt,
          'securityStatus.warningMessage': 'En proceso de verificación',
          updatedAt: now,
        });

        console.log(`[ConsensusService] Reporte en revisión para venue ${venueId}. Reportes independientes: ${distinctCount}/${CONFIG.QUORUM_REQUIRED_REPORTS}`);
      }
    });

    return {
      status: quorumReached ? 'active_alert' : 'under_review',
      quorumReached,
      distinctReportsCount: distinctCount,
    };
  }
}

function getWarningMessage(incidentType: IncidentType): string {
  switch (incidentType) {
    case 'pelea':
      return 'Reporte comunitario verificado: Altercado/Pelea en curso.';
    case 'altercado_violento':
      return 'Alerta comunitaria: Situación de conflicto en la zona.';
    case 'sobrecupo_critico':
      return 'Aviso de afluencia: Sobrecupo crítico en acceso e interior.';
    case 'operativo_policial':
      return 'Operativo de seguridad y vialidad activo en el perímetro.';
    case 'conato_bronca':
      return 'Precaución: Tensión y conato de altercado reportado.';
    case 'acoso_inseguridad':
      return 'Aviso preventivo de seguridad reportado por asistentes.';
    default:
      return 'Aviso de incidente preventivo verificado.';
  }
}
