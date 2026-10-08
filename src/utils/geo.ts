import { CONFIG } from '../config';

/**
 * Calcula la distancia ortodrómica en metros entre dos coordenadas usando la fórmula de Haversine.
 */
export function calculateHaversineDistanceMeters(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371e3; // Radio de la Tierra en metros
  const phi1 = (lat1 * Math.PI) / 180;
  const phi2 = (lat2 * Math.PI) / 180;
  const deltaPhi = ((lat2 - lat1) * Math.PI) / 180;
  const deltaLambda = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
    Math.cos(phi1) * Math.cos(phi2) *
    Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}

export interface GeofenceValidationResult {
  isValid: boolean;
  distanceMeters: number;
  reason?: string;
}

/**
 * Valida la prueba de proximidad (Proof of Proximity) para un establecimiento.
 * Rechaza lecturas imprecisas o ubicadas fuera del radio permitido (150m).
 */
export function validateProximity(
  venueLat: number,
  venueLon: number,
  userLat: number,
  userLon: number,
  userAccuracyMeters: number,
  allowedRadiusMeters: number = CONFIG.GEOFENCE_MAX_RADIUS_METERS
): GeofenceValidationResult {
  if (userAccuracyMeters > CONFIG.MAX_GPS_ACCURACY_METERS) {
    return {
      isValid: false,
      distanceMeters: 0,
      reason: `Precisión GPS insuficiente (${Math.round(userAccuracyMeters)}m). Máximo permitido: ${CONFIG.MAX_GPS_ACCURACY_METERS}m para evitar spoofing o rebotes de señal.`
    };
  }

  const distance = calculateHaversineDistanceMeters(venueLat, venueLon, userLat, userLon);

  if (distance > allowedRadiusMeters) {
    return {
      isValid: false,
      distanceMeters: distance,
      reason: `Usuario fuera del radio permitido (${Math.round(distance)}m detectados vs máx ${allowedRadiusMeters}m). Se requiere presencia física in situ.`
    };
  }

  return {
    isValid: true,
    distanceMeters: distance
  };
}
