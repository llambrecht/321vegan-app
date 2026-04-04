import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vegan_app/models/product_scores.dart';

class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0/product';
  static const Duration _timeout = Duration(seconds: 8);

  /// Fetches nutriscore and ecoscore for [barcode] from OpenFoodFacts.
  /// Returns a [ProductScores] with null grades when the product is not found
  /// or the scores are not available.
  static Future<ProductScores> fetchScores(String barcode) async {
    try {
      final uri = Uri.parse('$_baseUrl/$barcode.json');
      final response = await http.get(
        uri,
        headers: {'User-Agent': '321Vegan - Flutter App'},
      ).timeout(_timeout);

      if (response.statusCode != 200) return const ProductScores();

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'];

      // Product not found on OpenFoodFacts
      if (status == 0) return const ProductScores();

      return ProductScores.fromOpenFoodFacts(json);
    } catch (e) {
      debugPrint('OpenFoodFacts fetch error for $barcode: $e');
      return const ProductScores();
    }
  }
}
