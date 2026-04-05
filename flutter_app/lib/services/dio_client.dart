import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

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
        if (error.response?.statusCode == 401 &&
            error.type != DioExceptionType.connectionTimeout &&
            error.type != DioExceptionType.sendTimeout &&
            error.type != DioExceptionType.receiveTimeout &&
            error.type != DioExceptionType.connectionError &&
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
            // Attempt to refresh the token (with dedicated timeout)
            final response = await _dio!.post(
              '/auth/refresh',
              options: Options(
                sendTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

            if (response.statusCode == 200 &&
                response.data['access_token'] != null) {
              final newAccessToken = response.data['access_token'];
              debugPrint('✅ Token refreshed successfully');

              // Sync token to AuthService in-memory cache + SharedPreferences
              await AuthService.updateTokenFromInterceptor(newAccessToken);

              // Update the original request with new token
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              // Retry the original request
              final retryResponse = await _dio!.fetch(error.requestOptions);

              // Process all queued requests with the new token
              final queued = List.of(_requestsWaitingForRefresh);
              _requestsWaitingForRefresh.clear();
              _isRefreshing = false;

              for (var q in queued) {
                q.options.headers['Authorization'] =
                    'Bearer $newAccessToken';
                try {
                  final queuedResponse = await _dio!.fetch(q.options);
                  q.handler.resolve(queuedResponse);
                } catch (e) {
                  q.handler.reject(
                      DioException(requestOptions: q.options, error: e));
                }
              }

              return handler.resolve(retryResponse);
            } else {
              throw Exception('Token refresh failed');
            }
          } catch (refreshError) {
            debugPrint('❌ Token refresh failed: $refreshError');

            // Always reset flag and drain queue before returning
            _isRefreshing = false;
            final queued = List.of(_requestsWaitingForRefresh);
            _requestsWaitingForRefresh.clear();

            // Only clear tokens on actual authentication errors (401)
            // Keep user logged in on network errors (API down, timeout, etc.)
            bool shouldLogout = false;
            if (refreshError is DioException) {
              // Only logout on 401 - authentication actually expired
              if (refreshError.response?.statusCode == 401) {
                shouldLogout = true;
                debugPrint('🔒 Authentication expired - logging out');
              } else if (refreshError.type ==
                      DioExceptionType.connectionTimeout ||
                  refreshError.type == DioExceptionType.sendTimeout ||
                  refreshError.type == DioExceptionType.receiveTimeout ||
                  refreshError.type == DioExceptionType.connectionError ||
                  refreshError.type == DioExceptionType.unknown) {
                debugPrint(
                    '⚠️ Network/timeout error during token refresh - keeping user logged in');
              } else {
                debugPrint(
                    '⚠️ Server error during token refresh - keeping user logged in');
              }
            } else {
              debugPrint(
                  '⚠️ Unexpected error during token refresh - keeping user logged in');
            }

            if (shouldLogout) {
              // Sync logout to AuthService in-memory cache + SharedPreferences
              await AuthService.clearTokenFromInterceptor();
              await clearCookies();
            }

            // Reject all queued requests
            for (var q in queued) {
              q.handler.reject(DioException(
                requestOptions: q.options,
                error: shouldLogout
                    ? 'Authentication expired'
                    : 'Network error - please try again',
                type: shouldLogout
                    ? DioExceptionType.badResponse
                    : DioExceptionType.connectionError,
              ));
            }

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
