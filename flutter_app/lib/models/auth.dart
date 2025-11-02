class AuthToken {
  final String accessToken;
  final String tokenType;

  AuthToken({
    required this.accessToken,
    required this.tokenType,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, String> toFormData() {
    return {
      'username': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String nickname;
  final String role;
  final bool isActive;
  final DateTime? veganSince;
  final int nbProductsSent;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nickname,
    this.role = 'user',
    this.isActive = true,
    this.veganSince,
    this.nbProductsSent = 0,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'email': email,
      'password': password,
      'nickname': nickname,
      'role': role,
      'is_active': isActive,
      'nb_products_sent': nbProductsSent,
    };

    if (veganSince != null) {
      json['vegan_since'] = veganSince!.toIso8601String();
    }

    return json;
  }
}

class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class PasswordResetConfirm {
  final String token;
  final String newPassword;

  PasswordResetConfirm({
    required this.token,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'new_password': newPassword,
    };
  }
}

class PasswordResetTokenVerify {
  final String token;

  PasswordResetTokenVerify({required this.token});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
