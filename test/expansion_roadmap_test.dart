import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colima_night/features/venues/presentation/widgets/expansion_roadmap_modal.dart';
import 'package:colima_night/features/venues/presentation/views/discovery_feed_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Expansion Roadmap Modal Tests (Tecomán & Manzanillo)', () {
    testWidgets('ExpansionRoadmapModal displays current zone and upcoming coastal zones', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpansionRoadmapModal(),
          ),
        ),
      );

      // Verify header and description
      expect(find.text('Expansión Estatal'), findsOneWidget);
      expect(find.textContaining('El radar nocturno crece con la respuesta de nuestra comunidad'), findsOneWidget);

      // Verify Active zone
      expect(find.text('Colima & Villa de Álvarez'), findsOneWidget);
      expect(find.text('FASE 1 • ACTIVO EN VIVO'), findsOneWidget);

      // Verify Tecomán and Manzanillo upcoming zones
      expect(find.text('Manzanillo (Costa & Puerto)'), findsOneWidget);
      expect(find.text('PRÓXIMAMENTE • FASE 2'), findsOneWidget);
      expect(find.text('Tecomán & Costa Sur'), findsOneWidget);
      expect(find.text('PRÓXIMAMENTE • FASE 3'), findsOneWidget);

      // Verify community contribution action
      expect(find.text('Sugerir un lugar en Tecomán o Manzanillo'), findsOneWidget);
    });

    testWidgets('DiscoveryFeedView header displays the discreet Cyber Pill for upcoming expansion', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DiscoveryFeedView(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Colima & VDA'), findsOneWidget);
      expect(find.text('Próx: Tecomán & Mzo'), findsOneWidget);
      expect(find.byIcon(Icons.waves_rounded), findsWidgets);
    });
  });
}
