import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/product_of_interest.dart';
import '../../../models/scanned_product.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class VegandexModal extends StatefulWidget {
  const VegandexModal({super.key});

  @override
  State<VegandexModal> createState() => _VegandexModalState();
}

class _VegandexModalState extends State<VegandexModal> {
  List<ProductOfInterest> _products = [];
  List<ScannedProduct> _scannedProducts = [];
  bool _isLoading = true;
  final baseUrl = dotenv.env['API_BASE_URL'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Fetch interesting products
    final products = await ApiService.getInterestingProducts();

    // Get scanned products from current user
    final user = AuthService.currentUser;
    final scannedProducts = user?.scannedProducts ?? [];

    if (mounted) {
      setState(() {
        _products = products;
        _scannedProducts = scannedProducts;
        _isLoading = false;
      });
    }
  }

  bool _isProductScanned(String ean) {
    return _scannedProducts.any((scanned) => scanned.ean == ean);
  }

  int _getScannedCount() {
    return _products.where((product) => _isProductScanned(product.ean)).length;
  }

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF1A722E),
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
            child: _isLoading
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
                    : GridView.builder(
                        padding: EdgeInsets.all(24.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final isScanned = _isProductScanned(product.ean);
                          return _buildProductCard(product, isScanned);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductOfInterest product, bool isScanned) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isScanned
              ? const Color(0xFF1A722E).withValues(alpha: 0.3)
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
              ),
              child: ColorFiltered(
                colorFilter: isScanned
                    ? const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      )
                    : const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                child: Image.network(
                  '$baseUrl/${product.image}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 80.sp,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isScanned ? Colors.grey.shade100 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w700,
                        color: isScanned
                            ? Colors.grey.shade900
                            : Colors.grey.shade600,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Brand
                    Text(
                      product.brandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w500,
                        color: isScanned
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Scan count
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 40.sp,
                          color: isScanned
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Scanné ${_scannedProducts.where((sp) => sp.ean == product.ean).length} fois',
                          style: TextStyle(
                            fontSize: 40.sp,
                            color: isScanned
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
