import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';

class CyberAdMobCard extends StatelessWidget {
  final int index;

  const CyberAdMobCard({
    super.key,
    this.index = 0,
  });

  static final List<Map<String, String>> _mockAds = [
    {
      'title': 'Safe Ride Colima • Taxi Nocturno Seguro',
      'tagline': 'Tarifas fijas nocturnas, unidades con GPS y chofer designado.',
      'actionText': 'Pedir Chofer Seguro',
      'url': 'https://wa.me/523121234567?text=Hola,%20solicito%20chofer%20seguro%20de%20noche',
      'imageUrl': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=1000&q=80',
      'tag': 'TRANSPORTE SEGURO',
    },
    {
      'title': 'Taquería El Güero • Abierto hasta las 6 AM',
      'tagline': 'El after por excelencia: tacos de asada, gringas y consomé hirviendo.',
      'actionText': 'Ver Menú Nocturno',
      'url': 'https://google.com/maps',
      'imageUrl': 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?auto=format&fit=crop&w=1000&q=80',
      'tag': 'AFTER PARTY SPONSOR',
    },
  ];

  Future<void> _openAdLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = _mockAds[index % _mockAds.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GlassContainer(
        borderRadius: 22,
        padding: EdgeInsets.zero,
        borderColor: AppColors.neonAmber.withOpacity(0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de banner publicitario nativo
            SizedBox(
              height: 125,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: CachedNetworkImage(
                      imageUrl: ad['imageUrl']!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
                      errorWidget: (_, __, ___) => Container(color: AppColors.surface),
                    ),
                  ),

                  // Gradiente Cyber
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
                      ),
                    ),
                  ),

                  // Badge de Patrocinado / Google AdMob Mockup
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.neonAmber.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.neonAmber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AD',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            ad['tag']!,
                            style: AppTypography.badgeLabel.copyWith(
                              color: Colors.white70,
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logo / Tagline sutil
                  Positioned(
                    bottom: 8,
                    left: 12,
                    right: 12,
                    child: Text(
                      ad['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido inferior y botón de acción
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ad['tagline']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _openAdLink(ad['url']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.neonAmber.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonAmber.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ad['actionText']!,
                            style: AppTypography.badgeLabel.copyWith(
                              color: AppColors.neonAmber,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonAmber, size: 10),
                        ],
                      ),
                    ),
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
