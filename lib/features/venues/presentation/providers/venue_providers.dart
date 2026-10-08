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
    zone: 'Ignacio Sandoval 1943, Paseo de la Cantera, Colima',
    description:
        'Club nocturno sobre Ignacio Sandoval con DJ sets, audio envolvente y coctelería.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2631,
    longitude: -103.7043,
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
    zone: 'Tercer Anillo Periférico, Colima',
    description:
        'Cervezas artesanales de barril, comida casual y amplia terraza al aire libre sobre Tercer Anillo.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2828,
    longitude: -103.7325,
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
    name: 'Cervecería de la Costa - San Fernando',
    category: 'Taproom Cervecero',
    zone: 'Av. San Fernando / Sevilla del Río, Colima',
    description:
        'Taproom cervecero con selección fresca de IPAs de la casa y ambiente relajado para precopeo.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2522,
    longitude: -103.7206,
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
    name: 'Cervecería de la Costa - Ignacio Sandoval',
    category: 'Taproom & Jardín',
    zone: 'Av. Ignacio Sandoval, Colima',
    description:
        'Sucursal sobre el corredor gastronómico de Sandoval con cocina urbana y cervezas frías.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1575444758702-4a6b9222336e?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2605,
    longitude: -103.7064,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Craft Beer / Indie',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_pablo_silva',
    name: 'Cervecería de la Costa - Pablo Silva',
    category: 'Taproom & Terraza',
    zone: 'Av. Pablo Silva García, Villa de Álvarez',
    description:
        'Punto cervecero en Villa de Álvarez ideal para reunirse con amigos toda la semana.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2664,
    longitude: -103.7491,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Indie Beats / Chill Out',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_carranza',
    name: 'Cervecería de la Costa - Carranza',
    category: 'Taproom & Terraza',
    zone: 'Av. Venustiano Carranza, Colima',
    description:
        'Terraza cervecera sobre el norte de la ciudad con cervezas artesanales y platillos para compartir.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2800,
    longitude: -103.7124,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Rock Clásico / Pop en inglés',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_la_paz',
    name: 'Cervecería de la Costa - La Paz',
    category: 'Taproom & Cocina',
    zone: 'Av. La Paz, Colima',
    description:
        'Espacio cervecero íntimo con ambiente fresco, cocina al grill y cervezas de temporada.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2674,
    longitude: -103.7170,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Acoustic & Indie',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_griselda_alvarez',
    name: 'Cervecería de la Costa - Griselda Álvarez',
    category: 'Taproom Cervecero',
    zone: 'Av. Griselda Álvarez, Villa de Álvarez',
    description:
        'Sucursal en Villa de Álvarez con terraza abierta, barra de barriles frescos y snacks botaneros.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2750,
    longitude: -103.7510,
    instagramHandle: '@cerveceriadelacosta',
    vibeGenre: 'Pop / Crossover',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 10,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'costa_santa_fe',
    name: 'Cervecería de la Costa - Santa Fe',
    category: 'Taproom & Bar',
    zone: 'Zona Residencial Santa Fe / Norte, Colima',
    description:
        'Taproom en la zona norte con propuesta cervecera artesanal y ambiente tranquilo.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2892,
    longitude: -103.7250,
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
    name: 'Estación Colimita - Andador Centro',
    category: 'Taproom & Cocina de Humo',
    zone: 'Andador Constitución / Centro, Colima',
    description:
        'Cervezas clásicas de la casa servidas de barril junto a cocina de humo en el corazón del Centro.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1575444758702-4a6b9222336e?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2439,
    longitude: -103.7275,
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
    name: 'Estación Colimita - Constitución',
    category: 'Taproom & Jardín Cervecero',
    zone: 'Av. Constitución 1690, Colima',
    description:
        'Jardín cervecero con toda la línea Colimita de barril y propuesta gastronómica contemporánea.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2578,
    longitude: -103.7158,
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
    zone: 'Degollado 28, Centro, Colima',
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
    latitude: 19.2430,
    longitude: -103.7270,
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
    zone: 'Degollado 34, Centro, Colima',
    description:
        'Terraza céntrica con tragos preparados, cervezas y buena música para iniciar la noche.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2432,
    longitude: -103.7272,
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
    zone: 'Filomeno Medina 12, Centro, Colima',
    description:
        'Cantina tradicional del centro con botanas típicas colimotas al consumir bebidas.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2445,
    longitude: -103.7295,
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
    name: 'La Puerta Bar',
    category: 'Bar Bohemio & Sessions',
    zone: '27 de Septiembre 135, Centro, Colima',
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
    latitude: 19.2450,
    longitude: -103.7265,
    instagramHandle: '@lapuertabarcolima',
    vibeGenre: 'Bohemio / Reggae / Funk',
    schedule: '7:00 PM - 3:00 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),
  const VenueModel(
    id: 'low_social_club',
    name: 'Low Social Club (Low)',
    category: 'Club & Bar',
    zone: 'Calle Miguel Hidalgo 165, Centro, Colima',
    description:
        'Club nocturno en el Centro Histórico con música electrónica, coctelería y DJ sets en vivo.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2410,
    longitude: -103.7256,
    instagramHandle: '@lowsocialclub',
    tikTokHandle: '@low_colima',
    vibeGenre: 'House / Tech-House / Electrónica',
    schedule: '9:00 PM - 4:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
  ),

  // --- LOCALES SANDOVAL ---
  const VenueModel(
    id: 'almada_cantina',
    name: 'Almada Cantina',
    category: 'Cantina Contemporánea',
    zone: 'Ignacio Sandoval 1906, Colima',
    description:
        'Cantina con ambiente animado, cocina mexicana, mixología y música para cantar con amigos.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2625,
    longitude: -103.7048,
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
    zone: 'Ignacio Sandoval 1866, Colima',
    description:
        'Botanero tradicional con variedad de platillos incluidos en cada ronda y micheladas preparadas.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2618,
    longitude: -103.7055,
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
    zone: 'Av. Felipe Sevilla del Río 534, Colima',
    description:
        'Bar y cantina festiva con antojitos, cantaritos de tequila y música regional mexicana.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2542,
    longitude: -103.7180,
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
    zone: 'Blvd. Camino Real, Colima',
    description:
        'Terraza relajada sobre Camino Real para tomar tragos preparados y convivir con amigos.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1574096079513-d8259312b785?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2460,
    longitude: -103.7100,
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
    zone: 'Av. Constitución 1999, Colima',
    description:
        'Bar especializado en mixología con mezcales artesanales y ambiente musical contemporáneo.',
    coverImageUrl:
        'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=1200&q=80',
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
    latitude: 19.2615,
    longitude: -103.7120,
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
    zone: 'Av. Venustiano Carranza 1310, Colima',
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
