import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_venue_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/venue_model.dart';

/// Barra superior en formato podio/carrusel con los 5 establecimientos más concurridos
class TopRankingPodiumBar extends StatelessWidget {
  final List<VenueModel> topVenues;
  final ValueChanged<VenueModel> onVenueTap;

  const TopRankingPodiumBar({
    super.key,
    required this.topVenues,
    required this.onVenueTap,
  });

  @override
  Widget build(BuildContext context) {
    if (topVenues.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.leaderboard_rounded, color: AppColors.neonAmber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'TOP RANKING DE HOY',
                    style: AppTypography.badgeLabel.copyWith(
                      letterSpacing: 0.8,
                      color: AppColors.neonAmber,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                'Mayor afluencia en vivo',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 98,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: topVenues.length,
            itemBuilder: (context, index) {
              final venue = topVenues[index];
              final rank = index + 1;
              final medalColor = rank == 1
                  ? const Color(0xFFFFD700) // Oro
                  : rank == 2
                      ? const Color(0xFFC0C0C0) // Plata
                      : rank == 3
                          ? const Color(0xFFCD7F32) // Bronce
                          : AppColors.neonCyan;

              return Container(
                width: 145,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: GestureDetector(
                  onTap: () => onVenueTap(venue),
                  child: GlassContainer(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(8),
                    borderColor: rank <= 3 ? medalColor.withOpacity(0.5) : AppColors.glassBorder,
                    fillColor: AppColors.surfaceElevated.withOpacity(0.7),
                    child: Row(
                      children: [
                        // Mini foto con badge de medalla superpuesto
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 50,
                                height: 75,
                                child: AppVenueImage(
                                  imageUrl: venue.coverImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              left: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: medalColor, width: 1),
                                ),
                                child: Text(
                                  '#$rank',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: medalColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),

                        // Info compacta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                venue.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyBold.copyWith(
                                  fontSize: 11,
                                  color: Colors.white,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                venue.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: (venue.capacityPercent >= 85
                                            ? AppColors.neonRedAlert
                                            : AppColors.neonAmber)
                                        .withOpacity(0.5),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  '🔥 ${venue.capacityPercent}%',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: venue.capacityPercent >= 85
                                        ? AppColors.neonRedAlert
                                        : AppColors.neonAmber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
