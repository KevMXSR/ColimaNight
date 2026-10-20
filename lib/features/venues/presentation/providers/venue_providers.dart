import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/venue_model.dart';

enum VenueFilterChip {
  all('Todos'),
  liveMusic('Música en vivo'),
  promos('2x1 & Promos'),
  parking('Estacionamiento'),
  highCapacity('Ambiente a tope'),
  vip('VIP / Influencers');

  final String label;
  const VenueFilterChip(this.label);
}

// Catálogo oficial actualizado de la vida nocturna en la zona conurbada Colima - Villa de Álvarez
// Sin menciones históricas ni reaperturas, descripciones concisas (1 frase) y coordenadas exactas
final List<VenueModel> _initialVenues = [
  // --- DESTACADO / HOT RIGHT NOW ---
  const VenueModel(
    id: 'el_guachi',
    name: 'El Guachi',
    category: 'Club & Antro',
    zone: 'Calle Ignacio Sandoval 1943, Paseo de La Cantera, La Cantera, 28018 Colima, Col.',
    description:
        'Club nocturno sobre Ignacio Sandoval con DJ sets, audio envolvente y coctelería.',
    coverImageUrl: 'assets/images/venues/el_guachi.jpg',
    galleryUrls: [
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.9,
    reviewsCount: 412,
    capacityPercent: 94,
    isHotRightNow: true,
    hotReason: '🔥 El club con mayor afluencia de la noche y aforo al 94%',
    hasLiveMusic: true,
    liveMusicAct: 'DJ Sets en vivo & Reggaetón Hits',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Valet parking sobre Ignacio Sandoval',
    latitude: 19.263319260681573,
    longitude: -103.70427827536956,
    instagramHandle: '@elguachiclub',
    tikTokHandle: '@elguachicolima',
    facebookUrl: 'https://facebook.com/elguachicolima',
    vibeGenre: 'Perreo / Tech-House / Pop Latino',
    schedule: '9:30 PM - 5:30 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // --- SUCURSALES OFICIALES CERVECERÍA DE LA COSTA ---
  const VenueModel(
    id: 'costa_tercer_anillo',
    name: 'Cervecería de la Costa - Tercer Anillo',
    category: 'Taproom & Terraza',
    zone: '28979, El Ángel, 28979 Cdad. de Villa de Álvarez, Col.',
    description:
        'Cervezas artesanales de barril, comida casual y amplia terraza al aire libre sobre Tercer Anillo.',
    coverImageUrl: 'assets/images/venues/costa_tercer_anillo.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 460,
    capacityPercent: 88,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Happy Hour en IPAs de la casa hasta las 9 PM',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento propio vigilado sobre lateral',
    latitude: 19.283056528553324,
    longitude: -103.73252591954697,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Craft Beer / Indie Pop / Chill Beats',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_san_fernando',
    name: 'Cervecería de la Costa Terraza San Fernando',
    category: 'Taproom Cervecero',
    zone: 'Av. Constitución 555, Las Amarillas, 28030 Colima, Col.',
    description:
        'Taproom cervecero con selección fresca de IPAs de la casa y ambiente relajado para precopeo.',
    coverImageUrl: 'assets/images/venues/costa_san_fernando.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 385,
    capacityPercent: 76,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Pinta del día a precio especial',
    parkingAvailable: true,
    parkingDetails: 'Cajones sobre lateral y estacionamiento cercano',
    latitude: 19.25238924521272,
    longitude: -103.72060620420548,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costasevilla',
    vibeGenre: 'Cerveza Artesanal / Pop Rock 90s & 2000s',
    schedule: '5:30 PM - 2:00 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_sandoval',
    name: 'Cervecería de la Costa Ignacio Sandoval',
    category: 'Taproom & Jardín',
    zone: 'Calle Ignacio Sandoval 1793-2, Girasoles, 28018 Colima, Col.',
    description:
        'Sucursal sobre el corredor gastronómico de Sandoval con cocina urbana y cervezas frías.',
    coverImageUrl: 'assets/images/venues/costa_sandoval.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 310,
    capacityPercent: 82,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: '2x1 en cervezas seleccionadas en barra',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento contiguo vigilado',
    latitude: 19.260780246591853,
    longitude: -103.70639020420522,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Craft Beer / Indie',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_pablo_silva',
    name: 'Cervecería de la Costa Pablo Silva',
    category: 'Taproom & Terraza',
    zone: 'Av Pablo Silva García 175, VILLAS DIAMANTE, 28986 Colima, Col.',
    description:
        'Punto cervecero en Villa de Álvarez ideal para reunirse con amigos toda la semana.',
    coverImageUrl: 'assets/images/venues/costa_pablo_silva.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 290,
    capacityPercent: 75,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Promo de botanas en la compra de tu sampler',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento libre sobre avenida',
    latitude: 19.266665752881863,
    longitude: -103.74911390420505,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Indie Beats / Chill Out',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_carranza',
    name: 'Cervecería de la Costa V. Carranza 1',
    category: 'Taproom & Terraza',
    zone: 'Avenida Venustiano Carranza 2090, Residencial Esmeralda Nte., 28017 Colima, Col.',
    description:
        'Terraza cervecera sobre el norte de la ciudad con cervezas artesanales y platillos para compartir.',
    coverImageUrl: 'assets/images/venues/costa_carranza.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 340,
    capacityPercent: 80,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Sampler cervecero de 4 estilos por \$180',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento plaza comercial',
    latitude: 19.280260132705344,
    longitude: -103.71243250420474,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Rock Clásico / Pop en inglés',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_carranza_2',
    name: 'Cervecería de la Costa V. Carranza 2',
    category: 'Taproom & Terraza',
    zone: 'Avenida Venustiano Carranza 2213, Rincón del Colibrí, Residencial Esmeralda Nte., 28017 Colima, Col.',
    description:
        'Segunda sucursal sobre Carranza con cervezas de línea, cocina al carbón y amplio jardín.',
    coverImageUrl: 'assets/images/venues/costa_carranza.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 280,
    capacityPercent: 79,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Pinta de la casa a precio preferencial',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento al frente del local',
    latitude: 19.283953050277574,
    longitude: -103.71044641736145,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Craft Beer / Indie',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_la_paz',
    name: 'Cervecería de la Costa La Paz 1',
    category: 'Taproom & Cocina',
    zone: 'Av La Paz 134, Sta Bárbara, 28017 Colima, Col.',
    description:
        'Espacio cervecero íntimo con ambiente fresco, cocina al grill y cervezas de temporada.',
    coverImageUrl: 'assets/images/venues/costa_la_paz.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 220,
    capacityPercent: 74,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Jueves cervecero con pintas a precio especial',
    parkingAvailable: true,
    parkingDetails: 'Cajones al frente del local',
    latitude: 19.267420114391854,
    longitude: -103.71702218801063,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Acoustic & Indie',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_la_paz_2',
    name: 'Cervecería de la Costa La Paz 2',
    category: 'Taproom & Cocina',
    zone: 'Av La Paz 51, Sta Bárbara, 28017 Colima, Col.',
    description:
        'Punto de degustación cervecera sobre Av. La Paz con botanas y cervezas frías.',
    coverImageUrl: 'assets/images/venues/costa_la_paz.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 205,
    capacityPercent: 73,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Happy Hour en pintas seleccionadas',
    parkingAvailable: true,
    parkingDetails: 'Cajones al frente sobre Av. La Paz',
    latitude: 19.26501012058269,
    longitude: -103.71355585360233,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Acoustic / Chill',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_griselda_alvarez',
    name: 'Cervecería de la Costa Griselda Álvarez',
    category: 'Taproom Cervecero',
    zone: 'Lib. Gobernadora Griselda Álvarez 32, Jardines del Llano, 28989 Cdad. de Villa de Álvarez, Col.',
    description:
        'Sucursal en Villa de Álvarez con terraza abierta, barra de barriles frescos y snacks botaneros.',
    coverImageUrl: 'assets/images/venues/costa_griselda_alvarez.jpg',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 215,
    capacityPercent: 72,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Litro cervecero artesanal en promoción',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento amplio al frente',
    latitude: 19.275246730426613,
    longitude: -103.75104793304038,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Pop / Crossover',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 10,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_santa_fe',
    name: 'Cervecería de la Costa Santa Fe',
    category: 'Taproom & Bar',
    zone: 'Prol. Hidalgo 1041, Real Santa Fe, 28978 Cdad. de Villa de Álvarez, Col.',
    description:
        'Taproom en la zona norte con propuesta cervecera artesanal y ambiente tranquilo.',
    coverImageUrl: 'assets/images/venues/costa_santa_fe.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 190,
    capacityPercent: 77,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: '2x1 en IPA de temporada',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento de fácil acceso',
    latitude: 19.289438686312888,
    longitude: -103.72504136187563,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Chill Hop / Indie Pop',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 10,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // --- SUCURSALES OFICIALES ESTACIÓN COLIMITA ---
  const VenueModel(
    id: 'colimita_centro',
    name: 'Estación Colimita Andador Centro',
    category: 'Taproom & Cocina de Humo',
    zone: 'Andador Constitución 39, Sangre de Cristo, 28000 Colima, Col.',
    description:
        'Cervezas clásicas de la casa servidas de barril junto a cocina de humo en el corazón del Centro.',
    coverImageUrl: 'assets/images/venues/colimita_centro.jpg',
    galleryUrls: [
      'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.9,
    reviewsCount: 780,
    capacityPercent: 84,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Música acústica y jazz en vivo',
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Tasting de 4 estilos Colimita por \$190',
    parkingAvailable: false,
    parkingDetails: 'Estacionamientos públicos del Centro Histórico',
    latitude: 19.24404247322328,
    longitude: -103.72753500931157,
    instagramHandle: '@estacioncolimita',
    tikTokHandle: '@cervezacolimita',
    facebookUrl: 'https://facebook.com/estacioncolimita',
    vibeGenre: 'Indie / Acústico / Cerveza Artesanal',
    schedule: '5:00 PM - 1:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'colimita_constitucion',
    name: 'Estación Colimita Constitución',
    category: 'Taproom & Jardín Cervecero',
    zone: 'Av. Constitución 1401-Loc 1, Jardines Vista Hermosa IV, 28017 Colima, Col.',
    description:
        'Jardín cervecero con toda la línea Colimita de barril y propuesta gastronómica contemporánea.',
    coverImageUrl: 'assets/images/venues/colimita_constitucion.jpg',
    galleryUrls: [],
    rating: 4.9,
    reviewsCount: 650,
    capacityPercent: 83,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Pinta Páramo y Ticús a precio preferencial',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento propio y servicio de valet',
    latitude: 19.258069674365704,
    longitude: -103.71573610520983,
    instagramHandle: '@estacioncolimita',
    tikTokHandle: '@cervezacolimita',
    vibeGenre: 'Craft Beer / Indie Pop / Lounge',
    schedule: '5:00 PM - 2:00 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // --- LOCALES CENTRO ---
  const VenueModel(
    id: 'dmt_rock_bar',
    name: 'DMT Rock Bar',
    category: 'Rock Bar & Live Music',
    zone: 'C. Santos Degollado 28, Centro, 28000 Colima, Col.',
    description:
        'El bar clásico de rock y música alternativa con tributos en vivo y cervezas frías.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1200&q=80',
    galleryUrls: [
      'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.8,
    reviewsCount: 510,
    capacityPercent: 86,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Banda de Rock en vivo: Tributos en directo',
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Cubetazo nacional 2x1 antes de la banda',
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento sobre calle Degollado',
    latitude: 19.243566028534627,
    longitude: -103.72893774790906,
    instagramHandle: '@dmtrockbar_colima',
    tikTokHandle: '@dmtrockbar',
    vibeGenre: 'Rock Clásico / Alternativo / Grunge',
    schedule: '8:00 PM - 4:00 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'dos_puntos',
    name: 'Dos Puntos Cervecería',
    category: 'Bar & Terraza',
    zone: 'C. Santos Degollado 34, Centro, 28000 Colima, Col.',
    description:
        'Terraza céntrica con tragos preparados, cervezas y buena música para iniciar la noche.',
    coverImageUrl: 'assets/images/venues/dos_puntos.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 390,
    capacityPercent: 82,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Jarras de clericot y mojitos 2x1',
    parkingAvailable: false,
    parkingDetails: 'Estacionamientos públicos del Centro',
    latitude: 19.243560963847916,
    longitude: -103.72891897244679,
    instagramHandle: '@dospuntoscerveceria',
    tikTokHandle: '@dospuntoscolima',
    vibeGenre: 'Crossover / Indie / Pop Hits',
    schedule: '6:00 PM - 2:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'el_taurino',
    name: 'El Taurino Cantina Bar',
    category: 'Cantina Tradicional',
    zone: 'Filomeno Medina 12, Obregón, 28000 Colima, Col.',
    description:
        'Cantina tradicional del centro con botanas típicas colimotas al consumir bebidas.',
    coverImageUrl: 'assets/images/venues/el_taurino.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 490,
    capacityPercent: 78,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Trío bohemio tradicional',
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Botanas de la casa incluidas por copeo',
    parkingAvailable: false,
    parkingDetails: 'Estacionamientos públicos cercanos',
    latitude: 19.241001022989938,
    longitude: -103.72426068358524,
    instagramHandle: '@eltaurinocolima',
    tikTokHandle: '@cantinaeltaurino',
    vibeGenre: 'Cantina / Tradicional / Bohemio',
    schedule: '2:00 PM - 1:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'la_puerta_bar',
    name: 'La Puerta Bar Colima',
    category: 'Bar Bohemio & Sessions',
    zone: 'C. 27 de Septiembre 135, Centro, 28000 Colima, Col.',
    description:
        'Espacio nocturno bohemio en el centro con coctelería, mezcales y presentaciones musicales.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1545128485-c400e7702796?auto=format&fit=crop&w=1200&q=80',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 340,
    capacityPercent: 75,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Funk, Reggae & Rock Acústico',
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Mezcal de la casa 2x1',
    parkingAvailable: false,
    parkingDetails: 'Estacionamientos públicos en el centro',
    latitude: 19.24465620515491,
    longitude: -103.72493732805331,
    instagramHandle: '@lapuertabarcolima',
    vibeGenre: 'Bohemio / Reggae / Funk',
    schedule: '7:00 PM - 3:00 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'low_social_club',
    name: 'Low Social Club',
    category: 'Club & Bar',
    zone: 'Calle Miguel Hidalgo 165, Centro, 28000 Colima, Col.',
    description:
        'Club nocturno en el Centro Histórico con música electrónica, coctelería y DJ sets en vivo.',
    coverImageUrl: 'assets/images/venues/low_social_club.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 260,
    capacityPercent: 84,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'DJ Sets en vivo: House & Tech-House',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Estacionamientos públicos del Centro Histórico',
    latitude: 19.241007671540903,
    longitude: -103.72559862649845,
    instagramHandle: '@lowsocialclub',
    tikTokHandle: '@low_colima',
    vibeGenre: 'House / Tech-House / Electrónica',
    schedule: '9:00 PM - 4:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // NUEVOS ESTABLECIMIENTOS CENTRO HISTÓRICO
  const VenueModel(
    id: 'mezcaleria_casa_colima',
    name: 'Casa Colima mezcaleria',
    category: 'Mezcalería & Bar de Autor',
    zone: 'Calle Venustiano Carranza 60, Centro, 28000 Colima, Col.',
    description:
        'Espacio de tradición y mixología artesanal con amplia selección de mezcales y ambiente bohemio.',
    coverImageUrl: 'assets/images/venues/mezcaleria_casa_colima.jpg',
    galleryUrls: [
      'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=800&q=80',
    ],
    rating: 4.9,
    reviewsCount: 310,
    capacityPercent: 81,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Noches de Trova, Son Jarocho y Acústico',
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Degustación de mezcal artesanal con maridaje de sales de Colima',
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento público sobre Venustiano Carranza y Centro',
    latitude: 19.244704192799993,
    longitude: -103.72786144335059,
    instagramHandle: '@casa.colima.mezcaleria',
    tikTokHandle: '@casacolimamezcal',
    facebookUrl: 'https://facebook.com/casacolimamezcaleria',
    vibeGenre: 'Mezcal / Acústico / Bohemio',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'los_toros_barra_taurina',
    name: 'Los Toros Barra Taurina',
    category: 'Barra Taurina & Cantina',
    zone: 'Emilio Carranza #164, Centro, 28000 Colima, Col.',
    description:
        'Barra tradicional con ambiente taurino, botanas de cantina y tragos clásicos en el Centro de Colima.',
    coverImageUrl: 'assets/images/venues/los_toros_barra_taurina.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 275,
    capacityPercent: 78,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Tequila tradicional y botanas botaneras de cortesía por consumo',
    parkingAvailable: false,
    parkingDetails: 'Cajones sobre calle Emilio Carranza y estacionamiento cercano',
    latitude: 19.24266787069572,
    longitude: -103.722301619548,
    instagramHandle: '@lostorosbarrataurina',
    tikTokHandle: '@lostorosbarrataurina',
    facebookUrl: 'https://facebook.com/lostorosbarrataurina',
    vibeGenre: 'Cantina / Taurino / Tradicional',
    schedule: '2:00 PM - 1:30 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // --- LOCALES SANDOVAL ---
  const VenueModel(
    id: 'almada_cantina',
    name: 'Almada Cantina Fina',
    category: 'Cantina Contemporánea',
    zone: 'Calle Ignacio Sandoval 1906-Loc 4-5, Las Pergolas, 28018 Colima, Col.',
    description:
        'Cantina con ambiente animado, cocina mexicana, mixología y música para cantar con amigos.',
    coverImageUrl: 'assets/images/venues/almada_cantina.jpg',
    galleryUrls: [],
    rating: 4.9,
    reviewsCount: 520,
    capacityPercent: 89,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Mariachi y show en vivo',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Valet parking sobre Ignacio Sandoval',
    latitude: 19.261512414791067,
    longitude: -103.70514769214344,
    instagramHandle: '@almadacantina_colima',
    tikTokHandle: '@almadacantina',
    facebookUrl: 'https://facebook.com/almadacantinafina',
    vibeGenre: 'Cantina / Regional / Fiesta',
    schedule: '4:00 PM - 3:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'el_gustito',
    name: 'El Gustito',
    category: 'Botanero & Cervecería',
    zone: 'C. Ignacio Sandoval 1866, Lomas Vista Hermosa, 28017 Colima, Col.',
    description:
        'Botanero tradicional con variedad de platillos incluidos en cada ronda y micheladas preparadas.',
    coverImageUrl: 'assets/images/venues/el_gustito.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 610,
    capacityPercent: 84,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Cerveza preparada con botana incluida a \$65',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento contiguo vigilado',
    latitude: 19.260107816881263,
    longitude: -103.70606657716623,
    instagramHandle: '@elgustito_vdea',
    vibeGenre: 'Botanero / Cumbia / Crossover',
    schedule: '2:00 PM - 2:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // --- OTROS LOCALES CONURBADOS ---
  const VenueModel(
    id: 'la_regional',
    name: 'La Regional',
    category: 'Cantina & Bar Mexicano',
    zone: 'Calle Ignacio Sandoval 1866, Real Vista Hermosa, 28000 Colima, Col.',
    description:
        'Bar y cantina festiva con antojitos, cantaritos de tequila y música regional mexicana.',
    coverImageUrl: 'assets/images/venues/la_regional.jpg',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 370,
    capacityPercent: 81,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Banda sinaloense en vivo',
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Cantaritos de 2 litros 2x1',
    parkingAvailable: true,
    parkingDetails: 'Cajones sobre lateral de avenida',
    latitude: 19.259922574313567,
    longitude: -103.70621318205616,
    instagramHandle: '@laregional_colima',
    tikTokHandle: '@laregionalbar',
    vibeGenre: 'Banda / Regional Mexicano',
    schedule: '7:00 PM - 3:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'la_chintola',
    name: 'La Chintola Bar',
    category: 'Bar & Coctelería',
    zone: '28010, Felipe Sevilla del Río 601, José María Morelos, 28000 Colima, Col.',
    description:
        'Terraza relajada para tomar tragos preparados, cócteles de la casa y convivir con amigos.',
    coverImageUrl: 'assets/images/venues/la_chintola.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 310,
    capacityPercent: 76,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Shots de bienvenida a grupos',
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento libre frente al local',
    latitude: 19.249507583722707,
    longitude: -103.70748201887055,
    instagramHandle: '@lachintolabar',
    tikTokHandle: '@lachintola_colima',
    vibeGenre: 'Reggaetón / Urbano / Latino',
    schedule: '7:30 PM - 3:00 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'santo_mezcal',
    name: 'Santo Mezcal',
    category: 'Mezcalería & Bar',
    zone: 'Av. Constitución 1999, Lomas Verdes, 28017 Colima, Col.',
    description:
        'Bar especializado en mixología con mezcales artesanales y ambiente musical contemporáneo.',
    coverImageUrl: 'assets/images/venues/santo_mezcal.jpg',
    galleryUrls: [],
    rating: 4.9,
    reviewsCount: 295,
    capacityPercent: 82,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Degustación de mezcales artesanales 20% off',
    parkingAvailable: true,
    parkingDetails: 'Valet parking sobre Constitución',
    latitude: 19.264627212083123,
    longitude: -103.71129970420515,
    instagramHandle: '@santomezcal_colima',
    tikTokHandle: '@santomezcalmx',
    vibeGenre: 'Deep House / Nu-Disco / Mezcal',
    schedule: '8:00 PM - 3:30 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'taverna_ny',
    name: 'Taverna New York Style Pizza',
    category: 'NY Pizza & Taproom',
    zone: 'Av. Venustiano Carranza 1310, Residencial Santa Bárbara, Colima',
    description:
        'Pizzas estilo neoyorquino por rebanada acompañadas de cervezas artesanales en terraza.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 440,
    capacityPercent: 76,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: true,
    promoHeadline: 'Rebanada grande + cerveza artesanal por \$99',
    parkingAvailable: true,
    parkingDetails: 'Cajones al frente de plaza comercial',
    latitude: 19.2720,
    longitude: -103.7185,
    instagramHandle: '@tavernanypizza',
    tikTokHandle: '@tavernacolima',
    vibeGenre: 'Indie / Hip-Hop 90s',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
];

class VenuesNotifier extends StateNotifier<List<VenueModel>> {
  VenuesNotifier() : super(_initialVenues);

  void updateCapacity(String venueId, int newCapacity) {
    state = state.map((v) {
      if (v.id == venueId) {
        return v.copyWith(capacityPercent: newCapacity.clamp(0, 100));
      }
      return v;
    }).toList();
    _recalculateHotSpot();
  }

  void toggleLiveMusic(String venueId) {
    state = state.map((v) {
      if (v.id == venueId) {
        return v.copyWith(hasLiveMusic: !v.hasLiveMusic);
      }
      return v;
    }).toList();
  }

  void togglePromo(String venueId) {
    state = state.map((v) {
      if (v.id == venueId) {
        return v.copyWith(hasPromo: !v.hasPromo);
      }
      return v;
    }).toList();
  }

  void toggleVip(String venueId) {
    state = state.map((v) {
      if (v.id == venueId) {
        return v.copyWith(isVipPresent: !v.isVipPresent);
      }
      return v;
    }).toList();
  }

  /// Simulación del algoritmo de consenso de incidentes con filtro anti-difamación y 4 categorías
  String submitIncidentReport({
    required String venueId,
    required String incidentType, // 'brawl', 'weapon', 'slow_service', 'other'
    required String rawText,
  }) {
    // 1. Filtro anti-difamación: Neutraliza menciones a personas específicas o insultos difamatorios
    String sanitized = rawText.trim();
    final forbiddenPatterns = [
      RegExp(r'\b(el dueño|la dueña|el cadenero|el mesero|el cantinero|juan|carlos|pedro|luis|maria|roba|droga|clona|ratero)\b', caseSensitive: false),
    ];
    bool wasSanitized = false;
    for (final pattern in forbiddenPatterns) {
      if (pattern.hasMatch(sanitized)) {
        sanitized = '[Detalle omitido por filtro de moderación y prevención de difamación]';
        wasSanitized = true;
        break;
      }
    }

    // 2. Aplicación de reglas según tipo de reporte
    state = state.map((v) {
      if (v.id == venueId) {
        final newCount = v.activeIncidentReportsCount + 1;
        String newStatus = v.securityStatus;

        if (incidentType == 'weapon') {
          // Máxima severidad: 2 reportes activan alerta roja
          if (newCount >= 2) {
            newStatus = 'active_alert';
          } else {
            newStatus = 'under_review';
          }
        } else if (incidentType == 'brawl') {
          // Riña o pelea: Requiere cuórum de 3 reportes
          if (newCount >= 3) {
            newStatus = 'active_alert';
          } else {
            newStatus = 'under_review';
          }
        }
        // Si es 'slow_service' o 'other', no activa alerta violenta de seguridad
        return v.copyWith(
          activeIncidentReportsCount: newCount,
          securityStatus: newStatus,
          lastIncidentType: incidentType,
          lastReportNote: sanitized.isNotEmpty ? sanitized : null,
        );
      }
      return v;
    }).toList();

    if (incidentType == 'weapon') {
      return wasSanitized ? '$sanitized (Reporte de seguridad prioritario)' : 'Reporte de seguridad registrado.';
    } else if (incidentType == 'brawl') {
      return wasSanitized ? sanitized : 'Reporte de altercado registrado anónimamente.';
    } else if (incidentType == 'slow_service') {
      return 'Nota de servicio registrada para la comunidad.';
    } else {
      return wasSanitized ? sanitized : 'Nota registrada: "$sanitized"';
    }
  }

  void resetIncident(String venueId) {
    state = state.map((v) {
      if (v.id == venueId) {
        return v.copyWith(
          securityStatus: 'normal',
          activeIncidentReportsCount: 0,
        );
      }
      return v;
    }).toList();
  }

  void _recalculateHotSpot() {
    if (state.isEmpty) return;
    final activeVenues = state.where((v) => !v.isPermanentlyClosed).toList();
    if (activeVenues.isEmpty) return;
    final maxCapacityVenue = activeVenues.reduce((a, b) => a.capacityPercent > b.capacityPercent ? a : b);
    state = state.map((v) {
      if (v.isPermanentlyClosed) {
        return v.copyWith(isHotRightNow: false);
      }
      final isMax = v.id == maxCapacityVenue.id && v.capacityPercent >= 75;
      return v.copyWith(
        isHotRightNow: isMax,
        hotReason: isMax ? '🔥 Mayor afluencia de la noche (${v.capacityPercent}%)' : null,
      );
    }).toList();
  }
}

// Provider de Establecimientos Reactivo (Permite simular cambios de aforo en caliente)
final mockVenuesProvider = StateNotifierProvider<VenuesNotifier, List<VenueModel>>((ref) {
  return VenuesNotifier();
});

// Estado de Búsqueda
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtro de Chips seleccionado
final selectedFilterChipProvider =
    StateProvider<VenueFilterChip>((ref) => VenueFilterChip.all);

// Antro seleccionado actualmente para la vista de detalle y mapa
final selectedVenueProvider = StateProvider<VenueModel?>((ref) {
  final venues = ref.watch(mockVenuesProvider);
  return venues.isNotEmpty ? venues.first : null;
});

// Venue "Hot Right Now" (destacado por mayor aforo o evento top)
final hotRightNowVenueProvider = Provider<VenueModel?>((ref) {
  final venues = ref.watch(mockVenuesProvider);
  try {
    return venues.firstWhere((v) => v.isHotRightNow);
  } catch (_) {
    return venues.isNotEmpty ? venues.first : null;
  }
});

// Lista filtrada en tiempo real
final filteredVenuesProvider = Provider<List<VenueModel>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final activeChip = ref.watch(selectedFilterChipProvider);
  final allVenues = ref.watch(mockVenuesProvider);

  return allVenues.where((venue) {
    // Filtro por texto
    final matchesQuery = query.isEmpty ||
        venue.name.toLowerCase().contains(query) ||
        venue.category.toLowerCase().contains(query) ||
        venue.zone.toLowerCase().contains(query) ||
        venue.vibeGenre.toLowerCase().contains(query);

    if (!matchesQuery) return false;

    // Filtro por Chips
    switch (activeChip) {
      case VenueFilterChip.all:
        return true;
      case VenueFilterChip.liveMusic:
        return venue.hasLiveMusic;
      case VenueFilterChip.promos:
        return venue.hasPromo;
      case VenueFilterChip.parking:
        return venue.parkingAvailable;
      case VenueFilterChip.highCapacity:
        return venue.capacityPercent >= 80;
      case VenueFilterChip.vip:
        return venue.isVipPresent;
    }
  }).toList();
});
