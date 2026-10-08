/// Modelo de Dominio para Establecimientos Nocturnos en Colima y Villa de Álvarez
class VenueModel {
  final String id;
  final String name;
  final String category; // 'Antro', 'Rooftop', 'Bar & Grill', 'Speakeasy', 'Cervecería'
  final String zone; // 'Av. Constitución', 'Tercer Anillo', 'Centro Colima'
  final String description;
  final String coverImageUrl;
  final List<String> galleryUrls;
  final double rating;
  final int reviewsCount;
  final int capacityPercent; // 0 - 100%
  final bool isHotRightNow;
  final String? hotReason;
  final bool hasLiveMusic;
  final String? liveMusicAct;
  final bool isVipPresent;
  final String? vipNote;
  final bool hasPromo;
  final String? promoHeadline;
  final bool parkingAvailable;
  final String? parkingDetails;
  final double latitude;
  final double longitude;
  final String? instagramHandle;
  final String? tikTokHandle;
  final String? facebookUrl;
  final String vibeGenre;
  final String schedule;
  final int estimatedMinutes; // Minutos estimados de llegada

  final String securityStatus; // 'normal', 'under_review', 'active_alert'
  final int activeIncidentReportsCount;
  final String? lastIncidentType; // 'brawl', 'weapon', 'slow_service', 'other'
  final String? lastReportNote;
  final bool isPermanentlyClosed;
  final String? closedJokeNote;

  const VenueModel({
    required this.id,
    required this.name,
    required this.category,
    required this.zone,
    required this.description,
    required this.coverImageUrl,
    required this.galleryUrls,
    required this.rating,
    required this.reviewsCount,
    required this.capacityPercent,
    this.isHotRightNow = false,
    this.hotReason,
    this.hasLiveMusic = false,
    this.liveMusicAct,
    this.isVipPresent = false,
    this.vipNote,
    this.hasPromo = false,
    this.promoHeadline,
    this.parkingAvailable = true,
    this.parkingDetails,
    required this.latitude,
    required this.longitude,
    this.instagramHandle,
    this.tikTokHandle,
    this.facebookUrl,
    required this.vibeGenre,
    required this.schedule,
    this.estimatedMinutes = 8,
    this.securityStatus = 'normal',
    this.activeIncidentReportsCount = 0,
    this.lastIncidentType,
    this.lastReportNote,
    this.isPermanentlyClosed = false,
    this.closedJokeNote,
  });

  /// Determina el color de aura/pin según su estado o vibe
  String get statusTag {
    if (isPermanentlyClosed) return closedJokeNote ?? '🪦 In Memoriam • RIP';
    if (securityStatus == 'active_alert') {
      if (lastIncidentType == 'weapon') return '🚨 Alerta: Posible Arma';
      return '⚠️ Altercado verificado';
    }
    if (securityStatus == 'under_review') return '👀 Reporte en revisión';
    if (lastIncidentType == 'slow_service') return '⏳ Servicio lento hoy';
    if (lastReportNote != null && lastReportNote!.isNotEmpty) return '📝 $lastReportNote';
    if (capacityPercent >= 85) return '🔥 Lleno total';
    if (hasLiveMusic) return '🎸 En vivo';
    if (hasPromo) return '⚡ 2x1 Activo';
    return '✨ Buen ambiente';
  }

  VenueModel copyWith({
    String? id,
    String? name,
    String? category,
    String? zone,
    String? description,
    String? coverImageUrl,
    List<String>? galleryUrls,
    double? rating,
    int? reviewsCount,
    int? capacityPercent,
    bool? isHotRightNow,
    String? hotReason,
    bool? hasLiveMusic,
    String? liveMusicAct,
    bool? isVipPresent,
    String? vipNote,
    bool? hasPromo,
    String? promoHeadline,
    bool? parkingAvailable,
    String? parkingDetails,
    double? latitude,
    double? longitude,
    String? instagramHandle,
    String? tikTokHandle,
    String? facebookUrl,
    String? vibeGenre,
    String? schedule,
    int? estimatedMinutes,
    String? securityStatus,
    int? activeIncidentReportsCount,
    String? lastIncidentType,
    String? lastReportNote,
    bool? isPermanentlyClosed,
    String? closedJokeNote,
  }) {
    return VenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      zone: zone ?? this.zone,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      capacityPercent: capacityPercent ?? this.capacityPercent,
      isHotRightNow: isHotRightNow ?? this.isHotRightNow,
      hotReason: hotReason ?? this.hotReason,
      hasLiveMusic: hasLiveMusic ?? this.hasLiveMusic,
      liveMusicAct: liveMusicAct ?? this.liveMusicAct,
      isVipPresent: isVipPresent ?? this.isVipPresent,
      vipNote: vipNote ?? this.vipNote,
      hasPromo: hasPromo ?? this.hasPromo,
      promoHeadline: promoHeadline ?? this.promoHeadline,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
      parkingDetails: parkingDetails ?? this.parkingDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      tikTokHandle: tikTokHandle ?? this.tikTokHandle,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      vibeGenre: vibeGenre ?? this.vibeGenre,
      schedule: schedule ?? this.schedule,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      securityStatus: securityStatus ?? this.securityStatus,
      activeIncidentReportsCount:
          activeIncidentReportsCount ?? this.activeIncidentReportsCount,
      lastIncidentType: lastIncidentType ?? this.lastIncidentType,
      lastReportNote: lastReportNote ?? this.lastReportNote,
      isPermanentlyClosed: isPermanentlyClosed ?? this.isPermanentlyClosed,
      closedJokeNote: closedJokeNote ?? this.closedJokeNote,
    );
  }
}
