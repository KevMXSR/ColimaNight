import { firestore } from 'firebase-admin';

export type IncidentCategory =
  | 'pelea'
  | 'arma_fuego'
  | 'arma_blanca'
  | 'sobrecupo_critico'
  | 'altercado'
  | 'operativo_policial'
  | 'acoso';

export type SecurityLevel = 'normal' | 'alert_verified';

export type VibeScore = 'tranquilo' | 'chill' | 'animado' | 'fiesta_total' | 'saturado';

export type ParkingStatus = 'available' | 'almost_full' | 'full' | 'valet_only' | 'no_parking' | 'nearby_public';

export interface VenueSecurityStatus {
  level: SecurityLevel;
  activeIncidentId?: string | null;
  incidentType?: IncidentCategory | null;
  lastReportedAt?: firestore.Timestamp | null;
  alertExpiresAt?: firestore.Timestamp | null;
  alertConfirmedAt?: firestore.Timestamp | null;
  warningMessage?: string | null;
}

export interface VenueStats {
  checkinsTonight: number;
  heartbeatsTonight: number;
  averageWaitMinutes: number;
  lastTelemetryUpdate: firestore.Timestamp;
}

export interface VenueDocument {
  id: string;
  name: string;
  slug: string;
  category: string;
  location: firestore.GeoPoint;
  address: string;
  zone: string;
  instagramHandle?: string;
  proofOfProximityRadiusMeters: number; // 80 metros exactos
  capacityThreshold: number; // capacidad estimada del establecimiento
  liveAttendeesCount: number; // aforo en tiempo real vía Presence Heartbeat
  currentOccupancyPercent: number; // cálculo dinámico (liveAttendeesCount / capacityThreshold * 100)
  vibeScore: VibeScore;
  noiseLevelDbEstimated?: number;
  securityStatus: VenueSecurityStatus;
  stats: VenueStats;
  active: boolean;
  isActive: boolean;
  isEasterEgg?: boolean;
  createdAt: firestore.Timestamp;
  updatedAt: firestore.Timestamp;
}

export interface PresenceHeartbeatDocument {
  id?: string;
  venueId: string;
  userId?: string | null;
  sessionToken: string;
  hashedDeviceId: string;
  clientLocation: firestore.GeoPoint;
  distanceMeters: number;
  accuracyMeters: number;
  isGuest: boolean;
  timestamp: firestore.Timestamp;
  expiresAt: firestore.Timestamp; // TTL de 45 minutos
}

export interface IncidentReportDocument {
  id?: string;
  venueId: string;
  incidentType: IncidentCategory;
  hashedDeviceId: string; // HMAC-SHA256 con salt de 24h
  saltDate: string; // YYYY-MM-DD
  clientLocation: firestore.GeoPoint;
  distanceMeters: number;
  rawComment?: string;
  sanitizedComment?: string;
  moderationResult: {
    passed: boolean;
    flaggedWords: string[];
    hadNamesOrDefamation: boolean;
    toxicityScore: number;
  };
  status: 'internal_audit' | 'counted_in_quorum' | 'shadowbanned' | 'rejected_distance' | 'expired';
  createdAt: firestore.Timestamp;
  expiresAt: firestore.Timestamp; // TTL de 45 minutos
}

export interface ActiveIncidentDocument {
  id: string; // venueId
  venueId: string;
  incidentType: IncidentCategory;
  status: 'internal_audit' | 'active_alert' | 'resolved' | 'expired';
  reportCount: number;
  distinctDeviceCount: number;
  reportingDeviceHashes: string[];
  reportingCoordinates: Array<{ latitude: number; longitude: number }>;
  firstReportAt: firestore.Timestamp;
  lastReportAt: firestore.Timestamp;
  alertTriggeredAt?: firestore.Timestamp | null;
  expiresAt: firestore.Timestamp; // TTL 45m tras último reporte
  isInternalAuditOnly: boolean; // true si reportes < cuórum (5 gral / 3 armas)
  warningMessage?: string | null;
}

export interface SocialEventDocument {
  id: string;
  venueId: string;
  venueName: string;
  instagramHandle: string;
  eventTitle: string;
  description: string;
  eventDate: firestore.Timestamp;
  djOrBand?: string;
  musicGenre?: string;
  coverPriceMxn?: number;
  promo?: string;
  mediaUrl: string;
  postUrl: string;
  source: 'instagram_graph_api' | 'official_feed';
  createdAt: firestore.Timestamp;
  expiresAt: firestore.Timestamp;
}

export type DonationTier = 'amigo_nocturno' | 'vip_supporter' | 'patrocinador_leyenda';

export interface DonationRecordDocument {
  id: string;
  userId?: string | null;
  donorName: string;
  donorEmail?: string | null;
  amountMxn: number;
  tier: DonationTier;
  paymentProvider: 'stripe' | 'mercadopago' | 'patreon' | 'community_qr';
  paymentStatus: 'pending' | 'completed' | 'failed';
  transactionReference: string;
  badgeEarned: string;
  createdAt: firestore.Timestamp;
}
