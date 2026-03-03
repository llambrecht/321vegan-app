import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import 'api_service.dart';
import 'auth_service.dart';

class SubscriptionService {
  // Tier 0 - Petit soutien
  static const String monthlyId = 'supporter_monthly';
  static const String yearlyId = 'supporter_yearly';

  // Tier 1 - soutien
  static const String tier1MonthlyId = 'supporter_tier1_monthly';
  static const String tier1YearlyId = 'supporter_tier1_yearly';

  // Tier 2 - Grand soutien
  static const String tier2MonthlyId = 'supporter_tier2_monthly';
  static const String tier2YearlyId = 'supporter_tier2_yearly';

  static const Set<String> _productIds = {
    monthlyId,
    yearlyId,
    tier1MonthlyId,
    tier1YearlyId,
    tier2MonthlyId,
    tier2YearlyId,
  };

  static const String _statusKey = 'subscription_status';
  static const String _expiresAtKey = 'subscription_expires_at';
  static const String _productIdKey = 'subscription_product_id';

  static StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  static List<ProductDetails> _products = [];
  static bool _isAvailable = false;
  static Subscription? _currentSubscription;

  /// Callback for UI to react to purchase state changes
  static VoidCallback? onSubscriptionChanged;

  /// Initialize the service and start listening to purchase updates
  static Future<void> init() async {
    _isAvailable = await InAppPurchase.instance.isAvailable();
    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      return;
    }

    // Listen to purchase updates
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    // Load cached subscription status
    await _loadCachedStatus();

    // Query available products
    await queryProducts();

    // If logged in, check subscription status from backend
    if (AuthService.isLoggedIn) {
      await checkSubscriptionStatus();
    }
  }

  /// Whether the store is available
  static bool get isAvailable => _isAvailable;

  /// Available products from the store
  static List<ProductDetails> get products => _products;

  /// Current subscription from backend
  static Subscription? get currentSubscription => _currentSubscription;

  /// Whether the user has an active subscription
  static bool get isSubscribed {
    // First check backend subscription
    if (_currentSubscription != null && _currentSubscription!.isActive) {
      return true;
    }
    // Fallback to cached status
    return _getCachedIsSubscribed();
  }

  /// Query available products from the store
  static Future<void> queryProducts() async {
    if (!_isAvailable) return;

    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);

    if (response.error != null) {
      debugPrint('Error querying products: ${response.error}');
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs.join(', ')}');
    }

    _products = response.productDetails;
  }

  /// Get a product by its ID
  static ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Get the display name for a product ID
  static String getProductDisplayName(String productId) {
    if (productId.contains('tier3')) return 'Grand soutien';
    if (productId.contains('tier2')) return 'Soutien';
    if (productId.contains('tier1')) return 'Petit soutien';
    // Legacy
    if (productId.contains('yearly')) return 'Annuel';
    if (productId.contains('monthly')) return 'Mensuel';
    return 'Soutien';
  }

  /// Initiate a purchase
  static Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) return false;

    final purchaseParam = PurchaseParam(productDetails: product);
    return InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore previous purchases
  static Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await InAppPurchase.instance.restorePurchases();
  }

  /// Check subscription status from backend
  static Future<Subscription?> checkSubscriptionStatus() async {
    if (!AuthService.isLoggedIn) return null;

    try {
      final subscription = await ApiService.getSubscriptionStatus();
      if (subscription != null) {
        _currentSubscription = subscription;
        await _cacheStatus(_currentSubscription!);
        onSubscriptionChanged?.call();
        return _currentSubscription;
      } else {
        // No subscription found
        _currentSubscription = null;
        await _clearCachedStatus();
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    }
    return null;
  }

  /// Handle purchase updates from the store
  static Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliverPurchase(purchase);
          break;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.pending:
          debugPrint('Purchase pending...');
          break;
        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled');
          break;
      }

      // Complete the purchase if pending
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase with backend and deliver content
  static Future<void> _verifyAndDeliverPurchase(
      PurchaseDetails purchase) async {
    if (!AuthService.isLoggedIn) {
      debugPrint('User not logged in, cannot verify purchase');
      return;
    }

    try {
      final String platform = Platform.isIOS ? 'apple' : 'google';

      final subscription = await ApiService.verifySubscription(
        platform: platform,
        productId: purchase.productID,
        transactionId: Platform.isIOS ? purchase.purchaseID : null,
        purchaseToken: Platform.isIOS
            ? null
            : purchase.verificationData.serverVerificationData,
      );

      if (subscription != null) {
        _currentSubscription = subscription;
        await _cacheStatus(_currentSubscription!);
        onSubscriptionChanged?.call();
        debugPrint('Purchase verified successfully');
      }
    } catch (e) {
      debugPrint('Error verifying purchase: $e');
    }
  }

  /// Cache subscription status locally
  static Future<void> _cacheStatus(Subscription subscription) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, subscription.status.name);
    await prefs.setString(_productIdKey, subscription.productId);
    if (subscription.expiresAt != null) {
      await prefs.setString(
          _expiresAtKey, subscription.expiresAt!.toIso8601String());
    }
  }

  /// Load cached subscription status
  static Future<void> _loadCachedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString(_statusKey);
    if (status == null) return;

    // Just use cached values for quick isSubscribed check
    // Full subscription object will be loaded from backend
  }

  /// Check cached subscription status
  static bool _getCachedIsSubscribed() {
    // Synchronous check from SharedPreferences is not possible,
    // so we rely on _currentSubscription being loaded at init
    return false;
  }

  /// Clear cached status
  static Future<void> _clearCachedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statusKey);
    await prefs.remove(_expiresAtKey);
    await prefs.remove(_productIdKey);
  }

  /// Dispose the service
  static void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}
