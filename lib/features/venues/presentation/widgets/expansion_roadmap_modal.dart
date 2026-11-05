import 'package:flutter/material.dart';
import '../../../../core/config/monetization_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Modal informativo de la Hoja de Ruta de Expansión de Colima Night hacia
/// Tecomán y Manzanillo. Brinda visibilidad del crecimiento futuro de la app
/// sin saturar la pantalla principal.
class ExpansionRoadmapModal extends StatelessWidget {
  const ExpansionRoadmapModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExpansionRoadmapModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: AppColors.neonCyan.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
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
                    color: AppColors.neonCyan.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.waves_rounded, color: AppColors.neonCyan, size: 24),
                ),
                const SizedBox(width: 10),
                Text(
                  'Expansión Estatal',
                  style: AppTypography.h2.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'El radar nocturno crece con la respuesta de nuestra comunidad.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 20),

            // Zona 1: Cobertura Actual Activa
            _buildPhaseCard(
              title: 'Colima & Villa de Álvarez',
              badge: 'FASE 1 • ACTIVO EN VIVO',
              description:
                  '27 Establecimientos verificados, cartelera semanal de eventos, telemetría comunitaria y pulso de aforos en tiempo real.',
              icon: Icons.check_circle_rounded,
              accentColor: AppColors.neonGreen,
              isActive: true,
            ),
            const SizedBox(height: 10),

            // Zona 2: Manzanillo
            _buildPhaseCard(
              title: 'Manzanillo (Costa & Puerto)',
              badge: 'PRÓXIMAMENTE • FASE 2',
              description:
                  'Antros de playa, bares del Bulevar Costero Miguel de la Madrid, Las Brisas, terrazas frente al mar y eventos de fin de semana.',
              icon: Icons.waves_rounded,
              accentColor: AppColors.neonCyan,
              isActive: false,
            ),
            const SizedBox(height: 10),

            // Zona 3: Tecomán
            _buildPhaseCard(
              title: 'Tecomán & Costa Sur',
              badge: 'PRÓXIMAMENTE • FASE 3',
              description:
                  'Botaneros tradicionales, palapas, música en vivo, eventos campestres y vida nocturna del valle tecomense.',
              icon: Icons.wb_sunny_rounded,
              accentColor: AppColors.neonAmber,
              isActive: false,
            ),
            const SizedBox(height: 18),

            // Mensaje del creador
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                'Iremos habilitando cada municipio gradualmente en función del apoyo comunitario y la participación de la gente. ¡Tu uso y recomendación de la app define qué tan rápido llegamos ahí!',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón para sugerir antro o evento en Tecomán / Manzanillo
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  const message =
                      'Hola Kevin, me gustaría recomendar un lugar/evento para la futura expansión de Tecomán y Manzanillo en Colima Night.';
                  final waUrl = MonetizationConfig.getBusinessWhatsAppUrl(message);
                  MonetizationConfig.launchUrlSafe(waUrl);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCyan.withOpacity(0.18),
                  side: const BorderSide(color: AppColors.neonCyan, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.neonCyan, size: 18),
                label: Text(
                  'Sugerir un lugar en Tecomán o Manzanillo',
                  style: AppTypography.bodyBold.copyWith(
                    color: AppColors.neonCyan,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard({
    required String title,
    required String badge,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(isActive ? 0.8 : 0.35),
          width: isActive ? 1.4 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.bodyBold.copyWith(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
