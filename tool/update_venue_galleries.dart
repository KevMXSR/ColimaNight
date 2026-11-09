import 'dart:io';

void main() {
  final file = File('lib/features/venues/presentation/providers/venue_providers.dart');
  String content = file.readAsStringSync();

  // Reemplazar cada bloque de galleryUrls con las 4 fotos de ambiente de cada local
  // Regex busca id: '(\w+)' seguido por ... galleryUrls: \[[^\]]*\]
  final venueRegex = RegExp(r"(id:\s*'([a-zA-Z0-9_]+)',[\s\S]*?galleryUrls:\s*\[)([\s\S]*?)(\],)");

  content = content.replaceAllMapped(venueRegex, (match) {
    final prefix = match.group(1)!;
    final venueId = match.group(2)!;
    final closing = match.group(4)!;

    String baseId = venueId;
    if (venueId == 'la_puerta_bar') {
      baseId = 'bar_la_puerta';
    }

    final newGallery = "\n      'assets/images/venues/$baseId.jpg',\n"
        "      'assets/images/venues/${baseId}_2.jpg',\n"
        "      'assets/images/venues/${baseId}_3.jpg',\n"
        "      'assets/images/venues/${baseId}_4.jpg',\n    ";

    return '$prefix$newGallery$closing';
  });

  // Asegurar que Bar La Puerta tenga coverImageUrl a bar_la_puerta.jpg
  content = content.replaceAll(
    "coverImageUrl: 'assets/images/venues/la_puerta_bar.jpg',",
    "coverImageUrl: 'assets/images/venues/bar_la_puerta.jpg',",
  );

  // Agregar Cervecería Chapultepec antes del cierre de _initialVenues si no existe
  if (!content.contains("'cerveceria_chapultepec'")) {
    const chapultepecBlock = '''
  // --- CERVECERÍA CHAPULTEPEC ---
  VenueModel(
    id: 'cerveceria_chapultepec',
    name: 'Cervecería Chapultepec',
    category: 'Cervecería & Bar Casual',
    zone: 'Av. Venustiano Carranza #1726, locales 3 y 4, Residencial Esmeralda Nte., 28017 Colima, Col.',
    description:
        'Cervecería casual en Av. Carranza con concepto "Todo a un Mismo Precio" en tarros helados, cócteles, hamburguesas, tacos y botanas.',
    coverImageUrl: 'assets/images/venues/cerveceria_chapultepec.jpg',
    galleryUrls: [
      'assets/images/venues/cerveceria_chapultepec.jpg',
      'assets/images/venues/cerveceria_chapultepec_2.jpg',
      'assets/images/venues/cerveceria_chapultepec_3.jpg',
      'assets/images/venues/cerveceria_chapultepec_4.jpg',
    ],
    rating: 4.6,
    reviewsCount: 390,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Todo a un Mismo Precio en Bebidas y Alimentos',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento de plaza comercial disponible',
    latitude: 19.273223,
    longitude: -103.715025,
    instagramHandle: '@cerveceriachapultepeccolima',
    tikTokHandle: '@cerveceriachapultepec',
    facebookUrl: 'https://www.facebook.com/cerveceriachapultepeccolima/',
    vibeGenre: 'Craft & Commercial Beer / Casual Dining / Pop Rock',
    schedule: 'Lunes a Domingo: 1:00 PM - 1:00 AM (Vie - Sáb hasta 2:00 AM)',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover (Entrada Libre)',
    livePresenceCount: 0,
    upcomingEvents: [
      VenueEvent(
        id: 'chapultepec_todo_mismo_precio',
        title: 'Todo a un Mismo Precio (Todos los Días)',
        dateDisplay: EventDateHelper.formatEventDate(DateTime.now()),
        eventDate: EventDateHelper.getUpcomingWeekday(DateTime.now().weekday, hour: 13, minute: 0),
        artistOrDj: 'Música Pop, Rock & Hits en Vivo',
        coverPrice: 'Entrada Libre',
        promoNote: 'Tarros, cócteles, hamburguesas y tacos a precio único accesible',
        flyerImageUrl: 'assets/images/venues/flyers/cerveceria_chapultepec_flyer.jpg',
        sourceInstagramUrl: 'https://www.instagram.com/cerveceriachapultepeccolima/',
        sourceInstagramHandle: '@cerveceriachapultepeccolima',
        sourceFacebookUrl: 'https://www.facebook.com/cerveceriachapultepeccolima/',
        isStoryAnnouncement: true,
        specialSchedule: 'Abierto desde la 1:00 PM todos los días',
      ),
    ],
  ),
''';

    content = content.replaceFirst(
      '  ),\n];',
      '  ),\n$chapultepecBlock];',
    );
  }

  file.writeAsStringSync(content);
  print('venue_providers.dart updated successfully!');
}
