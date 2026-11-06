import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';
import 'package:colima_night/features/venues/presentation/widgets/flyer_lightbox_dialog.dart';
import 'package:colima_night/features/venues/presentation/widgets/live_acts_lineup_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Social Stories & Flyers Domain Model Tests', () {
    test('VenueEvent holds flyer image, Instagram source, story flag, and special schedule', () {
      const event = VenueEvent(
        id: 'puerta_jueves_test',
        title: 'Jueves de Snacks & Drinks',
        dateDisplay: 'Jueves 7:00 PM',
        promoNote: 'Snacks y Drinks a partir de las 7:00 PM',
        flyerImageUrl: 'assets/images/venues/flyers/bar_la_puerta_flyer.jpg',
        sourceInstagramUrl: 'https://www.instagram.com/barlapuerta/',
        sourceInstagramHandle: '@barlapuerta',
        isStoryAnnouncement: true,
        specialSchedule: 'Apertura especial 7:00 PM',
      );

      expect(event.flyerImageUrl, 'assets/images/venues/flyers/bar_la_puerta_flyer.jpg');
      expect(event.sourceInstagramUrl, 'https://www.instagram.com/barlapuerta/');
      expect(event.sourceInstagramHandle, '@barlapuerta');
      expect(event.isStoryAnnouncement, isTrue);
      expect(event.specialSchedule, 'Apertura especial 7:00 PM');
    });

    test('VenueModel supports secondary Instagram handles and links for rooftops/clubs', () {
      const venue = VenueModel(
        id: 'guachi_test',
        name: 'El Guachi',
        category: 'Club & Antro',
        zone: 'Calle Ignacio Sandoval 1943',
        description: 'Club nocturno',
        coverImageUrl: 'assets/images/venues/el_guachi.jpg',
        galleryUrls: [],
        rating: 4.9,
        reviewsCount: 412,
        capacityPercent: 0,
        latitude: 19.263,
        longitude: -103.704,
        vibeGenre: 'Perreo / Tech-House',
        schedule: '9:30 PM - 5:30 AM',
        instagramHandle: '@guachirooftop',
        secondaryInstagramHandle: '@elguachicolima',
        secondaryInstagramUrl: 'https://www.instagram.com/elguachicolima/',
      );

      expect(venue.instagramHandle, '@guachirooftop');
      expect(venue.secondaryInstagramHandle, '@elguachicolima');
      expect(venue.secondaryInstagramUrl, 'https://www.instagram.com/elguachicolima/');

      final copied = venue.copyWith(secondaryInstagramHandle: '@elguachiclub');
      expect(copied.secondaryInstagramHandle, '@elguachiclub');
      expect(copied.instagramHandle, '@guachirooftop');
    });
  });

  group('Bar La Puerta & El Guachi Rooftop Catalog Tests', () {
    test('Bar La Puerta is configured with @barlapuerta, Thursday schedule, and promo headline', () {
      final container = ProviderContainer();
      final venues = container.read(mockVenuesProvider);

      final puerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');
      expect(puerta.name, 'Bar La Puerta');
      expect(puerta.instagramHandle, '@barlapuerta');
      expect(puerta.schedule, contains('7:00 PM'));
      expect(puerta.hasPromo, isTrue);
      expect(puerta.promoHeadline, contains('7:00 PM'));

      // Check upcoming events include Thursday Snacks & Drinks
      final thursdayEvent = puerta.upcomingEvents.firstWhere((e) => e.id == 'puerta_jueves_snacks_drinks');
      expect(thursdayEvent.title, contains('Snacks & Drinks'));
      expect(thursdayEvent.sourceInstagramUrl, 'https://www.instagram.com/barlapuerta/');
      expect(thursdayEvent.sourceInstagramHandle, '@barlapuerta');
      expect(thursdayEvent.isStoryAnnouncement, isTrue);
      expect(thursdayEvent.flyerImageUrl, isNotNull);
    });

    test('El Guachi is linked to @guachirooftop with Rooftop Sunset Session and flyer', () {
      final container = ProviderContainer();
      final venues = container.read(mockVenuesProvider);

      final guachi = venues.firstWhere((v) => v.id == 'el_guachi');
      expect(guachi.instagramHandle, '@guachirooftop');
      expect(guachi.secondaryInstagramHandle, '@elguachicolima');
      expect(guachi.hasPromo, isTrue);

      final sunsetEvent = guachi.upcomingEvents.firstWhere((e) => e.id == 'guachi_rooftop_sunset');
      expect(sunsetEvent.title, contains('Sunset Session'));
      expect(sunsetEvent.sourceInstagramUrl, 'https://www.instagram.com/guachirooftop/');
      expect(sunsetEvent.isStoryAnnouncement, isTrue);
      expect(sunsetEvent.flyerImageUrl, isNotNull);
    });
  });

  group('2x1 & Promos Filter Integration Tests', () {
    test('VenueFilterChip.promos includes venues with hasPromo: true and story promo announcements', () {
      final container = ProviderContainer();

      // Set filter to promos
      container.read(selectedFilterChipProvider.notifier).state = VenueFilterChip.promos;
      final promoVenues = container.read(filteredVenuesProvider);

      final promoIds = promoVenues.map((v) => v.id).toList();

      // Ensure Bar La Puerta and El Guachi are included in 2x1 & Promos
      expect(promoIds, contains('la_puerta_bar'));
      expect(promoIds, contains('el_guachi'));
      expect(promoIds, contains('dos_puntos'));
      expect(promoIds, contains('low_social_club'));

      // All returned venues have hasPromo true or promoNote in upcomingEvents
      for (final venue in promoVenues) {
        final hasPromoOrNote = venue.hasPromo ||
            venue.upcomingEvents.any((e) => e.promoNote != null && e.promoNote!.isNotEmpty);
        expect(hasPromoOrNote, isTrue);
      }
    });
  });

  group('FlyerLightboxDialog Widget Tests', () {
    testWidgets('FlyerLightboxDialog renders title, Instagram button, and handle', (tester) async {
      const event = VenueEvent(
        id: 'test_event',
        title: 'Sunset Session Guachi Rooftop',
        dateDisplay: 'Jueves 6:00 PM',
        specialSchedule: 'Apertura 6:00 PM',
        promoNote: '2x1 en mixología antes de 9:00 PM',
        flyerImageUrl: 'assets/images/venues/flyers/guachi_rooftop_flyer.jpg',
        sourceInstagramUrl: 'https://www.instagram.com/guachirooftop/',
        sourceInstagramHandle: '@guachirooftop',
        isStoryAnnouncement: true,
      );

      const venue = VenueModel(
        id: 'el_guachi',
        name: 'El Guachi',
        category: 'Club & Antro',
        zone: 'Calle Ignacio Sandoval',
        description: 'Club nocturno',
        coverImageUrl: 'assets/images/venues/el_guachi.jpg',
        galleryUrls: [],
        rating: 4.9,
        reviewsCount: 400,
        capacityPercent: 0,
        latitude: 19.26,
        longitude: -103.70,
        vibeGenre: 'Perreo / House',
        schedule: '9:30 PM - 5:30 AM',
        instagramHandle: '@guachirooftop',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlyerLightboxDialog(
              event: event,
              venue: venue,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sunset Session Guachi Rooftop'), findsOneWidget);
      expect(find.text('HISTORIA OFICIAL'), findsOneWidget);
      expect(find.text('VER EN INSTAGRAM DEL ESTABLECIMIENTO'), findsOneWidget);
      expect(find.textContaining('@guachirooftop'), findsWidgets);
      expect(find.textContaining('2x1 en mixología'), findsOneWidget);
    });
  });

  group('Cryptographic Image Uniqueness & Non-Collision Tests', () {
    test('All venue flyers have unique MD5 hashes and no duplicate binaries exist', () {
      final flyerFiles = [
        'assets/images/venues/flyers/bar_la_puerta_flyer.jpg',
        'assets/images/venues/flyers/dos_puntos_flyer.jpg',
        'assets/images/venues/flyers/guachi_rooftop_flyer.jpg',
        'assets/images/venues/flyers/low_social_flyer.jpg',
        'assets/images/venues/flyers/foro_dmt_rock_flyer.jpg',
      ];

      final Map<String, String> hashes = {};
      for (final path in flyerFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'File must exist on disk: $path');
        final bytes = file.readAsBytesSync();
        final md5Hash = md5.convert(bytes).toString();
        
        expect(hashes.containsKey(md5Hash), isFalse,
            reason: 'Collision detected! $path shares binary content with ${hashes[md5Hash]}');
        hashes[md5Hash] = path;
      }

      // Explicit check: Bar La Puerta flyer must NOT equal Dos Puntos flyer or Dos Puntos cover
      final puertaFlyer = md5.convert(File('assets/images/venues/flyers/bar_la_puerta_flyer.jpg').readAsBytesSync()).toString();
      final dosPuntosFlyer = md5.convert(File('assets/images/venues/flyers/dos_puntos_flyer.jpg').readAsBytesSync()).toString();
      final dosPuntosCover = md5.convert(File('assets/images/venues/dos_puntos.jpg').readAsBytesSync()).toString();

      expect(puertaFlyer != dosPuntosFlyer, isTrue);
      expect(puertaFlyer != dosPuntosCover, isTrue);
    });
  });

  group('LiveActsLineupSection Adaptive Genre Music Tests', () {
    testWidgets('LiveActsLineupSection renders adaptive genre badges and live acts', (tester) async {
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

      // Verify Header
      expect(find.text('CARTELERA DE MÚSICA EN VIVO & DJS'), findsOneWidget);

      // Verify Genre Badges rendered
      expect(find.text('ROCK & METAL'), findsOneWidget);
      expect(find.text('TECH-HOUSE & DJS'), findsWidgets);
      expect(find.text('PERREO & URBANO'), findsWidgets);
      expect(find.text('INDIE & VINYL'), findsOneWidget);
      expect(find.text('MARIACHI & BOHEMIA'), findsOneWidget);
      expect(find.text('TRANSMISIÓN DEPORTIVA HD'), findsOneWidget);

      // Verify specific acts
      expect(find.text('Bandas Locales & Noche de Rock en Vivo'), findsOneWidget);
      expect(find.text('DJ Sets Perreo Old School & Snacks'), findsOneWidget);
      expect(find.text('La Puerta del Perreo • Bellakeo Underground'), findsOneWidget);
      expect(find.text('⚽ Clásico Nacional en Pantalla Gigante HD'), findsOneWidget);
      expect(find.text('DJ Set en Terraza & Mezclas Funk / Indie'), findsOneWidget);
      expect(find.text('Mariachi & Banda Acústica en Vivo'), findsOneWidget);

      // Verify buttons
      expect(find.text('Ver Local'), findsWidgets);
      expect(find.text('Ruta'), findsWidgets);
    });
  });
}
