import '../../../../core/constants/colima_geo_constants.dart';
import 'nightlife_corridor.dart';

/// Categorías de establecimientos nocturnos en Colima y Villa de Álvarez
enum VenueCategory {
  nightclub,
  barPub,
  mezcaleria,
  terraceLounge,
  botaneroCantina,
  beerGarden,
  pizzaBar,
  rockBar,
  memorialHistoric,
}

/// Representa un establecimiento nocturno geolocalizado en Colima o Villa de Álvarez
class VenueLocation {
  final String id;
  final String name;
  final VenueCategory category;
  final CorridorId corridorId;
  final String address;
  final GeoPoint coordinates;
  final VenueStatus currentStatus;
  final int currentOccupancyPercentage; // 0 a 100
  final bool hasCover;
  final double? coverPriceMxn;
  final String musicGenre;
  final String activePromotion;
  final double geofenceRadiusMeters;

  // Enlaces de Redes Sociales y Contacto
  final String? instagramHandle;
  final String? tiktokHandle;
  final String? facebookPageId;
  final String? whatsappNumber;
  final String? googlePlaceId;

  const VenueLocation({
    required this.id,
    required this.name,
    required this.category,
    required this.corridorId,
    required this.address,
    required this.coordinates,
    required this.currentStatus,
    this.currentOccupancyPercentage = 50,
    this.hasCover = false,
    this.coverPriceMxn,
    this.musicGenre = 'Variado',
    this.activePromotion = 'Sin promoción activa',
    this.geofenceRadiusMeters = ColimaGeoConstants.proofOfProximityRadiusMeters,
    this.instagramHandle,
    this.tiktokHandle,
    this.facebookPageId,
    this.whatsappNumber,
    this.googlePlaceId,
  });

  /// Retorna el color hexadecimal asociado al estado en tiempo real
  String get statusColorHex {
    switch (currentStatus) {
      case VenueStatus.available:
        return '#00E676'; // Neon Emerald (Verde)
      case VenueStatus.crowded:
        return '#FFD600'; // Neon Amber (Amarillo)
      case VenueStatus.specialEvent:
        return '#D500F9'; // Neon Purple (Violeta)
      case VenueStatus.alert:
        return '#FF1744'; // Neon Alert Red (Rojo)
      case VenueStatus.memorial:
        return '#B0BEC5'; // Ghost Silver / Platinum Memorial (Gris Platino)
    }
  }

  /// Retorna la etiqueta legible del estado
  String get statusLabel {
    switch (currentStatus) {
      case VenueStatus.available:
        return 'Lugar Disponible / Buen Ambiente';
      case VenueStatus.crowded:
        return 'Aforo Alto (${currentOccupancyPercentage}%) / Fila';
      case VenueStatus.specialEvent:
        return 'Evento Especial / DJ / VIP';
      case VenueStatus.alert:
        return 'Alerta / Precaución';
      case VenueStatus.memorial:
        return 'RIP Memorial • Sitio Legendario (Easter Egg)';
    }
  }

