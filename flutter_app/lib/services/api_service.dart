import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.321vegan.fr';
  static String get _apiKey => dotenv.env['API_KEY'] ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
      };

  /// Post a product with its vegan status
  /// [ean] - The product's barcode
  /// [status] - One of: "VEGAN", "NON_VEGAN", "MAYBE_VEGAN"
  static Future<bool> postProduct({
    required String ean,
    required String status,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/products/');
      final body = json.encode({
        'ean': ean,
        'status': status,
      });

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      // 409 means product already exists, which is fine for the user
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          response.statusCode == 409;
    } catch (e) {
      debugPrint('Error posting product: $e');
      return false;
    }
  }

  /// Post an error report
  /// [ean] - The product's barcode/EAN
  /// [comment] - User's comment about the error
  /// [contact] - User's contact information (email/phone)
  static Future<bool> postErrorReport({
    required String ean,
    required String comment,
    required String contact,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/error-reports/');
      final body = json.encode({
        'ean': ean,
        'comment': comment,
        'contact': contact,
        'handled': false,
      });

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Error posting error report: $e');
      return false;
    }
  }
}
