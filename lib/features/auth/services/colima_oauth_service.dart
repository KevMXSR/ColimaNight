import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tipos de proveedores de identidad social soportados
enum SocialAuthProvider {
  google,
  instagram,
  facebook,
}

/// Servicio oficial para lanzar el selector de cuentas y perfiles del dispositivo
/// correspondiente a cada red social (Google Account Chooser, Facebook Dialog, Instagram OAuth).
class ColimaOAuthService {
  ColimaOAuthService._();

  /// Obtiene la URL de redirección dinámica basada en la instancia activa de la aplicación
  static String get _appRedirectUrl {
    try {
      final base = Uri.base;
      if (base.host.isNotEmpty) {
        final portPart = (base.port == 80 || base.port == 443 || base.port == 0)
            ? ''
            : ':${base.port}';
        return '${base.scheme}://${base.host}$portPart${base.path}';
      }
    } catch (_) {}
    return 'https://kevin-sandoval-colima.github.io/ColimaNight/';
  }

  /// Construye la URL oficial del proveedor que dispara la selección de cuentas reales
  static Uri buildProviderAccountChooserUri(SocialAuthProvider provider) {
    final redirect = _appRedirectUrl;
    final encodedRedirect = Uri.encodeComponent(redirect);

    switch (provider) {
      case SocialAuthProvider.google:
        // Fuerza el selector oficial de Google con todas las cuentas sincronizadas en el dispositivo
        return Uri.parse(
          'https://accounts.google.com/o/oauth2/v2/auth'
          '?client_id=1089234895678-colimanight.apps.googleusercontent.com'
          '&redirect_uri=$encodedRedirect'
          '&response_type=token%20id_token'
          '&scope=openid%20profile%20email'
          '&prompt=select_account',
        );

      case SocialAuthProvider.facebook:
        // Abre el diálogo oficial de Facebook para seleccionar o continuar con el perfil activo
        return Uri.parse(
          'https://www.facebook.com/v19.0/dialog/oauth'
          '?client_id=1089234895678912'
          '&redirect_uri=$encodedRedirect'
          '&response_type=token'
          '&scope=public_profile,email',
        );

      case SocialAuthProvider.instagram:
        // Abre la autorización oficial de Instagram para continuar con el perfil activo
        return Uri.parse(
          'https://api.instagram.com/oauth/authorize'
          '?client_id=1089234895678912'
          '&redirect_uri=$encodedRedirect'
          '&response_type=code'
          '&scope=user_profile',
        );
    }
  }

  /// Abre la página oficial del proveedor en el navegador o app externa
  /// para que el usuario seleccione su perfil real sin tecleado manual.
  static Future<bool> launchAccountChooser(SocialAuthProvider provider) async {
    final uri = buildProviderAccountChooserUri(provider);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      return success;
    } catch (e) {
      debugPrint('Error al lanzar selector de cuentas oficial para $provider: $e');
      // Fallback a modo estándar si externalApplication falla en la plataforma
      try {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (fallbackError) {
        debugPrint('Fallback launch error: $fallbackError');
        return false;
      }
    }
  }
}
