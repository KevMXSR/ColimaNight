import '../utils/venue_schedule_evaluator.dart';

/// Representa un evento específico o de cartelera en un establecimiento
class VenueEvent {
  final String id;
  final String title;
  final String dateDisplay; // Ej: 'Viernes 31 Oct • 10:00 PM'
  final DateTime? eventDate; // Fecha estructurada para validación estricta de 'HOY' vs futuro
  final String? artistOrDj; // Ej: 'DJ Set en Vivo & Reggaetón Hits'
  final String? coverPrice; // Ej: 'Aprox. $100 MXN' o 'Entrada Libre'
  final String? promoNote; // Ej: '2x1 en copeo antes de las 11 PM'
  final bool? forcedIsToday;
  final String? flyerImageUrl; // Ej: 'assets/images/venues/flyers/guachi_rooftop_flyer.jpg'
  final String? sourceInstagramUrl; // Ej: 'https://www.instagram.com/guachirooftop/' o link directo al story/post
  final String? sourceInstagramHandle; // Ej: '@guachirooftop', '@barlapuerta'
  final bool isStoryAnnouncement; // Indica si proviene de anuncio de historias efímeras
  final String? specialSchedule; // Ej: 'Apertura especial 7:00 PM para Snacks & Drinks'
  final String? presaleUrl; // Enlace directo para compra de preventa (obtenido de fuente oficial)
  final String? presalePrice; // Ej: 'Preventa Especial: $120 MXN (Fase 1)'
  final bool isPresaleActive;
  final bool isSportsMatch; // Indica si es transmisión deportiva en vivo (fútbol, boxeo)
  final String? matchTeams; // Ej: 'Chivas vs América • Clásico Nacional'
  final String? broadcastDetails; // Ej: 'Pantalla gigante, audio en vivo y cubetazo'
  final bool isVideoStory; // Indica si proviene de un video reel o video en historia
  final String? sourceFacebookUrl; // Enlace directo a publicación o perfil de Facebook
  final DateTime? expiresAt; // Fecha/hora de expiración estricta del evento

  const VenueEvent({
    required this.id,
    required this.title,
    required this.dateDisplay,
    this.eventDate,
    this.artistOrDj,
    this.coverPrice,
    this.promoNote,
    this.forcedIsToday,
    this.flyerImageUrl,
    this.sourceInstagramUrl,
    this.sourceInstagramHandle,
    this.isStoryAnnouncement = false,
    this.specialSchedule,
    this.presaleUrl,
    this.presalePrice,
    this.isPresaleActive = false,
    this.isSportsMatch = false,
    this.matchTeams,
    this.broadcastDetails,
    this.isVideoStory = false,
    this.sourceFacebookUrl,
    this.expiresAt,
  });

  /// Evalúa dinámicamente si el evento está ocurriendo HOY según DateTime.now()
  bool get isToday {
    if (forcedIsToday != null) return forcedIsToday!;
    if (eventDate == null) return false;
    final now = DateTime.now();
    return eventDate!.year == now.year &&
        eventDate!.month == now.month &&
        eventDate!.day == now.day;
  }

  /// Valida si el evento ya caducó
  bool get isExpired {
    final now = DateTime.now();
    if (expiresAt != null) {
      return now.isAfter(expiresAt!);
    }
    if (eventDate != null) {
      // Concluye a las 06:00 AM del día posterior al evento
      final endOfNight = DateTime(eventDate!.year, eventDate!.month, eventDate!.day + 1, 6, 0);
      return now.isAfter(endOfNight);
    }
    return false;
  }

