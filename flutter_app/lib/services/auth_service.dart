import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/auth.dart';
import '../models/user.dart';

class AuthService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.321vegan.fr';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> get _headersWithApiKey => {
        'Content-Type': 'application/json',
        'x-api-key': dotenv.env['API_KEY'] ?? '',
      };

  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_accessToken}',
      };

  static String? _accessToken;
  static User? _currentUser;

  // Initialize the service and check for stored tokens
  static Future<void> init() async {
    await _loadStoredToken();
  }

  // Load stored access token from SharedPreferences
  static Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
    } catch (e) {
      debugPrint('Error loading stored token: $e');
    }
  }

  // Store access token in SharedPreferences
  static Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      _accessToken = token;
    } catch (e) {
      debugPrint('Error storing token: $e');
    }
  }

  // Clear stored token
  static Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      _accessToken = null;
      _currentUser = null;
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Check if user is logged in
  static bool get isLoggedIn => _accessToken != null;

  // Get current user
  static User? get currentUser => _currentUser;

  // Login
  static Future<AuthResult<AuthToken>> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: request.toFormData(),
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return AuthResult.error('Empty response from server');
        }
        try {
          final data = json.decode(response.body);
          final token = AuthToken.fromJson(data);
          await _storeToken(token.accessToken);
          return AuthResult.success(token);
        } catch (jsonError) {
          return AuthResult.error('Invalid response format');
        }
      } else {
        if (response.body.isEmpty) {
          return AuthResult.error(
              'Erreur de connexion (${response.statusCode})');
        }
        try {
          return AuthResult.error('Mot de passe ou email incorrect');
        } catch (jsonError) {
          return AuthResult.error(
              'Erreur de connexion (${response.statusCode})');
        }
      }
    } catch (e) {
      return AuthResult.error('Erreur réseau lors de la connexion');
    }
  }

  static Future<AuthResult<String>> register(RegisterRequest request) async {
    try {
      // Ensure URL ends with trailing slash to avoid redirects
      final url = Uri.parse('$_baseUrl/users/');
      final body = json.encode(request.toJson());

      // Use API key headers for registration
      final response = await http.post(
        url,
        headers: _headersWithApiKey,
        body: body,
      );

      // Handle redirects
      if (response.statusCode == 307 || response.statusCode == 308) {
        final redirectLocation = response.headers['location'];
        if (redirectLocation != null) {
          debugPrint('Following redirect to: $redirectLocation');
          final redirectResponse = await http.post(
            Uri.parse(redirectLocation),
            headers: _headersWithApiKey,
            body: body,
          );

          debugPrint(
              'Redirect response status: ${redirectResponse.statusCode}');
          debugPrint('Redirect response body: ${redirectResponse.body}');

          return _handleRegistrationResponse(redirectResponse);
        } else {
          return AuthResult.error(
              'Server redirect failed - no location provided');
        }
      }

      return _handleRegistrationResponse(response);
    } catch (e) {
      debugPrint('Error during registration: $e');
      return AuthResult.error('Network error during registration');
    }
  }

  // Helper method to handle registration response
  static AuthResult<String> _handleRegistrationResponse(
      http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Handle empty or non-JSON responses
      if (response.body.isEmpty) {
        return AuthResult.success('Votre compte a bien été créé !');
      }
      try {
        json.decode(response.body); // Just validate it's valid JSON
        return AuthResult.success('Votre compte a bien été créé !');
      } catch (jsonError) {
        debugPrint('JSON parsing error: $jsonError');
        return AuthResult.success('Votre compte a bien été créé !');
      }
    } else if (response.statusCode == 403) {
      return AuthResult.error(
          'L\'inscription n\'est actuellement pas disponible. Veuillez contacter un administrateur.');
    } else if (response.statusCode == 409) {
      return AuthResult.error(
          'Un utilisateur avec cet email ou ce pseudo existe déjà.');
    } else {
      // Handle error responses safely
      if (response.body.isEmpty) {
        return AuthResult.error(
            'L\'inscription a échoué (${response.statusCode})');
      }
      try {
        final error = json.decode(response.body);
        return AuthResult.error(error['detail'] ?? 'Registration failed');
      } catch (jsonError) {
        debugPrint('Error JSON parsing error: $jsonError');
        return AuthResult.error('Registration failed (${response.statusCode})');
      }
    }
  }

  // Refresh token
  static Future<AuthResult<AuthToken>> refreshToken() async {
    try {
      final url = Uri.parse('$_baseUrl/auth/refresh');

      final response = await http.post(
        url,
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = AuthToken.fromJson(data);
        await _storeToken(token.accessToken);
        return AuthResult.success(token);
      } else {
        await _clearToken();
        return AuthResult.error('Token refresh failed');
      }
    } catch (e) {
      debugPrint('Error during token refresh: $e');
      await _clearToken();
      return AuthResult.error('Network error during token refresh');
    }
  }

  // Logout
  static Future<AuthResult<String>> logout() async {
    try {
      final url = Uri.parse('$_baseUrl/auth/logout');

      final response = await http.get(
        url,
        headers: _authHeaders,
      );

      await _clearToken();

      if (response.statusCode == 200) {
        return AuthResult.success('Logged out successfully');
      } else {
        return AuthResult.success('Logged out locally');
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      await _clearToken();
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
      final url = Uri.parse('$_baseUrl/users/${currentUser.id}');

      final response = await http.delete(
        url,
        headers: _authHeaders,
      );

      if (response.statusCode == 204) {
        await _clearToken();
        return AuthResult.success('Compte supprimé avec succès.');
      } else {
        return AuthResult.error('Erreur lors de la suppression du compte');
      }
    } catch (e) {
      debugPrint('Error during account deletion: $e');
      await _clearToken();
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
      final url = Uri.parse('$_baseUrl/auth/password-reset/request');
      final body = json.encode(request.toJson());

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResult.success(data['detail'] ?? 'Reset email sent');
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['detail'] ?? 'Reset request failed');
      }
    } catch (e) {
      debugPrint('Error during password reset request: $e');
      return AuthResult.error('Network error during password reset request');
    }
  }

  // Confirm password reset
  static Future<AuthResult<String>> confirmPasswordReset(
      PasswordResetConfirm request) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/password-reset/confirm');
      final body = json.encode(request.toJson());

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResult.success(
            data['detail'] ?? 'Password reset successful');
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['detail'] ?? 'Password reset failed');
      }
    } catch (e) {
      debugPrint('Error during password reset confirmation: $e');
      return AuthResult.error('Network error during password reset');
    }
  }

  // Verify reset token
  static Future<AuthResult<String>> verifyResetToken(
      PasswordResetTokenVerify request) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/password-reset/verify-token');
      final body = json.encode(request.toJson());

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AuthResult.success(data['email'] ?? 'Token is valid');
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['detail'] ?? 'Invalid token');
      }
    } catch (e) {
      debugPrint('Error during token verification: $e');
      return AuthResult.error('Network error during token verification');
    }
  }

  // Get current user info (if you have a user profile endpoint)
  static Future<AuthResult<User>> getCurrentUser() async {
    try {
      final url = Uri.parse('$_baseUrl/auth/me');

      final response = await http.get(
        url,
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = User.fromJson(data);
        return AuthResult.success(_currentUser!);
      } else if (response.statusCode == 401) {
        await _clearToken();
        return AuthResult.error('Authentication expired');
      } else {
        return AuthResult.error('Failed to get user info');
      }
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return AuthResult.error('Network error getting user info');
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
