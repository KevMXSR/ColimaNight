import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colima_night/features/venues/domain/models/venue_model.dart';
import 'package:colima_night/features/venues/domain/utils/event_date_helper.dart';
import 'package:colima_night/features/venues/presentation/providers/venue_providers.dart';

void main() {
  group('Recurring Promotions & Event Focus Tests', () {
    test('Recurring promo stays active indefinitely without permanent expiration', () {
      const thursdayPromo = VenueEvent(
        id: 'promo_jueves_costa',
        title: 'Jueves 2x1 en Cerveza Artesanal',
        dateDisplay: 'Cada Jueves',
        isRecurring: true,
        recurringWeekday: 4, // Jueves
        promoNote: '2x1 en tarros toda la noche',
      );

      expect(thursdayPromo.isRecurring, isTrue);
      expect(thursdayPromo.isExpired, isFalse,
          reason: 'Las promociones recurrentes nunca caducan permanentemente.');
      expect(thursdayPromo.statusBadge.contains('Cada Jueves'), isTrue);
    });

    test('Upcoming event displays Proximamente before the event date and expires after 06:00 AM next day', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 22, 0);
      final upcomingEvent = VenueEvent(
        id: 'upcoming_event_1',
        title: 'Fiesta de Fin de Semana',
        dateDisplay: EventDateHelper.formatEventDate(tomorrow),
        eventDate: tomorrow,
        expiresAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day + 1, 6, 0),
      );

      expect(upcomingEvent.isUpcoming, isTrue);
      expect(upcomingEvent.isToday, isFalse);
      expect(upcomingEvent.isExpired, isFalse);
      expect(upcomingEvent.statusBadge, equals('Próximamente'));
    });

    test('Today event shows status ¡Hoy! and active badge', () {
      final now = DateTime.now();
      final tonight = DateTime(now.year, now.month, now.day, 21, 30);
      final todayEvent = VenueEvent(
        id: 'event_tonight_1',
        title: 'Noche de Club en Vivo',
        dateDisplay: EventDateHelper.formatEventDate(tonight),
        eventDate: tonight,
        expiresAt: DateTime(now.year, now.month, now.day + 1, 6, 0),
      );

      expect(todayEvent.isToday, isTrue);
      expect(todayEvent.isUpcoming, isFalse);
      expect(todayEvent.isExpired, isFalse);
      expect(todayEvent.statusBadge, equals('¡Hoy!'));
    });
  });

  group('Public App Security & Separation Verification', () {
    test('Public Flutter codebase does NOT expose Curation Studio or PIN inputs to users', () {
      final authModalFile = File('lib/features/auth/presentation/widgets/auth_modal.dart');
      expect(authModalFile.existsSync(), isTrue);
      final authModalContent = authModalFile.readAsStringSync();

      expect(authModalContent.contains('CurationStudio'), isFalse,
          reason: 'El Studio NO debe figurar en el modal de autenticación de usuarios públicos.');
      expect(authModalContent.contains('2026'), isFalse,
          reason: 'El PIN maestro nunca debe estar hardcodeado en la interfaz pública.');

      final feedViewFile = File('lib/features/venues/presentation/views/discovery_feed_view.dart');
      expect(feedViewFile.existsSync(), isTrue);
      final feedContent = feedViewFile.readAsStringSync();

      expect(feedContent.contains('CurationStudio'), isFalse,
          reason: 'El feed público debe permanecer 100% limpio de interfaces de administración.');
    });

    test('Standalone Curation Studio files exist in tool/studio/ isolated from public app', () {
      final studioHtml = File('tool/studio/index.html');
      final studioJs = File('tool/studio/app.js');
      final studioServer = File('tool/studio/serve.dart');
      final exportTool = File('tool/export_weekly_events.dart');

      expect(studioHtml.existsSync(), isTrue);
      expect(studioJs.existsSync(), isTrue);
      expect(studioServer.existsSync(), isTrue);
      expect(exportTool.existsSync(), isTrue);

      final htmlContent = studioHtml.readAsStringSync();
      expect(htmlContent.contains('id="venuesList"'), isTrue,
          reason: 'Debe contener la lista maestra vertical de establecimientos.');
      expect(htmlContent.contains('id="eventSchedule"'), isTrue,
          reason: 'Debe incluir el apartado de horarios de promoción.');
      expect(htmlContent.contains('id="flyerDropzone"'), isTrue,
          reason: 'Debe incluir la dropzone para carga de capturas y portapapeles.');

      final pubspecContent = File('pubspec.yaml').readAsStringSync();
      expect(pubspecContent.contains('assets/images/venues/flyers/'), isTrue,
          reason: 'La carpeta de flyers debe estar registrada en pubspec.yaml.');

      final serverContent = studioServer.readAsStringSync();
      expect(serverContent.contains('/api/upload'), isTrue,
          reason: 'El servidor local de Dart debe contar con el endpoint de subida /api/upload.');
    });
  });

  group('Serialization of Curated Events with Recurring, Schedule and Flyer Data', () {
    test('VenueEvent fromMap and toMap preserve recurring, specialSchedule and flyer properties', () {
      const event = VenueEvent(
        id: 'test_curated_1',
        title: 'Sunset Rooftop Session',
        dateDisplay: 'Cada Viernes • 7:00 PM - 11:00 PM',
        specialSchedule: '7:00 PM - 11:00 PM',
        isRecurring: true,
        recurringWeekday: 5,
        flyerImageUrl: 'assets/images/venues/flyers/flyer_el_guachi_12345.jpg',
        sourceInstagramHandle: '@guachirooftop',
        sourceInstagramUrl: 'https://instagram.com/guachirooftop',
        promoNote: '2x1 en mixología',
      );

      final map = event.toMap();
      expect(map['isRecurring'], isTrue);
      expect(map['recurringWeekday'], equals(5));
      expect(map['specialSchedule'], equals('7:00 PM - 11:00 PM'));
      expect(map['flyerImageUrl'], equals('assets/images/venues/flyers/flyer_el_guachi_12345.jpg'));

      final reconstructed = VenueEvent.fromMap(map, event.id);
      expect(reconstructed.isRecurring, isTrue);
      expect(reconstructed.recurringWeekday, equals(5));
      expect(reconstructed.specialSchedule, equals('7:00 PM - 11:00 PM'));
      expect(reconstructed.flyerImageUrl, equals(event.flyerImageUrl));
      expect(reconstructed.promoNote, equals('2x1 en mixología'));
    });
  });

  group('Social Media Catalog Integrity Tests (Anti-Hallucination & Accurate Handles)', () {
    test('Studio app.js catalog associates El Guachi with @guachirooftop and has no fake handles', () {
      final jsContent = File('tool/studio/app.js').readAsStringSync();

      expect(jsContent.contains("@elguachicolima"), isFalse,
          reason: 'El handle @elguachicolima fue inventado y no debe existir.');
      expect(jsContent.contains("id: 'el_guachi', name: 'El Guachi'"), isTrue);
      expect(jsContent.contains("instagram: '@guachirooftop'"), isTrue,
          reason: 'El Guachi debe estar asociado a su cuenta oficial @guachirooftop.');

      // Validar perfiles verificados de El Taurino y Los Toros Barra Taurina
      expect(jsContent.contains("id: 'el_taurino', name: 'El Taurino Bar', zone: 'Filomeno Medina 12, Centro', category: 'Cantina Tradicional', instagram: '@el_taurino_colima'"), isTrue);
      expect(jsContent.contains("id: 'los_toros_barra_taurina', name: 'Los Toros Barra Taurina', zone: 'Emilio Carranza #164, Centro', category: 'Bar & Botana', instagram: '@lostorosbarrataurina'"), isTrue);
      expect(jsContent.contains("id: 'la_chintola', name: 'La Chintola Bar', zone: 'Felipe Sevilla del Río 601', category: 'Bar & Botana', instagram: null"), isTrue);

      expect(jsContent.contains("@lachintolabar"), isFalse);
      expect(jsContent.contains("@eltaurinocolima"), isFalse);
    });

    test('Domain model associates authentic Instagram handles for El Taurino and Los Toros', () {
      final container = ProviderContainer();
      final venues = container.read(mockVenuesProvider);

      final taurino = venues.firstWhere((v) => v.id == 'el_taurino');
      expect(taurino.instagramHandle, equals('@el_taurino_colima'));

      final toros = venues.firstWhere((v) => v.id == 'los_toros_barra_taurina');
      expect(toros.instagramHandle, equals('@lostorosbarrataurina'));
    });
  });
}
