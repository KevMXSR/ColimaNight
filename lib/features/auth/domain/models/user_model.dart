/// Modelo de Usuario para Autenticación Social & Perfil Comunitario
class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isGuest;
  final bool isSupporter;
  final String? supporterTier;
  final DateTime? supporterSince;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isGuest = false,
    this.isSupporter = false,
    this.supporterTier,
    this.supporterSince,
  });

  /// Usuario no autenticado que navega en modo libre
  factory UserModel.guest() {
    return const UserModel(
      id: 'guest_user',
      displayName: 'Invitado',
      email: '',
      photoUrl: null,
      isGuest: true,
      isSupporter: false,
    );
  }

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isGuest,
    bool? isSupporter,
    String? supporterTier,
    DateTime? supporterSince,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isGuest: isGuest ?? this.isGuest,
      isSupporter: isSupporter ?? this.isSupporter,
      supporterTier: supporterTier ?? this.supporterTier,
      supporterSince: supporterSince ?? this.supporterSince,
    );
  }
}
