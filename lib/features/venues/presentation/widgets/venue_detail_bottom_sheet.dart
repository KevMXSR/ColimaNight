import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_venue_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/neon_badge.dart';
import '../../domain/models/venue_model.dart';
import 'faded_red_report_button.dart';

class VenueDetailBottomSheet extends ConsumerWidget {
  final VenueModel venue;
  final ScrollController scrollController;

  const VenueDetailBottomSheet({
    super.key,
    required this.venue,
    required this.scrollController,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openNavigation(BuildContext context) {
    // Abre Google Maps con las coordenadas del establecimiento en Colima
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${venue.latitude},${venue.longitude}';
    _launchUrl(url);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de agarre tipo Uber / DiDi
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Encabezado con Categoría, Título y Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.category.toUpperCase(),
                          style: AppTypography.badgeLabel.copyWith(
                            color: AppColors.neonCyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venue.name,
                          style: AppTypography.h1.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                venue.zone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.neonAmber.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.neonAmber, size: 18),
                            const SizedBox(width: 3),
                            Text(
                              venue.rating.toString(),
                              style: AppTypography.bodyBold.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          '${venue.reviewsCount} reseñas',
                          style: AppTypography.caption.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fila de Insignias y Estatus en Vivo
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  NeonBadge.livePresence(venue.livePresence, showRadius: true),
                  NeonBadge.capacity(venue.capacityPercent),
                  if (venue.hasLiveMusic)
                    NeonBadge.liveMusic(venue.liveMusicAct ?? 'En vivo'),
                  if (venue.isVipPresent)
                    NeonBadge.vip(venue.vipNote ?? 'VIP Activo'),
                  if (venue.hasPromo)
                    NeonBadge.promo(venue.promoHeadline ?? 'Promo 2x1'),
                  if (venue.parkingAvailable)
                    NeonBadge.parking(venue.parkingDetails ?? 'Valet Disponible'),
                ],
              ),
              const SizedBox(height: 18),

              // Botón Principal Estilo Uber/DiDi: "Llevarme Ahí" (Cómo llegar)
              GestureDetector(
                onTap: () => _openNavigation(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanVioletGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonCyan.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.navigation_rounded, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'LLEVARME AHÍ • ~${venue.estimatedMinutes} MIN',
                        style: AppTypography.bodyBold.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Redes Sociales Oficiales del Lugar
              Text(
                'REDES SOCIALES & AMBIENTE EN VIVO',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (venue.instagramHandle != null)
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Instagram',
                        handle: venue.instagramHandle!,
                        color: const Color(0xFFE1306C),
                        onTap: () => _launchUrl('https://instagram.com/${venue.instagramHandle!.replaceAll('@', '')}'),
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (venue.tikTokHandle != null)
                    Expanded(
                      child: _SocialButton(
                        icon: Icons.music_video_rounded,
                        label: 'TikTok',
                        handle: venue.tikTokHandle!,
                        color: AppColors.neonCyan,
                        onTap: () => _launchUrl('https://tiktok.com/@${venue.tikTokHandle!.replaceAll('@', '')}'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Galería Visual / Vibe del Lugar
              if (venue.galleryUrls.isNotEmpty) ...[
                Text(
                  'FOTOS DEL AMBIENTE',
                  style: AppTypography.badgeLabel.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: venue.galleryUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return AppVenueImage(
                        imageUrl: venue.galleryUrls[index],
                        width: 140,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(14),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Descripción y Horario
              Text(
                'SOBRE EL LUGAR',
                style: AppTypography.badgeLabel.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                venue.description,
                style: AppTypography.bodyMedium.copyWith(height: 1.45),
              ),
              const SizedBox(height: 16),

              // Ficha de Horario & Estacionamiento
              GlassContainer(
                blur: 8,
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi_tethering_rounded, color: AppColors.neonCyan, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Presencia Comunitaria:',
                          style: AppTypography.bodyBold,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${venue.livePresence} personas en radio de 80m',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.neonCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: AppColors.neonAmber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Horario:',
                          style: AppTypography.bodyBold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          venue.schedule,
                          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.local_parking_rounded, color: AppColors.neonCyan, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            venue.parkingDetails ?? 'Estacionamiento en zona',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botón con tono rojo desvanecido al final para reportes anónimos
              FadedRedReportButton(
                venue: venue,
                margin: const EdgeInsets.only(top: 8),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String handle;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.handle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                  ),
                  Text(
                    handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyBold.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
