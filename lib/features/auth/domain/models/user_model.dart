/// Modelo de Usuario para Autenticación Social (Google, Facebook, Instagram) & Perfil Comunitario
class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isGuest;
  final bool isSupporter;
  final String? supporterTier;
  final DateTime? supporterSince;
  final String authProvider; // 'google', 'facebook', 'instagram', 'guest'

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.isGuest = false,
    this.isSupporter = false,
    this.supporterTier,
    this.supporterSince,
    this.authProvider = 'guest',
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
      authProvider: 'guest',
    );
  }

  /// Obtiene las iniciales estilizadas del nombre (ej: "Kevin Ramos" -> "KR", "Alex" -> "A")
  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isGoogle => authProvider.toLowerCase() == 'google';
  bool get isFacebook => authProvider.toLowerCase() == 'facebook';
  bool get isInstagram => authProvider.toLowerCase() == 'instagram';

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isGuest,
    bool? isSupporter,
    String? supporterTier,
    DateTime? supporterSince,
    String? authProvider,
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
      authProvider: authProvider ?? this.authProvider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isGuest': isGuest,
      'isSupporter': isSupporter,
      'supporterTier': supporterTier,
      'supporterSince': supporterSince?.toIso8601String(),
      'authProvider': authProvider,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? 'guest_user',
      displayName: json['displayName'] as String? ?? 'Invitado',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      isSupporter: json['isSupporter'] as bool? ?? false,
      supporterTier: json['supporterTier'] as String?,
      supporterSince: json['supporterSince'] != null
          ? DateTime.tryParse(json['supporterSince'] as String)
          : null,
      authProvider: json['authProvider'] as String? ?? 'guest',
    );
  }
}
