import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_venue_image.dart';
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
  @override
  Widget build(BuildContext context) {
    Widget cardContent = GlassContainer(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      borderColor: venue.isOpenNow ? AppColors.glassBorder : Colors.white12,
      fillColor: venue.isOpenNow
          ? AppColors.surfaceElevated.withOpacity(0.85)
          : AppColors.surface.withOpacity(0.4),
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
                AppVenueImage(
                  imageUrl: venue.coverImageUrl,
                  fit: BoxFit.cover,
                  alignment: venue.id == 'costa_carranza_2'
                      ? const Alignment(0, -0.3)
                      : Alignment.center,
                  heroTag: 'venue_cover_${venue.id}',
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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

                // Badge de Telemetría en Vivo y Aforo en esquina superior derecha
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (venue.isOpenNow)
                        NeonBadge.livePresence(venue.livePresence)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bedtime_rounded, size: 11, color: Colors.white60),
                              SizedBox(width: 4),
                              Text(
                                'Inactivo',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 6),
                      venue.securityStatus == 'active_alert'
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
                                    'Alerta',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : (venue.isOpenNow
                              ? NeonBadge.capacity(venue.capacityPercent)
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Text(
                                    '0% Aforo',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                    ],
                  ),
                ),

                // Chip de Categoría & Estatus de apertura en esquina superior izquierda
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: venue.isOpenNow ? AppColors.glassBorder : Colors.white24),
                        ),
                        child: Text(
                          venue.category.toUpperCase(),
                          style: AppTypography.badgeLabel.copyWith(
                            color: venue.isOpenNow ? AppColors.neonCyan : Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: venue.isOpenNow
                              ? AppColors.neonGreen.withOpacity(0.2)
                              : AppColors.neonRedAlert.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: venue.isOpenNow
                                ? AppColors.neonGreen.withOpacity(0.6)
                                : AppColors.neonRedAlert.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              venue.isOpenNow ? Icons.circle : Icons.nightlight_round,
                              size: venue.isOpenNow ? 6 : 10,
                              color: venue.isOpenNow
                                  ? AppColors.neonGreen
                                  : AppColors.neonRedAlert.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              venue.isOpenNow ? 'Abierto' : 'Cerrado',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: venue.isOpenNow
                                    ? AppColors.neonGreen
                                    : AppColors.neonRedAlert.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    // Insignias dinámicas (Cover, Eventos, Música en vivo, 2x1, VIP, Parking)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Badge de Cover
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: venue.hasCover
                                  ? AppColors.neonAmber.withOpacity(0.6)
                                  : AppColors.neonCyan.withOpacity(0.6),
                            ),
                          ),
                          child: Text(
                            '🎟️ ${venue.coverTag}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: venue.hasCover ? AppColors.neonAmber : AppColors.neonCyan,
                            ),
                          ),
                        ),
                        if (venue.hasLiveMusic)
                          NeonBadge.liveMusic(venue.liveMusicAct ?? 'Banda en vivo'),
                        if (venue.hasPromo)
                          NeonBadge.promo(venue.promoHeadline ?? '2x1 Activo'),
                        if (venue.isVipPresent)
                          NeonBadge.vip(venue.vipNote ?? 'VIP Presente'),
                        if (venue.parkingAvailable)
                          NeonBadge.parking('Estacionamiento'),
                        if (venue.upcomingEvents.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonViolet.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.neonViolet.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_note_rounded, size: 12, color: AppColors.neonViolet),
                                const SizedBox(width: 4),
                                Text(
                                  venue.upcomingEvents.first.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    // Horario / Próxima apertura cuando está desenergizado
                    if (!venue.isOpenNow) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 13, color: Colors.white70),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                venue.closedReason ?? 'Cerrado ahora',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
        );

    // Efecto desenergizado / blanco y negro si el local está cerrado
    if (!venue.isOpenNow) {
      cardContent = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Opacity(
          opacity: 0.65,
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: cardContent,
      ),
    );
  }
}
