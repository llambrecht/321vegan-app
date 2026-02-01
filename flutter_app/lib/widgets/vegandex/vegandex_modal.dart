import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/product_of_interest.dart';
import '../../../models/scanned_product.dart';
import '../../../models/product_category.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import 'category_list_view.dart';
import 'category_products_view.dart';

class VegandexModal extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const VegandexModal({super.key, this.onNavigateToProfile});

  @override
  State<VegandexModal> createState() => _VegandexModalState();
}

class _VegandexModalState extends State<VegandexModal> {
  List<ProductOfInterest> _products = [];
  List<ProductCategory> _categories = [];
  Map<String, ScannedProduct> _scannedProducts = {};
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  ProductCategory? _selectedCategory;
  final baseUrl = dotenv.env['API_BASE_URL'];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadData();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (mounted) {
      setState(() {
        _hasLocationPermission = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // If denied forever, open app settings
      if (permission == LocationPermission.deniedForever) {
        await openAppSettings();
      }
    }

    // Re-check permission after request
    await _checkLocationPermission();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Fetch interesting products and categories in parallel
    final results = await Future.wait([
      ApiService.getInterestingProducts(),
      ApiService.getProductCategories(),
    ]);

    final products = results[0] as List<ProductOfInterest>;
    final categories = results[1] as List<ProductCategory>;

    // Get scanned products from current user and build a map
    final user = AuthService.currentUser;
    final scannedProductsList = user?.scannedProducts ?? [];
    final scannedProductsMap = {
      for (var sp in scannedProductsList) sp.ean: sp,
    };

    if (mounted) {
      setState(() {
        _products = products;
        _categories = categories;
        _scannedProducts = scannedProductsMap;
        _isLoading = false;
      });
    }
  }

  bool _isProductScanned(String ean) {
    return _scannedProducts.containsKey(ean);
  }

  int _getScannedCount() {
    return _products.where((product) => _isProductScanned(product.ean)).length;
  }

  void _onCategorySelected(ProductCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onBackToCategories() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void _navigateToProfile() {
    // Close the modal first
    Navigator.pop(context);

    // Use the callback if provided, otherwise show a snackbar message
    if (widget.onNavigateToProfile != null) {
      widget.onNavigateToProfile!();
    } else {
      // Fallback: show a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez aller dans l\'onglet Profil pour vous connecter.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthService.isLoggedIn;
    final bool showContent = isLoggedIn && _hasLocationPermission;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28.r),
                topRight: Radius.circular(28.r),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 100.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Icon(
                      Icons.catching_pokemon,
                      size: 80.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Vegandex',
                                style: TextStyle(
                                  fontSize: 64.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'BETA',
                                  style: TextStyle(
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Scannez les produits pour les ajouter à votre collection. Trouvez-les tous !',
                            style: TextStyle(
                              fontSize: 40.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        size: 80.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Progress
                if (showContent)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 60.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${_getScannedCount()} / ${_products.length}',
                          style: TextStyle(
                            fontSize: 52.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'produits trouvés',
                          style: TextStyle(
                            fontSize: 40.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Products grid
          Expanded(
            child: !isLoggedIn
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 200.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'Connexion requise',
                            style: TextStyle(
                              fontSize: 64.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Pour participer au Vegandex et collectionner des produits, vous devez vous connecter ou créer un compte.',
                            style: TextStyle(
                              fontSize: 48.sp,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 48.h),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: ElevatedButton(
                                onPressed: _navigateToProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A722E),
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.login,
                                        color: Colors.white, size: 24),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Se connecter / S\'inscrire',
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Icon(
                            Icons.catching_pokemon,
                            size: 160.sp,
                            color:
                                const Color(0xFF1A722E).withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  )
                : !_hasLocationPermission
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(48.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 200.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 32.h),
                              Text(
                                'Géolocalisation requise',
                                style: TextStyle(
                                  fontSize: 64.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'La fonctionnalité Vegandex nécessite l\'accès à votre position pour ajouter des produits à votre collection. Ces données géographiques nous permettront d\'aider les utilisateurices à trouver ces produits ! Veuillez activer la géolocalisation.',
                                style: TextStyle(
                                  fontSize: 48.sp,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 48.h),
                              SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  child: ElevatedButton(
                                    onPressed: _requestLocationPermission,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A722E),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: Colors.white, size: 24),
                                        SizedBox(width: 12.w),
                                        Text(
                                          'Activer la géolocalisation',
                                          style: TextStyle(
                                            fontSize: 40.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Icon(
                                Icons.catching_pokemon,
                                size: 160.sp,
                                color: const Color(0xFF1A722E)
                                    .withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _products.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 120.sp,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'Aucun produit disponible',
                                      style: TextStyle(
                                        fontSize: 48.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _selectedCategory == null
                                ? CategoryListView(
                                    categories: _categories,
                                    products: _products,
                                    scannedProducts: _scannedProducts,
                                    onCategoryTap: _onCategorySelected,
                                  )
                                : CategoryProductsView(
                                    category: _selectedCategory!,
                                    allProducts: _products,
                                    scannedProducts: _scannedProducts,
                                    onBack: _onBackToCategories,
                                  ),
          ),
        ],
      ),
    );
  }
}
