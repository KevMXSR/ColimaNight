import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colima_night/features/splash/presentation/providers/manifesto_provider.dart';
import 'package:colima_night/features/splash/presentation/views/cinematic_manifesto_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cinematic Manifesto & View Count Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ManifestoViewCountNotifier increments and respects 3-5 limit (auto-shows 4 times)', () async {
      SharedPreferences.setMockInitialValues({kManifestoViewCountKey: 0});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(manifestoViewCountProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));

      // Initial state
      expect(notifier.shouldAutoShow, isTrue);

      // Increment 1
      await notifier.recordView();
      expect(container.read(manifestoViewCountProvider).value, equals(1));
      expect(notifier.shouldAutoShow, isTrue);

      // Increment to 4
      await notifier.recordView();
      await notifier.recordView();
      await notifier.recordView();
      expect(container.read(manifestoViewCountProvider).value, equals(4));

      // After 4 views (between 3 and 5 times), auto-show turns false
      expect(notifier.shouldAutoShow, isFalse);
    });

    testWidgets('CinematicManifestoView renders Scene 1 with verified author dedication',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CinematicManifestoView(isManualReplay: true),
          ),
        ),
      );

      // Let animations settle
      await tester.pump(const Duration(milliseconds: 100));

      // Header / Badge
      expect(find.textContaining('CARTA DEL CREADOR'), findsOneWidget);
      expect(find.textContaining('El Origen & La Dedicatoria'), findsOneWidget);

      // Dedicated text from the author
      expect(
        find.textContaining('Colima Night nació en el silencio de una madrugada'),
        findsOneWidget,
      );
      expect(
        find.textContaining('De mí, y desde mi soledad, hacia la gente verdaderamente excepcional de Colima'),
        findsOneWidget,
      );

      // Controls
      expect(find.text('Cerrar'), findsOneWidget);
    });

    testWidgets('CinematicManifestoView does not auto-advance and waits for click or tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CinematicManifestoView(isManualReplay: true),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('CARTA DEL CREADOR'), findsOneWidget);

      // Advance clock by 10 simulated seconds without touching
      await tester.pump(const Duration(seconds: 10));

      // It must STILL be on Scene 1 (no auto-advance)
      expect(find.textContaining('CARTA DEL CREADOR'), findsOneWidget);
      expect(find.textContaining('LA REALIDAD DE LA NOCHE'), findsNothing);
    });

    testWidgets('CinematicManifestoView advances manually through all 5 approved scenes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CinematicManifestoView(isManualReplay: true),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Scene 1 -> Tap forward button to Scene 2
      final forwardIcon = find.byIcon(Icons.arrow_forward_ios_rounded);
      expect(forwardIcon, findsOneWidget);
      await tester.tap(forwardIcon);
      await tester.pump(const Duration(milliseconds: 650));

      // Scene 2 text requested by user
      expect(find.textContaining('LA REALIDAD DE LA NOCHE'), findsOneWidget);
      expect(
        find.textContaining('en un salón, un bar, un lugar especial— termina en decepción'),
        findsOneWidget,
      );
      expect(
        find.textContaining('un ambiente diferente al que aspiraste'),
        findsOneWidget,
      );

      // Scene 2 -> Tap forward button to Scene 3
      await tester.tap(forwardIcon);
      await tester.pump(const Duration(milliseconds: 650));

      // Scene 3 text requested by user
      expect(find.textContaining('EL RADAR HONESTO'), findsOneWidget);
      expect(
        find.textContaining('No es un directorio inflado ni trata de vender aforos falsos'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Es el pulso real de la ciudad'),
        findsOneWidget,
      );

      // Scene 3 -> Tap forward button to Scene 4 ("Asistencia a la App")
      await tester.tap(forwardIcon);
      await tester.pump(const Duration(milliseconds: 650));

      // Scene 4 text requested by user
      expect(find.textContaining('ASISTENCIA A LA APP'), findsOneWidget);
      expect(
        find.textContaining('Colima Night cobra vida gracias a ti'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Mientras más comunidad se sume, mejor y más precisa será nuestra brújula'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Conéctate y ayúdanos a mostrar la información más precisa del ambiente'),
        findsOneWidget,
      );

      // Scene 4 -> Tap forward button to Scene 5 ("Nuestra Comunidad & Bienvenida")
      await tester.tap(forwardIcon);
      await tester.pump(const Duration(milliseconds: 650));

      // Scene 5 text requested by user
      expect(find.textContaining('NUESTRA COMUNIDAD'), findsOneWidget);
      expect(
        find.textContaining('Hecho con el corazón, espero y te sirva'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Bienvenidos a Colima Night.'),
        findsOneWidget,
      );

      // Final CTA button appears
      expect(find.text('ENTRAR A COLIMA NIGHT'), findsOneWidget);
    });
  });
}
