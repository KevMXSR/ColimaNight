import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colima_night/features/auth/domain/models/user_model.dart';
import 'package:colima_night/features/auth/presentation/providers/auth_provider.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';

void main() {
  group('Auth & Guest Mode Tests', () {
    test('UserModel.guest initializes correctly without auth friction', () {
      final guest = UserModel.guest();

      expect(guest.isGuest, isTrue);
      expect(guest.displayName, 'Invitado');
      expect(guest.isSupporter, isFalse);
      expect(guest.supporterTier, isNull);
    });

    test('AuthNotifier initializes with guest state and can simulate Google Sign-In', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialUser = container.read(authProvider);
      expect(initialUser.isGuest, isTrue);

      final success = await container.read(authProvider.notifier).signInWithGoogle(
            mockName: 'Explorador Colimense',
            mockEmail: 'explorador@colimanight.app',
          );
      expect(success, isTrue);

      final authedUser = container.read(authProvider);
      expect(authedUser.isGuest, isFalse);
      expect(authedUser.displayName, 'Explorador Colimense');
      expect(authedUser.email, 'explorador@colimanight.app');
    });

    test('AuthNotifier upgrades to Patreon supporter and preserves user identity', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).signInWithGoogle(
            mockName: 'Explorador Colimense',
            mockEmail: 'explorador@colimanight.app',
          );
      container.read(authProvider.notifier).becomeSupporter('Mesa VIP Supporter');

      final supporter = container.read(authProvider);
      expect(supporter.isSupporter, isTrue);
      expect(supporter.supporterTier, 'Mesa VIP Supporter');
      expect(supporter.displayName, 'Explorador Colimense');

      // Test sign out resets to guest
      container.read(authProvider.notifier).signOut();
      final resetUser = container.read(authProvider);
      expect(resetUser.isGuest, isTrue);
      expect(resetUser.isSupporter, isFalse);
    });
  });

  group('Live Presence Telemetry Tests', () {
    test('VenueModel calculates livePresence dynamically based on capacity and livePresenceCount', () {
      const venueWithManualPresence = VenueModel(
        id: 'test_venue_1',
        name: 'Bar de Prueba',
        category: 'Bar',
        zone: 'Centro',
        vibeGenre: 'Rock',
        schedule: '8:00 PM - 3:00 AM',
        description: 'Bar de prueba',
        coverImageUrl: 'assets/images/venues/test.jpg',
        galleryUrls: [],
        rating: 4.5,
        reviewsCount: 10,
        capacityPercent: 75,
        latitude: 19.24,
        longitude: -103.72,
        estimatedMinutes: 5,
        livePresenceCount: 42,
      );

      expect(venueWithManualPresence.livePresence, 42);

      const venueWithFallbackPresence = VenueModel(
        id: 'test_venue_2',
        name: 'Antro de Prueba',
        category: 'Antro',
        zone: 'San Fernando',
        vibeGenre: 'Electrónica',
        schedule: '10:00 PM - 4:00 AM',
        description: 'Antro de prueba',
        coverImageUrl: 'assets/images/venues/test2.jpg',
        galleryUrls: [],
        rating: 4.8,
        reviewsCount: 20,
        capacityPercent: 90,
        latitude: 19.25,
        longitude: -103.71,
        estimatedMinutes: 8,
      );

      // (90 * 1.5).round() = 135
      expect(venueWithFallbackPresence.livePresence, 135);
    });

    test('All mock venues have positive livePresence counts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      for (final v in venues) {
        expect(v.livePresence, greaterThan(0));
      }
    });
  });
}
