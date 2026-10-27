/// Representa un evento específico o de cartelera en un establecimiento
class VenueEvent {
  final String id;
  final String title;
  final String dateDisplay; // Ej: 'Viernes 31 Oct • 10:00 PM'
  final String? artistOrDj; // Ej: 'DJ Set en Vivo & Reggaetón Hits'
  final String? coverPrice; // Ej: '$100 MXN' o 'Entrada Libre'
  final String? promoNote; // Ej: '2x1 en copeo antes de las 11 PM'
  final bool isToday;

  const VenueEvent({
    required this.id,
    required this.title,
    required this.dateDisplay,
    this.artistOrDj,
    this.coverPrice,
    this.promoNote,
    this.isToday = false,
  });
}

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
  final int? livePresenceCount; // Telemetría de presencia activa en radio de 80m

  // Nuevas propiedades: Cover, Horario y Reservaciones
  final bool hasCover;
  final String? coverDescription; // Ej: 'Sin cover', '$50 - $100 MXN', 'Cover $100 después de 11 PM'
  final bool isOpenNow;
  final String? closedReason; // Ej: 'Abre hoy a las 8:00 PM', 'Cerrado los lunes', 'Cerrado por remodelación'
  final String? reservationPhone; // Ej: '+523121234567'
  final String? whatsappReservation; // Número para enlace directo WhatsApp
  final List<VenueEvent> upcomingEvents;

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
    this.livePresenceCount,
    this.hasCover = false,
    this.coverDescription,
    this.isOpenNow = true,
    this.closedReason,
    this.reservationPhone,
    this.whatsappReservation,
    this.upcomingEvents = const [],
  });

  /// Telemetría de personas en vivo en radio de 80m sincronizada con el aforo
  int get livePresence {
    if (isPermanentlyClosed) return 0;
    if (livePresenceCount != null) return livePresenceCount!;
    final base = (capacityPercent * 1.5).round();
    return base > 0 ? base : 12;
  }

  /// Etiqueta visible del cover
  String get coverTag {
    if (!hasCover || coverDescription == null || coverDescription!.isEmpty) {
      return 'Sin Cover';
    }
    return coverDescription!;
  }

  /// Etiqueta visible del horario / estatus de apertura
  String get openStatusTag {
    if (isPermanentlyClosed) return 'In Memoriam';
    if (!isOpenNow) {
      return closedReason ?? 'Cerrado Ahora';
    }
    return 'Abierto Ahora';
  }

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
    int? livePresenceCount,
    bool? hasCover,
    String? coverDescription,
    bool? isOpenNow,
    String? closedReason,
    String? reservationPhone,
    String? whatsappReservation,
    List<VenueEvent>? upcomingEvents,
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
      livePresenceCount: livePresenceCount ?? this.livePresenceCount,
      hasCover: hasCover ?? this.hasCover,
      coverDescription: coverDescription ?? this.coverDescription,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      closedReason: closedReason ?? this.closedReason,
      reservationPhone: reservationPhone ?? this.reservationPhone,
      whatsappReservation: whatsappReservation ?? this.whatsappReservation,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }
}
