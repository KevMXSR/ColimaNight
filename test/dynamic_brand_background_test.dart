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

    testWidgets('renders primary logo with colossal responsive sizing and 0.24 default opacity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicBrandBackground(
              type: BrandBackgroundType.primaryLogo,
              child: SizedBox(),
            ),
          ),
        ),
      );

      final bgWidget = tester.widget<DynamicBrandBackground>(find.byType(DynamicBrandBackground));
      expect(bgWidget.opacity, 0.24);

      // Verify Image is inside an OverflowBox and a colossal dimensioned SizedBox
      expect(find.byType(OverflowBox), findsOneWidget);
      final sizedBoxFinder = find.ancestor(
        of: find.byType(Image),
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsWidgets);

      final SizedBox logoBox = tester.widget(sizedBoxFinder.first);
      // On 800x600 test surface (desktop/tablet), dimension should be >= 1000 dp
      expect(logoBox.width, greaterThanOrEqualTo(1000.0));
      expect(logoBox.height, greaterThanOrEqualTo(1000.0));
    });

    testWidgets('respects customLogoSize when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DynamicBrandBackground(
              type: BrandBackgroundType.primaryLogo,
              customLogoSize: 620.0,
              child: SizedBox(),
            ),
          ),
        ),
      );

      final sizedBoxFinder = find.ancestor(
        of: find.byType(Image),
        matching: find.byType(SizedBox),
      );
      final SizedBox logoBox = tester.widget(sizedBoxFinder.first);
      expect(logoBox.width, 620.0);
      expect(logoBox.height, 620.0);
    });
  });
}
