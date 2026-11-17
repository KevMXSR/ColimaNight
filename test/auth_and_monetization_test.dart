import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colima_night/core/config/monetization_config.dart';
import 'package:colima_night/core/services/firestore_cost_optimizer.dart';
import 'package:colima_night/features/auth/domain/models/user_model.dart';
import 'package:colima_night/features/auth/presentation/providers/auth_provider.dart';
import 'package:colima_night/features/auth/services/colima_oauth_service.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
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

    test('Official B2B Contact Email linking builds structured mailto uri', () {
      expect(MonetizationConfig.contactEmail, 'contact.colimanight@gmail.com');
      final emailUrl = MonetizationConfig.getContactEmailUrl();
      expect(emailUrl.startsWith('mailto:contact.colimanight@gmail.com'), isTrue);
      expect(emailUrl.contains('subject='), isTrue);
      expect(emailUrl.contains('body='), isTrue);

      final customUrl = MonetizationConfig.getContactEmailUrl(
        subject: 'Patrocinio VIP',
        body: 'Quiero anunciarme',
      );
      expect(customUrl.contains('subject=Patrocinio%20VIP'), isTrue);
      expect(customUrl.contains('body=Quiero%20anunciarme'), isTrue);
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

    test('AuthNotifier has zero fake profiles by default and saves genuine recent accounts', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Cero cuentas falsas o simuladas por defecto
      final initialAccounts = await container.read(authProvider.notifier).getRecentAccounts();
      expect(initialAccounts.isEmpty, isTrue);

      // Save a new genuine account and verify it prepends to recent list
      await container.read(authProvider.notifier).saveRecentAccount(
            displayName: 'Usuario Real Colima',
            email: 'real@gmail.com',
            provider: 'google',
          );

      final updatedAccounts = await container.read(authProvider.notifier).getRecentAccounts();
      expect(updatedAccounts.length, equals(1));
      expect(updatedAccounts.first['displayName'], 'Usuario Real Colima');
      expect(updatedAccounts.first['email'], 'real@gmail.com');
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

  group('ColimaOAuthService Official Device Chooser Tests', () {
    test('buildProviderAccountChooserUri builds valid Google Account Chooser with prompt=select_account', () {
      final googleUri = ColimaOAuthService.buildProviderAccountChooserUri(SocialAuthProvider.google);
      expect(googleUri.host, contains('accounts.google.com'));
      expect(googleUri.queryParameters['prompt'], equals('select_account'));
      expect(googleUri.queryParameters['scope'], contains('email'));
    });

    test('buildProviderAccountChooserUri builds valid Facebook OAuth dialog URI', () {
      final fbUri = ColimaOAuthService.buildProviderAccountChooserUri(SocialAuthProvider.facebook);
      expect(fbUri.host, contains('facebook.com'));
      expect(fbUri.queryParameters['client_id'], isNotEmpty);
    });

    test('buildProviderAccountChooserUri builds valid Instagram OAuth URI', () {
      final igUri = ColimaOAuthService.buildProviderAccountChooserUri(SocialAuthProvider.instagram);
      expect(igUri.host, contains('instagram.com'));
      expect(igUri.queryParameters['scope'], contains('user_profile'));
    });
  });

  group('FirestoreCostOptimizer (Spark 0-Cost & Blaze Expansion) Tests', () {
    test('Optimizes lifecycle and pauses Firestore listeners when app enters background', () {
      final optimizer = FirestoreCostOptimizer.instance;
      optimizer.initialize();

      bool paused = false;
      bool resumed = false;

      optimizer.registerManagedListener(
        listenerId: 'test_aforos_listener',
        onPause: () => paused = true,
        onResume: () => resumed = true,
      );

      expect(optimizer.isAppActive, isTrue);

      // Simular cambio de estado a segundo plano (paused)
      optimizer.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(optimizer.isAppActive, isFalse);
      expect(paused, isTrue);
      expect(optimizer.ghostReadsPrevented, greaterThan(0));

      // Simular regreso a primer plano (resumed)
      optimizer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(optimizer.isAppActive, isTrue);
      expect(resumed, isTrue);

      optimizer.unregisterManagedListener('test_aforos_listener');
    });

    test('Validates payload size to guarantee < 2KB documents and prevent binary blobs', () {
      final validDoc = {
        'venueId': 'la_cerve_sevilla',
        'currentCapacity': 85,
        'updatedAt': '2026-11-17T20:00:00Z',
        'flyerUrl': 'https://firebasestorage.googleapis.com/v0/b/app/o/flyer.webp',
      };
      expect(FirestoreCostOptimizer.validateDocumentPayload(validDoc), isTrue);

      // Document with fake base64 image string is rejected
      final invalidDoc = {
        'venueId': 'la_cerve_sevilla',
        'image': 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD...',
      };
      expect(FirestoreCostOptimizer.validateDocumentPayload(invalidDoc), isFalse);
    });

    test('Validates media URLs to point strictly to external CDNs, Firebase Storage or assets', () {
      expect(FirestoreCostOptimizer.isValidMediaUrl('https://firebasestorage.googleapis.com/photo.webp'), isTrue);
      expect(FirestoreCostOptimizer.isValidMediaUrl('assets/images/venues/torna.jpg'), isTrue);
      expect(FirestoreCostOptimizer.isValidMediaUrl('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...'), isFalse);
      expect(FirestoreCostOptimizer.isValidMediaUrl(''), isFalse);
    });

    test('FCM Topic registration matches official zero-cost push channels', () {
      expect(FirestoreCostOptimizer.fcmTopicFlashPromos, 'colima_flash_promos');
      expect(FirestoreCostOptimizer.fcmTopicSecurityAlerts, 'colima_security_alerts');
      expect(FirestoreCostOptimizer.fcmCorridorTopic('sevilla_rio'), 'corridor_sevilla_rio');
      expect(FirestoreCostOptimizer.fcmCorridorTopic('Centro Historico'), 'corridor_centro_historico');
    });

    test('Blaze regional expansion cost calculator reflects \$0.06 USD per 100k extra reads', () {
      // Under 1.5M monthly reads -> $0.00 USD
      expect(FirestoreCostOptimizer.calculateMonthlyBlazeCostUsd(totalMonthlyReads: 1200000), 0.0);

      // 1.5M monthly reads -> $0.00 USD (exact Spark boundary)
      expect(FirestoreCostOptimizer.calculateMonthlyBlazeCostUsd(totalMonthlyReads: 1500000), 0.0);

      // 2.5M monthly reads -> 1,000,000 extra billable reads -> 10 blocks of 100k -> $0.60 USD (~12 MXN)
      final cost2_5M = FirestoreCostOptimizer.calculateMonthlyBlazeCostUsd(totalMonthlyReads: 2500000);
      expect(cost2_5M, closeTo(0.60, 0.001));

      // 100k extra reads -> $0.06 USD
      final cost1_6M = FirestoreCostOptimizer.calculateMonthlyBlazeCostUsd(totalMonthlyReads: 1600000);
      expect(cost1_6M, closeTo(0.06, 0.001));
    });
  });
}
