import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// HTTP client with automatic cookie management for HTTPOnly cookies
/// Used for authentication with refresh tokens stored in cookies
class DioClient {
  static Dio? _dio;
  static PersistCookieJar? _cookieJar;

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
