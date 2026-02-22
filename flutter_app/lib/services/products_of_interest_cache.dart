import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_of_interest.dart';
import 'api_service.dart';

/// Manages caching of products of interest to ensure they're available even offline
class ProductsOfInterestCache {
  static const String _cacheKey = 'products_of_interest_cache';
  static const String _lastUpdateKey = 'products_of_interest_last_update';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Initialize cache at app startup as the user is most likely to have correct internet connexion
  /// Returns immediately (non-blocking) but triggers background update if needed
  static void initializeAtStartup() {
    // Don't await - let it run in background without blocking app startup
    Future(() async {
      try {
        final shouldRefresh = await shouldUpdate();
        if (shouldRefresh) {
          // Update cache in background with timeout
          await ApiService.getInterestingProducts()
              .timeout(const Duration(seconds: 10))
              .then((products) {
            if (products.isNotEmpty) {
              _saveToCache(products);
            }
          }).catchError((e) {
            // Silently fail - cache will be updated next time
            print('Startup cache update failed (expected if offline): $e');
          });
        }
      } catch (e) {
        print('Cache initialization error: $e');
      }
    });
  }

  /// Load products of interest from cache immediately, then update in background
  /// This ensures instant loading even with poor/no internet
  static Future<List<ProductOfInterest>> loadProductsOfInterest() async {
    try {
      // First, load from cache (instant)
      final cachedProducts = await _loadFromCache();

      // Then, check if we should update (only if cache is old or empty)
      final shouldRefresh = await shouldUpdate();
      if (shouldRefresh) {
        // Update from API in background with timeout
        // This won't block the UI
        _updateFromApiInBackground();
      }

      return cachedProducts;
    } catch (e) {
      print('Failed to load products of interest: $e');
      return [];
    }
  }

  /// Load products from local cache
  static Future<List<ProductOfInterest>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);

      if (cachedData == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(cachedData);
      return jsonList.map((json) => ProductOfInterest.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load from cache: $e');
      return [];
    }
  }

  /// Update cache from API in background
  static void _updateFromApiInBackground() {
    // Run in background without waiting
    Future(() async {
      try {
        // Add timeout to prevent slow network from blocking
        final products = await ApiService.getInterestingProducts()
            .timeout(const Duration(seconds: 10));

        if (products.isNotEmpty) {
          await _saveToCache(products);
        }
      } catch (e) {
        // Silently fail - we already have cached data
        print('Background update failed (expected if offline): $e');
      }
    });
  }

  /// Force update from API (useful for manual refresh)
  static Future<List<ProductOfInterest>> forceUpdate() async {
    try {
      final products = await ApiService.getInterestingProducts()
          .timeout(const Duration(seconds: 10));

      if (products.isNotEmpty) {
        await _saveToCache(products);
      }

      return products;
    } catch (e) {
      print('Force update failed: $e');
      // Return cached data as fallback
      return await _loadFromCache();
    }
  }

  /// Save products to cache
  static Future<void> _saveToCache(List<ProductOfInterest> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert to JSON and save
      final jsonList = products.map((p) => p.toJson()).toList();
      final String jsonString = json.encode(jsonList);

      await prefs.setString(_cacheKey, jsonString);
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Failed to save to cache: $e');
    }
  }

  /// Check if cache needs update (older than 24 hours)
  static Future<bool> shouldUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? lastUpdate = prefs.getInt(_lastUpdateKey);

      if (lastUpdate == null) {
        return true;
      }

      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();

      return now.difference(lastUpdateTime) > _cacheExpiry;
    } catch (e) {
      return true;
    }
  }

  /// Clear cache (useful for testing or logout)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }
}
