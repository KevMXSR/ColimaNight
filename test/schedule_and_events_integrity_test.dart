import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/domain/utils/venue_schedule_evaluator.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';
import 'package:colima_night/features/venues/presentation/widgets/flyer_lightbox_dialog.dart';
import 'package:colima_night/features/venues/presentation/widgets/live_acts_lineup_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Schedule Integrity & Evaluator Dynamic Tests', () {
    test('Venue with event occurring TODAY NEVER displays "Cerrado hoy"', () {
      final now = DateTime.now();
      final todayEvent = VenueEvent(
        id: 'test_event_today',
        title: 'Noche de Fiesta Especial',
        dateDisplay: 'Hoy 21:00 hrs',
        eventDate: DateTime(now.year, now.month, now.day, 21, 0),
        forcedIsToday: true,
      );

      final venue = VenueModel(
        id: 'foro_dmt',
        name: 'Foro DMT',
        category: 'Rock Bar',
        zone: 'Centro',
        description: 'Bar cultural',
        coverImageUrl: 'assets/images/venues/foro_dmt.jpg',
        galleryUrls: const [],
        rating: 4.8,
        reviewsCount: 300,
        capacityPercent: 0,
        vibeGenre: 'Rock',
        schedule: '8:00 PM - 3:00 AM',
        latitude: 19.2433,
        longitude: -103.7290,
        isOpenNow: false,
        closedReason: 'Cerrado hoy · Abre Jueves 20:00',
        upcomingEvents: [todayEvent],
      );

      // Evaluar en la tarde antes de abrir (16:00 hrs)
      final afternoonTime = DateTime(now.year, now.month, now.day, 16, 0);
      final afternoonStatus = VenueScheduleEvaluator.evaluate(venue, referenceTime: afternoonTime);

      expect(afternoonStatus.badgeType, equals(VenueBadgeType.openingToday));
      expect(afternoonStatus.badgeLabel, equals('Abre Hoy'));
      expect(afternoonStatus.isOpenNow, isFalse);
      expect(afternoonStatus.detailedStatus, startsWith('Abre hoy a las'));
      expect(afternoonStatus.detailedStatus, contains('Noche de Fiesta Especial'));
      expect(afternoonStatus.detailedStatus, isNot(contains('Cerrado hoy')));

      // Evaluar en plena noche durante horario operativo (22:30 hrs)
      final nightTime = DateTime(now.year, now.month, now.day, 22, 30);
      final nightStatus = VenueScheduleEvaluator.evaluate(venue, referenceTime: nightTime);

      expect(nightStatus.badgeType, equals(VenueBadgeType.open));
      expect(nightStatus.badgeLabel, equals('Abierto'));
      expect(nightStatus.isOpenNow, isTrue);
      expect(nightStatus.detailedStatus, startsWith('Abierto ahora'));
      expect(nightStatus.detailedStatus, isNot(contains('Cerrado')));
    });

    test('Venue on closed day without today event displays accurate next day schedule', () {
      final mondayAfternoon = DateTime(2026, 11, 2, 14, 0); // Lunes 14:00
      const venue = VenueModel(
        id: 'low_social_club',
        name: 'Low Social Club',
        category: 'Club',
        zone: 'Centro',
        description: 'Club nocturno',
        coverImageUrl: 'assets/images/venues/low_social_club.jpg',
        galleryUrls: [],
        rating: 4.8,
        reviewsCount: 300,
        capacityPercent: 0,
        vibeGenre: 'Tech-House',
        schedule: '10:00 PM - 5:00 AM',
        latitude: 19.2410,
        longitude: -103.7255,
        isOpenNow: false,
        upcomingEvents: [],
      );

      final status = VenueScheduleEvaluator.evaluate(venue, referenceTime: mondayAfternoon);
      expect(status.badgeType, equals(VenueBadgeType.closedToday));
      expect(status.badgeLabel, equals('Cerrado'));
      expect(status.isOpenNow, isFalse);
      expect(status.detailedStatus, contains('Jueves'));
      expect(status.detailedStatus, contains('10:00 PM'));
    });

    test('Bar La Puerta base schedule from Google Maps opens at 19:00 and is not delayed by 21:00 event', () {
      final thursdayEvening = DateTime(2026, 11, 5, 19, 30); // Jueves 19:30 hrs
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final laPuerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');

      final status = VenueScheduleEvaluator.evaluate(laPuerta, referenceTime: thursdayEvening);
      expect(status.badgeType, equals(VenueBadgeType.open));
      expect(status.badgeLabel, equals('Abierto'));
      expect(status.isOpenNow, isTrue);
    });

    test('Cervecería Chapultepec base schedule is open daily from 13:00', () {
      final sundayAfternoon = DateTime(2026, 11, 8, 14, 0); // Domingo 14:00 hrs
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final chapultepec = venues.firstWhere((v) => v.id == 'cerveceria_chapultepec');

      final status = VenueScheduleEvaluator.evaluate(chapultepec, referenceTime: sundayAfternoon);
      expect(status.badgeType, equals(VenueBadgeType.open));
      expect(status.badgeLabel, equals('Abierto'));
      expect(status.isOpenNow, isTrue);
    });
  });

  group('Secondary Profiles & Video Stories Verification Tests', () {
    test('Bar La Puerta contains @lapuertadelperreo.dog and dedicated flyer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final laPuerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');

      expect(laPuerta.instagramHandle, equals('@barlapuerta'));
      expect(laPuerta.secondaryInstagramHandle, equals('@lapuertadelperreo.dog'));
      expect(laPuerta.secondaryInstagramUrl, equals('https://www.instagram.com/lapuertadelperreo.dog/'));
      expect(laPuerta.facebookUrl, contains('barlapuertacolima'));

      final perreoEvent = laPuerta.upcomingEvents.firstWhere((e) => e.id == 'puerta_perreo_bellako');
      expect(perreoEvent.title, contains('La Puerta del Perreo'));
      expect(perreoEvent.sourceInstagramHandle, equals('@lapuertadelperreo.dog'));
      expect(perreoEvent.sourceInstagramUrl, equals('https://www.instagram.com/lapuertadelperreo.dog/'));
      expect(perreoEvent.flyerImageUrl, equals('assets/images/venues/flyers/la_puerta_del_perreo_flyer.jpg'));
    });

    test('Costa Carranza 1 contains sports match screening and video story flags', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final costaCarranza = venues.firstWhere((v) => v.id == 'costa_carranza');

      expect(costaCarranza.facebookUrl, equals('https://www.facebook.com/costacarranzacolima/'));
      expect(costaCarranza.upcomingEvents.isNotEmpty, isTrue);

      final matchEvent = costaCarranza.upcomingEvents.firstWhere((e) => e.id == 'costa_carranza_futbol_clasico');
      expect(matchEvent.isSportsMatch, isTrue);
      expect(matchEvent.isVideoStory, isTrue);
      expect(matchEvent.matchTeams, contains('CHIVAS vs AMÉRICA'));
      expect(matchEvent.broadcastDetails, contains('Pantalla Gigante HD'));
      expect(matchEvent.flyerImageUrl, equals('assets/images/venues/flyers/costa_carranza_futbol_flyer.jpg'));
      expect(matchEvent.sourceFacebookUrl, isNotNull);
    });

    test('Foro DMT and Low Social Club presale verification', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final foroDmt = venues.firstWhere((v) => v.id == 'foro_dmt');
      final dmtEvent = foroDmt.upcomingEvents.firstWhere((e) => e.id == 'foro_dmt_rock_friday');

      expect(dmtEvent.isPresaleActive, isTrue);
      expect(dmtEvent.presalePrice, contains('120'));
      expect(dmtEvent.presaleUrl, equals('https://www.instagram.com/foro_dmt/'));

      final lowClub = venues.firstWhere((v) => v.id == 'low_social_club');
      final lowEvent = lowClub.upcomingEvents.firstWhere((e) => e.id == 'low_club_friday');

      expect(lowEvent.isPresaleActive, isTrue);
      expect(lowEvent.presalePrice, contains('100'));
      expect(lowEvent.presaleUrl, equals('https://www.instagram.com/lowclub.col/'));
    });
  });

  group('Presale Ticket Link Security & UI Presentation Tests', () {
    testWidgets('FlyerLightboxDialog renders presale button ONLY when presaleUrl is present', (tester) async {
      const venue = VenueModel(
        id: 'foro_dmt',
        name: 'Foro DMT',
        category: 'Rock Bar',
        zone: 'Centro',
        description: 'Bar cultural',
        coverImageUrl: 'assets/images/venues/foro_dmt.jpg',
        galleryUrls: [],
        rating: 4.8,
        reviewsCount: 300,
        capacityPercent: 0,
        vibeGenre: 'Rock',
        schedule: '8:00 PM - 3:00 AM',
        latitude: 19.2433,
        longitude: -103.7290,
        upcomingEvents: [],
      );

      // Evento CON link de preventa verificado
      const eventWithLink = VenueEvent(
        id: 'event_with_link',
        title: 'Rock Fest con Preventa',
        dateDisplay: 'Viernes 21:00 hrs',
        isPresaleActive: true,
        presalePrice: 'Preventa: \$120 MXN',
        presaleUrl: 'https://www.instagram.com/foro_dmt/',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => FlyerLightboxDialog.show(ctx, eventWithLink, venue),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Debe mostrar el botón de compra
      expect(find.textContaining('COMPRAR PREVENTA'), findsOneWidget);

      // Cerrar diálogo
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Evento SIN link de preventa (solo taquilla)
      const eventWithoutLink = VenueEvent(
        id: 'event_without_link',
        title: 'Rock Fest Taquilla',
        dateDisplay: 'Viernes 21:00 hrs',
        isPresaleActive: true,
        presalePrice: 'Preventa: \$100 MXN en barra',
        presaleUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => FlyerLightboxDialog.show(ctx, eventWithoutLink, venue),
                child: const Text('Open Dialog 2'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog 2'));
      await tester.pumpAndSettle();

      // NO debe haber botón 'COMPRAR PREVENTA' porque presaleUrl es nulo
      expect(find.textContaining('COMPRAR PREVENTA'), findsNothing);
    });

    testWidgets('LiveActsLineupSection renders sports match and presale cards cleanly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LiveActsLineupSection(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Transmisión deportiva
      expect(find.text('TRANSMISIÓN DEPORTIVA HD'), findsOneWidget);
      expect(find.text('⚽ Clásico Nacional en Pantalla Gigante HD'), findsOneWidget);
      expect(find.text('PANTALLA GIGANTE'), findsOneWidget);

      // Preventa activa
      expect(find.text('PREVENTA DISPONIBLE'), findsWidgets);
      expect(find.text('Comprar'), findsWidgets);

      // Perfil secundario @lapuertadelperreo.dog
      expect(find.text('La Puerta del Perreo • Bellakeo Underground'), findsOneWidget);
      expect(find.text('@lapuertadelperreo.dog'), findsOneWidget);
    });
  });
}
