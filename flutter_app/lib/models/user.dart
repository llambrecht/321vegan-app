class User {
  final int id;
  final String email;
  final String nickname;
  final bool isActive;
  final int? nbProductsSent;
  final int? supporterLevel;
  final int? nbErrorReports;
  final int? nbProductsModified;
  final int? nbCheckings;
  final DateTime? veganSince;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.isActive,
    required this.nbProductsSent,
    required this.supporterLevel,
    required this.nbErrorReports,
    this.nbProductsModified,
    this.nbCheckings,
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
      supporterLevel: json['supporter'] ?? 0,
      nbErrorReports: json['error_reports'] != null
          ? (json['error_reports'] as List).length
          : 0,
      nbProductsModified: json['nb_products_modified'] ?? 0,
      nbCheckings: json['nb_checkings'] ?? 0,
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
      'supporter': supporterLevel,
      'vegan_since': veganSince?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
