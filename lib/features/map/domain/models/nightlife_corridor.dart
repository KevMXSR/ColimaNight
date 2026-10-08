import '../../../core/constants/colima_geo_constants.dart';

/// Coordenada geodésica simple (Latitud, Longitud)
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      );
}

/// Modelo que representa un corredor nocturno estratégico de la zona conurbada
/// de Colima y Villa de Álvarez.
class NightlifeCorridor {
  final CorridorId id;
  final String name;
  final String municipality; // 'Colima', 'Villa de Álvarez' o 'Conurbado'
  final String description;
  final GeoPoint focalPoint;
  final List<GeoPoint> polylinePoints;
  final List<String> tags;
  final String vibe;
  final double estimatedAverageDrivingSpeedKmH;

  const NightlifeCorridor({
    required this.id,
    required this.name,
    required this.municipality,
    required this.description,
    required this.focalPoint,
    required this.polylinePoints,
    required this.tags,
    required this.vibe,
    this.estimatedAverageDrivingSpeedKmH = 35.0,
  });

  /// Lista oficial de los 6 corredores nocturnos reconfigurados
  static List<NightlifeCorridor> get colimaNightlifeCorridors => [
        // 1. Corredor Ignacio Sandoval
        const NightlifeCorridor(
          id: CorridorId.ignacioSandoval,
          name: 'Corredor Ignacio Sandoval',
          municipality: 'Colima',
          description:
              'Epicentro gastronómico y de cantinas contemporáneas de Colima. Alberga Plaza Las Pérgolas, Paseo de la Cantera, marisquerías nocturnas y cervecerías craft.',
          focalPoint: GeoPoint(19.2625, -103.7045),
          polylinePoints: [
            GeoPoint(19.2520, -103.7190), // Cruce Sevilla del Río
            GeoPoint(19.2575, -103.7110), // Av. Ignacio Sandoval media
            GeoPoint(19.2620, -103.7041), // Zona El Gustito
            GeoPoint(19.2625, -103.7040), // Plaza Las Pérgolas / Almada
            GeoPoint(19.2635, -103.7043), // Paseo de la Cantera / El Guachi
          ],
          tags: ['Cantinas Contemporáneas', 'Craft Beer', 'Las Pérgolas', 'Mixología'],
          vibe: 'Cantinas Finas, Botaneros & Taprooms',
          estimatedAverageDrivingSpeedKmH: 30.0,
        ),

        // 2. Corredor Centro Histórico
        const NightlifeCorridor(
          id: CorridorId.centroHistorico,
          name: 'Corredor Centro Histórico',
          municipality: 'Colima',
          description:
              'Corazón colonial, bohemio y alternativo. Andador Constitución, Calle Santos Degollado, Portales de Medellín/Morelos, Calle Miguel Hidalgo, bares de rock, clubes electrónicos (Low Social Club), mezcalerías y cantinas de tradición.',
          focalPoint: GeoPoint(19.2435, -103.7275),
          polylinePoints: [
            GeoPoint(19.2408, -103.7225), // El Taurino / Filomeno Medina
            GeoPoint(19.2410, -103.7256), // Low Social Club (Calle Miguel Hidalgo 165)
            GeoPoint(19.2425, -103.7265), // Santos Degollado / DMT / Dos Puntos
            GeoPoint(19.2439, -103.7275), // Andador Constitución / Estación Colimita
            GeoPoint(19.2448, -103.7295), // 27 de Septiembre / La Puerta Bar
            GeoPoint(19.2460, -103.7240), // Teatro Hidalgo & Madero
          ],
          tags: ['Bohemio', 'Rock en Vivo', 'Cantinas Clásicas', 'Low Social Club', 'Electrónica', 'Mezcal', 'Andador'],
          vibe: 'Bohemio, Rock Clásico, Electrónica Underground & Tradición',
          estimatedAverageDrivingSpeedKmH: 20.0,
        ),

        // 3. Corredor Constitución / San Fernando
        const NightlifeCorridor(
          id: CorridorId.constitucionSanFernando,
          name: 'Corredor Constitución / San Fernando',
          municipality: 'Colima',
          description:
              'Eje vibrante desde Plaza San Fernando ascendiendo por Av. Constitución hacia Residencial Esmeralda y Bugambilias. Terrazas chic, gastro-bares, mezcalerías y el punto memorial histórico de Barezzito (Constitución 1450).',
          focalPoint: GeoPoint(19.2550, -103.7170),
          polylinePoints: [
            GeoPoint(19.2524, -103.7210), // Av. Constitución 1450 (Barezzito Memorial / Plaza San Fernando)
            GeoPoint(19.2578, -103.7158), // Estación Colimita Constitución
            GeoPoint(19.2630, -103.7138), // Residencial Esmeralda
            GeoPoint(19.2730, -103.7080), // Santo Mezcal (Constitución 1999)
          ],
          tags: ['Terrazas San Fernando', 'Colimita', 'Santo Mezcal', 'Barezzito Memorial', 'Chic'],
          vibe: 'Gastro-Bars, Terrazas & Mixología Chic',
          estimatedAverageDrivingSpeedKmH: 28.0,
        ),

        // 4. Corredor Venustiano Carranza
        const NightlifeCorridor(
          id: CorridorId.venustianoCarranza,
          name: 'Corredor Venustiano Carranza',
          municipality: 'Colima',
          description:
              'Avenida gastronómica y nocturna moderna que conecta la zona centro-norte con Tercer Anillo. Pizzerías de estilo neoyorquino, bares cerveceros y cocina urbana.',
          focalPoint: GeoPoint(19.2700, -103.7125),
          polylinePoints: [
            GeoPoint(19.2612, -103.7125), // Taverna NY Style Pizza (Carranza 1310)
            GeoPoint(19.2680, -103.7124), // Zona Residencial Carranza
            GeoPoint(19.2800, -103.7124), // Cervecería de la Costa Venustiano Carranza
          ],
          tags: ['Pizza & Beer', 'Cervecería de la Costa', 'Cocina Urbana', 'Lounges'],
          vibe: 'Craft Beer, NY Pizza & Urban Dining',
          estimatedAverageDrivingSpeedKmH: 32.0,
        ),

        // 5. Corredor Tercer Anillo / VDA (Villa de Álvarez)
        const NightlifeCorridor(
          id: CorridorId.tercerAnilloVda,
          name: 'Corredor Tercer Anillo / VDA',
          municipality: 'Conurbado (Colima - Villa de Álvarez)',
          description:
              'El mayor eje metropolitano de alta afluencia nocturna. Integra las grandes sucursales de Tercer Anillo, Plaza Zentralia, Santa Fe, y penetra a Villa de Álvarez por Av. Pablo Silva y Av. Griselda Álvarez.',
          focalPoint: GeoPoint(19.2750, -103.7380),
          polylinePoints: [
            GeoPoint(19.2664, -103.7491), // Pablo Silva (Villa de Álvarez)
            GeoPoint(19.2750, -103.7510), // Griselda Álvarez (Villa de Álvarez)
            GeoPoint(19.2687, -103.7248), // Cruce Blvd. Miguel de la Madrid / Zentralia
            GeoPoint(19.2828, -103.7325), // Cervecería de la Costa Tercer Anillo
            GeoPoint(19.2892, -103.7250), // Santa Fe Tercer Anillo Norte
          ],
          tags: ['Tercer Anillo', 'Villa de Álvarez', 'Zentralia', 'Grandes Taprooms', 'Santa Fe'],
          vibe: 'Macro-Clubs, Taprooms Expansivos & Vía Rápida',
          estimatedAverageDrivingSpeedKmH: 45.0,
        ),

        // 6. Corredor Sevilla del Río & Camino Real
        const NightlifeCorridor(
          id: CorridorId.sevillaDelRioCaminoReal,
          name: 'Corredor Sevilla del Río & Camino Real',
          municipality: 'Colima',
          description:
              'Tradición viva de Colima. Conecta la Glorieta del DIF y Sevilla del Río con el Blvd. Camino Real y la Glorieta Monumental. Bares tradicionales, botaneros y terrazas.',
          focalPoint: GeoPoint(19.2510, -103.7140),
          polylinePoints: [
            GeoPoint(19.2530, -103.7180), // La Regional (Sevilla del Río 534)
            GeoPoint(19.2674, -103.7170), // Cervecería de la Costa La Paz
            GeoPoint(19.2485, -103.7085), // La Chintola (Camino Real / Monumental)
          ],
          tags: ['La Regional', 'Camino Real', 'La Chintola', 'La Paz', 'Botaneros'],
          vibe: 'Botaneros Tradicionales, Terrazas & Cervecería Local',
          estimatedAverageDrivingSpeedKmH: 30.0,
        ),
      ];
}
