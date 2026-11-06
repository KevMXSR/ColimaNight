import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../providers/venue_providers.dart';

/// Tarjeta / Banner interactivo y colapsable de la Cartelera Digital de ColimaNight.
/// Ubicado estratégicamente entre los chips de filtro y la sección "Hot Right Now".
/// Permite alternar zonas rápidamente, consultar estatus en vivo y compartir el plan por WhatsApp.
class NightlifeDigitalFlyerCard extends ConsumerStatefulWidget {
  const NightlifeDigitalFlyerCard({super.key});

  @override
  ConsumerState<NightlifeDigitalFlyerCard> createState() =>
      _NightlifeDigitalFlyerCardState();
}

class _NightlifeDigitalFlyerCardState extends ConsumerState<NightlifeDigitalFlyerCard> {
  bool _isExpanded = false;
  String _activeZone = 'todos';

  void _copyShareMessage(BuildContext context) {
    const message =
        '¡Oigan! Revisemos la app de ColimaNight 🍸🌙 para ver qué lugares tienen buen aforo y 2x1 hoy: https://colimanight.app';
    Clipboard.setData(const ClipboardData(text: message));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neonCyan, width: 1.2),
        ),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🎉 Plan nocturno copiado para enviar por WhatsApp',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GlassContainer(
        blur: 16,
        borderRadius: 22,
        padding: const EdgeInsets.all(14),
        fillColor: AppColors.surfaceElevated.withOpacity(0.85),
        borderColor: AppColors.neonCyan.withOpacity(0.3),
        shadows: [
          BoxShadow(
            color: AppColors.neonViolet.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabecera del Banner: Logotipo Primario, Título y Botón Colapsar/Expandir
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  // Isotipo Primario Oficial (Tropical Lounge & Coctelería de Autor)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonMagenta.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/logo_colimanight_primary.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.nightlife_rounded, color: AppColors.neonMagenta, size: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Título & Indicador de Estado
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'CARTELERA DIGITAL',
                              style: AppTypography.bodyBold.copyWith(
                                fontSize: 13,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.neonGreen.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'EN VIVO',
                                style: TextStyle(
                                  color: AppColors.neonGreen,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '22 spots en Colima & Villa de Álvarez',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón Expandir / Colapsar
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.neonCyan,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido Desplegable (Filtros de Zonas & Botón Compartir Plan)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chips de Zonas Rápidas
                    Text(
                      'CORREDORES DESTACADOS',
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildZoneChip('todos', 'Todos (22)', Icons.stars_rounded),
                        _buildZoneChip('sandoval', 'Sandoval', Icons.local_bar_rounded),
                        _buildZoneChip('centro', 'Centro', Icons.location_city_rounded),
                        _buildZoneChip('craft', 'Craft Beer', Icons.sports_bar_rounded),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Fila Inferior: Botón Compartir Plan y Sello Secundario
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _copyShareMessage(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.neonCyan, AppColors.neonViolet],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonCyan.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.share_rounded, size: 16, color: Color(0xFF0A0A0F)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Compartir Plan con Amigos',
                                    style: TextStyle(
                                      color: Color(0xFF0A0A0F),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Miniatura Logo Secundario (Monograma Luxury CN) como sello de calidad
                        Tooltip(
                          message: 'Sello Oficial ColimaNight',
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.neonViolet.withOpacity(0.6)),
                              color: AppColors.background,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset(
                                'assets/images/logo_colimanight_secondary.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.verified_rounded, size: 18, color: AppColors.neonCyan),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneChip(String zoneKey, String label, IconData icon) {
    final isSelected = _activeZone == zoneKey;
    return InkWell(
      onTap: () {
        setState(() {
          _activeZone = zoneKey;
        });
        // Aplicar filtro reactivo en el estado global de la app
        if (zoneKey == 'todos') {
          ref.read(searchQueryProvider.notifier).state = '';
          ref.read(selectedFilterChipProvider.notifier).state = VenueFilterChip.all;
        } else if (zoneKey == 'sandoval') {
          ref.read(searchQueryProvider.notifier).state = 'Sandoval';
        } else if (zoneKey == 'centro') {
          ref.read(searchQueryProvider.notifier).state = 'Centro';
        } else if (zoneKey == 'craft') {
          ref.read(searchQueryProvider.notifier).state = 'Cervecería';
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
