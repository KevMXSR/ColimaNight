import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/colima_geo_constants.dart';
import '../../map/domain/models/venue_location.dart';

/// Resultado del cálculo de proximidad hacia un establecimiento
class ProximityEstimate {
  final double distanceMeters;
  final String formattedDistance;
  final int walkingEtaMinutes;
  final int drivingEtaMinutes;
  final bool isWithinGeofence;
  final CorridorId? nearestCorridor;

  const ProximityEstimate({
    required this.distanceMeters,
    required this.formattedDistance,
    required this.walkingEtaMinutes,
    required this.drivingEtaMinutes,
    required this.isWithinGeofence,
    this.nearestCorridor,
  });

  Map<String, dynamic> toJson() => {
        'distanceMeters': distanceMeters,
        'formattedDistance': formattedDistance,
        'walkingEtaMinutes': walkingEtaMinutes,
        'drivingEtaMinutes': drivingEtaMinutes,
        'isWithinGeofence': isWithinGeofence,
        'nearestCorridor': nearestCorridor?.name,
      };
}

/// Token criptográfico generado tras validar el 'Proof of Proximity'
class ProofOfProximityToken {
  final bool isValid;
  final String? rejectionReason;
  final String? venueId;
  final String? userId;
  final int? timestampUtcMs;
  final double? verifiedDistanceMeters;
  final String? verificationHash;

  const ProofOfProximityToken.success({
    required this.venueId,
    required this.userId,
    required this.timestampUtcMs,
    required this.verifiedDistanceMeters,
    required this.verificationHash,
  })  : isValid = true,
        rejectionReason = null;

  const ProofOfProximityToken.rejected({
    required this.rejectionReason,
  })  : isValid = false,
        venueId = null,
        userId = null,
        timestampUtcMs = null,
        verifiedDistanceMeters = null,
        verificationHash = null;

  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        'rejectionReason': rejectionReason,
        'venueId': venueId,
        'userId': userId,
        'timestampUtcMs': timestampUtcMs,
        'verifiedDistanceMeters': verifiedDistanceMeters,
        'verificationHash': verificationHash,
      };
}

/// Servicio integral de geolocalización, cálculo de ETA en Colima y validación antifraude
class ColimaLocationService {
  final String _securitySecretSalt;

  ColimaLocationService({String? securitySecretSalt})
      : _securitySecretSalt = securitySecretSalt ?? 'ColimaNight_Salt_VDA_2026_SecureKey';

  // --------------------------------------------------------------------------
  // Gestión de Permisos y Ubicación del Dispositivo
  // --------------------------------------------------------------------------

