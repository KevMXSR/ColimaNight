import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/transport_provider.dart';

/// Modal interactivo Cyber-Night para elegir entre DiDi y Uber
/// cuando el usuario tiene ambas aplicaciones o se ejecuta en Web.
class RideChooserSheet extends ConsumerWidget {
  final double latitude;
  final double longitude;
  final String destinationName;

  const RideChooserSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.destinationName,
  });

  static Future<void> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String destinationName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RideChooserSheet(
        latitude: latitude,
        longitude: longitude,
        destinationName: destinationName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transport = ref.watch(transportProvider);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF14121B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: const Color(0xFFFF007F).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barra táctil de arrastre
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 18),

          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF007F).withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF007F).withOpacity(0.5)),
                ),
                child: const Icon(Icons.local_taxi_rounded, color: Color(0xFFFF007F), size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                'Pedir Transporte Seguro',
                style: AppTypography.h2.copyWith(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Elige tu plataforma preferida. El destino ya estará configurado hacia:',
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(
              destinationName,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.neonCyan,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),

          // Opción 1: DiDi Pasajero (Recomendado en Colima)
          _buildTransportCard(
            context: context,
            title: 'DiDi Pasajero',
            subtitle: 'Abre DiDi con destino fijado en un toque',
            badge: 'POPULAR EN COLIMA',
            accentColor: const Color(0xFFFF7D00), // DiDi Orange
            icon: Icons.directions_car_filled_rounded,
            onTap: () {
              Navigator.of(context).pop();
              transport.openDiDi(
                lat: latitude,
                lng: longitude,
                destinationName: destinationName,
              );
            },
          ),
          const SizedBox(height: 12),

          // Opción 2: Uber
          _buildTransportCard(
            context: context,
            title: 'Uber',
            subtitle: 'Pide tu viaje con coordenadas exactas',
            badge: 'DIRECTO',
            accentColor: Colors.white,
            icon: Icons.local_taxi_rounded,
            onTap: () {
              Navigator.of(context).pop();
              transport.openUber(
                lat: latitude,
                lng: longitude,
                destinationName: destinationName,
              );
            },
          ),
          const SizedBox(height: 12),

          // Opción 3: Alternativa Google Maps
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              final mapsUri = Uri.parse(
                'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
              );
              ref.read(transportProvider).openUber(
                    lat: latitude,
                    lng: longitude,
                    destinationName: destinationName,
                  );
            },
            icon: const Icon(Icons.map_rounded, size: 16, color: AppColors.textSecondary),
            label: Text(
              'O ver cómo llegar en Google Maps',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 1.5),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 15)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
