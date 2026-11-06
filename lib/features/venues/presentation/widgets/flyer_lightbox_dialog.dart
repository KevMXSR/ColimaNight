import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_venue_image.dart';
import '../../domain/models/venue_model.dart';

/// Modal interactivo estilo Lightbox para visualizar Flyers y Anuncios de Historias de Instagram en pantalla completa.
/// Incluye zoom interactivo (pinch-to-zoom) y botón directo de redirección al perfil/historia de Instagram oficial.
class FlyerLightboxDialog extends StatelessWidget {
  final VenueEvent event;
  final VenueModel venue;

  const FlyerLightboxDialog({
    super.key,
    required this.event,
    required this.venue,
  });

  static Future<void> show(BuildContext context, VenueEvent event, VenueModel venue) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => FlyerLightboxDialog(
        event: event,
        venue: venue,
      ),
    );
  }

  Future<void> _launchInstagram(BuildContext context) async {
    final targetUrl = event.sourceInstagramUrl ??
        (venue.instagramHandle != null
            ? 'https://instagram.com/${venue.instagramHandle!.replaceAll('@', '')}'
            : 'https://instagram.com');

    final uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo abrir el perfil: $targetUrl'),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = event.flyerImageUrl ?? venue.coverImageUrl;
    final handle = event.sourceInstagramHandle ?? venue.instagramHandle ?? '@colimanight';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
              maxWidth: 520,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE1306C).withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE1306C).withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Encabezado del Flyer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 14, 52, 12),
                    color: AppColors.surfaceElevated,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 11),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.isStoryAnnouncement ? 'HISTORIA OFICIAL' : 'FLYER OFICIAL',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                venue.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.neonCyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.h3.copyWith(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              event.dateDisplay,
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                            if (event.specialSchedule != null) ...[
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.neonAmber),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.specialSchedule!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.neonAmber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Imagen del Flyer con Zoom Interactivo
                  Flexible(
                    child: Container(
                      color: Colors.black,
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(16),
                        minScale: 0.8,
                        maxScale: 4.0,
                        child: Center(
                          child: AppVenueImage(
                            imageUrl: imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Barra Inferior con Promociones y Botón de Instagram
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    color: AppColors.surfaceElevated,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (event.promoNote != null && event.promoNote!.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.neonAmber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.neonAmber.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.local_offer_rounded, color: AppColors.neonAmber, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    event.promoNote!,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.neonAmber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Botón de Enlace Directo a Instagram
                        GestureDetector(
                          onTap: () => _launchInstagram(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFD1D1D).withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'VER EN INSTAGRAM DEL ESTABLECIMIENTO',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyBold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 15),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Publicado originalmente por $handle',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de Cerrar (X)
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                splashRadius: 20,
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
