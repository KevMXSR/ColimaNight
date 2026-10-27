import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';
import 'package:colima_night/features/map/domain/models/venue_location.dart';

void main() {
  group('Venue Data & Deduplication Tests', () {
    test('mockVenuesProvider contains new venues Casa Colima and Los Toros', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      final casaColima = venues.firstWhere((v) => v.id == 'mezcaleria_casa_colima');
      expect(casaColima.name, 'Casa Colima Mezcalería');
      expect(casaColima.zone, 'Calle Aldama, Centro, Colima, Col.');
      expect(casaColima.instagramHandle, '@casa.colima.mezcaleria');
      expect(casaColima.latitude, 19.24567890123456);
      expect(casaColima.longitude, -103.72890123456789);

      final losToros = venues.firstWhere((v) => v.id == 'los_toros_barra_taurina');
      expect(losToros.name, 'Los Toros Barra Taurina');
      expect(losToros.zone, 'Santos Degollado, Centro, Colima, Col.');
      expect(losToros.latitude, 19.24390123456789);
      expect(losToros.longitude, -103.72765432109876);
    });

    test('Preserves ambient reference images for DMT Rock Bar and La Puerta Bar', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      final dmt = venues.firstWhere((v) => v.id == 'dmt_rock_bar');
      expect(dmt.coverImageUrl, 'assets/images/venues/dmt_rock_bar.jpg');

      final laPuerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');
      expect(laPuerta.coverImageUrl, 'assets/images/venues/la_puerta_bar.jpg');
    });

    test('Verified addresses match reference folder names', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      expect(venues.firstWhere((v) => v.id == 'el_guachi').zone,
          'Calle Ignacio Sandoval 1943, Paseo de La Cantera, La Cantera, 28018 Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'almada_cantina').zone,
          'Av. Constitución 2073, Residencial Santa Bárbara, Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'dos_puntos').zone,
          'Calz. Galván Norte, Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'la_regional').zone,
          'Av. Ignacio Sandoval, Plaza Vista Hermosa, Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'la_chintola').zone,
          'Zaragoza, Centro Histórico, Colima, Col.');
    });

    test('Hot right now venue is excluded from displayVenues list in feed', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final hotVenue = container.read(hotRightNowVenueProvider);
      final filteredVenues = container.read(filteredVenuesProvider);
      final searchQuery = container.read(searchQueryProvider);

      expect(hotVenue, isNotNull);
      expect(searchQuery, isEmpty);

      final displayVenues = hotVenue != null && searchQuery.isEmpty
          ? filteredVenues.where((v) => v.id != hotVenue.id).toList()
          : filteredVenues;

      expect(displayVenues.any((v) => v.id == hotVenue!.id), isFalse);
      expect(displayVenues.length, filteredVenues.length - 1);
    });
    test('Local ambient reference images are mapped to assets/images/venues/', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      final elGuachi = venues.firstWhere((v) => v.id == 'el_guachi');
      expect(elGuachi.coverImageUrl, 'assets/images/venues/el_guachi.jpg');

      final almada = venues.firstWhere((v) => v.id == 'almada_cantina');
      expect(almada.coverImageUrl, 'assets/images/venues/almada_cantina.jpg');

      final casaColima = venues.firstWhere((v) => v.id == 'mezcaleria_casa_colima');
      expect(casaColima.coverImageUrl, 'assets/images/venues/mezcaleria_casa_colima.jpg');

      final losToros = venues.firstWhere((v) => v.id == 'los_toros_barra_taurina');
      expect(losToros.coverImageUrl, 'assets/images/venues/los_toros_barra_taurina.jpg');

      final dosPuntos = venues.firstWhere((v) => v.id == 'dos_puntos');
      expect(dosPuntos.coverImageUrl, 'assets/images/venues/dos_puntos.jpg');

      final carranza2 = venues.firstWhere((v) => v.id == 'costa_carranza_2');
      expect(carranza2.coverImageUrl, 'assets/images/venues/costa_carranza_2.jpg');

      final laPaz2 = venues.firstWhere((v) => v.id == 'costa_la_paz_2');
      expect(laPaz2.coverImageUrl, 'assets/images/venues/costa_la_paz_2.jpg');
    });

    test('Geographic coordinates are aligned to actual venue landmarks', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      final sanFernando = venues.firstWhere((v) => v.id == 'costa_san_fernando');
      expect(sanFernando.latitude, 19.25052345091702);
      expect(sanFernando.longitude, -103.72265917387127);

      final elTaurino = venues.firstWhere((v) => v.id == 'el_taurino');
      expect(elTaurino.latitude, 19.24412345678901);
      expect(elTaurino.longitude, -103.72567890123456);

      final low = venues.firstWhere((v) => v.id == 'low_social_club');
      expect(low.latitude, 19.25678901234567);
      expect(low.longitude, -103.71345678901234);
    });

    test('Barezzito Easter Egg is correctly positioned at Av. Constitución', () {
      const barezzito = VenueLocation.barezzitoEasterEgg;
      expect(barezzito.coordinates.latitude, 19.257904781349012);
      expect(barezzito.coordinates.longitude, -103.7152190343091);
      expect(barezzito.address.contains('Constitución'), isTrue);
    });

    test('Active venues count is exactly 27 and excludes Taverna', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final activeVenues = venues.where((v) => !v.isPermanentlyClosed).toList();
      expect(activeVenues.length, equals(27));
      expect(venues.length, equals(28)); // 27 activos + 1 in memoriam (Barezzito)
      expect(venues.any((v) => v.name.toLowerCase().contains('taverna')), isFalse);
      expect(VenueLocation.verifiedColimaVenues.length, equals(27));
      expect(VenueLocation.verifiedColimaVenues.any((v) => v.name.toLowerCase().contains('taverna')), isFalse);
    });

    test('Foro DMT and Paraíso Drinks Colima metadata, Instagram, and events are verified', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      final foroDmt = venues.firstWhere((v) => v.id == 'foro_dmt');
      expect(foroDmt.name, equals('Foro DMT'));
      expect(foroDmt.coverImageUrl, equals('assets/images/venues/foro_dmt.jpg'));
      expect(foroDmt.galleryUrls, contains('assets/images/venues/foro_dmt_2.jpg'));
      expect(foroDmt.instagramHandle, equals('@foro_dmt'));
      expect(foroDmt.latitude, equals(19.243385050696823));
      expect(foroDmt.longitude, equals(-103.72907994355953));
      expect(foroDmt.zone, equals('C. Santos Degollado 50, Centro, 28000 Colima, Col.'));
      expect(foroDmt.hasCover, isTrue);
      expect(foroDmt.coverTag, contains('evento en vivo'));
      expect(foroDmt.whatsappReservation, isNotNull);
      expect(foroDmt.upcomingEvents.length, equals(1));

      final paraisoDrinks = venues.firstWhere((v) => v.id == 'paraiso_drinks');
      expect(paraisoDrinks.name, equals('Paraíso Drinks Colima'));
      expect(paraisoDrinks.coverImageUrl, equals('assets/images/venues/paraiso_drinks.jpg'));
      expect(paraisoDrinks.instagramHandle, equals('@paraisodrinkscolima'));
      expect(paraisoDrinks.latitude, equals(19.278276708508628));
      expect(paraisoDrinks.longitude, equals(-103.70990174232882));
      expect(paraisoDrinks.zone, equals('Av. de los Diamantes 140, Residencial Esmeralda Nte., 28017 Colima, Col.'));
      expect(paraisoDrinks.hasCover, isFalse);
      expect(paraisoDrinks.coverTag, equals('Sin Cover'));
      expect(paraisoDrinks.whatsappReservation, isNotNull);
      expect(paraisoDrinks.upcomingEvents.length, equals(0));
    });

    test('Cervecería de la Costa and Estación Colimita do not allow table reservations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final noReservationVenues = venues.where((v) =>
          v.id.startsWith('costa_') || v.id.startsWith('colimita_'));

      expect(noReservationVenues, isNotEmpty);
      for (final v in noReservationVenues) {
        expect(v.hasTableReservation, isFalse,
            reason: '${v.name} should NOT allow table reservations');
        expect(v.whatsappReservation, isNull,
            reason: '${v.name} whatsappReservation must be null');
      }
    });

    test('Real-time operational status correctly reflects open and desenergizado venues', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      // Venues open on Tuesday afternoon (cantinas / cervecerías with kitchen)
      final elTaurino = venues.firstWhere((v) => v.id == 'el_taurino');
      expect(elTaurino.isOpenNow, isTrue);
      expect(elTaurino.livePresence, greaterThan(0));

      final costaTercerAnillo = venues.firstWhere((v) => v.id == 'costa_tercer_anillo');
      expect(costaTercerAnillo.isOpenNow, isTrue);
      expect(costaTercerAnillo.livePresence, greaterThan(0));

      // Venues closed on Tuesday (nightclubs / rock bars opening later/weekend)
      final elGuachi = venues.firstWhere((v) => v.id == 'el_guachi');
      expect(elGuachi.isOpenNow, isFalse);
      expect(elGuachi.livePresence, equals(0));
      expect(elGuachi.closedReason, isNotNull);

      final lowClub = venues.firstWhere((v) => v.id == 'low_social_club');
      expect(lowClub.isOpenNow, isFalse);
      expect(lowClub.livePresence, equals(0));
      expect(lowClub.closedReason, contains('Jueves'));

      final foroDmt = venues.firstWhere((v) => v.id == 'foro_dmt');
      expect(foroDmt.isOpenNow, isFalse);
      expect(foroDmt.livePresence, equals(0));
    });

    test('Feed view mode defaults to compact (Lista Top) and toggles cleanly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(feedViewModeProvider), equals(ViewMode.compact));

      container.read(feedViewModeProvider.notifier).state = ViewMode.cards;
      expect(container.read(feedViewModeProvider), equals(ViewMode.cards));

      container.read(feedViewModeProvider.notifier).state = ViewMode.compact;
      expect(container.read(feedViewModeProvider), equals(ViewMode.compact));
    });

    test('Strict cover pricing and free admission verification', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      // Cervecería de la Costa (todas las 10 sucursales) y Estación Colimita (2) SIN cover
      final costaVenues = venues.where((v) => v.id.startsWith('costa_')).toList();
      expect(costaVenues.length, equals(10));
      for (final v in costaVenues) {
        expect(v.hasCover, isFalse, reason: '${v.name} NO debe cobrar cover');
        expect(v.coverTag, equals('Sin Cover'));
        expect(v.upcomingEvents, isEmpty, reason: '${v.name} sin eventos ficticios');
      }

      final colimitaVenues = venues.where((v) => v.id.startsWith('colimita_')).toList();
      expect(colimitaVenues.length, equals(2));
      for (final v in colimitaVenues) {
        expect(v.hasCover, isFalse, reason: '${v.name} NO debe cobrar cover');
        expect(v.coverTag, equals('Sin Cover'));
        expect(v.upcomingEvents, isEmpty, reason: '${v.name} sin eventos ficticios');
      }

      // Únicos con cover: Guachi, Dos Puntos, Low Social Club, Foro DMT
      final guachi = venues.firstWhere((v) => v.id == 'el_guachi');
      expect(guachi.hasCover, isTrue);
      expect(guachi.coverDescription, contains('100'));

      final dosPuntos = venues.firstWhere((v) => v.id == 'dos_puntos');
      expect(dosPuntos.hasCover, isTrue);
      expect(dosPuntos.coverDescription, contains('180'));

      final low = venues.firstWhere((v) => v.id == 'low_social_club');
      expect(low.hasCover, isTrue);
      expect(low.coverDescription, contains('100'));

      final foroDmt = venues.firstWhere((v) => v.id == 'foro_dmt');
      expect(foroDmt.hasCover, isTrue);
      expect(foroDmt.coverDescription, contains('evento en vivo'));
    });

    test('Strict parking details match verified user specifications', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      // Sin estacionamiento
      expect(venues.firstWhere((v) => v.id == 'el_taurino').parkingAvailable, isFalse);
      expect(venues.firstWhere((v) => v.id == 'colimita_constitucion').parkingAvailable, isFalse);
      expect(venues.firstWhere((v) => v.id == 'la_chintola').parkingAvailable, isFalse);

      // Plazas comerciales
      expect(venues.firstWhere((v) => v.id == 'costa_tercer_anillo').parkingDetails,
          'Estacionamiento Plaza del Carmen');
      expect(venues.firstWhere((v) => v.id == 'costa_san_fernando').parkingDetails,
          'Estacionamiento Plaza San Fernando');
      expect(venues.firstWhere((v) => v.id == 'el_gustito').parkingDetails,
          'Estacionamiento Plaza Vista Hermosa');
      expect(venues.firstWhere((v) => v.id == 'la_regional').parkingDetails,
          'Estacionamiento Plaza Vista Hermosa');

      // Disponibilidad variable según afluencia
      final variableParking = [
        'costa_sandoval',
        'costa_carranza',
        'costa_carranza_2',
        'costa_santa_fe',
        'costa_pablo_silva',
        'costa_la_paz',
        'costa_la_paz_2',
        'costa_griselda_alvarez',
        'almada_cantina',
        'santo_mezcal',
        'paraiso_drinks',
      ];
      for (final id in variableParking) {
        expect(venues.firstWhere((v) => v.id == id).parkingDetails,
            'Estacionamiento local (Disponibilidad variable según la afluencia)');
      }

      // Ningún establecimiento debe tener valet parking
      for (final v in venues) {
        if (v.parkingDetails != null) {
          expect(v.parkingDetails!.toLowerCase().contains('valet'), isFalse,
              reason: '${v.name} no debe mencionar valet parking');
        }
      }
    });

    test('Weekly events provider aggregates verified events with correct isToday evaluation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final weeklyEvents = container.read(weeklyEventsProvider);
      expect(weeklyEvents, isNotEmpty);

      // Los eventos de fin de semana (viernes/sábado) no deben marcar isToday en martes
      for (final item in weeklyEvents) {
        expect(item.event.isToday, isFalse,
            reason: '${item.event.title} no debe tener badge HOY fuera de su fecha');
      }
    });

    test('Top ranked venues provider selects top 5 by occupancy/capacity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final top5 = container.read(topRankedVenuesProvider);
      expect(top5.length, equals(5));

      for (int i = 0; i < top5.length - 1; i++) {
        expect(top5[i].capacityPercent >= top5[i + 1].capacityPercent, isTrue);
      }
    });
  });
}
