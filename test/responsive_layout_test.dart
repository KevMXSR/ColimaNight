import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/core/utils/responsive_breakpoints.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';
import 'package:colima_night/features/venues/presentation/widgets/hot_right_now_card.dart';
import 'package:colima_night/features/venues/presentation/widgets/venue_card.dart';
import 'package:colima_night/features/splash/presentation/views/cinematic_manifesto_view.dart';
import 'package:colima_night/features/venues/presentation/widgets/weekly_events_sheet.dart';
import 'package:colima_night/features/monetization/presentation/widgets/patreon_support_modal.dart';
import 'package:colima_night/features/venues/presentation/widgets/expansion_roadmap_modal.dart';
import 'package:colima_night/features/venues/presentation/widgets/incident_report_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  void setViewport(WidgetTester tester, double width, double height) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
  }

  group('ResponsiveBreakpoints Unit Tests', () {
    testWidgets('accurately identifies compact, medium, and desktop viewports', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. Compact Viewport (Mobile: 375 x 812)
      setViewport(tester, 375, 812);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveBreakpoints.isCompact(context), isTrue);
              expect(ResponsiveBreakpoints.isDesktop(context), isFalse);
              expect(ResponsiveBreakpoints.isExtraSmall(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );

      // 2. Extra Small Viewport (iPhone SE / Small Android: 320 x 568)
      setViewport(tester, 320, 568);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveBreakpoints.isCompact(context), isTrue);
              expect(ResponsiveBreakpoints.isExtraSmall(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );

      // 3. Medium Viewport (Tablet Portrait: 768 x 1024)
      setViewport(tester, 768, 1024);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveBreakpoints.isCompact(context), isFalse);
              expect(ResponsiveBreakpoints.isMedium(context), isTrue);
              expect(ResponsiveBreakpoints.isDesktop(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );

      // 4. Desktop Viewport (PC / Laptop: 1920 x 1080)
      setViewport(tester, 1920, 1080);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(ResponsiveBreakpoints.isCompact(context), isFalse);
              expect(ResponsiveBreakpoints.isDesktop(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('ResponsiveContentContainer constrains width on PC and stays fluid on mobile', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Desktop: 1920 x 1080
      setViewport(tester, 1920, 1080);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContentContainer(
              maxWidth: 780,
              child: Container(key: const Key('feed_child'), height: 100),
            ),
          ),
        ),
      );

      final box = tester.renderObject<RenderBox>(find.byKey(const Key('feed_child')));
      expect(box.size.width, equals(780.0));

      // Mobile: 390 x 844
      setViewport(tester, 390, 844);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveContentContainer(
              maxWidth: 780,
              child: Container(key: const Key('feed_child_mobile'), height: 100),
            ),
          ),
        ),
      );

      final boxMobile = tester.renderObject<RenderBox>(find.byKey(const Key('feed_child_mobile')));
      expect(boxMobile.size.width, equals(390.0));
    });
  });

  group('Anti-Overflow Component Tests', () {
    testWidgets('HotRightNowCard renders cleanly on ultra-narrow 320px viewport without RenderFlex overflow', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setViewport(tester, 320, 600);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final venue = ref.watch(mockVenuesProvider).first;
                return Scaffold(
                  body: HotRightNowCard(
                    venue: venue,
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('HOT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VenueCard renders unified top row on 340px viewport without collision or overflow', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setViewport(tester, 340, 600);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final venue = ref.watch(mockVenuesProvider).first;
                return Scaffold(
                  body: SingleChildScrollView(
                    child: VenueCard(
                      venue: venue,
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('CinematicManifestoView renders without vertical overflow on low-height 480px screen', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setViewport(tester, 360, 480);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CinematicManifestoView(isManualReplay: true),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('CARTA DEL CREADOR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Modal Sheets Desktop Width Constraints', () {
    testWidgets('WeeklyEventsSheet constrains width on PC 1920px screen', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setViewport(tester, 1920, 1080);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WeeklyEventsSheet(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      final constrainedBoxFinder = find.byWidgetPredicate(
        (w) => w is ConstrainedBox && w.constraints.maxWidth == ResponsiveBreakpoints.maxModalWidth,
      );
      expect(constrainedBoxFinder, findsWidgets);
    });

    testWidgets('PatreonSupportModal constrains width on PC 1920px screen', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setViewport(tester, 1920, 1080);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PatreonSupportModal(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      final constrainedBoxFinder = find.byWidgetPredicate(
        (w) => w is ConstrainedBox && w.constraints.maxWidth == ResponsiveBreakpoints.maxModalWidth,
      );
      expect(constrainedBoxFinder, findsWidgets);
    });

    testWidgets('ExpansionRoadmapModal and IncidentReportModal constrain width on PC', (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setViewport(tester, 1920, 1080);

      // ExpansionRoadmapModal
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ExpansionRoadmapModal(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == ResponsiveBreakpoints.maxModalWidth,
        ),
        findsWidgets,
      );

      // IncidentReportModal
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: IncidentReportModal(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == ResponsiveBreakpoints.maxModalWidth,
        ),
        findsWidgets,
      );
    });
  });
}
