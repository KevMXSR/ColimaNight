import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';
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
    test('Bar La Puerta is configured with @barlapuerta, secondary profile and Thursday schedule', () {
      final container = ProviderContainer();
      final venues = container.read(mockVenuesProvider);

      final puerta = venues.firstWhere((v) => v.id == 'la_puerta_bar');
      expect(puerta.name, 'Bar La Puerta');
      expect(puerta.instagramHandle, '@barlapuerta');
      expect(puerta.secondaryInstagramHandle, '@lapuertadelperreo.dog');
      expect(puerta.secondaryInstagramUrl, 'https://www.instagram.com/lapuertadelperreo.dog/');
      expect(puerta.schedule, contains('7:00 PM'));
    });

    test('El Guachi is linked to @elguachicolima with secondary handle @guachirooftop', () {
      final container = ProviderContainer();
      final venues = container.read(mockVenuesProvider);

      final guachi = venues.firstWhere((v) => v.id == 'el_guachi');
      expect(guachi.instagramHandle, '@elguachicolima');
      expect(guachi.secondaryInstagramHandle, '@guachirooftop');
      expect(guachi.secondaryInstagramUrl, 'https://www.instagram.com/guachirooftop/');
      expect(guachi.zone, contains('Ignacio Sandoval 1943'));
    });
  });

  group('2x1 & Promos Filter Integration Tests', () {
    test('VenueFilterChip.promos includes venues with hasPromo: true when toggled or active', () {
      final container = ProviderContainer();

      // Activar una promo controlada en un venue sin promo inicial
      container.read(venuesNotifierProvider.notifier).togglePromo('paraiso_drinks', promoHeadline: '2x1 en Mixología de 7 a 9 PM');

      // Set filter to promos
      container.read(selectedFilterChipProvider.notifier).state = VenueFilterChip.promos;
      final promoVenues = container.read(filteredVenuesProvider);

      final promoIds = promoVenues.map((v) => v.id).toList();
      expect(promoIds, contains('paraiso_drinks'));

      // All returned venues have hasPromo true or promoNote in upcomingEvents
      for (final venue in promoVenues) {
        final hasPromoOrNote = venue.hasPromo ||
            venue.upcomingEvents.any((e) => e.promoNote != null && e.promoNote!.isNotEmpty);
        expect(hasPromoOrNote, isTrue);
      }
    });
  });

  group('Cryptographic Image Uniqueness & Non-Collision Tests', () {
    test('All venue authentic photos have unique MD5 hashes and no duplicate binaries exist', () {
      final venuePhotos = [
        'assets/images/venues/bar_la_puerta.jpg',
        'assets/images/venues/dos_puntos.jpg',
        'assets/images/venues/el_guachi.jpg',
        'assets/images/venues/low_social_club.jpg',
        'assets/images/venues/foro_dmt.jpg',
        'assets/images/venues/cerveceria_chapultepec.jpg',
      ];

      final Map<String, String> hashes = {};
      for (final path in venuePhotos) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'File must exist on disk: $path');
        final bytes = file.readAsBytesSync();
        final md5Hash = md5.convert(bytes).toString();
        
        expect(hashes.containsKey(md5Hash), isFalse,
            reason: 'Collision detected! $path shares binary content with ${hashes[md5Hash]}');
        hashes[md5Hash] = path;
      }

      // Explicit check: Bar La Puerta authentic photo must NOT equal Dos Puntos photo
      final puertaPhoto = md5.convert(File('assets/images/venues/bar_la_puerta.jpg').readAsBytesSync()).toString();
      final dosPuntosPhoto = md5.convert(File('assets/images/venues/dos_puntos.jpg').readAsBytesSync()).toString();

      expect(puertaPhoto != dosPuntosPhoto, isTrue);
    });
  });

  group('LiveActsLineupSection Adaptive Genre Music Tests', () {
    testWidgets('LiveActsLineupSection renders adaptive genre badges and live acts cleanly', (tester) async {
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
      expect(find.text('Ver Local'), findsWidgets);
      expect(find.text('Ruta'), findsWidgets);
    });
  });
}
