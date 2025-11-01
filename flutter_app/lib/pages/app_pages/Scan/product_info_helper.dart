import 'package:vegan_app/helpers/database_helper.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:sqflite/sqflite.dart';

class ProductInfoHelper {
  // Get brand name from brand id
  static Future<String?> _getBrandNameFromId(Database db, int brandId) async {
    try {
      // Get the brand and build the full hierarchy
      List<String> brandHierarchy = [];
      int? currentBrandId = brandId;

      // Prevent infinite loops by tracking visited brands
      Set<int> visitedBrands = {};

      while (
          currentBrandId != null && !visitedBrands.contains(currentBrandId)) {
        visitedBrands.add(currentBrandId);

        final brandResult = await db.query(
          'brands',
          where: 'id = ?',
          whereArgs: [currentBrandId],
        );

        if (brandResult.isEmpty) break;

        final brand = brandResult.first;
        final brandName = brand['name'] as String?;

        if (brandName != null && brandName.isNotEmpty) {
          brandHierarchy.insert(
              0, brandName); // Insert at beginning to maintain hierarchy order
        }

        // Move to parent brand
        currentBrandId = brand['parent_id'] as int?;
      }

      // Reverse the list
      brandHierarchy = brandHierarchy.reversed.toList();
      return brandHierarchy.isNotEmpty ? brandHierarchy.join(', ') : null;
    } catch (e) {
      return null;
    }
  }

  // Resolve brand name from product data
  static Future<String> _resolveBrandName(Map<String, dynamic> product) async {
    String? brandName;

    // If brand_id exists, fetch the brand name from the brands table
    if (product['brand_id'] != null) {
      brandName = await _getBrandNameFromId(
          await DatabaseHelper.instance.database, product['brand_id']);
    }

    // Fallback to brand field if no brand_id or brand_id didn't resolve
    if (brandName == null || brandName.isEmpty) {
      brandName = (product['brand'] as String?)?.replaceAll('&quot;', "'");
    }

    // Default if no brand information found
    return brandName ?? 'Marque inconnue';
  }

  static Future<Map<String, dynamic>> getProductInfo(String barcode) async {
    // Default product info for unknown products
    Map<String, dynamic> defaultProductInfo = {
      'code': barcode,
      'name': barcode,
      'brand': 'inconnue',
      'is_vegan': 'unknown',
      'has_non_vegan_old_receipe': false,
      'problem': null,
      'biodynamie': false,
    };

    // Query the database
    final dbResult = await DatabaseHelper.instance.queryProduct(barcode);

    // If no product is found in database
    if (dbResult.isEmpty) {
      // Check if user scanned this product before
      final isAlreadyScanned =
          await PreferencesHelper.isCodeInPreferences(barcode);
      if (isAlreadyScanned) {
        return {
          'code': barcode,
          'name': 'Produit inconnu',
          'brand': 'Marque inconnue',
          'is_vegan': 'already_scanned',
          'has_non_vegan_old_receipe': false,
          'problem': null,
          'biodynamie': false,
        };
      }
      return defaultProductInfo;
    }

    // Product found in database
    final product = dbResult.first;
    final status = product['status'] as String?;

    // Format product name and handle HTML entities
    String productName = ((product['name'] as String?) ?? 'Produit inconnu')
        .replaceAll('&quot;', "'");

    // Handle brand name
    String brandName = await _resolveBrandName(product);

    // Convert biodynamie field to boolean
    bool isBiodynamie = product['biodynamie'] == 'Y';

    // Determine vegan status based on product status
    String veganStatus;
    switch (status) {
      case 'R':
        veganStatus = 'false'; // Rejected
        break;
      case 'M':
        veganStatus = 'waiting'; // Pending
        break;
      case 'N':
        veganStatus = 'not_found'; // Not found
        break;
      default:
        veganStatus = 'true'; // Approved
    }

    // Return the product information
    return {
      'code': product['code'] ?? barcode,
      'name': productName,
      'brand': brandName,
      'is_vegan': veganStatus,
      'has_non_vegan_old_receipe': product['has_non_vegan_old_receipe'] == 1,
      'problem': product['problem'],
      'biodynamie': status != 'M' && status != 'N' ? isBiodynamie : false,
    };
  }
}
