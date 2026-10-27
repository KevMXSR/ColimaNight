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
    final occupancyColor = !venue.isOpenNow
        ? Colors.grey.shade700
        : (venue.capacityPercent >= 85
            ? AppColors.neonRedAlert
            : venue.capacityPercent >= 65
                ? AppColors.neonAmber
                : AppColors.neonGreen);

    Widget tileContent = GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(10),
      borderColor: venue.isOpenNow
          ? AppColors.glassBorder.withOpacity(0.5)
          : Colors.white12,
      fillColor: venue.isOpenNow
          ? AppColors.surfaceElevated.withOpacity(0.65)
          : AppColors.surface.withOpacity(0.35),
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
                  color: !venue.isOpenNow
                      ? AppColors.textMuted
                      : (rankNumber! <= 3 ? AppColors.neonAmber : AppColors.textSecondary),
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
              boxShadow: venue.isOpenNow
                  ? [
                      BoxShadow(
                        color: occupancyColor.withOpacity(0.25),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
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
                          color: venue.isOpenNow ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                    // Horario / Apertura
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: venue.isOpenNow
                            ? AppColors.neonGreen.withOpacity(0.12)
                            : AppColors.neonRedAlert.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: venue.isOpenNow
                              ? AppColors.neonGreen.withOpacity(0.4)
                              : AppColors.neonRedAlert.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            venue.isOpenNow ? Icons.circle : Icons.nightlight_round,
                            size: venue.isOpenNow ? 5 : 8,
                            color: venue.isOpenNow
                                ? AppColors.neonGreen
                                : AppColors.neonRedAlert.withOpacity(0.9),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            venue.isOpenNow ? 'Abierto' : 'Cerrado',
                            style: TextStyle(
                              fontSize: 9,
                              color: venue.isOpenNow
                                  ? AppColors.neonGreen
                                  : AppColors.neonRedAlert.withOpacity(0.9),
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

                // Fila de Badges compactos (Aforo, Cover, Minutos o Razón de Cierre)
                Row(
                  children: [
                    // Aforo o Estatus Inactivo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: occupancyColor.withOpacity(0.5), width: 0.8),
                      ),
                      child: Text(
                        venue.isOpenNow ? '👥 ${venue.capacityPercent}%' : '💤 Cerrado',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: venue.isOpenNow ? occupancyColor : Colors.white60,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Cover o Horario de Apertura
                    if (venue.isOpenNow)
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
                      )
                    else
                      Expanded(
                        child: Text(
                          venue.closedReason ?? 'Cerrado ahora',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                    if (venue.isOpenNow) ...[
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
    );

    // Efecto desenergizado / blanco y negro si está cerrado
    if (!venue.isOpenNow) {
      tileContent = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(
          opacity: 0.65,
          child: tileContent,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: tileContent,
      ),
    );
  }
}
