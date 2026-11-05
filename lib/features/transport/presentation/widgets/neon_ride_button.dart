import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transport_provider.dart';

/// Botón de acción estilizado con estética Cyber-Night Neón Magenta
/// para solicitar transporte (DiDi / Uber) con destino automático.
class NeonRideButton extends ConsumerWidget {
  final double latitude;
  final double longitude;
  final String barName;
  final String? customLabel;

  const NeonRideButton({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.barName,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transportService = ref.watch(transportProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF007F).withOpacity(0.22), // Base Neón Magenta
          side: const BorderSide(color: Color(0xFFFF007F), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadowColor: const Color(0xFFFF007F),
          elevation: 8,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        icon: const Icon(Icons.time_to_leave, color: Colors.white, size: 20),
        label: Text(
          customLabel ?? 'PEDIR VIAJE AQUÍ 🚕',
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            fontSize: 14,
          ),
        ),
        onPressed: () => transportService.handleSmartRideRequest(
          context,
          lat: latitude,
          lng: longitude,
          destinationName: barName,
        ),
      ),
    );
  }
}
