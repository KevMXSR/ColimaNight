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
  // 3. VINCULACIÓN COMERCIAL B2B (ANUNCIANTES / EVENTOS)
  // ==========================================
  /// Número oficial de WhatsApp Business (Código país México: 52)
  static const String businessWhatsAppNumber = '523123742089';
  static const String businessWhatsAppDisplay = '(+52) 312 374 2089';

  /// Mensaje pre-cargado para dueños de bares, antros y organizadores de eventos
  static const String defaultSponsorMessage =
      'Hola Kevin, me interesa anunciar mi evento/establecimiento en Colima Night. '
      '¿Me podrías compartir los paquetes de difusión, banner y presencia destacada en el radar?';

  /// Construye el enlace de WhatsApp listo para abrir la conversación
  static String getBusinessWhatsAppUrl([String? customMessage]) {
    final message = Uri.encodeComponent(customMessage ?? defaultSponsorMessage);
    return 'https://wa.me/$businessWhatsAppNumber?text=$message';
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
