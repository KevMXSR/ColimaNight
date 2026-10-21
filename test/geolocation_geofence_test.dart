import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:colima_night/core/constants/colima_geo_constants.dart';
import 'package:colima_night/features/map/domain/models/venue_location.dart';
import 'package:colima_night/features/geolocation/services/colima_location_service.dart';

void main() {
  group('Phase 1 - 80m Geofence & Geolocation Audit Tests', () {
    test('proofOfProximityRadiusMeters is configured to exactly 80.0 meters', () {
      expect(ColimaGeoConstants.proofOfProximityRadiusMeters, equals(80.0));
    });

    test('All verified venues default to the 80m geofence radius', () {
      final venues = VenueLocation.verifiedColimaVenues;
      expect(venues, isNotEmpty);

      for (final venue in venues) {
        expect(
          venue.geofenceRadiusMeters,
          equals(80.0),
          reason: 'Venue ${venue.name} must have an 80m geofence radius',
        );
      }
    });

    test('Haversine distance calculation is mathematically precise for Colima coordinates', () {
      // Coordenadas conocidas: Jardín Libertad a Estación Colimita Andador Centro (~150m)
      const double jardinLat = 19.2435;
      const double jardinLng = -103.7275;

      const double colimitaLat = 19.2439;
      const double colimitaLng = -103.7275;

      final double distance = ColimaGeoConstants.calculateDistanceMeters(
        jardinLat,
        jardinLng,
        colimitaLat,
        colimitaLng,
      );

      // Distancia entre 19.2435 y 19.2439 en misma longitud es ~44.48 metros
      expect(distance, greaterThan(40.0));
      expect(distance, lessThan(50.0));
    });

    test('Proximity service evaluates isWithinGeofence correctly against 80m limit', () {
      final service = ColimaLocationService();
      final venue = VenueLocation.verifiedColimaVenues.first; // Cervecería de la Costa - Tercer Anillo

      // 1. Usuario a ~20 metros del antro -> isWithinGeofence debe ser true
      // Un desplazamiento de ~0.00015 grados en latitud corresponde a ~16 metros
      final estimateNear = service.calculateProximity(
        userLat: venue.coordinates.latitude + 0.00015,
        userLng: venue.coordinates.longitude,
        venue: venue,
      );

      expect(estimateNear.distanceMeters, lessThan(80.0));
      expect(estimateNear.isWithinGeofence, isTrue);

      // 2. Usuario a ~150 metros del antro -> isWithinGeofence debe ser false (excede los 80m)
      // Un desplazamiento de ~0.0012 grados en latitud corresponde a ~133 metros
      final estimateFar = service.calculateProximity(
        userLat: venue.coordinates.latitude + 0.0012,
        userLng: venue.coordinates.longitude,
        venue: venue,
      );

      expect(estimateFar.distanceMeters, greaterThan(80.0));
      expect(estimateFar.isWithinGeofence, isFalse);
    });

    test('Proof of Proximity token rejects user outside 80m geofence', () {
      final service = ColimaLocationService();
      final venue = VenueLocation.verifiedColimaVenues.first;

      // Posición fuera del radio de 80m (~150m de distancia)
      final farPosition = Position(
        latitude: venue.coordinates.latitude + 0.0013,
        longitude: venue.coordinates.longitude,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 500.0,
        altitudeAccuracy: 5.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        isMocked: false,
      );

      final token = service.validateProofOfProximity(
        position: farPosition,
        venue: venue,
        userId: 'test-user-123',
      );

      expect(token.isValid, isFalse);
      expect(token.rejectionReason, contains('80 m'));
    });

    test('Proof of Proximity token approves user within 80m geofence with high accuracy', () {
      final service = ColimaLocationService();
      final venue = VenueLocation.verifiedColimaVenues.first;

      // Posición dentro del radio de 80m (~25m de distancia)
      final nearPosition = Position(
        latitude: venue.coordinates.latitude + 0.0002,
        longitude: venue.coordinates.longitude,
        timestamp: DateTime.now(),
        accuracy: 8.0,
        altitude: 500.0,
        altitudeAccuracy: 5.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        isMocked: false,
      );

      final token = service.validateProofOfProximity(
        position: nearPosition,
        venue: venue,
        userId: 'test-user-123',
      );

      expect(token.isValid, isTrue);
      expect(token.verificationHash, isNotNull);
      expect(token.verifiedDistanceMeters, lessThan(80.0));
    });

    test('Proof of Proximity rejects mock/spoofed GPS location regardless of distance', () {
      final service = ColimaLocationService();
      final venue = VenueLocation.verifiedColimaVenues.first;

      // Posición a 0 metros pero con flag isMocked = true
      final mockedPosition = Position(
        latitude: venue.coordinates.latitude,
        longitude: venue.coordinates.longitude,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 500.0,
        altitudeAccuracy: 5.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        isMocked: true,
      );

      final token = service.validateProofOfProximity(
        position: mockedPosition,
        venue: venue,
        userId: 'test-user-123',
      );

      expect(token.isValid, isFalse);
      expect(token.rejectionReason, contains('simulada'));
    });
  });
}
