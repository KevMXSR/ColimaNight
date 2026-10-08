import 'dart:math';

/// Enumeración del estado operativo y aforo en tiempo real de los establecimientos
/// en la vida nocturna de Colima y Villa de Álvarez.
enum VenueStatus {
  /// Buen ambiente, entrada fluida, lugar disponible (Neon Emerald)
  available,

  /// Aforo alto (80%+ de capacidad), posible fila en puerta (Neon Amber)
  crowded,

  /// Evento especial, DJ invitado, acceso VIP o música en vivo (Neon Purple)
  specialEvent,

  /// Precaución, altercado reportado en la zona o cupo al 100% (Neon Alert Red)
  alert,

  /// Memorial / Fuera de operación histórica (Easter Egg)
  memorial,
}

/// Identificador de los 6 corredores nocturnos reconfigurados de la zona conurbada
enum CorridorId {
  ignacioSandoval,
  centroHistorico,
  constitucionSanFernando,
  venustianoCarranza,
  tercerAnilloVda,
  sevillaDelRioCaminoReal,
}

/// Coordenadas geográficas y constantes de geocercado para Colima y Villa de Álvarez
class ColimaGeoConstants {
  ColimaGeoConstants._();

  // --------------------------------------------------------------------------
  // Centro Metropolitano
  // --------------------------------------------------------------------------
  /// Coordenada central de referencia para la conurbación Colima - Villa de Álvarez
  /// (Conexión Av. Sevilla del Río / Glorieta del DIF / Calzada Galván / Tecnológico)
  static const double centerLatitude = 19.2433;
  static const double centerLongitude = -103.7247;

  /// Zoom por defecto centrado en la zona metropolitana
  static const double defaultZoom = 13.8;
  static const double corridorZoom = 15.2;
  static const double venueDetailZoom = 17.0;

  // --------------------------------------------------------------------------
  // Bounding Box Metropolitano (Límite Urbano Estricto Conurbado)
  // --------------------------------------------------------------------------
  /// Límite Sur: Libramiento Sur / El Diezmo / Av. Niños Héroes
  static const double boundingBoxSouth = 19.1950;

  /// Límite Norte: Tercer Anillo Periférico Norte / Altozano / Buenavista / Santa Fe
  static const double boundingBoxNorth = 19.3150;

  /// Límite Oeste: Villa de Álvarez / Pablo Silva / Griselda Álvarez / Libramiento Poniente
  static const double boundingBoxWest = -103.7850;

  /// Límite Este: Libramiento Ejército Mexicano / El Chanal / Autopista a Guadalajara
  static const double boundingBoxEast = -103.6650;

  // --------------------------------------------------------------------------
  // Parámetros de "Proof of Proximity" (Validación Antifraude de Reportes)
  // --------------------------------------------------------------------------
  /// Radio estándar de validación de proximidad en metros (150 m)
  static const double proofOfProximityRadiusMeters = 150.0;

  /// Radio extendido para macro-plazas o macro-recintos (ej. Zentralia, Plaza Las Pérgolas, La Petatera)
  static const double macroVenueProximityRadiusMeters = 280.0;

  /// Antigüedad máxima del fix GPS en segundos para considerar válido el reporte
  static const int maxGpsFixAgeSeconds = 45;

  /// Precisión máxima admitida de GPS (accuracy) en metros para validar presencia
  static const double maxGpsAccuracyMeters = 35.0;

  // --------------------------------------------------------------------------
  // Métodos de Validación Geográfica
  // --------------------------------------------------------------------------
  /// Verifica si una coordenada se encuentra dentro de la mancha metropolitana
  /// de Colima y Villa de Álvarez.
  static bool isInColimaMetropolitanArea(double latitude, double longitude) {
    return latitude >= boundingBoxSouth &&
        latitude <= boundingBoxNorth &&
        longitude >= boundingBoxWest &&
        longitude <= boundingBoxEast;
  }

  /// Calcula la distancia geodésica en metros entre dos puntos usando la fórmula de Haversine.
  static double calculateDistanceMeters(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const double earthRadius = 6371000; // Radio terrestre en metros
    final double dLat = _degreesToRadians(endLat - startLat);
    final double dLng = _degreesToRadians(endLng - startLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
