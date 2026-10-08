import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/venue_model.dart';
import 'incident_report_modal.dart';

/// Botón con tono rojo desvanecido ubicado al final de la pantalla
/// para reportes anónimos ciudadanos en tiempo real.
class FadedRedReportButton extends StatelessWidget {
  final VenueModel? venue;
  final EdgeInsetsGeometry margin;

  const FadedRedReportButton({
    super.key,
    this.venue,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: GestureDetector(
        onTap: () => IncidentReportModal.show(context, venue: venue),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            // Tono rojo desvanecido moderno (faded crimson gradient)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF330C16).withOpacity(0.85),
                const Color(0xFF1B070D).withOpacity(0.65),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonRedAlert.withOpacity(0.38),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonRedAlert.withOpacity(0.12),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con halo rojo desvanecido
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neonRedAlert.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.neonRedAlert.withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.neonRedAlert,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Textos de Acción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'REPORTE DE INCIDENCIA ANONIMA',
                          style: AppTypography.badgeLabel.copyWith(
                            color: AppColors.neonRedAlert,
                            letterSpacing: 0.8,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Peleas, armas, servicio u otros reportes',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha o indicador interactivo
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.neonRedAlert,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
