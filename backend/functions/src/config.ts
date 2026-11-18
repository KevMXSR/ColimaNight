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

  // 4. Rate Limiting & Anti-Sybil (Autoprotección Cero Costos)
  MIN_MINUTES_BETWEEN_REPORTS_SAME_DEVICE: 15, // Aumentado a 15 min para frenar spam
  MAX_REPORTS_PER_DEVICE_PER_NIGHT: 3,         // Máximo 3 reportes por dispositivo por noche
  MAX_HEARTBEATS_PER_MINUTE_SAME_DEVICE: 1,    // Máximo 1 latido por minuto por dispositivo
  MAX_HEARTBEATS_PER_10_MIN_SAME_DEVICE: 3,

  // 5. Blindaje Financiero & Mitigación Denial-of-Wallet (Objetivo: $0 USD de costo operativo)
  MAX_FUNCTION_INSTANCES: 10,                 // Tope estricto de instancias para evitar escalado DoS infinito
  CIRCUIT_BREAKER_MAX_ERRORS_PER_MINUTE: 30,  // Disparo automático de pausa defensiva si hay inundación
  EMERGENCY_BUDGET_CEILING_USD: 15,           // Techo financiero de contingencia absoluta
  TARGET_OPERATIONAL_COST_USD: 0,             // Operación priorizada dentro de la capa gratuita (Spark/Free Tier)

  // 6. Los 11 Canales Oficiales de Instagram para el Pipeline de Eventos
  OFFICIAL_INSTAGRAM_HANDLES: [
    { handle: '@dmtrockbar', venueId: 'dmt-rock-bar', name: 'DMT Rock Bar' },
    { handle: '@cerveceriadecolima', venueId: 'estacion-colimita-centro', name: 'Cervecería de Colima' },
    { handle: '@lapuertadelperreo.dog', venueId: 'la-puerta-bar', name: 'La Puerta Bar / Del Perreo' },
    { handle: '@guachirooftop', venueId: 'el-guachi', name: 'El Guachi' },
    { handle: '@almada_cantina.fina', venueId: 'almada-cantina-fina', name: 'Almada Cantina Fina' },
    { handle: '@dospuntoscerveceria', venueId: 'dos-puntos-cerveceria', name: 'Dos Puntos Cervecería' },
    { handle: '@lowclub.col', venueId: 'low-social-club', name: 'Low Social Club' },
    { handle: '@el_gustito_ignacio_sandoval', venueId: 'el-gustito', name: 'El Gustito (Ignacio Sandoval)' },
    { handle: '@la_regional_cantina', venueId: 'la-regional', name: 'La Regional Cantina' },
    { handle: '@mezcal.santo', venueId: 'santo-mezcal', name: 'Santo Mezcal' },
    { handle: '@casa.colima.mezcaleria', venueId: 'casa-colima-mezcaleria', name: 'Casa Colima Mezcalería' },
    { handle: '@el_taurino_colima', venueId: 'el_taurino', name: 'El Taurino Bar' },
    { handle: '@lostorosbarrataurina', venueId: 'los_toros_barra_taurina', name: 'Los Toros Barra Taurina' },
  ],

  // 7. Modelo de Donativos Comunitarios (Estilo Patreon)
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

  // 8. Secretos y Alertas Seguras (Protegidos por Google Secret Manager en Producción)
  HMAC_MASTER_SECRET: process.env.COLIMANIGHT_HMAC_SECRET || 'colima_night_hmac_secret_phase1_2026',
  ADMIN_TELEGRAM_BOT_TOKEN: process.env.COLIMANIGHT_TELEGRAM_TOKEN || '',
  ADMIN_TELEGRAM_CHAT_ID: process.env.COLIMANIGHT_TELEGRAM_CHAT_ID || '',
};
