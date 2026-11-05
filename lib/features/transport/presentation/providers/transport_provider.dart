import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/ride_chooser_sheet.dart';

final transportProvider = Provider((ref) => TransportService());

/// Servicio inteligente de transporte para Colima Night.
/// Gestiona la apertura nativa de DiDi y Uber con destinos pre-cargados,
/// selección dinámica si ambas apps están instaladas, y fallbacks web / tiendas.
class TransportService {
  /// Construye la URI del esquema nativo de DiDi
  Uri buildDiDiUri(double lat, double lng, String destinationName) {
    return Uri.parse(
      'didiwas://passenger/launch?dlat=$lat&dlng=$lng&dname=${Uri.encodeComponent(destinationName)}',
    );
  }

  /// Construye la URI del esquema nativo de Uber
  Uri buildUberUri(double lat, double lng, String destinationName) {
    return Uri.parse(
      'uber://?action=setPickup&dropoff[latitude]=$lat&dropoff[longitude]=$lng&dropoff[nickname]=${Uri.encodeComponent(destinationName)}',
    );
  }

  /// Construye la URI web móvil de Uber con coordenadas
  Uri buildUberWebUri(double lat, double lng, String destinationName) {
    return Uri.parse(
      'https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=$lat&dropoff[longitude]=$lng&dropoff[nickname]=${Uri.encodeComponent(destinationName)}',
    );
  }

  /// Construye la URI de fallback de DiDi (sitio web oficial)
  Uri buildDiDiWebUri() {
    return Uri.parse('https://didiglobal.com');
  }

  /// Verifica si el esquema nativo de DiDi puede ejecutarse
  Future<bool> canLaunchDiDi(double lat, double lng, String destinationName) async {
    if (kIsWeb) return false;
    try {
      final uri = buildDiDiUri(lat, lng, destinationName);
      return await canLaunchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  /// Verifica si el esquema nativo de Uber puede ejecutarse
  Future<bool> canLaunchUber(double lat, double lng, String destinationName) async {
    if (kIsWeb) return false;
    try {
      final uri = buildUberUri(lat, lng, destinationName);
      return await canLaunchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  /// Lanza DiDi directamente con destino pre-configurado
  Future<bool> openDiDi({
    required double lat,
    required double lng,
    required String destinationName,
  }) async {
    final nativeUri = buildDiDiUri(lat, lng, destinationName);
    if (!kIsWeb && await canLaunchUrl(nativeUri)) {
      return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    }

    // Si DiDi nativo no abre, intenta Uber nativo de respaldo
    final uberNativeUri = buildUberUri(lat, lng, destinationName);
    if (!kIsWeb && await canLaunchUrl(uberNativeUri)) {
      return await launchUrl(uberNativeUri, mode: LaunchMode.externalApplication);
    }

    // Fallback web universal de Uber con coordenadas
    final uberWebUri = buildUberWebUri(lat, lng, destinationName);
    if (await canLaunchUrl(uberWebUri)) {
      return await launchUrl(uberWebUri, mode: LaunchMode.externalApplication);
    }

    // Fallback final a DiDi Global
    final didiWeb = buildDiDiWebUri();
    return await launchUrl(didiWeb, mode: LaunchMode.externalApplication);
  }

  /// Lanza Uber directamente con destino pre-configurado
  Future<bool> openUber({
    required double lat,
    required double lng,
    required String destinationName,
  }) async {
    final nativeUri = buildUberUri(lat, lng, destinationName);
    if (!kIsWeb && await canLaunchUrl(nativeUri)) {
      return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
    }

    // Fallback web de Uber con coordenadas exactas
    final webUri = buildUberWebUri(lat, lng, destinationName);
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    // Fallback a DiDi si Uber no estuviera disponible
    return await openDiDi(lat: lat, lng: lng, destinationName: destinationName);
  }

  /// Gestión inteligente del viaje:
  /// - Si tiene ambas apps (o en navegador Web donde no se puede sondear nativamente),
  ///   despliega el menú rápido Cyber-Night para que el usuario elija su preferida.
  /// - Si solo tiene DiDi, abre DiDi de inmediato.
  /// - Si solo tiene Uber, abre Uber de inmediato.
  /// - Si no tiene ninguna, abre el selector rápido para elegir entre sus portales móviles.
  Future<void> handleSmartRideRequest(
    BuildContext context, {
    required double lat,
    required double lng,
    required String destinationName,
  }) async {
    final hasDiDi = await canLaunchDiDi(lat, lng, destinationName);
    final hasUber = await canLaunchUber(lat, lng, destinationName);

    // Caso 1: Solo DiDi instalado
    if (hasDiDi && !hasUber) {
      await openDiDi(lat: lat, lng: lng, destinationName: destinationName);
      return;
    }

    // Caso 2: Solo Uber instalado
    if (hasUber && !hasDiDi) {
      await openUber(lat: lat, lng: lng, destinationName: destinationName);
      return;
    }

    // Caso 3: Ambas disponibles o entorno Web -> Desplegar selector interactivo
    if (context.mounted) {
      await RideChooserSheet.show(
        context,
        latitude: lat,
        longitude: lng,
        destinationName: destinationName,
      );
    }
  }
}
