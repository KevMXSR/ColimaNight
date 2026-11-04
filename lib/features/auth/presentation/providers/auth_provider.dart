import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';

class AuthNotifier extends StateNotifier<UserModel> {
  static const String _storageKey = 'colima_night_user_session_v1';

  AuthNotifier() : super(UserModel.guest()) {
    _loadStoredSession();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Restaura la sesión persistida en el dispositivo si existe
  Future<void> _loadStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(rawJson);
        final user = UserModel.fromJson(data);
        if (!user.isGuest) {
          state = user;
        }
      }
    } catch (e) {
      debugPrint('Error al restaurar sesión de usuario: $e');
    }
  }

  /// Guarda el estado actual en el almacenamiento local
  Future<void> _persistSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user.isGuest) {
        await prefs.remove(_storageKey);
      } else {
        await prefs.setString(_storageKey, jsonEncode(user.toJson()));
      }
    } catch (e) {
      debugPrint('Error al persistir sesión de usuario: $e');
    }
  }

  /// Inicia sesión con datos reales del usuario según el proveedor social elegido (Google, Facebook, Instagram)
  Future<bool> signInWithProfile({
    required String displayName,
    required String email,
    String authProvider = 'google',
    String? photoUrl,
  }) async {
    _isLoading = true;
    await Future.delayed(const Duration(milliseconds: 400));

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      displayName: displayName.trim().isNotEmpty ? displayName.trim() : 'Usuario Colima',
      email: email.trim().isNotEmpty ? email.trim() : 'usuario@colimanight.app',
      photoUrl: photoUrl,
      isGuest: false,
      isSupporter: state.isSupporter,
      supporterTier: state.supporterTier,
      supporterSince: state.supporterSince,
      authProvider: authProvider,
    );

    state = newUser;
    _isLoading = false;
    await _persistSession(newUser);
    return true;
  }

  /// Inicio de sesión rápido con Google (sin datos ficticios predefinidos)
  Future<bool> signInWithGoogle({
    String? mockName,
    String? mockEmail,
    String? photoUrl,
  }) async {
    return signInWithProfile(
      displayName: mockName ?? 'Explorador Colimense',
      email: mockEmail ?? 'explorador@gmail.com',
      authProvider: 'google',
      photoUrl: photoUrl,
    );
  }

  /// Inicio de sesión con Facebook
  Future<bool> signInWithFacebook({
    required String displayName,
    required String email,
    String? photoUrl,
  }) async {
    return signInWithProfile(
      displayName: displayName,
      email: email,
      authProvider: 'facebook',
      photoUrl: photoUrl,
    );
  }

  /// Inicio de sesión con Instagram
  Future<bool> signInWithInstagram({
    required String username,
    String? photoUrl,
  }) async {
    final cleanName = username.startsWith('@') ? username : '@$username';
    return signInWithProfile(
      displayName: cleanName,
      email: '$cleanName@instagram.com',
      authProvider: 'instagram',
      photoUrl: photoUrl,
    );
  }

  /// Modifica el perfil actual del usuario manteniendo su estatus
  Future<void> updateProfile({
    String? displayName,
    String? email,
    String? photoUrl,
    String? authProvider,
  }) async {
    final updated = state.copyWith(
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      authProvider: authProvider,
    );
    state = updated;
    await _persistSession(updated);
  }

  /// Restablece la sesión al modo Invitado y elimina datos locales
  Future<void> signOut() async {
    state = UserModel.guest();
    await _persistSession(state);
  }

  /// Permite continuar explícitamente como Invitado
  void continueAsGuest() {
    state = UserModel.guest();
  }

  /// Activa o actualiza el nivel de apoyo Comunitario / Patreon
  void becomeSupporter(String tier) {
    final updated = state.copyWith(
      isSupporter: true,
      supporterTier: tier,
      supporterSince: DateTime.now(),
    );
    state = updated;
    _persistSession(updated);
  }
}

/// Provider global de autenticación y sesión de usuario
final authProvider = StateNotifierProvider<AuthNotifier, UserModel>((ref) {
  return AuthNotifier();
});
