import * as crypto from 'crypto';
import { CONFIG } from '../config';

/**
 * Retorna la fecha de la noche operativa de Colima (corte diario a las 06:00 AM).
 * Las horas entre 18:00 y 05:59 del día siguiente pertenecen a la misma jornada festiva,
 * asegurando consistencia de salts y previniendo que el usuario cambie de hash a medianoche.
 */
export function getNightlySaltDate(date: Date = new Date()): string {
  const utc = date.getTime() + (date.getTimezoneOffset() * 60000);
  const colimaOffsetHours = -6; // CST (UTC-6)
  const colimaDate = new Date(utc + (3600000 * colimaOffsetHours));

  if (colimaDate.getHours() < CONFIG.CUTOFF_HOUR_NIGHTLY) {
    colimaDate.setDate(colimaDate.getDate() - 1);
  }

  const year = colimaDate.getFullYear();
  const month = String(colimaDate.getMonth() + 1).padStart(2, '0');
  const day = String(colimaDate.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

/**
 * Genera el identificador anónimo de dispositivo mediante HMAC-SHA256 con salt de 24h.
 * No almacena datos personales ni permite trazabilidad entre distintos días.
 */
export function hashDeviceIdWithDailySalt(deviceFingerprint: string, saltDate: string): string {
  const saltKey = `${CONFIG.HMAC_MASTER_SECRET}_DAILY_${saltDate}`;
  return crypto
    .createHmac('sha256', saltKey)
    .update(deviceFingerprint)
    .digest('hex');
}

/**
 * Seudónimo criptográfico persistente para control de spam y shadowban silencioso.
 */
export function hashDeviceForReputation(deviceFingerprint: string): string {
  const pepper = `${CONFIG.HMAC_MASTER_SECRET}_PEPPER_LONGTERM`;
  return crypto
    .createHmac('sha256', pepper)
    .update(deviceFingerprint)
    .digest('hex');
}