  /// Verifica y solicita permisos de geolocalización
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtiene la posición GPS de alta precisión actual del usuario
  Future<Position?> getCurrentPosition() async {
    final bool hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  /// Stream continuo de cambios de ubicación (para mapa en vivo y navegación)
  Stream<Position> getPositionStream({int distanceFilterMeters = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Cálculo de Proximidad y Estimaciones de Tiempo (ETA)
  // --------------------------------------------------------------------------

  /// Calcula la distancia y tiempos de traslado estimados (caminando y auto)
  /// adaptados a las velocidades medias y semáforos de Colima - Villa de Álvarez.
  ProximityEstimate calculateProximity({
    required double userLat,
    required double userLng,
    required VenueLocation venue,
  }) {
    final double distanceMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      venue.coordinates.latitude,
      venue.coordinates.longitude,
    );

    // Formateo legible
    final String formattedDistance = distanceMeters < 1000
        ? '${distanceMeters.round()} m'
        : '${(distanceMeters / 1000).toStringAsFixed(1)} km';

    // Estimación caminando: Velocidad promedio urbana 4.5 km/h = 75 m/min + 10% esperas de cruce
    final int walkingMinutes = ((distanceMeters / 75.0) * 1.1).ceil();

    // Estimación en auto:
    // En Tercer Anillo: ~45 km/h (~750 m/min).
    // En Corredores Interiores (Constitución/Sevilla/Centro): ~28 km/h (~466 m/min).
    double metersPerMinuteDriving = 470.0;
    if (venue.corridorId == CorridorId.tercerAnilloVda) {
      metersPerMinuteDriving = 700.0;
    } else if (venue.corridorId == CorridorId.centroHistorico) {
      metersPerMinuteDriving = 320.0; // Calles angostas y topes coloniales
    }

    // Mínimo 2 minutos en auto por arranque/estacionamiento
    final int drivingMinutes = max(2, ((distanceMeters / metersPerMinuteDriving) + 1.5).ceil());

    final bool isWithinGeofence = distanceMeters <= venue.geofenceRadiusMeters;

    return ProximityEstimate(
      distanceMeters: distanceMeters,
      formattedDistance: formattedDistance,
      walkingEtaMinutes: walkingMinutes,
      drivingEtaMinutes: drivingMinutes,
      isWithinGeofence: isWithinGeofence,
      nearestCorridor: venue.corridorId,
    );
  }

  // --------------------------------------------------------------------------
  // Proof of Proximity (PoP) - Validación Antifraude de Reportes en Vivo
  // --------------------------------------------------------------------------

  /// Valida rigurosamente si un usuario se encuentra física y fehacientemente en el antro
  /// antes de permitirle enviar un reporte de aforo, fila o precios.
  ProofOfProximityToken validateProofOfProximity({
    required Position position,
    required VenueLocation venue,
    required String userId,
  }) {
    // 1. Detección de Ubicación Simulada (Fake GPS / Spoofing)
    if (position.isMocked) {
      return const ProofOfProximityToken.rejected(
        rejectionReason: 'Ubicación simulada o software de falseo GPS detectado.',
      );
    }

    // 2. Validación de Bounding Box de la Zona Metropolitana de Colima - Villa de Álvarez
    final bool isInMetro = ColimaGeoConstants.isInColimaMetropolitanArea(
      position.latitude,
      position.longitude,
    );
    if (!isInMetro) {
      return const ProofOfProximityToken.rejected(
        rejectionReason: 'La ubicación está fuera de la zona metropolitana de Colima y Villa de Álvarez.',
      );
    }

    // 3. Precisión de la señal GPS (Accuracy)
    if (position.accuracy > ColimaGeoConstants.maxGpsAccuracyMeters) {
      return ProofOfProximityToken.rejected(
        rejectionReason:
            'Señal GPS imprecisa (${position.accuracy.toStringAsFixed(1)} m). Se requiere precisión menor a ${ColimaGeoConstants.maxGpsAccuracyMeters} m.',
      );
    }

    // 4. Frescura de la lectura GPS (Timestamp freshness)
    final DateTime now = DateTime.now();
    final DateTime fixTime = position.timestamp;
    final int ageInSeconds = now.difference(fixTime).inSeconds.abs();
    if (ageInSeconds > ColimaGeoConstants.maxGpsFixAgeSeconds) {
      return ProofOfProximityToken.rejected(
        rejectionReason:
            'Lectura GPS caducada ($ageInSeconds s de antigüedad). Actualiza tu posición.',
      );
    }

    // 5. Cálculo de distancia al establecimiento
    final double distanceMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      venue.coordinates.latitude,
      venue.coordinates.longitude,
    );

    if (distanceMeters > venue.geofenceRadiusMeters) {
      return ProofOfProximityToken.rejected(
        rejectionReason:
            'Estás a ${distanceMeters.toStringAsFixed(0)} m del establecimiento. Debes estar a menos de ${venue.geofenceRadiusMeters.toInt()} m para reportar en tiempo real.',
      );
    }

    // 6. Generación del Hash de Verificación Criptográfica (SHA-256)
    // Se redondea el timestamp a ventanas de 3 minutos para permitir verificación en servidor backend
    final int timestampRounded = (now.millisecondsSinceEpoch ~/ 180000) * 180000;
    final String rawPayload =
        '$userId:${venue.id}:$timestampRounded:${distanceMeters.toStringAsFixed(2)}:$_securitySecretSalt';
    final String verificationHash = sha256.convert(utf8.encode(rawPayload)).toString();

    return ProofOfProximityToken.success(
      venueId: venue.id,
      userId: userId,
      timestampUtcMs: now.millisecondsSinceEpoch,
      verifiedDistanceMeters: distanceMeters,
      verificationHash: verificationHash,
    );
  }
}
