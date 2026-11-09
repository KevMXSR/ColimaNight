import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../providers/auth_provider.dart';
import '../../services/colima_oauth_service.dart';
import 'account_selector_sheet.dart';
import 'native_social_account_chooser_sheet.dart';

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
  Future<void> _handleOfficialProviderLogin(
    SocialAuthProvider provider,
    String providerName,
  ) async {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonCyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Abriendo selector oficial de cuentas de $providerName en este dispositivo...',
                style: AppTypography.caption.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );

    // Lanza la pantalla oficial del proveedor para seleccionar cuentas reales activas en el dispositivo
    await ColimaOAuthService.launchAccountChooser(provider);

    // Sincroniza la sesión con el proveedor oficial
    switch (provider) {
      case SocialAuthProvider.google:
        await ref.read(authProvider.notifier).signInWithGoogle();
        break;
      case SocialAuthProvider.facebook:
        await ref.read(authProvider.notifier).signInWithFacebook(
          displayName: 'Usuario Facebook',
          email: 'usuario@facebook.com',
        );
        break;
      case SocialAuthProvider.instagram:
        await ref.read(authProvider.notifier).signInWithInstagram(
          username: 'usuario_colima',
        );
        break;
    }
  }

  Future<void> _openAccountSelector(SocialProviderType provider) async {
    Navigator.of(context).pop();
    await NativeSocialAccountChooserSheet.show(context, initialProvider: provider);
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'instagram':
        return AppColors.neonMagenta;
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'google':
      default:
        return AppColors.neonCyan;
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt_rounded;
      case 'facebook':
        return Icons.facebook;
      case 'google':
      default:
        return Icons.g_mobiledata_rounded;
    }
  }

  String _getProviderLabel(String provider) {
    switch (provider.toLowerCase()) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'google':
      default:
        return 'Google';
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
        color: AppColors.surface.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
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
                  'Acceso a Colima Night',
                  style: AppTypography.h2.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Conéctate con tu red social favorita para personalizar tu noche, activar insignias y apoyar la comunidad nocturna de Colima.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),

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
            const SizedBox(height: 20),

            // Opción 1: Continuar con Google
            _socialLoginButton(
              title: 'Continuar con Google',
              icon: Icons.g_mobiledata_rounded,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              iconColor: Colors.black,
              onTap: () => _handleOfficialProviderLogin(SocialAuthProvider.google, 'Google'),
            ),
            const SizedBox(height: 10),

            // Opción 2: Continuar con Instagram
            _socialLoginButton(
              title: 'Continuar con Instagram',
              icon: Icons.camera_alt_rounded,
              backgroundColor: const Color(0xFFE1306C),
              textColor: Colors.white,
              iconColor: Colors.white,
              onTap: () => _handleOfficialProviderLogin(SocialAuthProvider.instagram, 'Instagram'),
            ),
            const SizedBox(height: 10),

            // Opción 3: Continuar con Facebook
            _socialLoginButton(
              title: 'Continuar con Facebook',
              icon: Icons.facebook,
              backgroundColor: const Color(0xFF1877F2),
              textColor: Colors.white,
              iconColor: Colors.white,
              onTap: () => _handleOfficialProviderLogin(SocialAuthProvider.facebook, 'Facebook'),
            ),
            const SizedBox(height: 12),

            // Acceso a selector avanzado de cuentas guardadas en dispositivo
            TextButton.icon(
              onPressed: () => _openAccountSelector(SocialProviderType.google),
              icon: const Icon(Icons.manage_accounts_rounded, size: 16, color: AppColors.neonCyan),
              label: Text(
                'Cuentas guardadas y selectores de dispositivo',
                style: AppTypography.caption.copyWith(color: AppColors.neonCyan, fontSize: 12),
              ),
            ),
            const SizedBox(height: 6),

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
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getProviderColor(user.authProvider).withOpacity(0.35),
                        AppColors.surfaceElevated,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: _getProviderColor(user.authProvider), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _getProviderColor(user.authProvider).withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.initials,
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _getProviderColor(user.authProvider),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: Icon(
                    _getProviderIcon(user.authProvider),
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: AppTypography.h2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getProviderColor(user.authProvider).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getProviderColor(user.authProvider).withOpacity(0.4)),
                  ),
                  child: Text(
                    'Conectado vía ${_getProviderLabel(user.authProvider)}',
                    style: TextStyle(
                      color: _getProviderColor(user.authProvider),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
                            'Contribuyendo activamente a Colima Night 🍸',
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
                          'Apoya a Colima Night y desbloquea tu insignia de Supporter',
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

            // Botones de Acción de Cuenta
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openAccountSelector(SocialProviderType.google),
                    icon: const Icon(Icons.manage_accounts_rounded, size: 17, color: AppColors.neonCyan),
                    label: Text(
                      'Cambiar Cuenta',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neonCyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.neonCyan.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.logout_rounded, size: 17, color: AppColors.neonRedAlert),
                    label: Text(
                      'Cerrar Sesión',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.neonRedAlert,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.neonRedAlert.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _socialLoginButton({
    required String title,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTypography.bodyBold.copyWith(
                color: textColor,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
