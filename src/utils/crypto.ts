import * as crypto from 'crypto';
import { CONFIG } from '../config';

/**
 * Obtiene la fecha operativa del ciclo nocturno en Colima (Corte a las 06:00 AM).
 * Si son las 03:00 AM del domingo, pertenece a la noche del sábado.
 * Esto evita que el salt rote en pleno auge nocturno (a la medianoche).
 */
export function getNightlySaltDate(date: Date = new Date()): string {
  // Ajuste a la hora de Colima / Ciudad de México (UTC-6)
  const utc = date.getTime() + (date.getTimezoneOffset() * 60000);
  const colimaOffsetHours = -6; // CST (UTC-6)
  const colimaDate = new Date(utc + (3600000 * colimaOffsetHours));

  // Si son antes de las 06:00 AM, restamos 1 día para mantener el salt de la noche en curso
  if (colimaDate.getHours() < 6) {
    colimaDate.setDate(colimaDate.getDate() - 1);
  }

  const year = colimaDate.getFullYear();
  const month = String(colimaDate.getMonth() + 1).padStart(2, '0');
  const day = String(colimaDate.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

/**
 * Genera el hash anónimo efímero del dispositivo mediante HMAC-SHA256.
 * Rota diariamente con el salt de la noche operativa, haciendo matemáticamente imposible
 * rastrear a un usuario entre diferentes días o deducir su identidad de hardware real.
 */
export function hashDeviceIdWithDailySalt(deviceFingerprint: string, saltDate: string): string {
  const saltKey = `${CONFIG.HMAC_MASTER_SECRET}_DAILY_${saltDate}`;
  return crypto
    .createHmac('sha256', saltKey)
    .update(deviceFingerprint)
    .digest('hex');
}

/**
 * Genera un seudónimo permanente de reputación para mitigar ataques Sybil / troles recurrentes.
 * Este hash NO se vincula con cuentas de Google/Apple, nombres, correos ni números de teléfono.
 * Solo se usa en el backend para rastrear la tasa de veracidad de reportes del dispositivo.
 */
export function hashDeviceForReputation(deviceFingerprint: string): string {
  const pepper = `${CONFIG.HMAC_MASTER_SECRET}_LONGTERM_REPUTATION_PEPPER`;
  return crypto
    .createHmac('sha256', pepper)
    .update(deviceFingerprint)
    .digest('hex');
}
