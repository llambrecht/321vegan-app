import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/product_of_interest.dart';

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

      // Get the current user's ID if logged in
      final userId = AuthService.currentUser?.id;

      final body = json.encode({
        'ean': ean,
        'status': status,
        if (userId != null) 'user_id': userId,
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
      return false;
    }
  }

  /// Post an error report
  /// [ean] - The product's barcode/EAN
  /// [comment] - User's comment about the error
  /// [contact] - User's contact information (email/phone)
  /// Automatically adds the logged-in user's ID to created_by if available
  static Future<bool> postErrorReport({
    required String ean,
    required String comment,
    required String contact,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/error-reports/');

      // Get the current user's ID if logged in
      final userId = AuthService.currentUser?.id;

      final body = json.encode({
        'ean': ean,
        'comment': comment,
        'contact': contact,
        'handled': false,
        if (userId != null) 'created_by': userId,
      });

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  /// Get all interesting products (products of interest)
  static Future<List<ProductOfInterest>> getInterestingProducts() async {
    try {
      final url = Uri.parse('$_baseUrl/interesting-products');

      final response = await http.get(
        url,
        headers: _headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => ProductOfInterest.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Post a scan event for a product of interest
  /// [ean] - The product's barcode
  /// [latitude] - User's latitude (optional)
  /// [longitude] - User's longitude (optional)
  /// Automatically adds the logged-in user's ID if available
  static Future<bool> postScanEvent({
    required String ean,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/scan-events/');

      // Get the current user's ID if logged in
      final userId = AuthService.currentUser?.id;

      final body = json.encode({
        'ean': ean,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (userId != null) 'user_id': userId,
      });

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}
