import 'package:url_launcher/url_launcher.dart';

/// Configuración oficial del modelo económico y pasarelas de pago de Colima Night.
/// Vincula directamente a las cuentas oficiales de Kevin Sandoval Ramirez.
class MonetizationConfig {
  MonetizationConfig._();

  // ==========================================
  // 1. PASARELA DIGITAL PAYPAL
  // ==========================================
  static const String paypalUsername = 'GameKevMXSR';
  static const String paypalBaseUrl = 'https://paypal.me/$paypalUsername';

  /// Genera una URL directa de PayPal con el importe pre-cargado en Pesos Mexicanos (MXN).
  static String getPayPalUrlForAmount(int mxnAmount) {
    return '$paypalBaseUrl/${mxnAmount}MXN';
  }

  // ==========================================
  // 2. TRANSFERENCIA BANCARIA NACIONAL (SPEI)
  // ==========================================
  static const String bankName = 'BBVA México';
  static const String beneficiaryName = 'Kevin Sandoval Ramirez';
  
  /// CLABE interbancaria en formato estándar de 18 dígitos para portapapeles
  static const String clabeRaw = '012090015533382042';

  /// CLABE interbancaria con espaciado legible para la vista
  static const String clabeFormatted = '012 090 01553338204 2';

  // ==========================================
  // 3. CANAL OFICIAL DE CONTACTO & PATROCINIOS B2B
  // ==========================================
  /// Correo oficial de atención y patrocinios de Colima Night
  static const String contactEmail = 'contact.colimanight@gmail.com';

  /// Asunto y mensaje predeterminado para anunciantes, antros y eventos
  static const String defaultSponsorSubject = 'Contacto y Patrocinios • Colima Night';
  static const String defaultSponsorBody =
      'Hola equipo de Colima Night,\n\n'
      'Me interesa anunciar mi evento o establecimiento en la plataforma. '
      '¿Me podrían compartir los paquetes de difusión, banner y presencia destacada en el radar?\n\n'
      'Saludos cordiales.';

  /// Construye el enlace 'mailto:' listo para abrir el cliente de correo
  static String getContactEmailUrl({String? subject, String? body}) {
    final cleanSubject = Uri.encodeComponent(subject ?? defaultSponsorSubject);
    final cleanBody = Uri.encodeComponent(body ?? defaultSponsorBody);
    return 'mailto:$contactEmail?subject=$cleanSubject&body=$cleanBody';
  }

  /// Método utilitario seguro para abrir URLs externas
  static Future<bool> launchUrlSafe(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
