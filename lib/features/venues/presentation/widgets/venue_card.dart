import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neon_badge.dart';
import '../../domain/models/venue_model.dart';

class VenueCard extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback onTap;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          borderRadius: 22,
          padding: EdgeInsets.zero,
          borderColor: AppColors.glassBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección Imagen Superior con Badges Flotantes
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'venue_cover_${venue.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                        child: CachedNetworkImage(
                          imageUrl: venue.coverImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceElevated,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.neonViolet,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.nightlife, color: AppColors.neonViolet),
                          ),
                        ),
                      ),
                    ),

                    // Gradiente oscuro para contraste de textos
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),

                    // Badge de Aforo en esquina superior derecha
                    Positioned(
                      top: 12,
                      right: 12,
                      child: venue.securityStatus == 'active_alert'
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.neonRedAlert,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Alerta Altercado',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : NeonBadge.capacity(venue.capacityPercent),
                    ),

                    // Chip de Categoría & Vibe en esquina superior izquierda
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          venue.category.toUpperCase(),
                          style: AppTypography.badgeLabel.copyWith(
                            color: AppColors.neonCyan,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),

                    // Nombre y Rating superpuestos en la base de la imagen
                    Positioned(
                      bottom: 10,
                      left: 14,
                      right: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  venue.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.h3.copyWith(
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.headphones_rounded,
                                        size: 13, color: AppColors.neonViolet),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        venue.vibeGenre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.neonAmber.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.neonAmber, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  venue.rating.toString(),
                                  style: AppTypography.bodyBold.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Cuerpo de la tarjeta con Insignias Dinámicas y Zona
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Insignias dinámicas (Música en vivo, 2x1, VIP, Parking)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (venue.hasLiveMusic)
                          NeonBadge.liveMusic(venue.liveMusicAct ?? 'Banda en vivo'),
                        if (venue.hasPromo)
                          NeonBadge.promo(venue.promoHeadline ?? '2x1 Activo'),
                        if (venue.isVipPresent)
                          NeonBadge.vip(venue.vipNote ?? 'VIP Presente'),
                        if (venue.parkingAvailable)
                          NeonBadge.parking('Estacionamiento'),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Separador sutil
                    Divider(color: Colors.white.withOpacity(0.08), height: 1),
                    const SizedBox(height: 10),

                    // Barra inferior de ubicación y tiempo estimado
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded, size: 14, color: AppColors.neonCyan),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            venue.zone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'A ~${venue.estimatedMinutes} min',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
