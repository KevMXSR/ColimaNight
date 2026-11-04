import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

enum SocialProviderType { google, instagram, facebook }

class AccountSelectorSheet extends ConsumerStatefulWidget {
  final SocialProviderType initialProvider;

  const AccountSelectorSheet({
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
      builder: (_) => AccountSelectorSheet(initialProvider: initialProvider),
    );
  }

  @override
  ConsumerState<AccountSelectorSheet> createState() => _AccountSelectorSheetState();
}

class _AccountSelectorSheetState extends ConsumerState<AccountSelectorSheet> {
  late SocialProviderType _selectedProvider;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  // Sugerencias rápidas para comodidad del usuario
  final List<String> _suggestedNames = ['Kevin', 'Kev', 'Explorador Colima'];

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.initialProvider;
    _updatePlaceholders();
  }

  void _updatePlaceholders() {
    if (_accountController.text.isEmpty) {
      switch (_selectedProvider) {
        case SocialProviderType.google:
          _accountController.text = '';
          break;
        case SocialProviderType.instagram:
          _accountController.text = '@';
          break;
        case SocialProviderType.facebook:
          _accountController.text = '';
          break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Color get _providerColor {
    switch (_selectedProvider) {
      case SocialProviderType.google:
        return AppColors.neonCyan;
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

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final account = _accountController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu nombre o alias');
      return;
    }

    if (account.isEmpty || account == '@') {
      setState(() => _errorMessage = 'Por favor ingresa tu correo o usuario de $_providerName');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final providerKey = _providerName.toLowerCase();
    await ref.read(authProvider.notifier).signInWithProfile(
          displayName: name,
          email: account.contains('@') ? account : '$account@$_providerName.com',
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '¡Bienvenido a Colima Night, $name!',
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
        color: AppColors.surface.withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
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
            // Indicador de arrastre táctil
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),

            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_providerIcon, color: _providerColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Configurar Perfil de Acceso',
                  style: AppTypography.h2.copyWith(fontSize: 19),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Elige tu red social e ingresa tus datos para personalizar tu pulso en Colima Night.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 18),

            // Selector de Proveedor Social (Google / Instagram / Facebook)
            Row(
              children: [
                _buildProviderTab(SocialProviderType.google, 'Google', Icons.g_mobiledata_rounded, AppColors.neonCyan),
                const SizedBox(width: 8),
                _buildProviderTab(SocialProviderType.instagram, 'Instagram', Icons.camera_alt_rounded, AppColors.neonMagenta),
                const SizedBox(width: 8),
                _buildProviderTab(SocialProviderType.facebook, 'Facebook', Icons.facebook, const Color(0xFF1877F2)),
              ],
            ),
            const SizedBox(height: 20),

            // Previsualización de Avatar en tiempo real
            Center(
              child: AnimatedBuilder(
                animation: _nameController,
                builder: (context, _) {
                  final initial = _getInitials(_nameController.text);
                  return Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _providerColor.withOpacity(0.35),
                          AppColors.surfaceElevated,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: _providerColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _providerColor.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Chips de Sugerencia Rápida de Nombre
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sugerencias rápidas de nombre:',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _suggestedNames.map((name) {
                return ActionChip(
                  label: Text(name),
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _nameController.text == name ? Colors.black : Colors.white,
                  ),
                  backgroundColor: _nameController.text == name
                      ? _providerColor
                      : AppColors.surfaceElevated,
                  side: BorderSide(
                    color: _nameController.text == name
                        ? _providerColor
                        : AppColors.glassBorder,
                  ),
                  onPressed: () {
                    setState(() {
                      _nameController.text = name;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Campo de Nombre / Alias
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Tu Nombre o Alias',
                labelStyle: TextStyle(color: _providerColor.withOpacity(0.8), fontSize: 13),
                hintText: 'Ej. Kevin',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.person_rounded, color: Colors.white70, size: 20),
                filled: true,
                fillColor: AppColors.surfaceElevated.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _providerColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Campo de Correo / Usuario
            TextField(
              controller: _accountController,
              keyboardType: _selectedProvider == SocialProviderType.instagram
                  ? TextInputType.text
                  : TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: _selectedProvider == SocialProviderType.instagram
                    ? 'Usuario de Instagram'
                    : 'Correo de $_providerName',
                labelStyle: TextStyle(color: _providerColor.withOpacity(0.8), fontSize: 13),
                hintText: _selectedProvider == SocialProviderType.instagram
                    ? '@tu_usuario'
                    : 'tu_cuenta@gmail.com',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                prefixIcon: Icon(_providerIcon, color: Colors.white70, size: 18),
                filled: true,
                fillColor: AppColors.surfaceElevated.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: _providerColor, width: 1.5),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.neonRedAlert.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neonRedAlert.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.neonRedAlert, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),

            // Botón Principal de Confirmación
            GestureDetector(
              onTap: _isSubmitting ? null : _handleSave,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _providerColor,
                      _providerColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _providerColor.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isSubmitting
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
                          Icon(_providerIcon, color: Colors.black, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Iniciar Sesión con $_providerName',
                            style: AppTypography.bodyBold.copyWith(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Botón Cancelar
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderTab(
    SocialProviderType type,
    String name,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedProvider == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedProvider = type;
            _updatePlaceholders();
            _errorMessage = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceElevated.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.glassBorder,
              width: isSelected ? 1.6 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: isSelected ? color : Colors.white60),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
