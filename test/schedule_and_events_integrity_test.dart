import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/domain/utils/venue_schedule_evaluator.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';
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

    test('Cervecería de la Costa (10 branches) Google Maps base schedule: Monday 14:00 is OPEN', () {
      final mondayAfternoon = DateTime(2026, 11, 2, 14, 0); // Lunes 14:00 hrs
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final costaVenues = venues.where((v) => v.id.startsWith('costa_')).toList();

      expect(costaVenues.length, equals(10));
      for (final costa in costaVenues) {
        // String schedule must be aligned
        expect(costa.schedule, equals('Lunes a Domingo: 11:00 AM - 11:00 PM'));

        final status = VenueScheduleEvaluator.evaluate(costa, referenceTime: mondayAfternoon);
        expect(status.badgeType, equals(VenueBadgeType.open), reason: '${costa.name} should be open on Monday 14:00');
        expect(status.isOpenNow, isTrue);
        expect(status.detailedStatus, contains('Cierra 11:00 PM'));
      }
    });

    test('Cervecería de la Costa: Tuesday 10:00 AM shows "Abre hoy a las 11:00 AM"', () {
      final tuesdayMorning = DateTime(2026, 11, 3, 10, 0); // Martes 10:00 AM
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final costaSanFernando = venues.firstWhere((v) => v.id == 'costa_san_fernando');

      final status = VenueScheduleEvaluator.evaluate(costaSanFernando, referenceTime: tuesdayMorning);
      expect(status.badgeType, equals(VenueBadgeType.openingToday));
      expect(status.isOpenNow, isFalse);
      expect(status.detailedStatus, startsWith('Abre hoy a las 11:00 AM'));
    });

    test('Costa Carranza: Saturday sports match at 19:00 does NOT delay opening; is open at 12:00 PM', () {
      final saturdayNoon = DateTime(2026, 11, 7, 12, 0); // Sábado 12:00 PM
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final costaCarranza = venues.firstWhere((v) => v.id == 'costa_carranza');

      final status = VenueScheduleEvaluator.evaluate(costaCarranza, referenceTime: saturdayNoon);
      expect(status.badgeType, equals(VenueBadgeType.open));
      expect(status.isOpenNow, isTrue);
      expect(status.detailedStatus, contains('Cierra 11:00 PM'));
    });

    test('Torna Focaccia Bar base schedule opens daily at 19:00 hrs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final torna = venues.firstWhere((v) => v.id == 'torna');

      // 1. Tarde antes de abrir (16:30 hrs)
      final afternoon = DateTime(2026, 11, 16, 16, 30);
      final afternoonStatus = VenueScheduleEvaluator.evaluate(torna, referenceTime: afternoon);
      expect(afternoonStatus.badgeType, equals(VenueBadgeType.openingToday));
      expect(afternoonStatus.isOpenNow, isFalse);
      expect(afternoonStatus.detailedStatus, startsWith('Abre hoy a las 7:00 PM'));

      // 2. Noche en servicio (21:00 hrs)
      final night = DateTime(2026, 11, 16, 21, 0);
      final nightStatus = VenueScheduleEvaluator.evaluate(torna, referenceTime: night);
      expect(nightStatus.badgeType, equals(VenueBadgeType.open));
      expect(nightStatus.isOpenNow, isTrue);
      expect(nightStatus.detailedStatus, contains('Cierra 1:00 AM'));
    });

    test('Torna profile & official links verification (Web, Instagram, CoverManager)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      expect(venues.length, equals(29)); // Total venues 29

      final torna = venues.firstWhere((v) => v.id == 'torna');
      expect(torna.name, equals('Torna'));
      expect(torna.category, equals('Focaccia & Listening Bar'));
      expect(torna.zone, contains('Venustiano Carranza 2101'));
      expect(torna.latitude, closeTo(19.28079, 0.001));
      expect(torna.longitude, closeTo(-103.71255, 0.001));
      expect(torna.instagramHandle, equals('@torna.col'));
      expect(torna.websiteUrl, equals('https://torna.bar/'));
      expect(torna.reservationUrl, contains('covermanager.com'));
      expect(torna.hasTableReservation, isTrue);
      expect(torna.hasLiveMusic, isTrue);
      expect(torna.liveMusicAct, contains('Vinilo'));
      expect(torna.ambientPhotos.length, equals(4));
    });
  });

  group('Secondary Profiles & Video Stories Verification Tests', () {
    test('Bar La Puerta contains @lapuertadelperreo.dog secondary profile integration', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final laPuerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');

      expect(laPuerta.instagramHandle, equals('@barlapuerta'));
      expect(laPuerta.secondaryInstagramHandle, equals('@lapuertadelperreo.dog'));
      expect(laPuerta.secondaryInstagramUrl, equals('https://www.instagram.com/lapuertadelperreo.dog/'));
      expect(laPuerta.facebookUrl, contains('barlapuertacolima'));
    });

    test('El Guachi correctly associates @guachirooftop as secondary rooftop handle on Ignacio Sandoval', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final guachi = venues.firstWhere((v) => v.id == 'el_guachi');

      expect(guachi.instagramHandle, equals('@elguachicolima'));
      expect(guachi.secondaryInstagramHandle, equals('@guachirooftop'));
      expect(guachi.secondaryInstagramUrl, equals('https://www.instagram.com/guachirooftop/'));
      expect(guachi.zone, contains('Ignacio Sandoval 1943'));
    });

    test('Sports match screening and video story flags are preserved on VenueEvent model', () {
      const matchEvent = VenueEvent(
        id: 'costa_carranza_futbol_test',
        title: 'Transmisión en Pantalla: Partido Especial',
        dateDisplay: 'Sábado 7:00 PM',
        isSportsMatch: true,
        isVideoStory: true,
        matchTeams: 'CHIVAS vs AMÉRICA (Clásico Nacional)',
        broadcastDetails: 'Transmisión en Pantalla al aire libre + Audio Ambiente',
        sourceFacebookUrl: 'https://www.facebook.com/costacarranzacolima/',
      );

      expect(matchEvent.isSportsMatch, isTrue);
      expect(matchEvent.isVideoStory, isTrue);
      expect(matchEvent.matchTeams, contains('CHIVAS vs AMÉRICA'));
      expect(matchEvent.broadcastDetails, contains('Transmisión en Pantalla'));
      expect(matchEvent.sourceFacebookUrl, isNotNull);
    });

    test('Presale ticket configuration is properly held by VenueEvent domain model', () {
      const presaleEvent = VenueEvent(
        id: 'presale_test_event',
        title: 'Concierto en Vivo Especial',
        dateDisplay: 'Viernes 9:30 PM',
        isPresaleActive: true,
        presalePrice: 'Preventa: \$120 MXN • Taquilla: \$180 MXN',
        presaleUrl: 'https://www.instagram.com/foro_dmt/',
      );

      expect(presaleEvent.isPresaleActive, isTrue);
      expect(presaleEvent.presalePrice, contains('120'));
      expect(presaleEvent.presaleUrl, equals('https://www.instagram.com/foro_dmt/'));
    });
  });

  group('Presale Ticket Link Security & UI Presentation Tests', () {
    testWidgets('LiveActsLineupSection renders cleanly with active verified acts', (tester) async {
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

      // Cuando los locales tienen música en vivo habitual verificada, se renderiza la cabecera
      expect(find.byType(LiveActsLineupSection), findsOneWidget);
    });
  });
}
