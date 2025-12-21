import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP client with automatic cookie management for HTTPOnly cookies
/// Used for authentication with refresh tokens stored in cookies
class DioClient {
  static Dio? _dio;
  static PersistCookieJar? _cookieJar;
  static bool _isRefreshing = false;
  static final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _requestsWaitingForRefresh = [];

  /// Get configured Dio instance with cookie support
  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    // Create persistent cookie jar
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    _cookieJar = PersistCookieJar(
      storage: FileStorage('$appDocPath/.cookies/'),
    );

    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.321vegan.fr';

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add cookie manager interceptor - handles HTTPOnly cookies automatically
    _dio!.interceptors.add(CookieManager(_cookieJar!));

    // Add auth interceptor for automatic token refresh
    _dio!.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        // Check if this is a 401 error and not already a refresh attempt
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('/auth/refresh') &&
            !error.requestOptions.path.contains('/auth/login')) {
          debugPrint('🔄 401 error detected, attempting token refresh...');

          // If already refreshing, queue this request
          if (_isRefreshing) {
            debugPrint('⏳ Token refresh in progress, queueing request...');
            _requestsWaitingForRefresh
                .add((options: error.requestOptions, handler: handler));
            return;
          }

          _isRefreshing = true;

          try {
            // Attempt to refresh the token
            final response = await _dio!.post('/auth/refresh');

            if (response.statusCode == 200 &&
                response.data['access_token'] != null) {
              final newAccessToken = response.data['access_token'];
              debugPrint('✅ Token refreshed successfully');

              // Store the new token with expiration
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('access_token', newAccessToken);

              // Store expiration time (default 30 minutes)
              final expiresIn = response.data['expires_in'] ?? 1800;
              final expiresAt =
                  DateTime.now().add(Duration(seconds: expiresIn));
              await prefs.setString(
                  'token_expires_at', expiresAt.toIso8601String());

              // Update the original request with new token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              // Retry the original request
              final retryResponse = await _dio!.fetch(error.requestOptions);

              // Process all queued requests with the new token
              for (var queued in _requestsWaitingForRefresh) {
                queued.options.headers['Authorization'] =
                    'Bearer $newAccessToken';
                try {
                  final queuedResponse = await _dio!.fetch(queued.options);
                  queued.handler.resolve(queuedResponse);
                } catch (e) {
                  queued.handler.reject(
                      DioException(requestOptions: queued.options, error: e));
                }
              }
              _requestsWaitingForRefresh.clear();
              _isRefreshing = false;

              return handler.resolve(retryResponse);
            } else {
              throw Exception('Token refresh failed');
            }
          } catch (refreshError) {
            debugPrint('❌ Token refresh failed: $refreshError');
            _isRefreshing = false;

            // Only clear tokens on actual authentication errors (401)
            // Keep user logged in on network errors (API down, timeout, etc.)
            bool shouldLogout = false;
            if (refreshError is DioException) {
              // Only logout on 401 - authentication actually expired
              if (refreshError.response?.statusCode == 401) {
                shouldLogout = true;
                debugPrint('🔒 Authentication expired - logging out');
              } else {
                // Network error, server down, timeout, etc.
                debugPrint(
                    '⚠️ Temporary error during token refresh - keeping user logged in');
              }
            } else {
              // Non-Dio exceptions are likely network issues
              debugPrint(
                  '⚠️ Network error during token refresh - keeping user logged in');
            }

            if (shouldLogout) {
              // Clear stored tokens and cookies only on auth failure
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');
              await clearCookies();
            }

            // Reject all queued requests
            for (var queued in _requestsWaitingForRefresh) {
              queued.handler.reject(DioException(
                requestOptions: queued.options,
                error: shouldLogout
                    ? 'Authentication expired'
                    : 'Network error - please try again',
                type: shouldLogout
                    ? DioExceptionType.badResponse
                    : DioExceptionType.connectionError,
              ));
            }
            _requestsWaitingForRefresh.clear();

            return handler.reject(error);
          }
        }

        return handler.next(error);
      },
    ));

    if (kDebugMode) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    return _dio!;
  }

  // Clear all stored cookies (use on logout)
  static Future<void> clearCookies() async {
    if (_cookieJar != null) {
      await _cookieJar!.deleteAll();
      debugPrint('🗑️ All cookies cleared');
    }
  }

  // Get the cookie jar instance
  static PersistCookieJar? get cookieJar => _cookieJar;
}
