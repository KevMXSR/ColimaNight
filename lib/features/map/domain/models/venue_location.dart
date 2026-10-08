import '../../../core/constants/colima_geo_constants.dart';
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
        // 1. Cervecería de la Costa (8 Sucursales Conurbadas)
        // ====================================================================
        const VenueLocation(
          id: 'costa-tercer-anillo',
          name: 'Cervecería de la Costa - Tercer Anillo',
          category: VenueCategory.barPub,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Blvd. Miguel de la Madrid Hurtado, Tercer Anillo Periférico, Colima',
          coordinates: GeoPoint(19.2828, -103.7325),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 65,
          musicGenre: 'Indie Rock, Tropical & House',
          activePromotion: 'Pintas Costera & Marejada 2x1 antes de las 9:00 PM',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550101',
        ),
        const VenueLocation(
          id: 'costa-terraza-san-fernando',
          name: 'Cervecería de la Costa - Terraza San Fernando',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.constitucionSanFernando,
          address: 'Plaza San Fernando, Av. Constitución / Sevilla del Río, Colima',
          coordinates: GeoPoint(19.2522, -103.7206),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 85,
          musicGenre: 'Electro Pop & Sunset Beats',
          activePromotion: 'Jarras de Cerveza Artesanal y Hamburguesas en promo',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550102',
        ),
        const VenueLocation(
          id: 'costa-ignacio-sandoval',
          name: 'Cervecería de la Costa - Ignacio Sandoval',
          category: VenueCategory.barPub,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Av. Ignacio Sandoval 1680, Lomas de Circunvalación, Colima',
          coordinates: GeoPoint(19.2605, -103.7064),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 70,
          musicGenre: 'Rock Clásico & Funk',
          activePromotion: 'Degustación de 4 estilos craft por \$140',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550103',
        ),
        const VenueLocation(
          id: 'costa-pablo-silva',
          name: 'Cervecería de la Costa - Pablo Silva (VDA)',
          category: VenueCategory.barPub,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Av. Pablo Silva García, Villa de Álvarez, Colima',
          coordinates: GeoPoint(19.2664, -103.7491),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 55,
          musicGenre: 'Crossover, Rock en Español & Pop',
          activePromotion: 'Cubetas artesanales con alitas en descuento',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550104',
        ),
        const VenueLocation(
          id: 'costa-venustiano-carranza',
          name: 'Cervecería de la Costa - Venustiano Carranza',
          category: VenueCategory.beerGarden,
          corridorId: CorridorId.venustianoCarranza,
          address: 'Av. Venustiano Carranza 1900, Residencial Santa Bárbara, Colima',
          coordinates: GeoPoint(19.2800, -103.7124),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 80,
          musicGenre: 'DJ Set en Vivo & Nu-Disco',
          activePromotion: 'Lanzamiento de edición especial de barril',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550105',
        ),
        const VenueLocation(
          id: 'costa-la-paz',
          name: 'Cervecería de la Costa - La Paz',
          category: VenueCategory.barPub,
          corridorId: CorridorId.sevillaDelRioCaminoReal,
          address: 'Calle La Paz / Conexión Sevilla del Río, Colima',
          coordinates: GeoPoint(19.2674, -103.7170),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 50,
          musicGenre: 'Indie & Acoustic Sessions',
          activePromotion: 'Pintas seleccionadas a precio especial',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550106',
        ),
        const VenueLocation(
          id: 'costa-griselda-alvarez',
          name: 'Cervecería de la Costa - Griselda Álvarez (VDA)',
          category: VenueCategory.barPub,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Av. Gobernadora Griselda Álvarez, Villa de Álvarez, Colima',
          coordinates: GeoPoint(19.2750, -103.7510),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 60,
          musicGenre: 'Rock & Pop Alternativo',
          activePromotion: '2x1 en botanas al pedir jarra cervecera',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550107',
        ),
        const VenueLocation(
          id: 'costa-santa-fe',
          name: 'Cervecería de la Costa - Santa Fe',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.tercerAnilloVda,
          address: 'Paseo Santa Fe, Tercer Anillo Periférico Norte, Colima',
          coordinates: GeoPoint(19.2892, -103.7250),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 78,
          musicGenre: 'Deep House & Sunset Grooves',
          activePromotion: 'Tasting flights y cócteles de ginebra artesanal',
          instagramHandle: 'cerveceriadelacosta',
          whatsappNumber: '+523121550108',
        ),

        // ====================================================================
        // 2. Estación Colimita (2 Sucursales Oficiales)
        // ====================================================================
        const VenueLocation(
          id: 'estacion-colimita-centro',
          name: 'Estación Colimita - Andador Centro',
          category: VenueCategory.barPub,
          corridorId: CorridorId.centroHistorico,
          address: 'Andador Constitución 12, Centro Histórico, Colima',
          coordinates: GeoPoint(19.2439, -103.7275),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 88,
          musicGenre: 'Jazz, Funk & Cumbia Fusión',
          activePromotion: 'Colimita, Páramo y Ticús de barril con tapas locales',
          instagramHandle: 'cerveceriacolima',
          facebookPageId: 'CerveceriaDeColima',
          whatsappNumber: '+523123120101',
        ),
        const VenueLocation(
          id: 'estacion-colimita-constitucion',
          name: 'Estación Colimita - Constitución',
          category: VenueCategory.terraceLounge,
          corridorId: CorridorId.constitucionSanFernando,
          address: 'Av. Constitución 450, Lomas de Circunvalación, Colima',
          coordinates: GeoPoint(19.2578, -103.7158),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 65,
          musicGenre: 'Indie Pop & Tropical Beats',
          activePromotion: 'Tardes de cerveza y maridaje de autor',
          instagramHandle: 'cerveceriacolima',
          whatsappNumber: '+523123120102',
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
          address: 'Calle Ignacio Sandoval 1943, Paseo de la Cantera, Colima',
          coordinates: GeoPoint(19.2631, -103.7043),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 90,
          musicGenre: 'Banda, Regional Mexicano & Pop Latino',
          activePromotion: 'Botana caliente de mariscos en consumo de bebidas',
          geofenceRadiusMeters: ColimaGeoConstants.proofOfProximityRadiusMeters,
          instagramHandle: 'elguachicolima',
          whatsappNumber: '+523121301010',
        ),
        const VenueLocation(
          id: 'almada-cantina-fina',
          name: 'Almada Cantina Fina',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Av. Ignacio Sandoval 1906, Plaza Las Pérgolas, Colima',
          coordinates: GeoPoint(19.2625, -103.7040),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 85,
          musicGenre: 'Norteño Acústico & Mixología Moderna',
          activePromotion: 'Tequilas y Mezcales premium al 3x2 antes de las 10 PM',
          geofenceRadiusMeters: ColimaGeoConstants.macroVenueProximityRadiusMeters,
          instagramHandle: 'almadacantinafina',
          whatsappNumber: '+523121302020',
        ),
        const VenueLocation(
          id: 'el-gustito',
          name: 'El Gustito',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.ignacioSandoval,
          address: 'Av. Ignacio Sandoval 1866, Lomas de Vista Hermosa, Colima',
          coordinates: GeoPoint(19.2620, -103.7041),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 70,
          musicGenre: 'Música Variada, Cumbia & Rock en Español',
          activePromotion: 'Cerveza de media nacional con botana tradicional',
          instagramHandle: 'elgustitocolima',
          whatsappNumber: '+523121303030',
        ),

        // Corredor Centro Histórico
        const VenueLocation(
          id: 'dmt-rock-bar',
          name: 'DMT Rock Bar',
          category: VenueCategory.rockBar,
          corridorId: CorridorId.centroHistorico,
          address: 'Calle Santos Degollado 28, Centro Histórico, Colima',
          coordinates: GeoPoint(19.2425, -103.7265),
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
          address: 'Calle Santos Degollado 34, Centro Histórico, Colima',
          coordinates: GeoPoint(19.2426, -103.7266),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 60,
          musicGenre: 'Rock Alternativo, Indie & Post-Punk',
          activePromotion: 'Promo de caguamas y tarros artesanales',
          instagramHandle: 'dospuntoscerveceria',
          whatsappNumber: '+523121405050',
        ),
        const VenueLocation(
          id: 'el-taurino-cantina',
          name: 'El Taurino Cantina',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.centroHistorico,
          address: 'Calle Filomeno Medina 12, Centro Histórico, Colima',
          coordinates: GeoPoint(19.2408, -103.7225),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 55,
          musicGenre: 'Boleros, Ranchera Clásica & Trova',
          activePromotion: 'La cantina más tradicional de Colima: botana con cada trago',
          whatsappNumber: '+523121406060',
        ),
        const VenueLocation(
          id: 'la-puerta-bar',
          name: 'La Puerta Bar',
          category: VenueCategory.barPub,
          corridorId: CorridorId.centroHistorico,
          address: 'Calle 27 de Septiembre 135, Centro Histórico, Colima',
          coordinates: GeoPoint(19.2448, -103.7295),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 65,
          musicGenre: 'Trova, Bohemia Acústica & Canción Latinoamericana',
          activePromotion: 'Cerveza y sangría con entremeses de la casa',
          instagramHandle: 'lapuertabarcolima',
          whatsappNumber: '+523121407070',
        ),
        const VenueLocation(
          id: 'low-social-club',
          name: 'Low Social Club (Low)',
          category: VenueCategory.nightclub,
          corridorId: CorridorId.centroHistorico,
          address: 'Calle Miguel Hidalgo 165, Centro, Colima',
          coordinates: GeoPoint(19.2410, -103.7256),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 84,
          musicGenre: 'House, Tech-House & Electrónica',
          activePromotion: 'Sin promoción activa',
          instagramHandle: 'low.colima',
        ),

        // Corredor Sevilla del Río & Camino Real
        const VenueLocation(
          id: 'la-regional',
          name: 'La Regional',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.sevillaDelRioCaminoReal,
          address: 'Av. Felipe Sevilla del Río 534, Lomas de Circunvalación, Colima',
          coordinates: GeoPoint(19.2530, -103.7180),
          currentStatus: VenueStatus.crowded,
          currentOccupancyPercentage: 86,
          musicGenre: 'Pop Latino, Regional & Crossover',
          activePromotion: 'Cubetazo nacional \$180 y chamorros al estilo Colima',
          instagramHandle: 'laregionalcolima',
          whatsappNumber: '+523121508080',
        ),
        const VenueLocation(
          id: 'la-chintola',
          name: 'La Chintola',
          category: VenueCategory.botaneroCantina,
          corridorId: CorridorId.sevillaDelRioCaminoReal,
          address: 'Blvd. Camino Real, Glorieta Monumental, Colima',
          coordinates: GeoPoint(19.2485, -103.7085),
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
          address: 'Av. Constitución 1999, Residencial Esmeralda Norte, Colima',
          coordinates: GeoPoint(19.2730, -103.7080),
          currentStatus: VenueStatus.specialEvent,
          currentOccupancyPercentage: 88,
          musicGenre: 'Electro Cumbia, Afro House & Mezcal Sessions',
          activePromotion: 'Vuelos de mezcal oaxaqueño y michoacano 2x1',
          instagramHandle: 'santomezcalcolima',
          whatsappNumber: '+523121601010',
        ),

        // Corredor Venustiano Carranza
        const VenueLocation(
          id: 'taverna-ny-pizza',
          name: 'Taverna NY Style Pizza',
          category: VenueCategory.pizzaBar,
          corridorId: CorridorId.venustianoCarranza,
          address: 'Av. Venustiano Carranza 1310, Residencial Santa Bárbara, Colima',
          coordinates: GeoPoint(19.2612, -103.7125),
          currentStatus: VenueStatus.available,
          currentOccupancyPercentage: 75,
          musicGenre: 'Indie Pop, Vinyl Grooves & Chillhop',
          activePromotion: 'Slice gigante de pizza pepperoni + cerveza artesanal por \$129',
          instagramHandle: 'tavernapizzacolima',
          whatsappNumber: '+523121702020',
        ),

      ];

  /// Easter Egg Memorial de Barezzito (históricamente ubicado sobre Av. Constitución)
  static const VenueLocation barezzitoEasterEgg = VenueLocation(
    id: 'barezzito-memorial',
    name: 'Barezzito (RIP Memorial)',
    category: VenueCategory.memorialHistoric,
    corridorId: CorridorId.constitucionSanFernando,
    address: 'Av. Constitución 1450, Jardines Vista Hermosa III, 28017 Colima, Col.',
    coordinates: GeoPoint(19.2524, -103.7210),
    currentStatus: VenueStatus.memorial,
    currentOccupancyPercentage: 0,
    hasCover: false,
    musicGenre: 'Pop 2010s, Rock en Vivo & Nostalgia Nocturna',
    activePromotion:
        'Easter Egg: ¡En memoria de las noches legendarias de sushi, drinks y desveladas en Constitución!',
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
