import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../../map/domain/models/venue_location.dart';

/// Servicio de Deep Linking y navegación externa optimizado para ColimaNight
class ColimaDeepLinkService {
  ColimaDeepLinkService._();

  // --------------------------------------------------------------------------
  // Redes Sociales de Establecimientos
  // --------------------------------------------------------------------------

  /// Abre el perfil de Instagram en la app nativa o redirige a la versión web
  static Future<bool> openInstagramProfile(String username) async {
    final String cleanUsername = username.replaceAll('@', '').trim();
    final Uri appUri = Uri.parse('instagram://user?username=$cleanUsername');
    final Uri webUri = Uri.parse('https://www.instagram.com/$cleanUsername/');

    return await _launchWithFallback(appUri: appUri, webFallbackUri: webUri);
  }

  /// Abre el perfil de TikTok en la app oficial o redirige al navegador
  static Future<bool> openTikTokProfile(String handle) async {
    final String cleanHandle = handle.replaceAll('@', '').trim();
    final Uri appUri = Uri.parse('tiktok://user?screen_name=$cleanHandle');
    final Uri webUri = Uri.parse('https://www.tiktok.com/@$cleanHandle');

    return await _launchWithFallback(appUri: appUri, webFallbackUri: webUri);
  }

  /// Abre la página oficial de Facebook en la aplicación o en navegador
  static Future<bool> openFacebookPage(String pageIdOrVanity) async {
    final Uri appUri = Uri.parse(
      Platform.isIOS
          ? 'fb://profile/$pageIdOrVanity'
          : 'fb://page/$pageIdOrVanity',
    );
    final Uri webUri = Uri.parse('https://www.facebook.com/$pageIdOrVanity');

    return await _launchWithFallback(appUri: appUri, webFallbackUri: webUri);
  }

  /// Abre chat directo de WhatsApp con mensaje pre-rellenado para reservaciones en Colima
  static Future<bool> openWhatsAppReservation({
    required String rawPhoneNumber,
    required String venueName,
    String? preferredDate,
    int? guestsCount,
  }) async {
    // Normalizar número telefónico asegurando lada de México (+52)
    String cleanNumber = rawPhoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '52$cleanNumber';
    } else if (cleanNumber.startsWith('044') || cleanNumber.startsWith('045')) {
      cleanNumber = '52${cleanNumber.substring(3)}';
    }

    final String guestsStr = guestsCount != null ? ' para $guestsCount personas' : '';
    final String dateStr = preferredDate != null ? ' para el día $preferredDate' : '';

    final String message =
        '¡Hola! Vi a *$venueName* en la app *ColimaNight* 🍸🌙 y me gustaría solicitar informes o reservar una mesa$guestsStr$dateStr. ¿Tienen disponibilidad y costos de consumo mínimo? ¡Gracias!';

    final Uri waUri = Uri.parse(
      'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}',
    );

