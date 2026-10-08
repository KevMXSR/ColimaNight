export const CONFIG = {
  // Geofence & Proximity
  GEOFENCE_MAX_RADIUS_METERS: 150,      // Radio estricto de cercanía al bar (Proof of Proximity)
  MACRO_VENUE_MAX_RADIUS_METERS: 280,   // Radio extendido para macro-plazas o recintos amplios
  MAX_GPS_ACCURACY_METERS: 40,          // Precisión máxima permitida para aceptar lectura GPS

  // Consenso y Cuórum
  QUORUM_REQUIRED_REPORTS: 3,      // Número de reportes independientes requeridos
  QUORUM_WINDOW_MINUTES: 10,       // Ventana rodante en minutos para acumular cuórum
  MIN_COORDINATE_DELTA_METERS: 5,  // Distancia mínima entre coordenadas de reportes independientes

  // Caducidad (TTL)
  INCIDENT_TTL_MINUTES: 45,        // Tiempo de vida de un incidente sin nuevas confirmaciones
  VIBE_TTL_MINUTES: 120,           // Tiempo de vida de una señal de aforo/vibe (2 horas)

  // Rate Limiting & Anti-Sybil
  MIN_MINUTES_BETWEEN_REPORTS_SAME_VENUE: 10,
  MAX_REPORTS_PER_DEVICE_PER_DAY: 4,

  // Sistema de Reputación y Shadowban
  REPUTATION: {
    INITIAL_SCORE: 0.7,
    SHADOWBAN_THRESHOLD: 0.35,
    STRIKES_FOR_SHADOWBAN: 2,
    SHADOWBAN_DURATION_HOURS: 72,
    PENALTY_FALSE_REPORT: 0.3,
    REWARD_CONFIRMED_REPORT: 0.1,
  },

  // Moderación
  MAX_COMMENT_LENGTH: 120,

  // Timezone de Colima
  TIMEZONE: 'America/Mexico_City',

  // Salt secreto base para HMAC (en producción obtenido de Cloud Secret Manager o env)
  HMAC_MASTER_SECRET: process.env.COLIMANIGHT_HMAC_SECRET || 'colima_night_super_secret_salt_2026_xyz',
};
