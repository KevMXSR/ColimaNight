import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'native_social_account_chooser_sheet.dart';

export 'native_social_account_chooser_sheet.dart' show SocialProviderType;

/// Selector visual de cuentas sociales nativo de 1 solo toque (One-Tap).
/// Elimina por completo la fricción de tecleado manual delegando al selector oficial del dispositivo.
class AccountSelectorSheet extends ConsumerWidget {
  final SocialProviderType initialProvider;

  const AccountSelectorSheet({
    super.key,
    this.initialProvider = SocialProviderType.google,
  });

  static Future<bool?> show(
    BuildContext context, {
    SocialProviderType initialProvider = SocialProviderType.google,
  }) {
    return NativeSocialAccountChooserSheet.show(context, initialProvider: initialProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NativeSocialAccountChooserSheet(initialProvider: initialProvider);
  }
}
