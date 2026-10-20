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
      expect(casaColima.name, 'Casa Colima mezcaleria');
      expect(casaColima.zone, 'Calle Venustiano Carranza 60, Centro, 28000 Colima, Col.');
      expect(casaColima.instagramHandle, '@casa.colima.mezcaleria');
      expect(casaColima.latitude, 19.244704192799993);
      expect(casaColima.longitude, -103.72786144335059);

      final losToros = venues.firstWhere((v) => v.id == 'los_toros_barra_taurina');
      expect(losToros.name, 'Los Toros Barra Taurina');
      expect(losToros.zone, 'Emilio Carranza #164, Centro, 28000 Colima, Col.');
      expect(losToros.instagramHandle, '@lostorosbarrataurina');
      expect(losToros.latitude, 19.24266787069572);
      expect(losToros.longitude, -103.722301619548);
    });

    test('Preserves ambient reference images for DMT Rock Bar and La Puerta Bar', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      final dmt = venues.firstWhere((v) => v.id == 'dmt_rock_bar');
      expect(dmt.coverImageUrl, 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=1200&q=80');

      final laPuerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');
      expect(laPuerta.coverImageUrl, 'https://images.unsplash.com/photo-1545128485-c400e7702796?auto=format&fit=crop&w=1200&q=80');
    });

    test('Verified addresses match reference folder names', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);

      expect(venues.firstWhere((v) => v.id == 'el_guachi').zone,
          'Calle Ignacio Sandoval 1943, Paseo de La Cantera, La Cantera, 28018 Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'almada_cantina').zone,
          'Calle Ignacio Sandoval 1906-Loc 4-5, Las Pergolas, 28018 Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'dos_puntos').zone,
          'C. Santos Degollado 34, Centro, 28000 Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'la_regional').zone,
          'Calle Ignacio Sandoval 1866, Real Vista Hermosa, 28000 Colima, Col.');
      expect(venues.firstWhere((v) => v.id == 'la_chintola').zone,
          '28010, Felipe Sevilla del Río 601, José María Morelos, 28000 Colima, Col.');
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
      expect(sanFernando.latitude, 19.25238924521272);
      expect(sanFernando.longitude, -103.72060620420548);

      final elTaurino = venues.firstWhere((v) => v.id == 'el_taurino');
      expect(elTaurino.latitude, 19.241001022989938);
      expect(elTaurino.longitude, -103.72426068358524);

      final low = venues.firstWhere((v) => v.id == 'low_social_club');
      expect(low.latitude, 19.241007671540903);
      expect(low.longitude, -103.72559862649845);
    });

    test('Barezzito Easter Egg is correctly positioned at Av. Constitución', () {
      const barezzito = VenueLocation.barezzitoEasterEgg;
      expect(barezzito.coordinates.latitude, 19.257904781349012);
      expect(barezzito.coordinates.longitude, -103.7152190343091);
      expect(barezzito.address.contains('Constitución'), isTrue);
    });
  });
}
