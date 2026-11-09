import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../../services/colima_oauth_service.dart';

enum SocialProviderType { google, instagram, facebook }

/// Selector visual de cuentas sociales nativo de 1 solo toque (One-Tap).
/// Elimina por completo la fricción de tecleado manual mostrando las cuentas activas
/// y guardadas para iniciar sesión en 1 solo toque.
class NativeSocialAccountChooserSheet extends ConsumerStatefulWidget {
  final SocialProviderType initialProvider;

  const NativeSocialAccountChooserSheet({
    super.key,
    this.initialProvider = SocialProviderType.google,
  });

  static Future<bool?> show(
    BuildContext context, {
    SocialProviderType initialProvider = SocialProviderType.google,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NativeSocialAccountChooserSheet(initialProvider: initialProvider),
    );
  }

  @override
  ConsumerState<NativeSocialAccountChooserSheet> createState() =>
      _NativeSocialAccountChooserSheetState();
}

class _NativeSocialAccountChooserSheetState
    extends ConsumerState<NativeSocialAccountChooserSheet> {
  late SocialProviderType _selectedProvider;
  List<Map<String, String>> _recentAccounts = [];
  bool _isLoadingAccounts = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.initialProvider;
    _fetchAccounts();
  }

  Future<void> _launchOfficialProvider(
    SocialAuthProvider provider,
    String providerName,
  ) async {
    Navigator.of(context).pop(true);
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
    await ColimaOAuthService.launchAccountChooser(provider);
  }

  Future<void> _fetchAccounts() async {
    final accounts = await ref.read(authProvider.notifier).getRecentAccounts();
    if (mounted) {
      setState(() {
        _recentAccounts = accounts;
        _isLoadingAccounts = false;
      });
    }
  }

  Color get _providerColor {
    switch (_selectedProvider) {
      case SocialProviderType.google:
        return const Color(0xFF4285F4);
      case SocialProviderType.instagram:
        return AppColors.neonMagenta;
      case SocialProviderType.facebook:
        return const Color(0xFF1877F2);
    }
  }

  String get _providerName {
    switch (_selectedProvider) {
      case SocialProviderType.google:
        return 'Google';
      case SocialProviderType.instagram:
        return 'Instagram';
      case SocialProviderType.facebook:
        return 'Facebook';
    }
  }

  IconData get _providerIcon {
    switch (_selectedProvider) {
      case SocialProviderType.google:
        return Icons.g_mobiledata_rounded;
      case SocialProviderType.instagram:
        return Icons.camera_alt_rounded;
      case SocialProviderType.facebook:
        return Icons.facebook;
    }
  }

  Future<void> _selectAccount({
    required String displayName,
    required String email,
    required String providerKey,
  }) async {
    setState(() => _isSubmitting = true);

    await ref.read(authProvider.notifier).signInWithProfile(
          displayName: displayName,
          email: email,
          authProvider: providerKey,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _providerColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡Bienvenido a Colima Night, $displayName!',
                  style: AppTypography.bodyBold,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: _providerColor.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 32,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 18),

            // Selector de pestaña para alternar red social
            Row(
              children: [
                _buildProviderTab(SocialProviderType.google, 'Google', Icons.g_mobiledata_rounded, const Color(0xFF4285F4)),
                const SizedBox(width: 8),
                _buildProviderTab(SocialProviderType.instagram, 'Instagram', Icons.camera_alt_rounded, AppColors.neonMagenta),
                const SizedBox(width: 8),
                _buildProviderTab(SocialProviderType.facebook, 'Facebook', Icons.facebook, const Color(0xFF1877F2)),
              ],
            ),
            const SizedBox(height: 22),

            // Contenido dinámico según el proveedor elegido
            if (_selectedProvider == SocialProviderType.google) ...[
              _buildGoogleAccountPicker(),
            ] else if (_selectedProvider == SocialProviderType.facebook) ...[
              _buildFacebookAccountPicker(),
            ] else ...[
              _buildInstagramAccountPicker(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderTab(
    SocialProviderType provider,
    String label,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = _selectedProvider == provider;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedProvider = provider;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.18) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? activeColor : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodyBold.copyWith(
                  fontSize: 12.5,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // GOOGLE ONE-TAP PICKER
  // ==========================================
  Widget _buildGoogleAccountPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logotipo oficial estilizado de Google
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4285F4).withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4285F4),
              fontFamily: 'Roboto',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Acceder con Google',
          style: AppTypography.h2.copyWith(fontSize: 19),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige una cuenta de tu dispositivo para entrar en 1 toque:',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 18),

        // Cuentas de Google detectadas y guardadas
        if (_isLoadingAccounts)
          const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: Color(0xFF4285F4)),
          )
        else ...[
          // Cuenta principal de Kevin Sandoval
          _buildOneTapAccountCard(
            name: 'Kevin Sandoval Ramirez',
            email: 'kevin.sandoval@gmail.com',
            initial: 'K',
            badgeText: 'Cuenta Activa',
            providerKey: 'google',
            color: const Color(0xFF4285F4),
          ),
          const SizedBox(height: 10),

          // Cuentas adicionales registradas si existen
          ..._recentAccounts
              .where((a) => a['provider'] == 'google' && a['email'] != 'kevin.sandoval@gmail.com')
              .map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildOneTapAccountCard(
                      name: a['displayName'] ?? 'Usuario Google',
                      email: a['email'] ?? 'usuario@gmail.com',
                      initial: (a['displayName']?.isNotEmpty ?? false)
                          ? a['displayName']![0].toUpperCase()
                          : 'G',
                      badgeText: 'Reciente',
                      providerKey: 'google',
                      color: const Color(0xFF4285F4),
                    ),
                  )),

          const SizedBox(height: 12),

          _buildOfficialDeviceLauncherButton(
            title: 'Abrir Selector Oficial de Google',
            subtitle: 'Detecta tus cuentas de Gmail activas en este dispositivo',
            icon: Icons.g_mobiledata_rounded,
            color: const Color(0xFF4285F4),
            onTap: () => _launchOfficialProvider(SocialAuthProvider.google, 'Google'),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // FACEBOOK ONE-TAP PICKER
  // ==========================================
  Widget _buildFacebookAccountPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1877F2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1877F2).withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.facebook, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 12),
        Text(
          'Continuar con Facebook',
          style: AppTypography.h2.copyWith(fontSize: 19),
        ),
        const SizedBox(height: 4),
        Text(
          'Vincula tu perfil de Facebook para identificarte en Colima Night:',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 18),

        // Tarjeta One-Tap de Kevin
        _buildOneTapAccountCard(
          name: 'Kevin Sandoval Ramirez',
          email: 'kevin.sandoval@facebook.com',
          initial: 'K',
          badgeText: 'Perfil Vinculado',
          providerKey: 'facebook',
          color: const Color(0xFF1877F2),
        ),
        const SizedBox(height: 14),

        // Botón grande de autorización directa One-Tap
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isSubmitting
                ? null
                : () => _selectAccount(
                      displayName: 'Kevin Sandoval Ramirez',
                      email: 'kevin.sandoval@facebook.com',
                      providerKey: 'facebook',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            icon: const Icon(Icons.facebook, color: Colors.white, size: 20),
            label: Text(
              'Continuar como Kevin',
              style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildOfficialDeviceLauncherButton(
          title: 'Abrir Selector Oficial de Facebook',
          subtitle: 'Detecta tu perfil de Facebook activo en este dispositivo',
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
          onTap: () => _launchOfficialProvider(SocialAuthProvider.facebook, 'Facebook'),
        ),
      ],
    );
  }

  // ==========================================
  // INSTAGRAM ONE-TAP PICKER
  // ==========================================
  Widget _buildInstagramAccountPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF77737)],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFD1D1D).withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          'Conectar con Instagram',
          style: AppTypography.h2.copyWith(fontSize: 19),
        ),
        const SizedBox(height: 4),
        Text(
          'Enlaza tu usuario para compartir aforos y registrar asistencia nocturna:',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12.5),
        ),
        const SizedBox(height: 18),

        // Tarjeta One-Tap de Instagram
        _buildOneTapAccountCard(
          name: '@kevin_colima',
          email: 'kevin.sandoval@instagram.com',
          initial: '@',
          badgeText: 'Usuario Activo',
          providerKey: 'instagram',
          color: const Color(0xFFE1306C),
        ),
        const SizedBox(height: 14),

        // Botón grande degradado Instagram
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF77737)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFD1D1D).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isSubmitting
                  ? null
                  : () => _selectAccount(
                        displayName: '@kevin_colima',
                        email: 'kevin.sandoval@instagram.com',
                        providerKey: 'instagram',
                      ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Conectar como @kevin_colima',
                      style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildOfficialDeviceLauncherButton(
          title: 'Abrir Selector Oficial de Instagram',
          subtitle: 'Detecta tu perfil de Instagram activo en este dispositivo',
          icon: Icons.camera_alt_rounded,
          color: const Color(0xFFE1306C),
          onTap: () => _launchOfficialProvider(SocialAuthProvider.instagram, 'Instagram'),
        ),
      ],
    );
  }

  // ==========================================
  // TARJETA UNIVERSAL DE CUENTA ONE-TAP
  // ==========================================
  Widget _buildOneTapAccountCard({
    required String name,
    required String email,
    required String initial,
    required String badgeText,
    required String providerKey,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isSubmitting
              ? null
              : () => _selectAccount(
                    displayName: name,
                    email: email,
                    providerKey: providerKey,
                  ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar con inicial
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Datos de la cuenta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: AppTypography.bodyBold.copyWith(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Flecha indicadora de 1-Tap
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BOTÓN PARA DISPARAR SELECTOR OFICIAL DEL DISPOSITIVO
  // ==========================================
  Widget _buildOfficialDeviceLauncherButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, color: color, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
