import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/core/widgets/dynamic_brand_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DynamicBrandBackground Widget Tests', () {
    testWidgets('renders primary logo background with child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicBrandBackground(
              type: BrandBackgroundType.primaryLogo,
              child: Text('ColimaNight Feed Content'),
            ),
          ),
        ),
      );

      // Verify child content is displayed
      expect(find.text('ColimaNight Feed Content'), findsOneWidget);

      // Verify DynamicBrandBackground is present
      expect(find.byType(DynamicBrandBackground), findsOneWidget);

      // Verify Image.asset exists for the primary logo
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image imageWidget = tester.widget(imageFinder);
      expect((imageWidget.image as AssetImage).assetName,
          'assets/images/logo_colimanight_primary.png');
    });

    testWidgets('renders secondary neon map background with child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicBrandBackground(
              type: BrandBackgroundType.neonMapSecondary,
              child: Text('ColimaNight Secondary Content'),
            ),
          ),
        ),
      );

      expect(find.text('ColimaNight Secondary Content'), findsOneWidget);

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image imageWidget = tester.widget(imageFinder);
      expect((imageWidget.image as AssetImage).assetName,
          'assets/images/colima_neon_map_bg.png');
    });

    testWidgets('allows tap interactions through to child widgets', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicBrandBackground(
              child: ElevatedButton(
                onPressed: () {
                  tapped = true;
                },
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