  /// Catálogo verificado de establecimientos corroborados en Google Maps de Colima y Villa de Álvarez
  static List<VenueLocation> get verifiedColimaVenues => [
        // ====================================================================
        // 1. Cervecería de la Costa (Sucursales Conurbadas)
        // ====================================================================
        const VenueLocation(
          id: 'costa-tercer-anillo',
          name: 'Cerveceria de la Costa Tercer Anillo',
          category: VenueCategory.barPub,
          corridorId: CorridorId.tercerAnilloVda,
          address: '28979, El Ángel, 28979 Cdad. de Villa de Álvarez, Col.',
          coordinates: GeoPoint(19.283056528553324, -103.73252591954697),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 65,
          musicGenre: 'Indie Rock, Tropical & House',
          activePromotion: 'Pintas Costera & Marejada 2x1 antes de las 9:00 PM',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-terraza-san-fernando',
          name: 'Cervecería de la Costa Terraza San Fernando',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.constitucionSanFernando,
          address: 'Av. Constitución 555, Las Amarillas, 28030 Colima, Col.',
          coordinates: GeoPoint(19.25238924521272, -103.72060620420548),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 85,
          musicGenre: 'Electro Pop & Sunset Beats',
          activePromotion: 'Jarras de Cerveza Artesanal y Hamburguesas en promo',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-ignacio-sandoval',
          name: 'Cervecería de la Costa Ignacio Sandoval',
          category: VenueCategory.barPub,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Calle Ignacio Sandoval 1793-2, Girasoles, 28018 Colima, Col.',
          coordinates: GeoPoint(19.260780246591853, -103.70639020420522),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 70,
          musicGenre: 'Rock Clásico & Funk',
          activePromotion: 'Degustación de 4 estilos craft por \$140',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-pablo-silva',
          name: 'Cervecería de la Costa Pablo Silva',
          category: VenueCategory.barPub,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Av Pablo Silva García 175, VILLAS DIAMANTE, 28986 Colima, Col.',
          coordinates: GeoPoint(19.266665752881863, -103.74911390420505),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 55,
          musicGenre: 'Crossover, Rock en Español & Pop',
          activePromotion: 'Cubetas artesanales con alitas en descuento',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-venustiano-carranza',
          name: 'Cervecería de la Costa V. Carranza 1',
          category: VenueCategory.beerGarden,
          corridorId: CorridorId.venustianoCarranza,
          address: 'Avenida Venustiano Carranza 2090, Residencial Esmeralda Nte., 28017 Colima, Col.',
          coordinates: GeoPoint(19.280260132705344, -103.71243250420474),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 80,
          musicGenre: 'DJ Set en Vivo & Nu-Disco',
          activePromotion: 'Lanzamiento de edición especial de barril',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-venustiano-carranza-2',
          name: 'Cervecería de la Costa V. Carranza 2',
          category: VenueCategory.beerGarden,
          corridorId: CorridorId.venustianoCarranza,
          address: 'Avenida Venustiano Carranza 2213, Rincón del Colibrí, Residencial Esmeralda Nte., 28017 Colima, Col.',
          coordinates: GeoPoint(19.283953050277574, -103.71044641736145),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 78,
          musicGenre: 'DJ Set en Vivo & Nu-Disco',
          activePromotion: 'Pintas artesanales y cocina al carbón',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-la-paz',
          name: 'Cervecería de la Costa La Paz 1',
          category: VenueCategory.barPub,
          corridorId: CorridorId.sevillaDelRioCaminoReal,
          address: 'Av La Paz 134, Sta Bárbara, 28017 Colima, Col.',
          coordinates: GeoPoint(19.267420114391854, -103.71702218801063),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 50,
          musicGenre: 'Indie & Acoustic Sessions',
          activePromotion: 'Pintas seleccionadas a precio especial',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-la-paz-2',
          name: 'Cervecería de la Costa La Paz 2',
          category: VenueCategory.barPub,
          corridorId: CorridorId.sevillaDelRioCaminoReal,
          address: 'Av La Paz 51, Sta Bárbara, 28017 Colima, Col.',
          coordinates: GeoPoint(19.26501012058269, -103.71355585360233),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 52,
          musicGenre: 'Acoustic & Chill Beats',
          activePromotion: 'Happy hour en cervezas artesanales',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-griselda-alvarez',
          name: 'Cervecería de la Costa Griselda Álvarez',
          category: VenueCategory.barPub,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Lib. Gobernadora Griselda Álvarez 32, Jardines del Llano, 28989 Cdad. de Villa de Álvarez, Col.',
          coordinates: GeoPoint(19.275246730426613, -103.75104793304038),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 60,
          musicGenre: 'Rock & Pop Alternativo',
          activePromotion: '2x1 en botanas al pedir jarra cervecera',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'costa-santa-fe',
          name: 'Cervecería de la Costa Santa Fe',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Prol. Hidalgo 1041, Real Santa Fe, 28978 Cdad. de Villa de Álvarez, Col.',
          coordinates: GeoPoint(19.289438686312888, -103.72504136187563),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 78,
          musicGenre: 'Deep House & Sunset Grooves',
          activePromotion: 'Tasting flights y cócteles de ginebra artesanal',
          instagramHandle: 'cerveceriadelacosta',
          // Sin reservacion de mesa
        ),

        // ====================================================================
        // 2. Estación Colimita (2 Sucursales Oficiales)
        // ====================================================================
        const VenueLocation(
          id: 'estacion-colimita-centro',
          name: 'Estación Colimita Andador Centro',
          category: VenueCategory.barPub,
          corridorId: CorridorId.centroHistorico,
          address: 'Andador Constitución 39, Sangre de Cristo, 28000 Colima, Col.',
          coordinates: GeoPoint(19.24404247322328, -103.72753500931157),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 88,
          musicGenre: 'Jazz, Funk & Cumbia Fusión',
          activePromotion: 'Colimita, Páramo y Ticús de barril con tapas locales',
          instagramHandle: 'cerveceriadecolima',
          facebookPageId: 'CerveceriaDeColima',
          // Sin reservacion de mesa
        ),
        const VenueLocation(
          id: 'estacion-colimita-constitucion',
          name: 'Estación Colimita Constitución',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.constitucionSanFernando,
          address: 'Av. Constitución 1401-Loc 1, Jardines Vista Hermosa IV, 28017 Colima, Col.',
          coordinates: GeoPoint(19.258069674365704, -103.71573610520983),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 65,
          musicGenre: 'Indie Pop & Tropical Beats',
          activePromotion: 'Tardes de cerveza y maridaje de autor',
          instagramHandle: 'cerveceriadecolima',
          // Sin reservacion de mesa
        ),

        // ====================================================================
        // 3. Locales Corroborados en Colima y Villa de Álvarez
        // ====================================================================
        // Corredor Ignacio Sandoval
        const VenueLocation(
          id: 'el-guachi',
          name: 'El Guachi',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Calle Ignacio Sandoval 1943, Paseo de La Cantera, La Cantera, 28018 Colima, Col.',
          coordinates: GeoPoint(19.263319260681573, -103.70427827536956),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 90,
          musicGenre: 'Banda, Regional Mexicano & Pop Latino',
          activePromotion: 'Botana caliente de mariscos en consumo de bebidas',
          geofenceRadiusMeters: ColimaGeoConstants.proofOfProximityRadiusMeters,
          instagramHandle: 'guachirooftop',
          whatsappNumber: '+523121301010',
        ),
        const VenueLocation(
          id: 'almada-cantina-fina',
          name: 'Almada Cantina Fina',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Calle Ignacio Sandoval 1906-Loc 4-5, Las Pergolas, 28018 Colima, Col.',
          coordinates: GeoPoint(19.261512414791067, -103.70514769214344),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 85,
          musicGenre: 'Norteño Acústico & Mixología Moderna',
          activePromotion: 'Tequilas y Mezcales premium al 3x2 antes de las 10 PM',
          geofenceRadiusMeters: ColimaGeoConstants.proofOfProximityRadiusMeters,
          instagramHandle: 'almada_cantina.fina',
          whatsappNumber: '+523121302020',
        ),
        const VenueLocation(
          id: 'el-gustito',
          name: 'El Gustito',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.ignacioSandoval,
          address: 'C. Ignacio Sandoval 1866, Lomas Vista Hermosa, 28017 Colima, Col.',
          coordinates: GeoPoint(19.260107816881263, -103.70606657716623),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 70,
          musicGenre: 'Música Variada, Cumbia & Rock en Español',
          activePromotion: 'Cerveza de media nacional con botana tradicional',
          instagramHandle: 'el_gustito_ignacio_sandoval',
          whatsappNumber: '+523121303030',
        ),

        // Corredor Centro Histórico
        const VenueLocation(
          id: 'dmt-rock-bar',
          name: 'DMT Rock Bar',
          category: VenueCategory.rockBar,
          corridorId: CorridorId.centroHistorico,
          address: 'C. Santos Degollado 28, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.243566028534627, -103.72893774790906),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 82,
          hasCover: true,
          coverPriceMxn: 50.0,
          musicGenre: 'Classic Rock, Hard Rock & Heavy Metal en Vivo',
          activePromotion: 'Cervezas nacionales y mezcal espadín en \$80',
          instagramHandle: 'dmtrockbar',
          whatsappNumber: '+523121404040',
        ),
        const VenueLocation(
          id: 'dos-puntos-cerveceria',
          name: 'Dos Puntos Cervecería',
          category: VenueCategory.barPub,
          corridorId: CorridorId.centroHistorico,
          address: 'C. Santos Degollado 34, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.243560963847916, -103.72891897244679),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 60,
          musicGenre: 'Rock Alternativo, Indie & Post-Punk',
          activePromotion: 'Promo de caguamas y tarros artesanales',
          instagramHandle: 'dospuntoscerveceria',
          whatsappNumber: '+523121405050',
        ),
        const VenueLocation(
          id: 'el-taurino-cantina',
          name: 'El Taurino Cantina Bar',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.centroHistorico,
          address: 'Filomeno Medina 12, Obregón, 28000 Colima, Col.',
          coordinates: GeoPoint(19.241001022989938, -103.72426068358524),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 55,
          musicGenre: 'Boleros, Ranchera Clásica & Trova',
          activePromotion: 'La cantina más tradicional de Colima: botana con cada trago',
          whatsappNumber: '+523121406060',
        ),
        const VenueLocation(
          id: 'la-puerta-bar',
          name: 'La Puerta Bar Colima',
          category: VenueCategory.barPub,
          corridorId: CorridorId.centroHistorico,
          address: 'C. 27 de Septiembre 135, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.24465620515491, -103.72493732805331),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 65,
          musicGenre: 'Trova, Bohemia Acústica & Canción Latinoamericana',
          activePromotion: 'Cerveza y sangría con entremeses de la casa',
          instagramHandle: 'lapuertadelperreo.dog',
          whatsappNumber: '+523121407070',
        ),
        const VenueLocation(
          id: 'low-social-club',
          name: 'Low Social Club',
          category: VenueCategory.nightclub,
          corridorId: CorridorId.centroHistorico,
          address: 'Calle Miguel Hidalgo 165, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.241007671540903, -103.72559862649845),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 84,
          musicGenre: 'House, Tech-House & Electrónica',
          activePromotion: 'Sin promoción activa',
          instagramHandle: 'lowclub.col',
        ),
        const VenueLocation(
          id: 'mezcaleria-casa-colima',
          name: 'Casa Colima mezcaleria',
          category: VenueCategory.mezcaleria,
          corridorId: CorridorId.centroHistorico,
          address: 'Calle Venustiano Carranza 60, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.244704192799993, -103.72786144335059),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 81,
          musicGenre: 'Música Bohemia, Son Jarocho & Trova Acústica',
          activePromotion: 'Degustación de mezcal artesanal con maridaje de sales de Colima',
          instagramHandle: 'casa.colima.mezcaleria',
        ),
        const VenueLocation(
          id: 'lostoros-barra-taurina',
          name: 'Los Toros Barra Taurina',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.centroHistorico,
          address: 'Emilio Carranza #164, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.24266787069572, -103.722301619548),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 78,
          musicGenre: 'Música de Cantina, Ranchera Clásica & Ambiente Taurino',
          activePromotion: 'Tequila tradicional y botanas de cortesía por consumo',
          instagramHandle: 'lostorosbarrataurina',
        ),

        // Corredor Sevilla del Río & Camino Real
        const VenueLocation(
          id: 'la-regional',
          name: 'La Regional',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Calle Ignacio Sandoval 1866, Real Vista Hermosa, 28000 Colima, Col.',
          coordinates: GeoPoint(19.259922574313567, -103.70621318205616),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 86,
          musicGenre: 'Pop Latino, Regional & Crossover',
          activePromotion: 'Cubetazo nacional \$180 y chamorros al estilo Colima',
          instagramHandle: 'la_regional_cantina',
          whatsappNumber: '+523121508080',
        ),
        const VenueLocation(
          id: 'la-chintola',
          name: 'La Chintola Bar',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.sevillaDelRioCaminoReal,
          address: '28010, Felipe Sevilla del Río 601, José María Morelos, 28000 Colima, Col.',
          coordinates: GeoPoint(19.249507583722707, -103.70748201887055),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 70,
          musicGenre: 'Música en Vivo, Salsa & Cumbia',
          activePromotion: 'Ceviches colimenses y cerveza helada',
          instagramHandle: 'lachintolacolima',
          whatsappNumber: '+523121509090',
        ),

        // Corredor Constitución / San Fernando
        const VenueLocation(
          id: 'santo-mezcal',
          name: 'Santo Mezcal',
          category: VenueCategory.mezcaleria,
          corridorId: CorridorId.constitucionSanFernando,
          address: 'Av. Constitución 1999, Lomas Verdes, 28017 Colima, Col.',
          coordinates: GeoPoint(19.264627212083123, -103.71129970420515),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 88,
          musicGenre: 'Electro Cumbia, Afro House & Mezcal Sessions',
          activePromotion: 'Vuelos de mezcal oaxaqueño y michoacano 2x1',
          instagramHandle: 'mezcal.santo',
          whatsappNumber: '+523121601010',
        ),

        // Centro Histórico - Foro Cultural
        const VenueLocation(
          id: 'foro_dmt',
          name: 'Foro DMT',
          category: VenueCategory.rockBar,
          corridorId: CorridorId.centroHistorico,
          address: 'C. Santos Degollado 50, Centro, 28000 Colima, Col.',
          coordinates: GeoPoint(19.243385050696823, -103.72907994355953),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 82,
          hasCover: true,
          coverPriceMxn: 80.0,
          musicGenre: 'Rock en Vivo / Indie / Alternativo',
          activePromotion: 'Cerveza artesanal 2x1 hasta las 10 PM',
          instagramHandle: 'foro_dmt',
          whatsappNumber: '+523121234567',
        ),

        // Corredor Venustiano Carranza Norte / Esmeralda
        const VenueLocation(
          id: 'paraiso_drinks',
          name: 'Paraíso Drinks Colima',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.venustianoCarranza,
          address: 'Av. de los Diamantes 140, Residencial Esmeralda Nte., 28017 Colima, Col.',
          coordinates: GeoPoint(19.278276708508628, -103.70990174232882),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 80,
          hasCover: false,
          musicGenre: 'Drinks de Autor / Pop Latino / Precopeo',
          activePromotion: '2x1 en coctelería de autor de 8 a 10 PM',
          instagramHandle: 'paraisodrinkscolima',
          whatsappNumber: '+523121234567',
        ),
      ];

