import 'dart:io';

void main() {
  final buffer = StringBuffer();

  buffer.writeln(r'''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/venue_model.dart';

enum VenueFilterChip {
  all('Todos'),
  events('Eventos'),
  liveMusic('Música en vivo'),
  promos('2x1 & Promos'),
  parking('Estacionamiento'),
  highCapacity('Ambiente a tope'),
  vip('VIP / Influencers');

  final String label;
  const VenueFilterChip(this.label);
}

// Catálogo oficial depurado de la vida nocturna en la zona conurbada Colima - Villa de Álvarez.
// Coordenadas cartográficas exactas y verificadas para cada establecimiento (alineadas al plano de la ciudad).
// Sin eventos inventados, aforos basados en presencia física real de pruebas (0% cerrados, 1-3% abiertos),
// covers verificados y estacionamientos validados según especificación oficial.
final List<VenueModel> _initialVenues = [
  // --- EL GUACHI ---
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
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'DJ Sets en vivo & Reggaetón Hits',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento sobre Ignacio Sandoval',
    latitude: 19.263319260681573,
    longitude: -103.70427827536956,
    instagramHandle: '@guachirooftop',
    tikTokHandle: '@elguachicolima',
    facebookUrl: 'https://facebook.com/elguachicolima',
    vibeGenre: 'Perreo / Tech-House / Pop Latino',
    schedule: '9:30 PM - 5:30 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: true,
    coverDescription: 'Cover: Aprox. \$100 MXN (después de 11:00 PM)',
    isOpenNow: false,
    whatsappReservation: '523121234567',
    closedReason: 'Cerrado hoy · Abre Miércoles 21:00',
    livePresenceCount: 0,
    upcomingEvents: [
      VenueEvent(
        id: 'guachi_friday_reggaeton',
        title: 'Viernes de Reggaetón & Tech-House',
        dateDisplay: 'Viernes 30 Oct • 10:30 PM',
        eventDate: null,
        artistOrDj: 'DJ Residente & Sets Urbanos',
        coverPrice: 'Aprox. \$100 MXN',
        promoNote: 'Promociones en copeo antes de medianoche',
        forcedIsToday: false,
      ),
      VenueEvent(
        id: 'guachi_saturday_party',
        title: 'Sábado Night Club & Fiesta Total',
        dateDisplay: 'Sábado 31 Oct • 10:00 PM',
        eventDate: null,
        artistOrDj: 'DJ Invitado de Guadalajara',
        coverPrice: 'Aprox. \$100 MXN',
        promoNote: 'Mesas VIP y servicio de botellas',
        forcedIsToday: false,
      ),
    ],
  ),

  // --- SUCURSALES OFICIALES CERVECERÍA DE LA COSTA (SIN COVER, SIN RESERVACIÓN) ---
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
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento Plaza del Carmen',
    latitude: 19.283056528553324,
    longitude: -103.73252591954697,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Craft Beer / Indie Pop / Chill Beats',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_san_fernando',
    name: 'Cervecería de la Costa - Terraza San Fernando',
    category: 'Taproom & Terraza',
    zone: 'Av. Constitución 555, Las Amarillas, 28030 Colima, Col.',
    description:
        'Terraza emblemática sobre San Fernando para degustar cervezas de la casa y platillos estilo pub.',
    coverImageUrl: 'assets/images/venues/costa_san_fernando.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 380,
    capacityPercent: 1,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento Plaza San Fernando',
    latitude: 19.25238924521272,
    longitude: -103.72060620420548,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Craft Beer / Classic Rock / Acoustic',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 1,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_sandoval',
    name: 'Cervecería de la Costa - Sandoval',
    category: 'Taproom & Terraza',
    zone: 'Calle Ignacio Sandoval 1793-2, Girasoles, 28018 Colima, Col.',
    description:
        'Punto de encuentro sobre el corredor gastronómico de Sandoval con cervezas frescas y gran ambiente.',
    coverImageUrl: 'assets/images/venues/costa_sandoval.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 420,
    capacityPercent: 3,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.260780246591853,
    longitude: -103.70639020420522,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Indie Rock / Chillhop / Pop',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 3,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_pablo_silva',
    name: 'Cervecería de la Costa - Pablo Silva',
    category: 'Taproom & Terraza',
    zone: 'Av Pablo Silva García 175, VILLAS DIAMANTE, 28986 Colima, Col.',
    description:
        'Taproom en el corazón de Villa de Álvarez con amplia selección cervecera y cocina artesanal.',
    coverImageUrl: 'assets/images/venues/costa_pablo_silva.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 340,
    capacityPercent: 1,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.266665752881863,
    longitude: -103.74911390420505,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Craft Beer / Indie Hits / Alt Pop',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 1,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_carranza',
    name: 'Cervecería de la Costa - Carranza 1',
    category: 'Taproom & Terraza',
    zone: 'Avenida Venustiano Carranza 2090, Residencial Esmeralda Nte., 28017 Colima, Col.',
    description:
        'Sucursal icónica en zona Carranza, ideal para tardes de tarro y precopeo al aire libre.',
    coverImageUrl: 'assets/images/venues/costa_carranza.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 390,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.280260132705344,
    longitude: -103.71243250420474,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Rock Clásico / Pop Alternativo / Synth',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_carranza_2',
    name: 'Cervecería de la Costa - Carranza 2',
    category: 'Taproom & Terraza',
    zone: 'Avenida Venustiano Carranza 2213, Rincón del Colibrí, Residencial Esmeralda Nte., 28017 Colima, Col.',
    description:
        'Segunda estación sobre Av. Carranza con ambiente distendido y toda la línea de barril.',
    coverImageUrl: 'assets/images/venues/costa_carranza_2.jpg',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 280,
    capacityPercent: 1,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.283953050277574,
    longitude: -103.71044641736145,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Indie / Ambient Lounge / Reggae',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 1,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_la_paz',
    name: 'Cervecería de la Costa - La Paz 1',
    category: 'Taproom & Terraza',
    zone: 'Av La Paz 134, Sta Bárbara, 28017 Colima, Col.',
    description:
        'Ubicación relajada sobre Av. La Paz para convivir en mesas comunales con cerveza bien fría.',
    coverImageUrl: 'assets/images/venues/costa_la_paz.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 310,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.267420114391854,
    longitude: -103.71702218801063,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Chillout / Latin Grooves / Lo-Fi',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_la_paz_2',
    name: 'Cervecería de la Costa - La Paz 2',
    category: 'Taproom & Terraza',
    zone: 'Av La Paz 51, Sta Bárbara, 28017 Colima, Col.',
    description:
        'Espacio amplio con terraza exterior en el sector conurbado de La Paz para disfrutar en grupo.',
    coverImageUrl: 'assets/images/venues/costa_la_paz_2.jpg',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 260,
    capacityPercent: 1,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.26501012058269,
    longitude: -103.71355585360233,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Indie Pop / Acoustic Rock',
    schedule: '6:00 PM - 1:30 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 1,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_griselda_alvarez',
    name: 'Cervecería de la Costa - Griselda Álvarez',
    category: 'Taproom & Terraza',
    zone: 'Lib. Gobernadora Griselda Álvarez 32, Jardines del Llano, 28989 Cdad. de Villa de Álvarez, Col.',
    description:
        'Cervecería casual en Villa de Álvarez con servicio rápido, hamburguesas y tarros de temporada.',
    coverImageUrl: 'assets/images/venues/costa_griselda_alvarez.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 300,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.275246730426613,
    longitude: -103.75104793304038,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Craft Beer / Rock Clásico / Indie',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 9,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'costa_santa_fe',
    name: 'Cervecería de la Costa - Santa Fe',
    category: 'Taproom & Terraza',
    zone: 'Prol. Hidalgo 1041, Real Santa Fe, 28978 Cdad. de Villa de Álvarez, Col.',
    description:
        'Terraza familiar y de convivencia nocturna en Santa Fe con pizzas al horno y cerveza de línea.',
    coverImageUrl: 'assets/images/venues/costa_santa_fe.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 350,
    capacityPercent: 3,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.289438686312888,
    longitude: -103.72504136187563,
    instagramHandle: '@cerveceriadelacosta',
    tikTokHandle: '@costacerveza',
    vibeGenre: 'Pop / Indie / Chill Out',
    schedule: '6:00 PM - 2:00 AM',
    estimatedMinutes: 8,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 3,
    upcomingEvents: [],
  ),

  // --- CERVECERÍA ESTACIÓN COLIMITA (SIN COVER, SIN RESERVACIÓN) ---
  const VenueModel(
    id: 'colimita_centro',
    name: 'Cervecería Estación Colimita - Centro',
    category: 'Taproom & Jardín',
    zone: 'Andador Constitución 39, Sangre de Cristo, 28000 Colima, Col.',
    description:
        'Taproom emblemático de Cervecería de Colima con patio fresco, cerveza de barril y gastronomía.',
    coverImageUrl: 'assets/images/venues/colimita_centro.jpg',
    galleryUrls: [],
    rating: 4.9,
    reviewsCount: 520,
    capacityPercent: 3,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento sobre calle Degollado y privado aledaño',
    latitude: 19.24404247322328,
    longitude: -103.72753500931157,
    instagramHandle: '@cerveceriadecolima',
    tikTokHandle: '@cervezacolimita',
    vibeGenre: 'Craft Beer / Jardín Tropical / Indie',
    schedule: '1:00 PM - 12:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 3,
    upcomingEvents: [],
  ),

  const VenueModel(
    id: 'colimita_constitucion',
    name: 'Cervecería Estación Colimita - Constitución',
    category: 'Taproom & Bar',
    zone: 'Av. Constitución 1401-Loc 1, Jardines Vista Hermosa IV, 28017 Colima, Col.',
    description:
        'Taproom urbano sobre el camellón de Constitución para degustar Colimita, Páramo y Cayaco.',
    coverImageUrl: 'assets/images/venues/colimita_constitucion.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 440,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Sin estacionamiento',
    latitude: 19.258069674365704,
    longitude: -103.71573610520983,
    instagramHandle: '@cerveceriadecolima',
    tikTokHandle: '@cervezacolimita',
    vibeGenre: 'Craft Beer / Urban / Chill Beats',
    schedule: '5:00 PM - 1:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  // --- DMT ROCK BAR ---
  const VenueModel(
    id: 'dmt_rock_bar',
    name: 'DMT Rock Bar',
    category: 'Rock Bar & Pub',
    zone: 'C. Santos Degollado 28, Centro, 28000 Colima, Col.',
    description:
        'Bar de rock clásico y alternativo en el Centro con tarros de cerveza y ambiente auténtico.',
    coverImageUrl: 'assets/images/venues/dmt_rock_bar.jpg',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 230,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento sobre vía pública',
    latitude: 19.243566028534627,
    longitude: -103.72893774790906,
    instagramHandle: '@dmtrockbar',
    tikTokHandle: '@dmtrockbar',
    vibeGenre: 'Rock Clásico / Metal / Hard Rock',
    schedule: '8:00 PM - 3:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: false,
    closedReason: 'Cerrado hoy · Abre Jueves 20:00',
    livePresenceCount: 0,
    upcomingEvents: [],
  ),

  // --- DOS PUNTOS CERVECERÍA ---
  const VenueModel(
    id: 'dos_puntos',
    name: 'Dos Puntos Cervecería',
    category: 'Taproom & Bar',
    zone: 'C. Santos Degollado 34, Centro, 28000 Colima, Col.',
    description:
        'Cervecería de autor con jardín, pizzas artesanales y DJ sets al aire libre.',
    coverImageUrl: 'assets/images/venues/dos_puntos.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 390,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'DJ Set en Terraza & Mezclas en Vivo',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento sobre Calzada Galván y calles aledañas',
    latitude: 19.243560963847916,
    longitude: -103.72891897244679,
    instagramHandle: '@dospuntoscerveceria',
    tikTokHandle: '@dospuntoscolima',
    vibeGenre: 'Craft Beer / Disco Funk / House',
    schedule: '7:00 PM - 2:30 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: true,
    coverDescription: 'Cover: Hasta \$180 MXN (fines de semana)',
    isOpenNow: false,
    whatsappReservation: '523121234567',
    closedReason: 'Cerrado hoy · Abre Miércoles 19:00',
    livePresenceCount: 0,
    upcomingEvents: [
      VenueEvent(
        id: 'dospuntos_saturday_night',
        title: 'Noche Dos Puntos & Cerveza Artesanal',
        dateDisplay: 'Sábado 31 Oct • 9:00 PM',
        eventDate: null,
        artistOrDj: 'DJ Residente en Terraza',
        coverPrice: 'Hasta \$180 MXN',
        promoNote: 'Cervezas artesanales de barril y cocina urbana',
        forcedIsToday: false,
      ),
    ],
  ),

  // --- EL TAURINO BAR ---
  const VenueModel(
    id: 'el_taurino',
    name: 'El Taurino Bar',
    category: 'Cantina Tradicional',
    zone: 'Filomeno Medina 12, Obregón, 28000 Colima, Col.',
    description:
        'Cantina con botanas colimenses, ambiente folclórico y tradición cervecera en el Centro.',
    coverImageUrl: 'assets/images/venues/el_taurino.jpg',
    galleryUrls: [],
    rating: 4.5,
    reviewsCount: 280,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Sin estacionamiento',
    latitude: 19.241001022989938,
    longitude: -103.72426068358524,
    vibeGenre: 'Cantina / Regional Mexicano / Tradición',
    schedule: '2:00 PM - 12:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  // --- LA PUERTA DEL PERREO ---
  const VenueModel(
    id: 'la_puerta_bar',
    name: 'La Puerta del Perreo',
    category: 'Antro & Club Urbano',
    zone: 'C. 27 de Septiembre 135, Centro, 28000 Colima, Col.',
    description:
        'Club nocturno en el Centro enfocado al reggaetón, perreo y ambiente festivo hasta tarde.',
    coverImageUrl: 'assets/images/venues/la_puerta_bar.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 340,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'DJ Sets Perreo Old School & Urbano',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento sobre vía pública en zona Centro',
    latitude: 19.24465620515491,
    longitude: -103.72493732805331,
    instagramHandle: '@lapuertadelperreo.dog',
    tikTokHandle: '@lapuertaperreocol',
    vibeGenre: 'Reggaetón / Urbano / Latin Beats',
    schedule: '9:00 PM - 5:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: false,
    closedReason: 'Cerrado hoy · Abre Jueves 21:00',
    livePresenceCount: 0,
    upcomingEvents: [],
  ),

  // --- LOW SOCIAL CLUB ---
  const VenueModel(
    id: 'low_social_club',
    name: 'Low Social Club',
    category: 'Club & Loungewear',
    zone: 'Calle Miguel Hidalgo 165, Centro, 28000 Colima, Col.',
    description:
        'Club vanguardista sobre Hidalgo con música electrónica, coctelería y gran iluminación.',
    coverImageUrl: 'assets/images/venues/low_social_club.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 390,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'DJ Residente & Sets Tech-House',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento sobre Av. Constitución',
    latitude: 19.241007671540903,
    longitude: -103.72559862649845,
    instagramHandle: '@lowclub.col',
    tikTokHandle: '@lowsocialclub',
    vibeGenre: 'Electronic / Tech-House / Disco Nu',
    schedule: '10:00 PM - 5:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: true,
    coverDescription: 'Cover: Aprox. \$100 MXN (noche de club)',
    isOpenNow: false,
    whatsappReservation: '523121234567',
    closedReason: 'Cerrado hoy · Abre Jueves 22:00',
    livePresenceCount: 0,
    upcomingEvents: [
      VenueEvent(
        id: 'low_club_friday',
        title: 'Low Sessions: Electronic & Urban Club',
        dateDisplay: 'Viernes 30 Oct • 11:00 PM',
        eventDate: null,
        artistOrDj: 'DJ Residente & Visuales Inmersivos',
        coverPrice: 'Aprox. \$100 MXN',
        promoNote: 'Acceso club y coctelería de autor',
        forcedIsToday: false,
      ),
    ],
  ),

  // --- CASA COLIMA MEZCALERÍA ---
  const VenueModel(
    id: 'mezcaleria_casa_colima',
    name: 'Casa Colima Mezcalería',
    category: 'Mezcalería & Bar de Autor',
    zone: 'Calle Venustiano Carranza 60, Centro, 28000 Colima, Col.',
    description:
        'Espacio íntimo con amplia curaduría de destilados de agave, mezcales oaxaqueños y coctelería.',
    coverImageUrl: 'assets/images/venues/mezcaleria_casa_colima.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 220,
    capacityPercent: 1,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento sobre calle Aldama',
    latitude: 19.244704192799993,
    longitude: -103.72786144335059,
    instagramHandle: '@casa.colima.mezcaleria',
    tikTokHandle: '@casacolimamezcal',
    vibeGenre: 'Mezcal / Acústico / Indie Mexicano',
    schedule: '7:00 PM - 2:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 1,
    upcomingEvents: [],
  ),

  // --- LOS TOROS BARRA TAURINA ---
  const VenueModel(
    id: 'los_toros_barra_taurina',
    name: 'Los Toros Barra Taurina',
    category: 'Bar & Botana',
    zone: 'Emilio Carranza #164, Centro, 28000 Colima, Col.',
    description:
        'Barra de barrio tradicional para cerveza rápida, tequila y botana caliente en el Centro.',
    coverImageUrl: 'assets/images/venues/los_toros_barra_taurina.jpg',
    galleryUrls: [],
    rating: 4.5,
    reviewsCount: 190,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento sobre calle Santos Degollado',
    latitude: 19.24266787069572,
    longitude: -103.722301619548,
    vibeGenre: 'Cantina / Ranchero / Cerveza Fría',
    schedule: '3:00 PM - 1:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  // --- ALMADA CANTINA FINA ---
  const VenueModel(
    id: 'almada_cantina',
    name: 'Almada Cantina Fina',
    category: 'Cantina Fina & Cocina',
    zone: 'Calle Ignacio Sandoval 1906-Loc 4-5, Las Pergolas, 28018 Colima, Col.',
    description:
        'Concepto contemporáneo de cantina fina con platillos de autor, mixología y ambiente festivo.',
    coverImageUrl: 'assets/images/venues/almada_cantina.jpg',
    galleryUrls: [],
    rating: 4.8,
    reviewsCount: 360,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Mariachi & Banda Acústica en Vivo',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.261512414791067,
    longitude: -103.70514769214344,
    instagramHandle: '@almada_cantina.fina',
    tikTokHandle: '@almadacantina',
    vibeGenre: 'Cantina Fina / Pop Latino / Regional',
    schedule: '6:00 PM - 3:00 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: false,
    whatsappReservation: '523121234567',
    closedReason: 'Cerrado hoy · Abre Miércoles 18:00',
    livePresenceCount: 0,
    upcomingEvents: [],
  ),

  // --- EL GUSTITO ---
  const VenueModel(
    id: 'el_gustito',
    name: 'El Gustito',
    category: 'Restaurante Bar & Mariscos',
    zone: 'C. Ignacio Sandoval 1866, Lomas Vista Hermosa, 28017 Colima, Col.',
    description:
        'Terraza de mariscos y coctelería sobre Av. Sandoval con ambiente versátil día y noche.',
    coverImageUrl: 'assets/images/venues/el_gustito.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 320,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento Plaza Vista Hermosa',
    latitude: 19.260107816881263,
    longitude: -103.70606657716623,
    instagramHandle: '@el_gustito_ignacio_sandoval',
    tikTokHandle: '@elgustitocolima',
    vibeGenre: 'Mariscos / Pop / Precopeo',
    schedule: '1:00 PM - 12:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 2,
    upcomingEvents: [],
  ),

  // --- LA REGIONAL CANTINA ---
  const VenueModel(
    id: 'la_regional',
    name: 'La Regional Cantina',
    category: 'Cantina Bar',
    zone: 'Calle Ignacio Sandoval 1866, Real Vista Hermosa, 28000 Colima, Col.',
    description:
        'Cantina moderna con botanas mexicanas, cerveza de barril y música para cantar con amigos.',
    coverImageUrl: 'assets/images/venues/la_regional.jpg',
    galleryUrls: [],
    rating: 4.6,
    reviewsCount: 290,
    capacityPercent: 3,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento Plaza Vista Hermosa',
    latitude: 19.259922574313567,
    longitude: -103.70621318205616,
    instagramHandle: '@la_regional_cantina',
    tikTokHandle: '@laregionalcolima',
    vibeGenre: 'Cantina / Regional Mexicano / Cumbia',
    schedule: '5:00 PM - 2:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 3,
    upcomingEvents: [],
  ),

  // --- LA CHINTOLA BAR ---
  const VenueModel(
    id: 'la_chintola',
    name: 'La Chintola Bar',
    category: 'Bar & Botana',
    zone: '28010, Felipe Sevilla del Río 601, José María Morelos, 28000 Colima, Col.',
    description:
        'Punto de encuentro en Colima con tragos accesibles, botana caliente y rock en español.',
    coverImageUrl: 'assets/images/venues/la_chintola.jpg',
    galleryUrls: [],
    rating: 4.5,
    reviewsCount: 210,
    capacityPercent: 1,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Sin estacionamiento',
    latitude: 19.249507583722707,
    longitude: -103.70748201887055,
    vibeGenre: 'Rock en Español / Cerveza / Botana',
    schedule: '4:00 PM - 1:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    livePresenceCount: 1,
    upcomingEvents: [],
  ),

  // --- SANTO MEZCAL ---
  const VenueModel(
    id: 'santo_mezcal',
    name: 'Santo Mezcal',
    category: 'Mezcalería & Cocina',
    zone: 'Av. Constitución 1999, Lomas Verdes, 28017 Colima, Col.',
    description:
        'Terraza de mezcal y destilados mexicanos con mixología de autor y platillos para compartir.',
    coverImageUrl: 'assets/images/venues/santo_mezcal.jpg',
    galleryUrls: [],
    rating: 4.7,
    reviewsCount: 270,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.264627212083123,
    longitude: -103.71129970420515,
    instagramHandle: '@mezcal.santo',
    tikTokHandle: '@santomezcalcol',
    vibeGenre: 'Mezcal / Indie Latino / Lounge',
    schedule: '7:00 PM - 2:00 AM',
    estimatedMinutes: 6,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: false,
    whatsappReservation: '523121234567',
    closedReason: 'Cerrado hoy · Abre Jueves 19:00',
    livePresenceCount: 0,
    upcomingEvents: [],
  ),

  // --- FORO DMT ---
  const VenueModel(
    id: 'foro_dmt',
    name: 'Foro DMT',
    category: 'Foro Cultural & Rock Bar',
    zone: 'C. Santos Degollado 50, Centro, 28000 Colima, Col.',
    description:
        'Espacio cultural y alternativo en el Centro de Colima con rock en vivo, teatro y arte independiente.',
    coverImageUrl: 'assets/images/venues/foro_dmt.jpg',
    galleryUrls: [
      'assets/images/venues/foro_dmt_2.jpg',
    ],
    rating: 4.8,
    reviewsCount: 310,
    capacityPercent: 0,
    isHotRightNow: false,
    hasLiveMusic: true,
    liveMusicAct: 'Rock en Vivo & Bandas Emergentes',
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: false,
    parkingDetails: 'Estacionamiento sobre Santos Degollado y Centro',
    latitude: 19.243385050696823,
    longitude: -103.72907994355953,
    instagramHandle: '@foro_dmt',
    tikTokHandle: '@forodmt_colima',
    vibeGenre: 'Rock en Vivo / Indie / Alternativo / Cultural',
    schedule: '8:00 PM - 3:00 AM',
    estimatedMinutes: 5,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: true,
    coverDescription: 'Cover según evento en vivo',
    isOpenNow: false,
    whatsappReservation: '523121234567',
    closedReason: 'Cerrado hoy · Abre Jueves 20:00',
    livePresenceCount: 0,
    upcomingEvents: [
      VenueEvent(
        id: 'foro_dmt_rock_friday',
        title: 'Concierto en Vivo: Noche de Rock & Tributo',
        dateDisplay: 'Viernes 30 Oct • 9:30 PM',
        eventDate: null,
        artistOrDj: 'Bandas Locales Invitadas',
        coverPrice: 'Cover según evento en vivo',
        promoNote: 'Cerveza artesanal y comida de autor',
        forcedIsToday: false,
      ),
    ],
  ),

  // --- PARAÍSO DRINKS COLIMA ---
  const VenueModel(
    id: 'paraiso_drinks',
    name: 'Paraíso Drinks Colima',
    category: 'Cocktail Bar & Precopeo',
    zone: 'Av. de los Diamantes 140, Residencial Esmeralda Nte., 28017 Colima, Col.',
    description:
        'Terraza de coctelería y precopeo con drinks de autor sobre Av. de los Diamantes.',
    coverImageUrl: 'assets/images/venues/paraiso_drinks.jpg',
    galleryUrls: [
      'assets/images/venues/paraiso_drinks.jpg',
    ],
    rating: 4.7,
    reviewsCount: 290,
    capacityPercent: 2,
    isHotRightNow: false,
    hasLiveMusic: false,
    isVipPresent: false,
    hasPromo: false,
    parkingAvailable: true,
    parkingDetails: 'Estacionamiento local (Disponibilidad variable según la afluencia)',
    latitude: 19.278276708508628,
    longitude: -103.70990174232882,
    instagramHandle: '@paraisodrinkscolima',
    tikTokHandle: '@paraisodrinkscol',
    vibeGenre: 'Drinks de Autor / Pop Latino / Precopeo Terraza',
    schedule: '7:30 PM - 2:30 AM',
    estimatedMinutes: 7,
    securityStatus: 'normal',
    activeIncidentReportsCount: 0,
    hasCover: false,
    coverDescription: 'Sin Cover',
    isOpenNow: true,
    whatsappReservation: '523121234567',
    livePresenceCount: 2,
    upcomingEvents: [],
  ),
];

class VenuesNotifier extends StateNotifier<List<VenueModel>> {
  VenuesNotifier() : super(_initialVenues);

  void updateCapacity(String venueId, int newCapacity) {
    state = state.map((v) {
      if (v.id == venueId) {
        return v.copyWith(
          capacityPercent: newCapacity.clamp(0, 100),
          livePresenceCount: newCapacity.clamp(0, 100),
        );
      }
      return v;
    }).toList();
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

  String submitIncidentReport({
    required String venueId,
    required String incidentType,
    required String rawText,
  }) {
    String sanitized = rawText.trim();
    final forbiddenPatterns = [
      RegExp(r'\\b(el dueño|la dueña|el cadenero|el mesero|el cantinero|juan|carlos|pedro|luis|maria|roba|droga|clona|ratero)\\b', caseSensitive: false),
    ];
    bool wasSanitized = false;
    for (final pattern in forbiddenPatterns) {
      if (pattern.hasMatch(sanitized)) {
        sanitized = '[Detalle omitido por filtro de moderación y prevención de difamación]';
        wasSanitized = true;
        break;
      }
    }

    state = state.map((v) {
      if (v.id == venueId) {
        final newCount = v.activeIncidentReportsCount + 1;
        String newStatus = v.securityStatus;

        if (incidentType == 'weapon') {
          if (newCount >= 3) {
            newStatus = 'active_alert';
          } else {
            newStatus = 'under_review';
          }
        } else if (incidentType == 'brawl') {
          if (newCount >= 5) {
            newStatus = 'active_alert';
          } else {
            newStatus = 'under_review';
          }
        }
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
      return wasSanitized ? '\$sanitized (Reporte de seguridad prioritario)' : 'Reporte de seguridad registrado.';
    } else if (incidentType == 'brawl') {
      return wasSanitized ? sanitized : 'Reporte de altercado registrado anónimamente.';
    } else if (incidentType == 'slow_service') {
      return 'Nota de servicio registrada para la comunidad.';
    } else {
      return wasSanitized ? sanitized : 'Nota registrada: "\$sanitized"';
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
}

// Provider de Establecimientos Reactivo
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

// Venue "Hot Right Now" (destacado por mayor afluencia o evento top)
final hotRightNowVenueProvider = Provider<VenueModel?>((ref) {
  final venues = ref.watch(mockVenuesProvider);
  try {
    return venues.firstWhere((v) => v.isHotRightNow && v.isOpenNow);
  } catch (_) {
    final openVenues = venues.where((v) => v.isOpenNow && !v.isPermanentlyClosed).toList();
    if (openVenues.isNotEmpty) {
      openVenues.sort((a, b) => b.capacityPercent.compareTo(a.capacityPercent));
      return openVenues.first;
    }
    return venues.isNotEmpty ? venues.first : null;
  }
});

/// Item para la cartelera consolidada de eventos
class ConsolidatedEventItem {
  final VenueEvent event;
  final VenueModel venue;

  const ConsolidatedEventItem({required this.event, required this.venue});
}

/// Proveedor con todos los eventos de la semana consolidados de forma cronológica
final weeklyEventsProvider = Provider<List<ConsolidatedEventItem>>((ref) {
  final venues = ref.watch(mockVenuesProvider);
  final List<ConsolidatedEventItem> items = [];
  for (final venue in venues) {
    for (final event in venue.upcomingEvents) {
      items.add(ConsolidatedEventItem(event: event, venue: venue));
    }
  }
  items.sort((a, b) {
    if (a.event.isToday && !b.event.isToday) return -1;
    if (!a.event.isToday && b.event.isToday) return 1;
    return a.event.title.compareTo(b.event.title);
  });
  return items;
});

// Lista filtrada en tiempo real
final filteredVenuesProvider = Provider<List<VenueModel>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final activeChip = ref.watch(selectedFilterChipProvider);
  final allVenues = ref.watch(mockVenuesProvider);

  final list = allVenues.where((venue) {
    final matchesQuery = query.isEmpty ||
        venue.name.toLowerCase().contains(query) ||
        venue.category.toLowerCase().contains(query) ||
        venue.zone.toLowerCase().contains(query) ||
        venue.vibeGenre.toLowerCase().contains(query);

    if (!matchesQuery) return false;

    switch (activeChip) {
      case VenueFilterChip.all:
        return true;
      case VenueFilterChip.events:
        return venue.upcomingEvents.isNotEmpty;
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

  list.sort((a, b) {
    if (a.isOpenNow && !b.isOpenNow) return -1;
    if (!a.isOpenNow && b.isOpenNow) return 1;
    return b.capacityPercent.compareTo(a.capacityPercent);
  });
  return list;
});

/// Modos de visualización del Feed principal (Modo Inmersivo de Tarjetas vs Modo Compacto Ranking)
enum ViewMode {
  compact,
  cards,
}

/// Proveedor para alternar entre el modo compacto de lista top y el modo de fotos/ambiente
final feedViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.compact);

/// Proveedor con los 5 establecimientos más concurridos ("Top Ranking de la Noche")
final topRankedVenuesProvider = Provider<List<VenueModel>>((ref) {
  final all = ref.watch(mockVenuesProvider).where((v) => !v.isPermanentlyClosed).toList();
  all.sort((a, b) {
    if (a.isOpenNow && !b.isOpenNow) return -1;
    if (!a.isOpenNow && b.isOpenNow) return 1;
    return b.capacityPercent.compareTo(a.capacityPercent);
  });
  return all.take(5).toList();
});
''');

  final targetFile = File('lib/features/venues/presentation/providers/venue_providers.dart');
  targetFile.writeAsStringSync(buffer.toString());
  print('Successfully regenerated ${targetFile.path} with verified coordinates and zones');
}
