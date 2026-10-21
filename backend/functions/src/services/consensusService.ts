import { firestore } from 'firebase-admin';
import { CONFIG } from '../config';
import {
  ActiveIncidentDocument,
  IncidentCategory,
  IncidentReportDocument,
} from '../types';
import { calculateHaversineDistanceMeters } from '../utils/geo';

export class ConsensusService {
  private db: firestore.Firestore;

  constructor(db: firestore.Firestore) {
    this.db = db;
  }

  /**
   * Procesa el reporte evaluando el blindaje reputacional:
   * - Requiere cuórum estricto de 5 dispositivos independientes en 10 minutos (3 para armas).
   * - Menos de 5 reportes permanecen en auditoría interna confidencial sin alterar el semáforo público.
   */
  async evaluateReport(
    venueId: string,
    incidentType: IncidentCategory,
    hashedDeviceId: string,
    userLocation: firestore.GeoPoint,
    sanitizedComment?: string
  ): Promise<{ status: 'internal_audit' | 'active_alert'; quorumReached: boolean; distinctCount: number }> {
    const venueRef = this.db.collection('venues').doc(venueId);
    const activeIncidentRef = this.db.collection('active_incidents').doc(venueId);

    const now = firestore.Timestamp.now();
    const tenMinutesAgo = new firestore.Timestamp(
      now.seconds - (CONFIG.QUORUM_WINDOW_MINUTES * 60),
      now.nanoseconds
    );
    const expiresAt = new firestore.Timestamp(
      now.seconds + (CONFIG.INCIDENT_TTL_MINUTES * 60),
      now.nanoseconds
    );

    // Consulta de reportes en la ventana rodante de 10 minutos
    const recentReportsSnap = await this.db.collection('incident_reports')
      .where('venueId', '==', venueId)
      .where('createdAt', '>=', tenMinutesAgo)
      .get();

    // Filtro de dispositivos únicos y dispersión espacial mínima (>= 4m)
    const uniqueDevices = new Set<string>();
    const locations: Array<{ latitude: number; longitude: number }> = [];

    uniqueDevices.add(hashedDeviceId);
    locations.push({ latitude: userLocation.latitude, longitude: userLocation.longitude });

    for (const doc of recentReportsSnap.docs) {
      const rep = doc.data() as IncidentReportDocument;
      if (!uniqueDevices.has(rep.hashedDeviceId)) {
        let isSpaced = true;
        for (const loc of locations) {
          const dist = calculateHaversineDistanceMeters(
            loc.latitude,
            loc.longitude,
            rep.clientLocation.latitude,
            rep.clientLocation.longitude
          );
          if (dist < CONFIG.MIN_COORDINATE_DELTA_METERS) {
            isSpaced = false; // Posible emulación de múltiples IDs en el mismo píxel
            break;
          }
        }

        if (isSpaced) {
          uniqueDevices.add(rep.hashedDeviceId);
          locations.push({
            latitude: rep.clientLocation.latitude,
            longitude: rep.clientLocation.longitude,
          });
        }
      }
    }

    const distinctCount = uniqueDevices.size;
    const isWeaponIncident = incidentType === 'arma_fuego' || incidentType === 'arma_blanca';
    const requiredQuorum = isWeaponIncident
      ? CONFIG.QUORUM_WEAPONS_THRESHOLD // 3 reportes
      : CONFIG.QUORUM_GENERAL_THRESHOLD; // 5 reportes

    const quorumReached = distinctCount >= requiredQuorum;

    await this.db.runTransaction(async (transaction) => {
      const activeIncDoc = await transaction.get(activeIncidentRef);
      const venueDoc = await transaction.get(venueRef);

      if (!venueDoc.exists) {
        throw new Error(`Establecimiento ${venueId} no encontrado.`);
      }

      if (quorumReached) {
        // === CUÓRUM ALCANZADO (>= 5 REPORTES O >= 3 ARMAS): ALERTA PÚBLICA ===
        const warningMessage = getPublicWarningMessage(incidentType);

        const activeData: ActiveIncidentDocument = {
          id: venueId,
          venueId,
          incidentType,
          status: 'active_alert',
          reportCount: (activeIncDoc.exists ? activeIncDoc.data()?.reportCount || 0 : 0) + 1,
          distinctDeviceCount: distinctCount,
          reportingDeviceHashes: Array.from(uniqueDevices),
          reportingCoordinates: locations,
          firstReportAt: activeIncDoc.exists ? activeIncDoc.data()?.firstReportAt : now,
          lastReportAt: now,
          alertTriggeredAt: now,
          expiresAt,
          isInternalAuditOnly: false,
          warningMessage,
        };

        transaction.set(activeIncidentRef, activeData, { merge: true });

        // Activación del semáforo público en el venue
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

        console.log(`[ConsensusService] ALERTA PÚBLICA ACTIVADA para ${venueId}. Cuórum verificado: ${distinctCount}/${requiredQuorum}`);
      } else {
        // === BLINDAJE REPUTACIONAL: MENOS DE 5 REPORTES -> AUDITORÍA INTERNA CONFIDENCIAL ===
        const activeData: ActiveIncidentDocument = {
          id: venueId,
          venueId,
          incidentType,
          status: 'internal_audit',
          reportCount: (activeIncDoc.exists ? activeIncDoc.data()?.reportCount || 0 : 0) + 1,
          distinctDeviceCount: distinctCount,
          reportingDeviceHashes: Array.from(uniqueDevices),
          reportingCoordinates: locations,
          firstReportAt: activeIncDoc.exists ? activeIncDoc.data()?.firstReportAt : now,
          lastReportAt: now,
          alertTriggeredAt: null,
          expiresAt,
          isInternalAuditOnly: true,
          warningMessage: 'En auditoría técnica interna (sin alerta pública)',
        };

        transaction.set(activeIncidentRef, activeData, { merge: true });

        // IMPORTANTE: NO se altera el estatus público del venue para no dañar su imagen
        console.log(`[ConsensusService] Reporte en auditoría interna para ${venueId}. Reportes independientes: ${distinctCount}/${requiredQuorum}. Reputación protegida.`);
      }
    });

    return {
      status: quorumReached ? 'active_alert' : 'internal_audit',
      quorumReached,
      distinctCount,
    };
  }
}

function getPublicWarningMessage(type: IncidentCategory): string {
  switch (type) {
    case 'arma_fuego':
    case 'arma_blanca':
      return 'Alerta confirmada por cuórum: Situación de alto riesgo reportada por asistentes.';
    case 'pelea':
    case 'altercado':
      return 'Aviso comunitario verificado: Conato de riña/altercado en el área.';
    case 'sobrecupo_critico':
      return 'Aviso de afluencia: Sobrecupo crítico en accesos e interior.';
    case 'operativo_policial':
      return 'Operativo de seguridad y vialidad activo en el perímetro.';
    default:
      return 'Aviso de precaución verificado por la comunidad.';
  }
}
