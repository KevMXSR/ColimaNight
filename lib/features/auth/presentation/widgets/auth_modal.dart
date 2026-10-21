import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../providers/auth_provider.dart';

class AuthModal extends ConsumerStatefulWidget {
  final VoidCallback? onOpenSupporterModal;

  const AuthModal({
    super.key,
    this.onOpenSupporterModal,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onOpenSupporterModal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthModal(onOpenSupporterModal: onOpenSupporterModal),
    );
  }

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> {
  bool _isSigningIn = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (mounted) {
      setState(() => _isSigningIn = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.neonCyan),
              const SizedBox(width: 8),
              Text(
                '¡Bienvenido, ${ref.read(authProvider).displayName}!',
                style: AppTypography.bodyBold,
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

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
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barra de arrastre táctil
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),

          if (user.isGuest) ...[
            // Encabezado para Invitado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nightlife_rounded, color: AppColors.neonViolet, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Acceso a ColimaNight',
                  style: AppTypography.h2.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Conéctate para personalizar tu noche, activar insignias y apoyar la plataforma nocturna de Colima.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Beneficios de la cuenta
            GlassContainer(
              blur: 8,
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  _benefitRow(Icons.favorite_rounded, AppColors.neonMagenta, 'Guarda tus antros y eventos favoritos'),
                  const SizedBox(height: 10),
                  _benefitRow(Icons.wifi_tethering_rounded, AppColors.neonCyan, 'Telemetría de presencia comunitaria (80m)'),
                  const SizedBox(height: 10),
                  _benefitRow(Icons.workspace_premium_rounded, AppColors.neonAmber, 'Insignias de Supporter en tu perfil'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón Principal de Google Sign-In
            GestureDetector(
              onTap: _isSigningIn ? null : _handleGoogleSignIn,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: _isSigningIn
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                            height: 20,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, color: Colors.black, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continuar con Google',
                            style: AppTypography.bodyBold.copyWith(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón para continuar como Invitado
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).continueAsGuest();
                Navigator.of(context).pop();
              },
              child: Text(
                'Permanecer en Modo Invitado (Sin registro)',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ] else ...[
            // Encabezado para Usuario Autenticado
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.neonViolet.withOpacity(0.3),
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName.isNotEmpty ? user.displayName[0] : 'U',
                          style: AppTypography.h1.copyWith(color: AppColors.neonCyan),
                        )
                      : null,
                ),
                if (user.isSupporter)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.neonAmber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.black, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: AppTypography.h2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              user.email,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Tarjeta de Estatus Supporter
            if (user.isSupporter) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2008), Color(0xFF1E172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonAmber.withOpacity(0.6), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.neonAmber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.supporterTier ?? 'Supporter Oficial',
                            style: AppTypography.bodyBold.copyWith(color: AppColors.neonAmber),
                          ),
                          Text(
                            'Contribuyendo activamente a ColimaNight 🍸',
                            style: AppTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Invitación a apoyar el proyecto
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  if (widget.onOpenSupporterModal != null) {
                    widget.onOpenSupporterModal!();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.neonAmber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neonAmber.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.neonAmber, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Apoya a ColimaNight y desbloquea tu insignia de Supporter',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.neonAmber, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botón de Cerrar Sesión
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sesión cerrada. Ahora navegas como Invitado.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.neonRedAlert),
              label: Text(
                'Cerrar Sesión',
                style: AppTypography.bodyBold.copyWith(color: AppColors.neonRedAlert),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _benefitRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
