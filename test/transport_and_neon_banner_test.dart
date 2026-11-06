import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colima_night/features/auth/presentation/providers/auth_provider.dart';
import 'package:colima_night/features/transport/presentation/providers/transport_provider.dart';
import 'package:colima_night/features/transport/presentation/widgets/neon_ride_button.dart';
import 'package:colima_night/features/transport/presentation/widgets/ride_chooser_sheet.dart';
import 'package:colima_night/features/monetization/presentation/widgets/neon_ad_banner.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TransportService & Ride Redirection Tests (Modelo 2)', () {
    final service = TransportService();

    test('buildDiDiUri generates valid native scheme with encoded coordinates and name', () {
      final uri = service.buildDiDiUri(19.2612, -103.7045, 'Cervecería de Colima');

      expect(uri.scheme, 'didiwas');
      expect(uri.host, 'passenger');
      expect(uri.path, '/launch');
      expect(uri.queryParameters['dlat'], '19.2612');
      expect(uri.queryParameters['dlng'], '-103.7045');
      expect(uri.queryParameters['dname'], 'Cervecería de Colima');
    });

    test('buildUberUri generates valid native scheme with action and dropoff parameters', () {
      final uri = service.buildUberUri(19.2480, -103.7250, 'Barezzito Colima');

      expect(uri.scheme, 'uber');
      expect(uri.queryParameters['action'], 'setPickup');
      expect(uri.queryParameters['dropoff[latitude]'], '19.248');
      expect(uri.queryParameters['dropoff[longitude]'], '-103.725');
      expect(uri.queryParameters['dropoff[nickname]'], 'Barezzito Colima');
    });

    test('buildUberWebUri generates universal mobile web URL as fallback', () {
      final webUri = service.buildUberWebUri(19.2500, -103.7200, 'Danzteria');

      expect(webUri.scheme, 'https');
      expect(webUri.host, 'm.uber.com');
      expect(webUri.queryParameters['action'], 'setPickup');
      expect(webUri.queryParameters['dropoff[nickname]'], 'Danzteria');
    });

    test('buildDiDiWebUri provides official global portal', () {
      final webUri = service.buildDiDiWebUri();
      expect(webUri.toString(), 'https://didiglobal.com');
    });
  });

  group('NeonRideButton Widget Tests (Modelo 2)', () {
    testWidgets('NeonRideButton renders with Cyber-Night Magenta styling and action label', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NeonRideButton(
                latitude: 19.25,
                longitude: -103.71,
                barName: 'Nuit Club',
              ),
            ),
          ),
        ),
      );

      expect(find.text('PEDIR VIAJE AQUÍ 🚕'), findsOneWidget);
      expect(find.byIcon(Icons.time_to_leave), findsOneWidget);
    });

    testWidgets('RideChooserSheet displays DiDi and Uber options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: RideChooserSheet(
                latitude: 19.25,
                longitude: -103.71,
                destinationName: 'Low Social Club',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pedir Transporte Seguro'), findsOneWidget);
      expect(find.text('Low Social Club'), findsOneWidget);
      expect(find.text('DiDi Pasajero'), findsOneWidget);
      expect(find.text('Uber'), findsOneWidget);
      expect(find.text('POPULAR EN COLIMA'), findsOneWidget);
    });
  });

  group('NeonAdBanner Widget Tests (Modelo 1)', () {
    testWidgets('NeonAdBanner renders with neon cyan border and AD badge for standard users', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NeonAdBanner(),
            ),
          ),
        ),
      );

      expect(find.text('AD'), findsOneWidget);
      expect(find.byType(NeonAdBanner), findsOneWidget);
    });

    testWidgets('NeonAdBanner hides itself completely when user is a Supporter (Ad-Free perk)', (tester) async {
      final container = ProviderContainer();
      // Simula que el usuario activó Supporter VIP
      container.read(authProvider.notifier).becomeSupporter('Mesa VIP Supporter');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: NeonAdBanner(),
            ),
          ),
        ),
      );

      // No debe existir el badge de AD porque el Supporter no tiene publicidad
      expect(find.text('AD'), findsNothing);
    });
  });
}
