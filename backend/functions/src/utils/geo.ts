import { CONFIG } from '../config';

/**
 * Calcula la distancia ortodrómica en metros entre dos coordenadas geográficas usando Haversine.
 */
export function calculateHaversineDistanceMeters(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371e3; // Radio terrestre en metros
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

export interface ProximityValidationResult {
  isValid: boolean;
  distanceMeters: number;
  reason?: string;
}

/**
 * Valida la prueba de proximidad estricta (Proof of Proximity) a 80 metros exactos del local.
 * Descalifica fixtures con baja precisión GPS (accuracy > 35m) para evitar spoofing o rebotes urbanos.
 */
export function validateProximity80m(
  venueLat: number,
  venueLon: number,
  userLat: number,
  userLon: number,
  userAccuracyMeters: number
): ProximityValidationResult {
  if (userAccuracyMeters > CONFIG.MAX_GPS_ACCURACY_METERS) {
    return {
      isValid: false,
      distanceMeters: 0,
      reason: `Precisión GPS insuficiente (${Math.round(userAccuracyMeters)}m). Máximo admitido: ${CONFIG.MAX_GPS_ACCURACY_METERS}m para validar presencia física in situ.`
    };
  }

  const distance = calculateHaversineDistanceMeters(venueLat, venueLon, userLat, userLon);

  if (distance > CONFIG.PROOF_OF_PROXIMITY_RADIUS_METERS) {
    return {
      isValid: false,
      distanceMeters: distance,
      reason: `Fuera del radio físico del establecimiento (${Math.round(distance)}m detectados vs máx ${CONFIG.PROOF_OF_PROXIMITY_RADIUS_METERS}m). Se requiere presencia directa en local o terraza.`
    };
  }

  return {
    isValid: true,
    distanceMeters: distance
  };
}
