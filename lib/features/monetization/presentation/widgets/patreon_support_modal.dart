import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PatreonSupportModal extends ConsumerWidget {
  const PatreonSupportModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PatreonSupportModal(),
    );
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _selectTier(BuildContext context, WidgetRef ref, String tierName, String price) {
    ref.read(authProvider.notifier).becomeSupporter(tierName);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F1A2A),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: AppColors.neonAmber, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Gracias por tu aporte de $price!',
                    style: AppTypography.bodyBold.copyWith(color: AppColors.neonAmber),
                  ),
                  Text(
                    'Has desbloqueado el estatus $tierName en tu perfil.',
                    style: AppTypography.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.neonAmber.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Indicador táctil
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),

            // Encabezado con Corona e Ícono de Donación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.neonMagenta, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Apoyo Comunitario',
                  style: AppTypography.h2.copyWith(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Justificación transparente requerida
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                'Tu donativo financia directamente los servidores en tiempo real, la cartografía de alta precisión y la actualización continua de eventos y seguridad para toda la comunidad nocturna de Colima.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'SELECCIONA TU NIVEL DE APORTE',
              style: AppTypography.badgeLabel.copyWith(
                color: AppColors.neonAmber,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),

            // Nivel 1: Cerveza Virtual ($25 MXN)
            _TierCard(
              title: 'Cerveza Virtual 🍺',
              price: '\$25 MXN',
              subtitle: 'Aporte base para costear servidores de presencia en vivo',
              perk: 'Insignia Supporter Bronce en tu perfil',
              borderColor: const Color(0xFFCD7F32),
              onTap: () => _selectTier(context, ref, 'Cerveza Virtual 🍺', '\$25 MXN'),
            ),
            const SizedBox(height: 10),

            // Nivel 2: Ronda de Shots ($50 MXN)
            _TierCard(
              title: 'Ronda de Shots 🥃',
              price: '\$50 MXN',
              subtitle: 'Impulsa la actualización de promociones 2x1 y eventos de fin de semana',
              perk: 'Insignia Supporter Plata + acceso prioritario',
              borderColor: const Color(0xFFC0C0C0),
              onTap: () => _selectTier(context, ref, 'Ronda de Shots 🥃', '\$50 MXN'),
            ),
            const SizedBox(height: 10),

            // Nivel 3: Mesa VIP Supporter ($100 MXN)
            _TierCard(
              title: 'Mesa VIP Supporter 👑',
              price: '\$100 MXN',
              subtitle: 'Financia la telemetría satelital y el monitoreo anti-incidentes 24/7',
              perk: 'Corona Dorada VIP en perfil + Agradecimiento destacado',
              borderColor: AppColors.neonAmber,
              isFeatured: true,
              onTap: () => _selectTier(context, ref, 'Mesa VIP Supporter 👑', '\$100 MXN'),
            ),
            const SizedBox(height: 14),

            // Enlace Libre a Patreon / Apoyo Externo
            GestureDetector(
              onTap: () => _launchExternalUrl('https://patreon.com/colimanight'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonCyan.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.open_in_new_rounded, color: AppColors.neonCyan, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Aporte Libre en Patreon o Stripe',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.neonCyan,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String perk;
  final Color borderColor;
  final bool isFeatured;
  final VoidCallback onTap;

  const _TierCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.perk,
    required this.borderColor,
    this.isFeatured = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isFeatured ? AppColors.surfaceElevated : AppColors.glassFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor.withOpacity(isFeatured ? 0.9 : 0.4),
            width: isFeatured ? 1.5 : 1.0,
          ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 15)),
                      if (isFeatured) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neonAmber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neonAmber),
                          ),
                          child: Text(
                            'POPULAR',
                            style: AppTypography.badgeLabel.copyWith(
                              color: AppColors.neonAmber,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: borderColor, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          perk,
                          style: AppTypography.caption.copyWith(
                            color: borderColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                price,
                style: AppTypography.bodyBold.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
