import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';

class AuthNotifier extends StateNotifier<UserModel> {
  AuthNotifier() : super(UserModel.guest());

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Inicia sesión con Google (Simulación / Flujo Social)
  Future<bool> signInWithGoogle({
    String mockName = 'Alex Mendoza',
    String mockEmail = 'alex.mendoza.col@gmail.com',
  }) async {
    _isLoading = true;
    // Simula latencia de red para autenticación OAuth 2.0 con Google
    await Future.delayed(const Duration(milliseconds: 700));

    state = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      displayName: mockName,
      email: mockEmail,
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      isGuest: false,
      isSupporter: state.isSupporter,
      supporterTier: state.supporterTier,
      supporterSince: state.supporterSince,
    );

    _isLoading = false;
    return true;
  }

  /// Restablece la sesión al modo Invitado
  void signOut() {
    state = UserModel.guest();
  }

  /// Permite continuar explícitamente como Invitado
  void continueAsGuest() {
    state = UserModel.guest();
  }

  /// Activa o actualiza el nivel de apoyo Comunitario / Patreon
  void becomeSupporter(String tier) {
    state = state.copyWith(
      isSupporter: true,
      supporterTier: tier,
      supporterSince: DateTime.now(),
    );
  }
}

/// Provider global de autenticación y sesión de usuario
final authProvider = StateNotifierProvider<AuthNotifier, UserModel>((ref) {
  return AuthNotifier();
});
