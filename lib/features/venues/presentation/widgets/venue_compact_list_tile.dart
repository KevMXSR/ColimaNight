import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_venue_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/venue_model.dart';

/// Tarjeta de lista compacta y estilizada para escanear rápidamente la vida nocturna
class VenueCompactListTile extends StatelessWidget {
  final VenueModel venue;
  final int? rankNumber;
  final VoidCallback onTap;

  const VenueCompactListTile({
    super.key,
    required this.venue,
    this.rankNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyColor = venue.capacityPercent >= 85
        ? AppColors.neonRedAlert
        : venue.capacityPercent >= 65
            ? AppColors.neonAmber
            : AppColors.neonGreen;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.all(10),
          borderColor: AppColors.glassBorder.withOpacity(0.5),
          fillColor: AppColors.surfaceElevated.withOpacity(0.65),
          child: Row(
            children: [
              // Número de Ranking (si aplica)
              if (rankNumber != null) ...[
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  child: Text(
                    '#$rankNumber',
                    style: AppTypography.badgeLabel.copyWith(
                      color: rankNumber! <= 3 ? AppColors.neonAmber : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              // Micro-avatar circular con borde de aforo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: occupancyColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: occupancyColor.withOpacity(0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: AppVenueImage(
                    imageUrl: venue.coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Información Principal (Nombre, Categoría/Vibe y Tags)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            venue.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyBold.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Horario / Apertura
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (venue.isOpenNow ? AppColors.neonGreen : AppColors.neonAmber).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (venue.isOpenNow ? AppColors.neonGreen : AppColors.neonAmber).withOpacity(0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: venue.isOpenNow ? AppColors.neonGreen : AppColors.neonAmber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                venue.isOpenNow ? 'Abierto' : 'Cerrado',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: venue.isOpenNow ? AppColors.neonGreen : AppColors.neonAmber,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Vibe y Ubicación
                    Text(
                      '${venue.category} • ${venue.vibeGenre.split('/').first.trim()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Fila de Badges compactos (Aforo, Cover, Minutos)
                    Row(
                      children: [
                        // Aforo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: occupancyColor.withOpacity(0.5), width: 0.8),
                          ),
                          child: Text(
                            '👥 ${venue.capacityPercent}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: occupancyColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Cover
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.glassBorder, width: 0.8),
                          ),
                          child: Text(
                            venue.hasCover ? '🎟️ ${venue.coverTag}' : '🎟️ Sin Cover',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Distancia
                        Text(
                          '~${venue.estimatedMinutes} min',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
