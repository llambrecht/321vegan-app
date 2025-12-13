import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';
import '../models/user.dart';
import '../helpers/preference_helper.dart';
import 'dio_client.dart';

class AuthService {
  static Map<String, String> get _headersWithApiKey => {
        'Content-Type': 'application/json',
        'x-api-key': dotenv.env['API_KEY'] ?? '',
      };

  static String? _accessToken;
  static User? _currentUser;
  static DateTime? _tokenExpiresAt;

  // Initialize the service and check for stored tokens
  static Future<void> init() async {
    await _loadStoredToken();
    if (isLoggedIn) {
      await _checkAndRefreshToken();
    }
  }

  // Load stored access token from SharedPreferences
  static Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      final expiresAtString = prefs.getString('token_expires_at');
      if (expiresAtString != null) {
        _tokenExpiresAt = DateTime.parse(expiresAtString);
      }
    } catch (e) {
      debugPrint('Error loading stored token: $e');
    }
  }

  // Store access token in SharedPreferences
  static Future<void> _storeToken(String token,
      {int expiresInSeconds = 1800}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      _accessToken = token;

      // Calculate and store expiration time (default 30 minutes)
      _tokenExpiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
      await prefs.setString(
          'token_expires_at', _tokenExpiresAt!.toIso8601String());
    } catch (e) {
      debugPrint('Error storing token: $e');
    }
  }

  // Clear stored token
  static Future<void> _clearToken() async {
    try {
      _tokenExpiresAt = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('token_expires_at');
      _accessToken = null;
      _currentUser = null;
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Check if token is expired or will expire soon, and refresh if needed
  static Future<void> _checkAndRefreshToken() async {
    if (_tokenExpiresAt == null) return;

    final now = DateTime.now();
    final minutesUntilExpiry = _tokenExpiresAt!.difference(now).inMinutes;

    // If token is expired or will expire in less than 5 minutes, refresh it
    if (minutesUntilExpiry < 5) {
      final result = await refreshToken();
      if (result.isSuccess) {
        debugPrint('✅ Token refreshed on app launch');
      } else {
        debugPrint('❌ Failed to refresh token on app launch');
      }
    } else {
      debugPrint('Token still valid (${minutesUntilExpiry} minutes remaining)');
    }
  }

  // Sync user data from backend to local preferences
  static Future<void> _syncUserDataToPreferences() async {
    try {
      final userResult = await getCurrentUser();
      if (userResult.isSuccess) {
        if (userResult.data?.veganSince != null) {
          // Use internal method to avoid calling backend again
          await PreferencesHelper.saveSelectedDateToPrefsOnly(
            userResult.data!.veganSince,
          );
        } else {
          // Backend has null, so clear local storage
          await PreferencesHelper.saveSelectedDateToPrefsOnly(null);
        }
      } else {}
    } catch (e) {
      // Don't throw - this is not critical for login
    }
  }

  // Check if user is logged in
  static bool get isLoggedIn => _accessToken != null;

  // Get current user
  static User? get currentUser => _currentUser;

  // Login
  static Future<AuthResult<AuthToken>> login(LoginRequest request) async {
    try {
      final dio = await DioClient.getDio();

      final response = await dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': request.email,
          'password': request.password,
        }),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(response.data);
        await _storeToken(token.accessToken);

        // Fetch user data and sync vegan date to local storage
        await _syncUserDataToPreferences();

        return AuthResult.success(token);
      } else {
        return AuthResult.error('Mot de passe ou email incorrect');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return AuthResult.error('Mot de passe ou email incorrect');
      }
      return AuthResult.error('Erreur réseau lors de la connexion');
    } catch (e) {
      return AuthResult.error('Erreur réseau lors de la connexion');
    }
  }

  static Future<AuthResult<String>> register(RegisterRequest request) async {
    try {
      final dio = await DioClient.getDio();

      // Use API key headers for registration
      final response = await dio.post(
        '/users/',
        data: request.toJson(),
        options: Options(
          headers: _headersWithApiKey,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      return _handleRegistrationResponse(response);
    } on DioException catch (e) {
      if (e.response != null) {
        return _handleRegistrationResponse(e.response!);
      }
      return AuthResult.error('Network error during registration');
    } catch (e) {
      return AuthResult.error('Network error during registration');
    }
  }

  // Helper method to handle registration response
  static AuthResult<String> _handleRegistrationResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return AuthResult.success('Votre compte a bien été créé !');
    } else if (response.statusCode == 403) {
      return AuthResult.error(
          'L\'inscription n\'est actuellement pas disponible. Veuillez contacter un administrateur.');
    } else if (response.statusCode == 409) {
      return AuthResult.error(
          'Un utilisateur avec cet email ou ce pseudo existe déjà.');
    } else {
      try {
        final error = response.data;
        if (error is Map && error['detail'] != null) {
          return AuthResult.error(error['detail']);
        }
        return AuthResult.error('Registration failed (${response.statusCode})');
      } catch (jsonError) {
        debugPrint('Error parsing registration error: $jsonError');
        return AuthResult.error('Registration failed (${response.statusCode})');
      }
    }
  }

  // Refresh token (kept for manual refresh if needed, but automatic refresh is now handled by Dio interceptor)
  static Future<AuthResult<AuthToken>> refreshToken() async {
    try {
      final dio = await DioClient.getDio();

      // The refresh_token cookie is automatically sent by dio_cookie_manager
      final response = await dio.post('/auth/refresh');

      if (response.statusCode == 200) {
        final token = AuthToken.fromJson(response.data);
        await _storeToken(token.accessToken);
        return AuthResult.success(token);
      } else if (response.statusCode == 401) {
        // Only clear tokens on authentication errors
        await _clearToken();
        await DioClient.clearCookies();
        return AuthResult.error('AUTH_EXPIRED');
      } else {
        // Other errors (5xx, etc.) shouldn't log user out
        return AuthResult.error('Token refresh failed');
      }
    } on DioException catch (e) {
      // Only clear tokens on 401 authentication errors
      if (e.response?.statusCode == 401) {
        await _clearToken();
        await DioClient.clearCookies();
        return AuthResult.error('AUTH_EXPIRED');
      }

      // Network errors (server down, timeout, no internet) should not log user out
      return AuthResult.error('NETWORK_ERROR');
    } catch (e) {
      // Unexpected errors should not log user out
      return AuthResult.error('NETWORK_ERROR');
    }
  }

  // Logout
  static Future<AuthResult<String>> logout() async {
    try {
      final dio = await DioClient.getDio();

      await dio.get(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      await _clearToken();
      await DioClient.clearCookies();

      return AuthResult.success('Logged out successfully');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      await _clearToken();
      await DioClient.clearCookies();
      return AuthResult.success('Logged out locally');
    }
  }

  // Delete account
  static Future<AuthResult<String>> deleteAccount(
      BuildContext context, currentUser) async {
    // Ask for confirmation before deleting account
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (!confirmed) {
      return AuthResult.error('Annulation de la suppression du compte');
    }
    try {
      final dio = await DioClient.getDio();

      await dio.delete(
        '/users/${currentUser.id}',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
          validateStatus: (status) => status! < 500,
        ),
      );

      await _clearToken();
      await DioClient.clearCookies();
      return AuthResult.success('Compte supprimé avec succès.');
    } on DioException catch (e) {
      debugPrint('❌ Account deletion error: ${e.message}');
      await _clearToken();
      await DioClient.clearCookies();
      return AuthResult.error('Erreur lors de la suppression du compte');
    } catch (e) {
      debugPrint('❌ Unexpected deletion error: $e');
      await _clearToken();
      await DioClient.clearCookies();
      return AuthResult.error('Erreur réseau lors de la suppression du compte');
    }
  }

  // Helper method to show delete confirmation dialog
  static Future<bool> _showDeleteConfirmationDialog(
      BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Confirmer la suppression'),
              content: const Text(
                  'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                TextButton(
                  child: const Text('Supprimer'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Request password reset
  static Future<AuthResult<String>> requestPasswordReset(
      PasswordResetRequest request) async {
    try {
      final dio = await DioClient.getDio();

      final response = await dio.post(
        '/auth/password-reset/request',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResult.success(data['detail'] ?? 'Reset email sent');
      } else {
        final error = response.data;
        return AuthResult.error(error['detail'] ?? 'Reset request failed');
      }
    } on DioException catch (e) {
      debugPrint('❌ Password reset request error: ${e.message}');
      if (e.response?.data != null && e.response!.data['detail'] != null) {
        return AuthResult.error(e.response!.data['detail']);
      }
      return AuthResult.error('Network error during password reset request');
    } catch (e) {
      debugPrint('❌ Unexpected password reset error: $e');
      return AuthResult.error('Network error during password reset request');
    }
  }

  // Confirm password reset
  static Future<AuthResult<String>> confirmPasswordReset(
      PasswordResetConfirm request) async {
    try {
      final dio = await DioClient.getDio();

      final response = await dio.post(
        '/auth/password-reset/confirm',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResult.success(
            data['detail'] ?? 'Password reset successful');
      } else {
        final error = response.data;
        return AuthResult.error(error['detail'] ?? 'Password reset failed');
      }
    } on DioException catch (e) {
      debugPrint('❌ Password reset confirmation error: ${e.message}');
      if (e.response?.data != null && e.response!.data['detail'] != null) {
        return AuthResult.error(e.response!.data['detail']);
      }
      return AuthResult.error('Network error during password reset');
    } catch (e) {
      debugPrint('❌ Unexpected password reset error: $e');
      return AuthResult.error('Network error during password reset');
    }
  }

  // Verify reset token
  static Future<AuthResult<String>> verifyResetToken(
      PasswordResetTokenVerify request) async {
    try {
      final dio = await DioClient.getDio();

      final response = await dio.post(
        '/auth/password-reset/verify-token',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AuthResult.success(data['email'] ?? 'Token is valid');
      } else {
        final error = response.data;
        return AuthResult.error(error['detail'] ?? 'Invalid token');
      }
    } on DioException catch (e) {
      debugPrint('❌ Token verification error: ${e.message}');
      if (e.response?.data != null && e.response!.data['detail'] != null) {
        return AuthResult.error(e.response!.data['detail']);
      }
      return AuthResult.error('Network error during token verification');
    } catch (e) {
      debugPrint('❌ Unexpected token verification error: $e');
      return AuthResult.error('Network error during token verification');
    }
  }

  // Get current user info
  static Future<AuthResult<User>> getCurrentUser() async {
    try {
      final dio = await DioClient.getDio();

      final response = await dio.get(
        '/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.error('Failed to get user info');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token refresh is now handled automatically by the Dio interceptor
        debugPrint('❌ Authentication expired');
        await _clearToken();
        await DioClient.clearCookies();
        return AuthResult.error('AUTH_EXPIRED');
      }

      // Network errors (server down, no internet, timeout) should not log user out
      debugPrint('⚠️ Temporary network error getting user info: ${e.message}');
      return AuthResult.error('NETWORK_ERROR');
    } catch (e) {
      debugPrint('❌ Unexpected get user error: $e');
      return AuthResult.error('NETWORK_ERROR');
    }
  }

  // Update user information
  static Future<AuthResult<User>> updateUser({
    int? userId,
    DateTime? veganSince,
    String? nickname,
    String? email,
  }) async {
    try {
      // Use the current user's id if not provided
      final id = userId ?? _currentUser?.id;
      if (id == null) {
        return AuthResult.error('User ID not found');
      }

      final dio = await DioClient.getDio();
      final Map<String, dynamic> updates = {};

      if (veganSince != null) {
        updates['vegan_since'] = veganSince.toIso8601String();
      }
      if (nickname != null) {
        updates['nickname'] = nickname;
      }
      if (email != null) {
        updates['email'] = email;
      }

      final response = await dio.patch(
        '/users/$id',
        data: updates,
        options: Options(
          headers: _headersWithApiKey,
        ),
      );

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        return AuthResult.success(_currentUser!);
      } else {
        return AuthResult.error('Impossible de mettre à jour le profil');
      }
    } on DioException catch (e) {
      debugPrint('❌ Update user error: ${e.message}');
      return AuthResult.error('Impossible de mettre à jour le profil');
    } catch (e) {
      debugPrint('❌ Unexpected update user error: $e');
      return AuthResult.error('Impossible de contacter le serveur');
    }
  }
}

// Generic result class for auth operations
class AuthResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  AuthResult._({this.data, this.error, required this.isSuccess});

  factory AuthResult.success(T data) {
    return AuthResult._(data: data, isSuccess: true);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(error: error, isSuccess: false);
  }
}
