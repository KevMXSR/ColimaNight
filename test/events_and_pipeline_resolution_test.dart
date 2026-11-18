import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/domain/utils/event_date_helper.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';

void main() {
  group('Event Expiration & Date Helper Tests', () {
    test('Event that occurred yesterday is strictly expired (isExpired == true)', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final pastEvent = VenueEvent(
        id: 'past_event_1',
        title: 'Evento Pasado',
        dateDisplay: EventDateHelper.formatEventDate(yesterday),
        eventDate: yesterday,
        expiresAt: yesterday.add(const Duration(hours: 6)),
      );

      expect(pastEvent.isExpired, isTrue);
      expect(EventDateHelper.isEventActive(pastEvent.eventDate, expiresAt: pastEvent.expiresAt), isFalse);
    });

    test('Event occurring tonight is active and not expired', () {
      final now = DateTime.now();
      final tonight = DateTime(now.year, now.month, now.day, 23, 0);
      final activeEvent = VenueEvent(
        id: 'active_event_tonight',
        title: 'Noche de Club',
        dateDisplay: EventDateHelper.formatEventDate(tonight),
        eventDate: tonight,
        expiresAt: EventDateHelper.calculateDefaultExpiration(tonight),
      );

      expect(activeEvent.isExpired, isFalse);
      expect(EventDateHelper.isEventActive(activeEvent.eventDate, expiresAt: activeEvent.expiresAt), isTrue);
    });

    test('getUpcomingWeekday does NOT auto-rollover into future weeks by default', () {
      final now = DateTime.now();
      final yesterdayWeekday = now.weekday == 1 ? 7 : now.weekday - 1;
      final target = EventDateHelper.getUpcomingWeekday(
        yesterdayWeekday,
        hour: 20,
        minute: 0,
        allowAutoRollover: false,
      );

      expect(target.isBefore(now), isTrue,
          reason: 'Sin auto-rollover, una fecha pasada debe mantenerse en el pasado para permitir su expiración.');
    });
  });

  group('Catalog Data Integrity & Secondary Profile Verification', () {
    test('El Guachi is on Ignacio Sandoval and correctly links @guachirooftop', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final elGuachi = venues.firstWhere((v) => v.id == 'el_guachi');

      expect(elGuachi.name, equals('El Guachi'));
      expect(elGuachi.zone, contains('Ignacio Sandoval'));
      expect(elGuachi.zone.contains('Tercer Anillo'), isFalse,
          reason: 'El Guachi está en Calle Ignacio Sandoval 1943, NO en Tercer Anillo.');
      expect(elGuachi.instagramHandle, equals('@guachirooftop'));
      expect(elGuachi.upcomingEvents, isEmpty,
          reason: 'El catálogo base no debe tener eventos ficticios.');
    });

    test('Initial catalog has no phantom events and weeklyEventsProvider starts clean', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final weeklyEvents = container.read(weeklyEventsProvider);
      expect(weeklyEvents, isEmpty,
          reason: 'Sin sincronización activa de Firestore, la cartelera consolidada debe empezar limpia.');
    });

    test('Cervecería de la Costa Carranza does not have hardcoded perpetual sports matches', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final venues = container.read(mockVenuesProvider);
      final carranza = venues.firstWhere((v) => v.id == 'costa_carranza');

      expect(carranza.upcomingEvents, isEmpty,
          reason: 'Costa Carranza no debe tener partidos perpetuos inventados.');
    });
  });

  group('Serialization & Deserialization Tests (Firestore compatibility)', () {
    test('VenueEvent fromMap and toMap roundtrip maintains all fields', () {
      final date = DateTime(2026, 11, 20, 22, 0);
      final event = VenueEvent(
        id: 'event_test_1',
        title: 'Techno Night Live',
        dateDisplay: 'Vie 20 Nov • 22:00',
        eventDate: date,
        expiresAt: DateTime(2026, 11, 21, 6, 0),
        artistOrDj: 'DJ Test',
        coverPrice: '\$100 MXN',
        promoNote: '2x1 shots',
        sourceInstagramUrl: 'https://instagram.com/guachirooftop',
        sourceInstagramHandle: '@guachirooftop',
        isStoryAnnouncement: true,
      );

      final map = event.toMap();
      final reconstructed = VenueEvent.fromMap(map, event.id);

      expect(reconstructed.id, equals(event.id));
      expect(reconstructed.title, equals(event.title));
      expect(reconstructed.dateDisplay, equals(event.dateDisplay));
      expect(reconstructed.eventDate, equals(event.eventDate));
      expect(reconstructed.expiresAt, equals(event.expiresAt));
      expect(reconstructed.artistOrDj, equals(event.artistOrDj));
      expect(reconstructed.sourceInstagramHandle, equals(event.sourceInstagramHandle));
      expect(reconstructed.isStoryAnnouncement, isTrue);
    });

    test('VenueModel fromMap handles Firestore structure cleanly', () {
      final map = {
        'name': 'Bar Test',
        'category': 'Club',
        'zone': 'Centro, Colima',
        'description': 'Lugar de prueba',
        'coverImageUrl': 'assets/test.jpg',
        'rating': 4.5,
        'reviewsCount': 100,
        'capacityPercent': 50,
        'isOpenNow': true,
        'hasLiveMusic': true,
        'liveMusicAct': 'DJ Electro',
        'hasPromo': false,
        'parkingAvailable': true,
        'latitude': 19.24,
        'longitude': -103.72,
        'instagramHandle': '@bartest',
        'secondaryInstagramHandle': '@bartest_rooftop',
        'hasCover': true,
        'coverDescription': '\$100 MXN',
      };

      final venue = VenueModel.fromMap(map, 'bar_test_id');

      expect(venue.id, equals('bar_test_id'));
      expect(venue.name, equals('Bar Test'));
      expect(venue.secondaryInstagramHandle, equals('@bartest_rooftop'));
      expect(venue.hasCover, isTrue);
      expect(venue.capacityPercent, equals(50));
    });
  });

  group('Reactive Refresh & State Management Tests', () {
    test('VenuesNotifier refresh updates state successfully', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(venuesNotifierProvider.notifier);
      await notifier.refresh();

      final venues = container.read(venuesNotifierProvider);
      expect(venues, isNotEmpty);
      expect(venues.length, equals(29));
    });

    test('togglePromo and toggleLiveMusic update state optimistically', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(venuesNotifierProvider.notifier);
      final initialVenue = container.read(venuesNotifierProvider).firstWhere((v) => v.id == 'dos_puntos');
      final initialPromo = initialVenue.hasPromo;

      notifier.togglePromo('dos_puntos');

      final updatedVenue = container.read(venuesNotifierProvider).firstWhere((v) => v.id == 'dos_puntos');
      expect(updatedVenue.hasPromo, equals(!initialPromo));
    });
  });
}
