import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:vegan_app/models/shops/shop.dart';
import 'package:vegan_app/models/shops/shop_scan_summary.dart';
import 'package:vegan_app/models/product_of_interest.dart';
import 'package:vegan_app/services/api_service.dart';
import 'package:vegan_app/services/products_of_interest_cache.dart';

class ShopDetailSheet extends StatefulWidget {
  final Shop shop;

  const ShopDetailSheet({super.key, required this.shop});

  @override
  State<ShopDetailSheet> createState() => _ShopDetailSheetState();
}

class _ShopDetailSheetState extends State<ShopDetailSheet> {
  List<ShopScanSummary> _scanSummaries = [];
  Map<String, ProductOfInterest> _productsMap = {};
  bool _isLoading = true;

  String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.321vegan.fr';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ApiService.getShopProducts(shopId: widget.shop.id),
      ProductsOfInterestCache.loadProductsOfInterest(),
    ]);

    final summaries = results[0] as List<ShopScanSummary>;
    final products = results[1] as List<ProductOfInterest>;

    if (mounted) {
      setState(() {
        _scanSummaries = summaries;
        _productsMap = {for (var p in products) p.ean: p};
        _isLoading = false;
      });
    }
  }

  Color _scanFreshnessColor(int days) {
    if (days <= 7) return Colors.green;
    if (days <= 14) return Colors.lightGreen;
    if (days <= 30) return Colors.orange;
    if (days <= 60) return Colors.deepOrange;
    if (days <= 90) return Colors.red;
    return Colors.red.shade900;
  }

  Widget _buildProductRow(ShopScanSummary summary) {
    final product = _productsMap[summary.ean];
    final dateFormat = DateFormat.yMMMd('fr_FR');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 200.w,
              height: 200.w,
              child: product != null && product.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: '$_baseUrl/${product.image}',
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: product?.name ?? summary.ean,
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product?.brandName != null &&
                          product!.brandName.isNotEmpty)
                        TextSpan(
                          text: '  ${product.brandName}',
                          style: TextStyle(
                            fontSize: 36.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Scanné ${summary.scanCount}x · Dernier scan il y a : ',
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      TextSpan(
                        text: '${summary.daysSinceLastScan} jours',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w600,
                          color: _scanFreshnessColor(summary.daysSinceLastScan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            // Shop header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      shop.shopType == 'vegan'
                          ? Icon(
                              Icons.eco,
                              color: Colors.green,
                              size: 64.r,
                            )
                          : Icon(
                              Icons.storefront,
                              color: Theme.of(context).colorScheme.primary,
                              size: 64.r,
                            ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                shop.name,
                                style: TextStyle(
                                  fontSize: 64.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (shop.shopType == 'vegan')
                              Container(
                                margin: EdgeInsets.only(left: 24.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: Colors.green.shade300,
                                  ),
                                ),
                                child: Text(
                                  '100% Vegan',
                                  style: TextStyle(
                                    fontSize: 36.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (shop.address != null || shop.city != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 32.w),
                      child: Text(
                        [shop.address, shop.city]
                            .where((s) => s != null)
                            .join(', '),
                        style: TextStyle(
                          fontSize: 50.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(height: 1.h),
            // Products list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _scanSummaries.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Text(
                              'Aucun produit scanné dans ce magasin',
                              style: TextStyle(
                                fontSize: 50.sp,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: _scanSummaries.length,
                          separatorBuilder: (_, __) => Divider(height: 1.h),
                          itemBuilder: (context, index) =>
                              _buildProductRow(_scanSummaries[index]),
                        ),
            ),
          ],
        );
      },
    );
  }
}
