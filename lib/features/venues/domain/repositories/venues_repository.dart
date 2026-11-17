import '../models/venue_model.dart';

/// Contrato del repositorio para la gestión de establecimientos,
/// aforos y carteleras de eventos en Colima y Villa de Álvarez.
abstract class VenuesRepository {
  /// Flujo reactivo en tiempo real con la lista consolidada de establecimientos
  Stream<List<VenueModel>> watchVenues();

  /// Consulta única puntual de establecimientos
  Future<List<VenueModel>> fetchVenues();

  /// Consulta los eventos vigentes asociados a un establecimiento específico
  Future<List<VenueEvent>> fetchEventsForVenue(String venueId);

  /// Actualización rápida de aforo en vivo
  Future<void> updateVenueCapacity(String venueId, int capacity);

  /// Actualización rápida de música en vivo (exclusivo para Staff o Admin verificado)
  Future<void> updateVenueLiveMusic({
    required String venueId,
    required bool hasLiveMusic,
    String? actName,
  });

  /// Actualización rápida de promociones 2x1 (exclusivo para Staff o Admin verificado)
  Future<void> updateVenuePromo({
    required String venueId,
    required bool hasPromo,
    String? promoHeadline,
  });
}
