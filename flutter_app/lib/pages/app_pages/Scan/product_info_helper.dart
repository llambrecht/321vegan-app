import 'package:vegan_app/helpers/database_helper.dart';
import 'package:vegan_app/helpers/preference_helper.dart';

class ProductInfoHelper {
  static Future<Map<String, dynamic>> getProductInfo(String barcode) async {
    // Query the database
    final dbResult = await DatabaseHelper.instance.queryProduct(barcode);

    if (dbResult.isNotEmpty &&
        dbResult.first['status'] != 'R' &&
        dbResult.first['status'] != 'N' &&
        dbResult.first['status'] != 'M') {
      // If data is found in the database
      final product = dbResult.first;
      return {
        'code': product['code'],
        'name':
            (product['name'] ?? 'Produit inconnu').replaceAll('&quot;', "'"),
        'brand':
            (product['brand'] ?? 'Marque inconnue').replaceAll('&quot;', "'"),
        'is_vegan': 'true',
        'problem': product['problem'], // Add problem field
        'biodynamie':
            (product['biodynamie'] != null && product['biodynamie'] == 'Y')
                ? true
                : false,
      };
    } else if (dbResult.isNotEmpty && dbResult.first['status'] == 'R') {
      // If data is found in the database but is rejected
      final product = dbResult.first;
      return {
        'code': barcode,
        'name': product['name'] ?? 'Produit inconnu',
        'brand': product['brand'] ?? 'Marque inconnue',
        'is_vegan': 'false',
        'problem': product['problem'], // Add problem field
        'biodynamie':
            (product['biodynamie'] != null && product['biodynamie'] == 'Y')
                ? true
                : false,
      };
    } else if (dbResult.isNotEmpty && dbResult.first['status'] == 'M') {
      // If data is found in the database but is pending
      final product = dbResult.first;
      return {
        'code': barcode,
        'name': product['name'] ?? 'Produit inconnu',
        'brand': product['brand'] ?? 'Marque inconnue',
        'is_vegan': 'waiting',
        'problem': product['problem'], // Add problem field
        'biodynamie': false,
      };
    } else if (dbResult.isNotEmpty && dbResult.first['status'] == 'N') {
      // If data is found in the database but is not found
      final product = dbResult.first;
      return {
        'code': barcode,
        'name': product['name'] ?? 'Produit inconnu',
        'brand': product['brand'] ?? 'Marque inconnue',
        'is_vegan': 'not_found',
        'problem': product['problem'], // Add problem field
        'biodynamie': false,
      };
    } else if (dbResult.isEmpty) {
      // Check in the user's preference if he scanned this product before
      final isAlreadyScanned =
          await PreferencesHelper.isCodeInPreferences(barcode);
      if (isAlreadyScanned) {
        return {
          'code': barcode,
          'name': 'Produit inconnu',
          'brand': 'Marque inconnue',
          'is_vegan': 'already_scanned',
          'problem': null, // No problem for already scanned products
          'biodynamie': false,
        };
      } else {
        return {
          'code': barcode,
          'name': barcode,
          'brand': 'inconnue',
          'is_vegan': 'unknown',
          'problem': null, // No problem for unknown products
          'biodynamie': false,
        };
      }
    } else {
      return {
        'code': barcode,
        'name': barcode,
        'brand': 'inconnue',
        'is_vegan': 'unknown',
        'problem': null, // No problem for fallback case
        'biodynamie': false,
      };
    }
  }
}
