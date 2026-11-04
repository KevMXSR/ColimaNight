import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colima_night/core/config/monetization_config.dart';
import 'package:colima_night/features/auth/domain/models/user_model.dart';
import 'package:colima_night/features/auth/presentation/providers/auth_provider.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MonetizationConfig Direct Economic Linking Tests', () {
    test('PayPal credentials and tier amounts match Kevin Sandoval specifications', () {
      expect(MonetizationConfig.paypalUsername, 'GameKevMXSR');
      expect(MonetizationConfig.paypalBaseUrl, 'https://paypal.me/GameKevMXSR');
      expect(MonetizationConfig.getPayPalUrlForAmount(25), 'https://paypal.me/GameKevMXSR/25MXN');
      expect(MonetizationConfig.getPayPalUrlForAmount(50), 'https://paypal.me/GameKevMXSR/50MXN');
      expect(MonetizationConfig.getPayPalUrlForAmount(100), 'https://paypal.me/GameKevMXSR/100MXN');
    });

    test('National SPEI / BBVA Banking data matches exact 18-digit CLABE and beneficiary', () {
      expect(MonetizationConfig.bankName, 'BBVA México');
      expect(MonetizationConfig.beneficiaryName, 'Kevin Sandoval Ramirez');
      expect(MonetizationConfig.clabeRaw, '012090015533382042');
      expect(MonetizationConfig.clabeRaw.length, 18);
      expect(MonetizationConfig.clabeFormatted, '012 090 01553338204 2');
    });

    test('B2B Venue & Event sponsorship WhatsApp linking builds pre-filled conversation', () {
      expect(MonetizationConfig.businessWhatsAppNumber, '523123742089');
      final waUrl = MonetizationConfig.getBusinessWhatsAppUrl();
      expect(waUrl.contains('523123742089'), isTrue);
      expect(waUrl.contains('paquetes%20de%20difusi%C3%B3n'), isTrue);
    });
  });

  group('Auth & Social Providers Tests (Google, Facebook, Instagram)', () {
    test('UserModel.guest initializes correctly without auth friction', () {
      final guest = UserModel.guest();

      expect(guest.isGuest, isTrue);
      expect(guest.displayName, 'Invitado');
      expect(guest.isSupporter, isFalse);
      expect(guest.supporterTier, isNull);
      expect(guest.authProvider, 'guest');
    });

    test('AuthNotifier can sign in with custom profile (Kevin) using Google, Facebook, or Instagram', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialUser = container.read(authProvider);
      expect(initialUser.isGuest, isTrue);

      // 1. Google sign-in with real user name
      await container.read(authProvider.notifier).signInWithProfile(
            displayName: 'Kevin',
            email: 'kevin.colima@gmail.com',
            authProvider: 'google',
          );

      final googleUser = container.read(authProvider);
      expect(googleUser.isGuest, isFalse);
      expect(googleUser.displayName, 'Kevin');
      expect(googleUser.email, 'kevin.colima@gmail.com');
      expect(googleUser.initials, 'K');
      expect(googleUser.isGoogle, isTrue);
      expect(googleUser.isFacebook, isFalse);
      expect(googleUser.isInstagram, isFalse);

      // Verify no random mock name like "Alex Mendoza"
      expect(googleUser.displayName.contains('Alex Mendoza'), isFalse);

      // 2. Instagram sign-in
      await container.read(authProvider.notifier).signInWithInstagram(
            username: 'kevin_night',
          );
      final igUser = container.read(authProvider);
      expect(igUser.displayName, '@kevin_night');
      expect(igUser.isInstagram, isTrue);

      // 3. Facebook sign-in
      await container.read(authProvider.notifier).signInWithFacebook(
            displayName: 'Kevin Ramos',
            email: 'kevin@facebook.com',
          );
      final fbUser = container.read(authProvider);
      expect(fbUser.displayName, 'Kevin Ramos');
      expect(fbUser.initials, 'KR');
      expect(fbUser.isFacebook, isTrue);
    });

    test('AuthNotifier upgrades to Patreon supporter and preserves user identity', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).signInWithProfile(
            displayName: 'Kevin',
            email: 'kevin@colimanight.app',
            authProvider: 'google',
          );
      container.read(authProvider.notifier).becomeSupporter('Mesa VIP Supporter');

      final supporter = container.read(authProvider);
      expect(supporter.isSupporter, isTrue);
      expect(supporter.supporterTier, 'Mesa VIP Supporter');
      expect(supporter.displayName, 'Kevin');

      // Test sign out resets to guest
      await container.read(authProvider.notifier).signOut();
      final resetUser = container.read(authProvider);
      expect(resetUser.isGuest, isTrue);
      expect(resetUser.isSupporter, isFalse);
    });

    test('AuthNotifier allows updating profile details', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authProvider.notifier).signInWithProfile(
            displayName: 'Kevin Original',
            email: 'kevin@gmail.com',
          );

      await container.read(authProvider.notifier).updateProfile(
            displayName: 'Kevin Actualizado',
            email: 'kevin.vip@gmail.com',
          );

      final updated = container.read(authProvider);
      expect(updated.displayName, 'Kevin Actualizado');
      expect(updated.email, 'kevin.vip@gmail.com');
    });

    test('AuthNotifier provides authentic recent accounts list for One-Tap login', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final accounts = await container.read(authProvider.notifier).getRecentAccounts();
      expect(accounts.isNotEmpty, isTrue);

      final googleAccount = accounts.firstWhere((a) => a['provider'] == 'google');
      expect(googleAccount['displayName'], 'Kevin Sandoval Ramirez');
      expect(googleAccount['email'], 'kevin.sandoval@gmail.com');

      // Save a new account and verify it prepends to recent list
      await container.read(authProvider.notifier).saveRecentAccount(
            displayName: 'Kevin Sandoval VIP',
            email: 'vip.kevin@gmail.com',
            provider: 'google',
          );

      final updatedAccounts = await container.read(authProvider.notifier).getRecentAccounts();
      expect(updatedAccounts.first['displayName'], 'Kevin Sandoval VIP');
      expect(updatedAccounts.first['email'], 'vip.kevin@gmail.com');
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

      const venueWithDefaultPresence = VenueModel(
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

      expect(venueWithDefaultPresence.livePresence, isNonNegative);
    });
  });
}