    return await launchUrl(waUri, mode: LaunchMode.externalApplication);
  }

  // --------------------------------------------------------------------------
  // Navegación GPS y Transporte Urbano (Waze, Google Maps, Uber)
  // --------------------------------------------------------------------------

  /// Abre navegación paso a paso con Google Maps hacia el antro
  static Future<bool> navigateWithGoogleMaps({
    required double destinationLat,
    required double destinationLng,
    String? venueName,
  }) async {
    final String query = venueName != null ? Uri.encodeComponent(venueName) : '';

    Uri appUri;
    if (Platform.isAndroid) {
      appUri = Uri.parse('google.navigation:q=$destinationLat,$destinationLng&mode=d');
    } else if (Platform.isIOS) {
      appUri = Uri.parse('comgooglemaps://?daddr=$destinationLat,$destinationLng&directionsmode=driving');
    } else {
      appUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&destination_place_id=$query');
    }

    final Uri webFallbackUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng',
    );

    return await _launchWithFallback(appUri: appUri, webFallbackUri: webFallbackUri);
  }

  /// Abre navegación en tiempo real con alertas de tráfico en Waze
  static Future<bool> navigateWithWaze({
    required double destinationLat,
    required double destinationLng,
  }) async {
    final Uri appUri = Uri.parse('waze://?ll=$destinationLat,$destinationLng&navigate=yes');
    final Uri webFallbackUri =
        Uri.parse('https://waze.com/ul?ll=$destinationLat,$destinationLng&navigate=yes');

    return await _launchWithFallback(appUri: appUri, webFallbackUri: webFallbackUri);
  }

  /// Solicita un viaje directo en Uber con destino precargado al antro o bar
  static Future<bool> requestUberRide({
    required double destinationLat,
    required double destinationLng,
    required String venueName,
    String? colimaNightClientId,
  }) async {
    final String encodedName = Uri.encodeComponent(venueName);
    final String clientIdParam =
        colimaNightClientId != null ? '&client_id=$colimaNightClientId' : '';

    final Uri appUri = Uri.parse(
      'uber://?action=setPickup&pickup=my_location&dropoff[latitude]=$destinationLat&dropoff[longitude]=$destinationLng&dropoff[nickname]=$encodedName$clientIdParam',
    );

    final Uri webFallbackUri = Uri.parse(
      'https://m.uber.com/ul/?action=setPickup&pickup=my_location&dropoff[latitude]=$destinationLat&dropoff[longitude]=$destinationLng&dropoff[nickname]=$encodedName$clientIdParam',
    );

    return await _launchWithFallback(appUri: appUri, webFallbackUri: webFallbackUri);
  }

  // --------------------------------------------------------------------------
  // Selector Rápido Multitarea para Establecimiento
  // --------------------------------------------------------------------------

  /// Dispara la acción social o de navegación adecuada según el establecimiento
  static Future<bool> launchVenueAction({
    required VenueLocation venue,
    required String actionType, // 'instagram', 'tiktok', 'facebook', 'whatsapp', 'maps', 'waze', 'uber'
  }) async {
    switch (actionType.toLowerCase()) {
      case 'instagram':
        if (venue.instagramHandle == null) return false;
        return await openInstagramProfile(venue.instagramHandle!);

      case 'tiktok':
        if (venue.tiktokHandle == null) return false;
        return await openTikTokProfile(venue.tiktokHandle!);

      case 'facebook':
        if (venue.facebookPageId == null) return false;
        return await openFacebookPage(venue.facebookPageId!);

      case 'whatsapp':
        if (venue.whatsappNumber == null) return false;
        return await openWhatsAppReservation(
          rawPhoneNumber: venue.whatsappNumber!,
          venueName: venue.name,
        );

      case 'maps':
        return await navigateWithGoogleMaps(
          destinationLat: venue.coordinates.latitude,
          destinationLng: venue.coordinates.longitude,
          venueName: venue.name,
        );

      case 'waze':
        return await navigateWithWaze(
          destinationLat: venue.coordinates.latitude,
          destinationLng: venue.coordinates.longitude,
        );

      case 'uber':
        return await requestUberRide(
          destinationLat: venue.coordinates.latitude,
          destinationLng: venue.coordinates.longitude,
          venueName: venue.name,
        );

      default:
        return false;
    }
  }

  // --------------------------------------------------------------------------
  // Rutina Interna de Fallback Seguro
  // --------------------------------------------------------------------------

  static Future<bool> _launchWithFallback({
    required Uri appUri,
    required Uri webFallbackUri,
  }) async {
    try {
      if (await canLaunchUrl(appUri)) {
        final bool launched = await launchUrl(appUri, mode: LaunchMode.externalNonBrowserApplication);
        if (launched) return true;
      }
    } catch (_) {
      // Ignorar excepción y proceder con el fallback en navegador web
    }

    try {
      return await launchUrl(webFallbackUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
