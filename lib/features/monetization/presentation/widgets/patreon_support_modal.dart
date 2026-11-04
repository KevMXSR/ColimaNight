import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/monetization_config.dart';
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

  void _handlePayPalTier(
    BuildContext context,
    WidgetRef ref,
    String tierName,
    String price,
    int mxnAmount,
  ) async {
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
                    'Has activado el estatus $tierName en tu perfil. Abriendo PayPal...',
                    style: AppTypography.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final payPalUrl = MonetizationConfig.getPayPalUrlForAmount(mxnAmount);
    await MonetizationConfig.launchUrlSafe(payPalUrl);
  }

  void _copyClabeToClipboard(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: MonetizationConfig.clabeRaw));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.neonCyan),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡CLABE BBVA copiada al portapapeles!',
                    style: AppTypography.bodyBold.copyWith(color: Colors.white),
                  ),
                  Text(
                    'Pégala en tu app bancaria para transferir directamente a Kevin Sandoval Ramirez.',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
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
        color: const Color(0xFF14121B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.neonAmber.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
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
                  'Apoyo & Patrocinios',
                  style: AppTypography.h2.copyWith(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Justificación transparente
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                'Tu aporte apoya directamente el desarrollo independiente de Colima Night: costea servidores en tiempo real, cartografía nocturna de alta precisión y el radar de aforos honesto.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ==========================================
            // SECCIÓN 1: APORTES PAYPAL DIRECTOS
            // ==========================================
            Row(
              children: [
                const Icon(Icons.payment_rounded, color: AppColors.neonAmber, size: 18),
                const SizedBox(width: 8),
                Text(
                  'APORTES EN LÍNEA VÍA PAYPAL',
                  style: AppTypography.badgeLabel.copyWith(
                    color: AppColors.neonAmber,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nivel 1: Cerveza Virtual ($25 MXN)
            _TierCard(
              title: 'Cerveza Virtual 🍺',
              price: '\$25 MXN',
              subtitle: 'Aporte base para costear servidores de presencia en vivo',
              perk: 'Insignia Supporter Bronce en tu perfil',
              borderColor: const Color(0xFFCD7F32),
              onTap: () => _handlePayPalTier(context, ref, 'Cerveza Virtual 🍺', '\$25 MXN', 25),
            ),
            const SizedBox(height: 10),

            // Nivel 2: Ronda de Shots ($50 MXN)
            _TierCard(
              title: 'Ronda de Shots 🥃',
              price: '\$50 MXN',
              subtitle: 'Impulsa la actualización de promociones 2x1 y eventos de fin de semana',
              perk: 'Insignia Supporter Plata + acceso prioritario',
              borderColor: const Color(0xFFC0C0C0),
              onTap: () => _handlePayPalTier(context, ref, 'Ronda de Shots 🥃', '\$50 MXN', 50),
            ),
            const SizedBox(height: 10),

            // Nivel 3: Mesa VIP Supporter ($100 MXN)
            _TierCard(
              title: 'Mesa VIP Supporter 👑',
              price: '\$100 MXN',
              subtitle: 'Financia la telemetría satelital y el monitoreo anti-incidentes 24/7',
              perk: 'Corona Dorada VIP en perfil + Anuncios desactivados',
              borderColor: AppColors.neonAmber,
              isFeatured: true,
              onTap: () => _handlePayPalTier(context, ref, 'Mesa VIP Supporter 👑', '\$100 MXN', 100),
            ),
            const SizedBox(height: 12),

            // Enlace Libre a PayPal
            GestureDetector(
              onTap: () => MonetizationConfig.launchUrlSafe(MonetizationConfig.paypalBaseUrl),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0079C1).withOpacity(0.6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0079C1), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Donar monto libre en PayPal (paypal.me/GameKevMXSR)',
                      style: AppTypography.bodyBold.copyWith(
                        color: Colors.white,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // SECCIÓN 2: TRANSFERENCIA SPEI (MÉXICO)
            // ==========================================
            Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.neonCyan, size: 18),
                const SizedBox(width: 8),
                Text(
                  'TRANSFERENCIA BANCARIA DIRECTA (SPEI)',
                  style: AppTypography.badgeLabel.copyWith(
                    color: AppColors.neonCyan,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004481), // BBVA Blue
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BBVA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            MonetizationConfig.bankName,
                            style: AppTypography.bodyBold.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        'Sin Comisión',
                        style: AppTypography.caption.copyWith(color: AppColors.neonCyan, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Titular / Beneficiario:',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  Text(
                    MonetizationConfig.beneficiaryName,
                    style: AppTypography.bodyBold.copyWith(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuenta CLABE (18 dígitos):',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          MonetizationConfig.clabeFormatted,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonCyan,
                            letterSpacing: 0.8,
                          ),
                        ),
                        InkWell(
                          onTap: () => _copyClabeToClipboard(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.neonCyan, width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.copy_rounded, size: 14, color: AppColors.neonCyan),
                                const SizedBox(width: 4),
                                Text(
                                  'Copiar',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.neonCyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
            const SizedBox(height: 24),

            // ==========================================
            // SECCIÓN 3: B2B EVENTOS Y ESTABLECIMIENTOS
            // ==========================================
            Row(
              children: [
                const Icon(Icons.celebration_rounded, color: AppColors.neonMagenta, size: 18),
                const SizedBox(width: 8),
                Text(
                  'ORGANIZADORES, BARES & HACIENDAS',
                  style: AppTypography.badgeLabel.copyWith(
                    color: AppColors.neonMagenta,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonMagenta.withOpacity(0.12),
                    AppColors.surfaceElevated,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonMagenta.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Organizas un evento o tienes un antro/salón?',
                    style: AppTypography.bodyBold.copyWith(fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No te arriesgues a que tu evento en rancho, hacienda o salón quede desolado. Destaca tu evento como Banner Neón de la Semana o fija tu Aforo Verificado en el Radar nocturno de Colima.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Botón de WhatsApp Business
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => MonetizationConfig.launchUrlSafe(
                        MonetizationConfig.getBusinessWhatsAppUrl(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'Hablar por WhatsApp (${MonetizationConfig.businessWhatsAppDisplay})',
                        style: AppTypography.bodyBold.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                        ),
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
