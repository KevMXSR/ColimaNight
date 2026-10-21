export const CONFIG = {
  // 1. Proof of Proximity (Ajustado estrictamente a 80 metros)
  PROOF_OF_PROXIMITY_RADIUS_METERS: 80, // Radio exacto de presencia física en local/terraza
  MAX_GPS_ACCURACY_METERS: 35,          // Precisión máxima GPS admitida para evitar spoofing o rebotes

  // 2. Blindaje Reputacional y Cuórum Mínimo
  QUORUM_GENERAL_THRESHOLD: 5,          // Mínimo 5 reportes independientes en 10 min para alerta general
  QUORUM_WEAPONS_THRESHOLD: 3,          // Mínimo 3 reportes independientes para alerta de armas
  QUORUM_WINDOW_MINUTES: 10,            // Ventana rodante de 10 minutos
  MIN_COORDINATE_DELTA_METERS: 4,       // Dispersión espacial requerida entre dispositivos

  // 3. Telemetría de Presencia & Caducidad (TTL)
  PRESENCE_HEARTBEAT_TTL_MINUTES: 45,   // TTL de 45 minutos para heartbeat de aforo en vivo
  INCIDENT_TTL_MINUTES: 45,             // TTL de 45 minutos para expiración de incidentes sin confirmación
  CUTOFF_HOUR_NIGHTLY: 6,               // Corte operativo a las 06:00 AM (Colima CST UTC-6)

  // 4. Rate Limiting & Anti-Sybil
  MIN_MINUTES_BETWEEN_REPORTS_SAME_DEVICE: 10,
  MAX_REPORTS_PER_DEVICE_PER_NIGHT: 4,
  MAX_HEARTBEATS_PER_MINUTE_SAME_DEVICE: 2,

  // 5. Los 11 Canales Oficiales de Instagram para el Pipeline de Eventos
  OFFICIAL_INSTAGRAM_HANDLES: [
    { handle: '@dmtrockbar', venueId: 'dmt-rock-bar', name: 'DMT Rock Bar' },
    { handle: '@cerveceriadecolima', venueId: 'estacion-colimita-centro', name: 'Cervecería de Colima' },
    { handle: '@lapuertadelperreo.dog', venueId: 'la-puerta-bar', name: 'La Puerta Bar / Del Perreo' },
    { handle: '@guachirooftop', venueId: 'el-guachi', name: 'El Guachi Rooftop' },
    { handle: '@almada_cantina.fina', venueId: 'almada-cantina-fina', name: 'Almada Cantina Fina' },
    { handle: '@dospuntoscerveceria', venueId: 'dos-puntos-cerveceria', name: 'Dos Puntos Cervecería' },
    { handle: '@lowclub.col', venueId: 'low-social-club', name: 'Low Social Club' },
    { handle: '@el_gustito_ignacio_sandoval', venueId: 'el-gustito', name: 'El Gustito (Ignacio Sandoval)' },
    { handle: '@la_regional_cantina', venueId: 'la-regional', name: 'La Regional Cantina' },
    { handle: '@mezcal.santo', venueId: 'santo-mezcal', name: 'Santo Mezcal' },
    { handle: '@casa.colima.mezcaleria', venueId: 'casa-colima-mezcaleria', name: 'Casa Colima Mezcalería' },
  ],

  // 6. Modelo de Donativos Comunitarios (Estilo Patreon)
  DONATION_TIERS: {
    amigo_nocturno: {
      name: 'Amigo Nocturno',
      amountMxn: 30,
      badge: '🌙 Donador Nocturno',
      description: 'Cubre 1 semana de costos de servidor y base de datos para la comunidad.',
    },
    vip_supporter: {
      name: 'Colima VIP Supporter',
      amountMxn: 99,
      badge: '🍸 VIP Supporter',
      description: 'Soporte mensual para procesamiento de geocercas e ingesta de Instagram.',
    },
    patrocinador_leyenda: {
      name: 'Patrocinador Leyenda',
      amountMxn: 250,
      badge: '👑 Leyenda de la Noche',
      description: 'Patrocinador distinguido para mejoras continuas y mapas nocturnos.',
    },
  },

  // Secret base para derivación de HMAC
  HMAC_MASTER_SECRET: process.env.COLIMANIGHT_HMAC_SECRET || 'colima_night_hmac_secret_phase1_2026',
};