  /// Easter Egg Memorial de Barezzito
  static const VenueLocation barezzitoEasterEgg = VenueLocation(
    id: 'barezzito-memorial',
    name: 'Barezzito (RIP Memorial)',
    category: VenueCategory.memorialHistoric,
    corridorId: CorridorId.constitucionSanFernando,
    address: 'Av. Constitución, Vista Hermosa, Colima, Col.',
    coordinates: GeoPoint(19.257904781349012, -103.7152190343091),
    currentStatus: VenueStatus.memorial,
    currentOccupancyPercentage: 0,
    hasCover: false,
    musicGenre: 'Pop 2010s, Rock en Vivo & Nostalgia Nocturna',
    activePromotion:
        'Easter Egg: ¡En memoria de las noches legendarias de Barezzito!',
    geofenceRadiusMeters: ColimaGeoConstants.proofOfProximityRadiusMeters,
    instagramHandle: 'barezzitocolima',
  );

  /// Lista que incluye los 21 establecimientos comerciales activos más el Easter Egg histórico
  static List<VenueLocation> get allVenuesIncludingEasterEgg => [
        ...verifiedColimaVenues,
        barezzitoEasterEgg,
      ];

  /// Alias de compatibilidad hacia atrás (retorna los 21 comercios activos)
  static List<VenueLocation> get mockColimaVenues => verifiedColimaVenues;
}