  factory VenueEvent.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val);
      try {
        final dynamic dynamicVal = val;
        return dynamicVal.toDate() as DateTime;
      } catch (_) {}
      return null;
    }

    final evDate = parseDate(map['eventDate']);
    final expDate = parseDate(map['expiresAt']);

    return VenueEvent(
      id: id,
      title: map['title'] ?? map['eventTitle'] ?? 'Evento Nocturno',
      dateDisplay: map['dateDisplay'] ?? (evDate != null ? '${evDate.day}/${evDate.month}' : 'Próximamente'),
      eventDate: evDate,
      artistOrDj: map['artistOrDj'] ?? map['djOrBand'],
      coverPrice: map['coverPrice'] ?? (map['coverPriceMxn'] != null ? '\$${map['coverPriceMxn']} MXN' : null),
      promoNote: map['promoNote'] ?? map['promo'],
      forcedIsToday: map['forcedIsToday'],
      flyerImageUrl: map['flyerImageUrl'] ?? map['mediaUrl'],
      sourceInstagramUrl: map['sourceInstagramUrl'] ?? map['postUrl'],
      sourceInstagramHandle: map['sourceInstagramHandle'] ?? map['instagramHandle'],
      isStoryAnnouncement: map['isStoryAnnouncement'] ?? false,
      specialSchedule: map['specialSchedule'],
      presaleUrl: map['presaleUrl'],
      presalePrice: map['presalePrice'],
      isPresaleActive: map['isPresaleActive'] ?? false,
      isSportsMatch: map['isSportsMatch'] ?? false,
      matchTeams: map['matchTeams'],
      broadcastDetails: map['broadcastDetails'],
      isVideoStory: map['isVideoStory'] ?? false,
      sourceFacebookUrl: map['sourceFacebookUrl'],
      expiresAt: expDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateDisplay': dateDisplay,
      'eventDate': eventDate?.toIso8601String(),
      'artistOrDj': artistOrDj,
      'coverPrice': coverPrice,
      'promoNote': promoNote,
      'forcedIsToday': forcedIsToday,
      'flyerImageUrl': flyerImageUrl,
      'sourceInstagramUrl': sourceInstagramUrl,
      'sourceInstagramHandle': sourceInstagramHandle,
      'isStoryAnnouncement': isStoryAnnouncement,
      'specialSchedule': specialSchedule,
      'presaleUrl': presaleUrl,
      'presalePrice': presalePrice,
      'isPresaleActive': isPresaleActive,
      'isSportsMatch': isSportsMatch,
      'matchTeams': matchTeams,
      'broadcastDetails': broadcastDetails,
      'isVideoStory': isVideoStory,
      'sourceFacebookUrl': sourceFacebookUrl,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
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
  final String? secondaryInstagramHandle; // Handle secundario (ej: @guachirooftop para terraza)
  final String? secondaryInstagramUrl; // Enlace directo a perfil secundario
  final String? tikTokHandle;
  final String? facebookUrl;
  final String? facebookHandle;
  final String? websiteUrl; // Sitio web oficial (ej: https://torna.bar/)
  final String? reservationUrl; // Enlace oficial para reservaciones (ej: CoverManager o web)
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
    this.secondaryInstagramHandle,
    this.secondaryInstagramUrl,
    this.tikTokHandle,
    this.facebookUrl,
    this.facebookHandle,
    this.websiteUrl,
    this.reservationUrl,
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

  /// Telemetría de personas en vivo en radio de 80m basada estrictamente en registro físico y geolocalización real
  int get livePresence {
    if (isPermanentlyClosed || !isOpenNow) return 0;
    if (livePresenceCount != null) return livePresenceCount!;
    // En fase de pruebas con usuarios reales registrados, no inflar artificialmente
    return 0;
  }

  /// Lista oficial de fotografías de ambiente del establecimiento,
  /// garantizando que siempre provengan de los archivos oficiales locales.
  List<String> get ambientPhotos {
    if (galleryUrls.isNotEmpty) return galleryUrls;
    return [coverImageUrl];
  }

  /// Indica si el establecimiento admite reservación previa de mesa.
  /// Cervecería de la Costa y Estación Colimita operan exclusivamente por orden de llegada (sin reservaciones).
  bool get hasTableReservation {
    if (isPermanentlyClosed) return false;
    final lowerId = id.toLowerCase();
    final lowerName = name.toLowerCase();
    if (lowerId.startsWith('costa_') ||
        lowerId.startsWith('costa-') ||
        lowerId.startsWith('colimita_') ||
        lowerId.startsWith('estacion-colimita') ||
        lowerName.contains('cervecería de la costa') ||
        lowerName.contains('cerveceria de la costa') ||
        lowerName.contains('estación colimita') ||
        lowerName.contains('estacion colimita')) {
      return false;
    }
    return (whatsappReservation != null && whatsappReservation!.isNotEmpty) ||
        (reservationPhone != null && reservationPhone!.isNotEmpty) ||
        (reservationUrl != null && reservationUrl!.isNotEmpty);
  }

  /// Etiqueta visible del cover
  String get coverTag {
    if (!hasCover || coverDescription == null || coverDescription!.isEmpty) {
      return 'Sin Cover';
    }
    return coverDescription!;
  }

  /// Estado operativo dinámico calculado en tiempo real sin incongruencias
  VenueScheduleStatus get dynamicScheduleStatus => VenueScheduleEvaluator.evaluate(this);

  /// Indica si el establecimiento está efectivamente en servicio ahora mismo
  bool get isEffectivelyOpen => dynamicScheduleStatus.isOpenNow;

  /// Etiqueta visible del horario / estatus de apertura
  String get openStatusTag {
    if (isPermanentlyClosed) return closedJokeNote ?? 'In Memoriam';
    return dynamicScheduleStatus.detailedStatus;
  }

  /// Determina el color de aura/pin según su estado o vibe
  String get statusTag {
    if (isPermanentlyClosed) return closedJokeNote ?? '🪦 In Memoriam • RIP';
    if (securityStatus == 'active_alert') {
      if (lastIncidentType == 'weapon') return '🚨 Alerta: Posible Arma';
      return '⚠️ Altercado verificado';
    }
    if (securityStatus == 'under_review') return '👀 Reporte en revisión';
    // Nota: Las notas y reportes de calidad de servicio son 100% privados para administración
    // y NUNCA se exhiben públicamente en el mapa ni en las tarjetas de la app.
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
    String? secondaryInstagramHandle,
    String? secondaryInstagramUrl,
    String? tikTokHandle,
    String? facebookUrl,
    String? facebookHandle,
    String? websiteUrl,
    String? reservationUrl,
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
      secondaryInstagramHandle: secondaryInstagramHandle ?? this.secondaryInstagramHandle,
      secondaryInstagramUrl: secondaryInstagramUrl ?? this.secondaryInstagramUrl,
      tikTokHandle: tikTokHandle ?? this.tikTokHandle,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      facebookHandle: facebookHandle ?? this.facebookHandle,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      reservationUrl: reservationUrl ?? this.reservationUrl,
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

  factory VenueModel.fromMap(Map<String, dynamic> map, String id) {
    double parseDouble(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    int parseInt(dynamic val, int fallback) {
      if (val == null) return fallback;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    // Ubicación (puede venir como GeoPoint de Firestore o lat/lng individuales)
    double lat = 19.2433;
    double lng = -103.7247;
    if (map['location'] != null) {
      try {
        final dynamic loc = map['location'];
        lat = parseDouble(loc.latitude, lat);
        lng = parseDouble(loc.longitude, lng);
      } catch (_) {}
    } else {
      lat = parseDouble(map['latitude'], lat);
      lng = parseDouble(map['longitude'], lng);
    }

    // Galería
    List<String> gallery = [];
    if (map['galleryUrls'] is List) {
      gallery = (map['galleryUrls'] as List).map((e) => e.toString()).toList();
    }

    // Subcolección o lista de eventos
    List<VenueEvent> events = [];
    if (map['upcomingEvents'] is List) {
      events = (map['upcomingEvents'] as List)
          .asMap()
          .entries
          .map((entry) => VenueEvent.fromMap(
                Map<String, dynamic>.from(entry.value as Map),
                entry.value['id']?.toString() ?? '${id}_event_${entry.key}',
              ))
          .toList();
    }

    // Música en vivo estructurada o booleana
    bool liveMusic = map['hasLiveMusic'] ?? false;
    String? liveAct = map['liveMusicAct'];
    if (map['liveMusic'] is Map) {
      final liveMusicMap = map['liveMusic'] as Map;
      liveMusic = liveMusicMap['hasLiveMusic'] ?? liveMusic;
      liveAct = liveMusicMap['bandOrDjName'] ?? liveAct;
    }

    // Promociones activas (puede venir de activePromos array de Firestore)
    bool promoActive = map['hasPromo'] ?? false;
    String? promoText = map['promoHeadline'];
    if (map['activePromos'] is List && (map['activePromos'] as List).isNotEmpty) {
      promoActive = true;
      final firstPromo = (map['activePromos'] as List).first;
      if (firstPromo is Map) {
        promoText = firstPromo['title'] ?? firstPromo['description'] ?? promoText;
      } else if (firstPromo is String) {
        promoText = firstPromo;
      }
    }

    // Redes sociales (socialLinks Map o directo)
    String? ig = map['instagramHandle'];
    String? fb = map['facebookUrl'];
    if (map['socialLinks'] is Map) {
      final social = map['socialLinks'] as Map;
      if (social['instagram'] != null) {
        final igUrl = social['instagram'].toString();
        ig = igUrl.split('/').where((s) => s.isNotEmpty).last;
        if (!ig.startsWith('@')) ig = '@$ig';
      }
      if (social['facebook'] != null) {
        fb = social['facebook'].toString();
      }
    }

    return VenueModel(
      id: id,
      name: map['name'] ?? 'Establecimiento',
      category: map['category'] ?? 'Bar',
      zone: map['zone'] ?? map['address'] ?? 'Colima',
      description: map['description'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? 'assets/images/venues/el_guachi.jpg',
      galleryUrls: gallery,
      rating: parseDouble(map['rating'], 4.8),
      reviewsCount: parseInt(map['reviewsCount'], 100),
      capacityPercent: parseInt(map['capacityPercent'] ?? map['currentOccupancyPercent'], 0),
      isHotRightNow: map['isHotRightNow'] ?? false,
      hotReason: map['hotReason'],
      hasLiveMusic: liveMusic,
      liveMusicAct: liveAct,
      isVipPresent: map['isVipPresent'] ?? false,
      vipNote: map['vipNote'],
      hasPromo: promoActive,
      promoHeadline: promoText,
      parkingAvailable: map['parkingAvailable'] ?? true,
      parkingDetails: map['parkingDetails'],
      latitude: lat,
      longitude: lng,
      instagramHandle: ig,
      secondaryInstagramHandle: map['secondaryInstagramHandle'],
      secondaryInstagramUrl: map['secondaryInstagramUrl'],
      tikTokHandle: map['tikTokHandle'],
      facebookUrl: fb,
      facebookHandle: map['facebookHandle'],
      websiteUrl: map['websiteUrl'],
      reservationUrl: map['reservationUrl'],
      vibeGenre: map['vibeGenre'] ?? map['vibeScore'] ?? 'Variado',
      schedule: map['schedule'] ?? '8:00 PM - 3:00 AM',
      estimatedMinutes: parseInt(map['estimatedMinutes'], 8),
      securityStatus: map['securityStatus'] is Map
          ? (map['securityStatus']['level'] ?? 'normal')
          : (map['securityStatus'] ?? 'normal'),
      activeIncidentReportsCount: parseInt(map['activeIncidentReportsCount'], 0),
      lastIncidentType: map['lastIncidentType'],
      lastReportNote: map['lastReportNote'],
      isPermanentlyClosed: map['isPermanentlyClosed'] ?? (map['isEasterEgg'] == true),
      closedJokeNote: map['closedJokeNote'],
      livePresenceCount: parseInt(map['livePresenceCount'] ?? map['liveAttendeesCount'], 0),
      hasCover: map['hasCover'] ?? false,
      coverDescription: map['coverDescription'],
      isOpenNow: map['isOpenNow'] ?? (map['active'] ?? true),
      closedReason: map['closedReason'],
      reservationPhone: map['reservationPhone'],
      whatsappReservation: map['whatsappReservation'],
      upcomingEvents: events,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'zone': zone,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'galleryUrls': galleryUrls,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'capacityPercent': capacityPercent,
      'isHotRightNow': isHotRightNow,
      'hotReason': hotReason,
      'hasLiveMusic': hasLiveMusic,
      'liveMusicAct': liveMusicAct,
      'isVipPresent': isVipPresent,
      'vipNote': vipNote,
      'hasPromo': hasPromo,
      'promoHeadline': promoHeadline,
      'parkingAvailable': parkingAvailable,
      'parkingDetails': parkingDetails,
      'latitude': latitude,
      'longitude': longitude,
      'instagramHandle': instagramHandle,
      'secondaryInstagramHandle': secondaryInstagramHandle,
      'secondaryInstagramUrl': secondaryInstagramUrl,
      'tikTokHandle': tikTokHandle,
      'facebookUrl': facebookUrl,
      'facebookHandle': facebookHandle,
      'websiteUrl': websiteUrl,
      'reservationUrl': reservationUrl,
      'vibeGenre': vibeGenre,
      'schedule': schedule,
      'estimatedMinutes': estimatedMinutes,
      'securityStatus': securityStatus,
      'activeIncidentReportsCount': activeIncidentReportsCount,
      'lastIncidentType': lastIncidentType,
      'lastReportNote': lastReportNote,
      'isPermanentlyClosed': isPermanentlyClosed,
      'closedJokeNote': closedJokeNote,
      'livePresenceCount': livePresenceCount,
      'hasCover': hasCover,
      'coverDescription': coverDescription,
      'isOpenNow': isOpenNow,
      'closedReason': closedReason,
      'reservationPhone': reservationPhone,
      'whatsappReservation': whatsappReservation,
      'upcomingEvents': upcomingEvents.map((e) => e.toMap()).toList(),
    };
  }
}
