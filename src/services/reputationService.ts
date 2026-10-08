import { firestore } from 'firebase-admin';
import { CONFIG } from '../config';
import { DeviceReputationDocument } from '../types';

export class ReputationService {
  private db: firestore.Firestore;

  constructor(db: firestore.Firestore) {
    this.db = db;
  }

  /**
   * Obtiene o inicializa el registro de reputación del dispositivo.
   */
  async getOrCreateDeviceReputation(reputationId: string): Promise<DeviceReputationDocument> {
    const docRef = this.db.collection('device_reputations').doc(reputationId);
    const snap = await docRef.get();

    if (!snap.exists) {
      const now = firestore.Timestamp.now();
      const newReputation: DeviceReputationDocument = {
        id: reputationId,
        reputationScore: CONFIG.REPUTATION.INITIAL_SCORE,
        totalReportsSubmitted: 0,
        reportsVerified: 0,
        reportsDebunked: 0,
        isShadowbanned: false,
        strikes: 0,
        lastReportAt: now,
        updatedAt: now,
      };
      await docRef.set(newReputation);
      return newReputation;
    }

    const data = snap.data() as DeviceReputationDocument;

    // Verificar si el shadowban temporal ya expiró
    if (data.isShadowbanned && data.shadowbannedUntil) {
      const now = firestore.Timestamp.now();
      if (data.shadowbannedUntil.toMillis() <= now.toMillis()) {
        // Levantar shadowban en periodo de prueba
        data.isShadowbanned = false;
        data.reputationScore = CONFIG.REPUTATION.SHADOWBAN_THRESHOLD + 0.05;
        data.updatedAt = now;
        await docRef.update({
          isShadowbanned: false,
          reputationScore: data.reputationScore,
          shadowbannedUntil: firestore.FieldValue.delete(),
          updatedAt: now,
        });
      }
    }

    return data;
  }

  /**
   * Verifica si el dispositivo está en cooldown o si violó límites de tasa de reporte (Rate Limit).
   */
  async checkRateLimit(
    reputationId: string,
    venueId: string,
    hashedDeviceId: string,
    saltDate: string
  ): Promise<{ allowed: boolean; reason?: string }> {
    const now = firestore.Timestamp.now();
    const tenMinutesAgo = new firestore.Timestamp(
      now.seconds - (CONFIG.MIN_MINUTES_BETWEEN_REPORTS_SAME_VENUE * 60),
      now.nanoseconds
    );

    // Consulta de reportes recientes del dispositivo para el mismo bar
    const recentReports = await this.db.collection('incident_reports')
      .where('venueId', '==', venueId)
      .where('hashedDeviceId', '==', hashedDeviceId)
      .where('createdAt', '>=', tenMinutesAgo)
      .get();

    if (!recentReports.empty) {
      return {
        allowed: false,
        reason: `Ya enviaste un reporte para este lugar recientemente. Por favor espera ${CONFIG.MIN_MINUTES_BETWEEN_REPORTS_SAME_VENUE} minutos.`
      };
    }

    // Consulta de cantidad máxima de reportes por noche para este dispositivo
    const dailyReports = await this.db.collection('incident_reports')
      .where('hashedDeviceId', '==', hashedDeviceId)
      .where('saltDate', '==', saltDate)
      .get();

    if (dailyReports.size >= CONFIG.MAX_REPORTS_PER_DEVICE_PER_DAY) {
      return {
        allowed: false,
        reason: `Has alcanzado el límite máximo de ${CONFIG.MAX_REPORTS_PER_DEVICE_PER_DAY} reportes por noche.`
      };
    }

    return { allowed: true };
  }

  /**
   * Aplica sanción y evalúa activación de shadowban por reporte falso o abusivo.
   */
  async penalizeDevice(reputationId: string, reason: string): Promise<void> {
    const docRef = this.db.collection('device_reputations').doc(reputationId);
    const snap = await docRef.get();
    if (!snap.exists) return;

    const data = snap.data() as DeviceReputationDocument;
    const newStrikes = data.strikes + 1;
    const newScore = Math.max(0.0, data.reputationScore - CONFIG.REPUTATION.PENALTY_FALSE_REPORT);
    const shouldShadowban =
      newStrikes >= CONFIG.REPUTATION.STRIKES_FOR_SHADOWBAN ||
      newScore < CONFIG.REPUTATION.SHADOWBAN_THRESHOLD;

    const now = firestore.Timestamp.now();
    const shadowbanDurationMs = CONFIG.REPUTATION.SHADOWBAN_DURATION_HOURS * 3600 * 1000;
    const shadowbannedUntil = shouldShadowban
      ? new firestore.Timestamp(Math.floor((now.toMillis() + shadowbanDurationMs) / 1000), 0)
      : undefined;

    const updatePayload: Partial<DeviceReputationDocument> = {
      reputationScore: newScore,
      strikes: newStrikes,
      reportsDebunked: data.reportsDebunked + 1,
      isShadowbanned: shouldShadowban,
      updatedAt: now,
    };

    if (shadowbannedUntil) {
      updatePayload.shadowbannedUntil = shadowbannedUntil;
    }

    await docRef.update(updatePayload);
    console.warn(`[ReputationService] Dispositivo ${reputationId} penalizado (${reason}). Score: ${newScore}, Shadowban: ${shouldShadowban}`);
  }

  /**
   * Recompensa reputación tras confirmación de incidente legítimo.
   */
  async rewardDevice(reputationId: string): Promise<void> {
    const docRef = this.db.collection('device_reputations').doc(reputationId);
    const snap = await docRef.get();
    if (!snap.exists) return;

    const data = snap.data() as DeviceReputationDocument;
    const newScore = Math.min(1.0, data.reputationScore + CONFIG.REPUTATION.REWARD_CONFIRMED_REPORT);

    await docRef.update({
      reputationScore: newScore,
      reportsVerified: data.reportsVerified + 1,
      updatedAt: firestore.Timestamp.now(),
    });
  }
}
