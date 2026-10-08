import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neon_badge.dart';
import '../../../../core/widgets/pulsing_glow.dart';
import '../../domain/models/venue_model.dart';

class HotRightNowCard extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback onTap;

  const HotRightNowCard({
    super.key,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PulsingGlow(
      glowColor: AppColors.neonMagenta,
      maxBlur: 24,
      minBlur: 8,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.neonMagenta.withOpacity(0.8),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen con Hero para transición fluida
                Hero(
                  tag: 'venue_cover_${venue.id}',
                  child: CachedNetworkImage(
                    imageUrl: venue.coverImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.neonMagenta,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.nightlife, color: AppColors.neonViolet, size: 48),
                    ),
                  ),
                ),

                // Gradientes Neón Nocturnos (Cyber Fade)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // Tag Flotante Superior: "🔥 HOT RIGHT NOW" & "Aforo %"
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.hotFireGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonRedAlert.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'HOT RIGHT NOW',
                              style: AppTypography.badgeLabel.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (venue.isVipPresent) ...[
                            NeonBadge.vip(venue.vipNote ?? 'VIP'),
                            const SizedBox(width: 8),
                          ],
                          NeonBadge.capacity(venue.capacityPercent),
                        ],
                      ),
                    ],
                  ),
                ),

                // Información Inferior en Glassmorphism
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: GlassContainer(
                    blur: 14,
                    borderRadius: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    borderColor: AppColors.neonMagenta.withOpacity(0.3),
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
                                style: AppTypography.h2.copyWith(fontSize: 19),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.neonViolet.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.neonViolet.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AppColors.neonAmber, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    venue.rating.toString(),
                                    style: AppTypography.bodyBold.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppColors.neonCyan, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                venue.zone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                            Text(
                              '~${venue.estimatedMinutes} min',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (venue.hotReason != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            venue.hotReason!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.neonAmber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
