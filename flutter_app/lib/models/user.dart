class User {
  final int id;
  final String email;
  final String nickname;
  final bool isActive;
  final int? nbProductsSent;
  final DateTime? veganSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.isActive,
    required this.nbProductsSent,
    required this.veganSince,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      isActive: json['is_active'] ?? false,
      nbProductsSent: json['nb_products_sent'] ?? 0,
      veganSince: json['vegan_since'] != null
          ? DateTime.tryParse(json['vegan_since'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'is_active': isActive,
      'nb_products_sent': nbProductsSent,
      'vegan_since': veganSince?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
