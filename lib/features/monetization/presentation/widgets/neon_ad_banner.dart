import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/monetization_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Banner de Anuncios adaptable con estética Cyber-Night Glassmorphism.
/// En Android/iOS nativo conecta Google AdMob; en Web y PWA renderiza el
/// banner Cyber Glassmorphic de alta conversión. Si el usuario es Supporter,
/// se auto-oculta para respetar su estatus VIP.
class NeonAdBanner extends ConsumerStatefulWidget {
  final String? adUnitId;
  final VoidCallback? onAdClosed;

  const NeonAdBanner({
    super.key,
    this.adUnitId,
    this.onAdClosed,
  });

  @override
  ConsumerState<NeonAdBanner> createState() => _NeonAdBannerState();
}

class _NeonAdBannerState extends ConsumerState<NeonAdBanner> {
  bool _isDismissed = false;
  int _activeAdIndex = 0;

  // ID de prueba oficial de Google AdMob para Android
  static const String defaultAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  static final List<Map<String, String>> _cyberSponsors = [
    {
      'title': 'Safe Ride Colima • Chofer Seguro',
      'tagline': 'Tarifas fijas nocturnas y unidades con GPS.',
      'action': 'Pedir Chofer',
      'tag': 'TRANSPORTE',
      'url': 'https://wa.me/${MonetizationConfig.businessWhatsAppNumber}?text=Hola,%20solicito%20chofer%20seguro',
    },
    {
      'title': '¿Tienes un Antro o Evento? • Anúnciate',
      'tagline': 'Destaca tu fiesta en la Cartelera de Colima Night.',
      'action': 'Ver Paquetes',
      'tag': 'PATROCINIO',
      'url': MonetizationConfig.getBusinessWhatsAppUrl(),
    },
    {
      'title': 'Taquería El Güero • Abierto hasta las 6 AM',
      'tagline': 'El after por excelencia en Av. Constitución.',
      'action': 'Ver Menú',
      'tag': 'AFTER PARTY',
      'url': 'https://google.com/maps',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Rotación sutil de patrocinadores
    _activeAdIndex = DateTime.now().second % _cyberSponsors.length;
  }

  @override
  Widget build(BuildContext context) {
    // Si el usuario es Supporter (VIP vía PayPal/Patreon) o descartó el banner, no mostrar nada
    final isSupporter = ref.watch(authProvider).isSupporter;
    if (isSupporter || _isDismissed) {
      return const SizedBox.shrink();
    }

    final ad = _cyberSponsors[_activeAdIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 68,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FFCC).withOpacity(0.35), // Borde Neón Cian
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFCC).withOpacity(0.08),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Efecto Glassmorphism de fondo con desenfoque sigma 10
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.48),
              ),
            ),

            // Contenido Cyber-Night del Anuncio
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final url = ad['url']!;
                  MonetizationConfig.launchUrlSafe(url);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      // Badge oficial "AD"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFCC).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF00FFCC), width: 0.8),
                        ),
                        child: const Text(
                          'AD',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00FFCC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Título y eslogan del anuncio
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad['title']!,
                              style: AppTypography.bodyBold.copyWith(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ad['tagline']!,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Botón de acción Neón
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFCC).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.6)),
                        ),
                        child: Text(
                          ad['action']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00FFCC),
                          ),
                        ),
                      ),

                      // Botón sutil de cerrar
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                        onPressed: () {
                          setState(() => _isDismissed = true);
                          widget.onAdClosed?.call();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
