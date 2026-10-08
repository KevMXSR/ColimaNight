import { firestore } from 'firebase-admin';

export type IncidentType =
  | 'pelea'                  // Fight / Altercation
  | 'sobrecupo_critico'     // Extreme Overcapacity
  | 'altercado_violento'    // Violent dispute / brawl
  | 'operativo_policial'    // Law enforcement raid / road checkpoint
  | 'acoso_inseguridad'     // Harassment or security alert
  | 'conato_bronca';        // Pre-fight escalation

export type SecurityLevel = 'normal' | 'under_review' | 'alert_verified';

export type VibeScore = 'tranquilo' | 'chill' | 'animado' | 'fiesta_total' | 'saturado';

export type ParkingStatus = 'available' | 'almost_full' | 'full' | 'valet_only' | 'no_parking' | 'nearby_public';

export interface VenueCelebrityPresence {
  hasCelebrity: boolean;
  description?: string;
  verified: boolean;
  reportedAt?: firestore.Timestamp;
}

export interface VenueLiveMusic {
  hasLiveMusic: boolean;
  bandOrDjName?: string;
  genre?: string;
  startTime?: firestore.Timestamp;
  endTime?: firestore.Timestamp;
}

export interface VenueParking {
  status: ParkingStatus;
  spotsEstimated: number;
  hasValet: boolean;
  lastUpdated: firestore.Timestamp;
}

export interface VenuePromo {
  id: string;
  title: string;
  description: string;
  validUntil: firestore.Timestamp;
  daysOfWeek: number[]; // 0 = Sunday, 1 = Monday...
}

export interface VenueSocialLinks {
  instagram?: string;
  facebook?: string;
  tiktok?: string;
  phone?: string;
  menuUrl?: string;
}

export interface VenueSecurityStatus {
  level: SecurityLevel;
  activeIncidentId?: string | null;
  incidentType?: IncidentType | null;
  lastReportedAt?: firestore.Timestamp | null;
  alertExpiresAt?: firestore.Timestamp | null;
  alertConfirmedAt?: firestore.Timestamp | null;
  warningMessage?: string | null;
}

export interface VenueStats {
  checkinsTonight: number;
  averageWaitMinutes: number;
  lastVibeUpdate: firestore.Timestamp;
}

export interface VenueDocument {
  id: string;
  name: string;
  slug: string;
  category: 'antro' | 'bar' | 'terraza' | 'cantina' | 'speakeasy' | 'club_playa' | 'sports_bar' | 'club_bar';
  location: firestore.GeoPoint;
  address: string;
  zone:
    | 'Corredor Ignacio Sandoval'
    | 'Centro Histórico'
    | 'Tercer Anillo'
    | 'Constitución / San Fernando'
    | 'Felipe Sevilla del Río'
    | 'Villa de Álvarez'
    | 'Zona Conurbada';
  proximityRadiusMeters?: number; // 150m estándar por defecto, 280m para macro-recintos
  currentOccupancyPercent: number; // 0 - 100%
  vibeScore: VibeScore;
  noiseLevelDbEstimated?: number;
  celebrityPresence: VenueCelebrityPresence;
  liveMusic: VenueLiveMusic;
  parking: VenueParking;
  activePromos: VenuePromo[];
  socialLinks: VenueSocialLinks;
  securityStatus: VenueSecurityStatus;
  stats: VenueStats;
  active: boolean; // true para los 21 locales comerciales vigentes, false para memoriales/Easter Egg
  isActive: boolean; // Alias de compatibilidad
  isEasterEgg?: boolean; // true para memoriales históricos como Barezzito
  createdAt: firestore.Timestamp;
  updatedAt: firestore.Timestamp;
}

export interface LiveVibeCheckinDocument {
  id?: string;
  venueId: string;
  hashedDeviceId: string;
  vibe: VibeScore;
  crowdLevel: 'vacio' | 'medio' | 'lleno' | 'sobrecupo';
  waitMinutes: number;
  location: firestore.GeoPoint;
  distanceMeters: number;
  createdAt: firestore.Timestamp;
  expiresAt: firestore.Timestamp;
}

export interface ModerationResult {
  passed: boolean;
  flaggedWords: string[];
  hadNamesOrDefamation: boolean;
  originalText?: string;
  sanitizedText: string;
  toxicityScore: number;
}

export interface IncidentReportDocument {
  id?: string;
  venueId: string;
  incidentType: IncidentType;
  hashedDeviceId: string; // HMAC-SHA256 con salt de 24h
  saltDate: string; // YYYY-MM-DD
  clientLocation: firestore.GeoPoint;
  distanceMeters: number;
  rawComment?: string;
  sanitizedComment?: string;
  moderationResult: ModerationResult;
  status: 'submitted' | 'counted_in_quorum' | 'shadowbanned' | 'rejected_distance' | 'expired';
  createdAt: firestore.Timestamp;
  expiresAt: firestore.Timestamp; // TTL de 45 minutos
}

export interface ActiveIncidentDocument {
  id: string; // venueId
  venueId: string;
  incidentType: IncidentType;
  status: 'under_review' | 'active_alert' | 'resolved' | 'expired' | 'debunked_by_staff';
  reportCount: number;
  distinctDeviceCount: number;
  reportingDeviceHashes: string[];
  reportingCoordinates: Array<{ latitude: number; longitude: number }>;
  firstReportAt: firestore.Timestamp;
  lastReportAt: firestore.Timestamp;
  alertTriggeredAt?: firestore.Timestamp;
  expiresAt: firestore.Timestamp; // TTL 45m tras último reporte
  confirmedByStaff: boolean;
  staffUserId?: string;
  staffResolutionNotes?: string;
  warningMessage?: string;
}

export interface DeviceReputationDocument {
  id: string; // deviceIdentifierHash (long-term pseudonym)
  reputationScore: number; // 0.0 - 1.0 (default 0.7)
  totalReportsSubmitted: number;
  reportsVerified: number;
  reportsDebunked: number;
  isShadowbanned: boolean;
  shadowbannedUntil?: firestore.Timestamp;
  strikes: number;
  lastReportAt: firestore.Timestamp;
  updatedAt: firestore.Timestamp;
}

export interface IncidentReportRequest {
  venueId: string;
  incidentType: IncidentType;
  deviceFingerprint: string; // ID hardware efímero enviado por app
  latitude: number;
  longitude: number;
  accuracyMeters: number;
  comment?: string;
}

export interface LiveVibeRequest {
  venueId: string;
  deviceFingerprint: string;
  latitude: number;
  longitude: number;
  accuracyMeters: number;
  vibe: VibeScore;
  crowdLevel: 'vacio' | 'medio' | 'lleno' | 'sobrecupo';
  waitMinutes: number;
}

export interface StaffVerifyRequest {
  venueId: string;
  action: 'confirm' | 'dismiss';
  notes?: string;
}
