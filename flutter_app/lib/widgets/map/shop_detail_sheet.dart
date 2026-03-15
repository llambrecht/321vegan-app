import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vegan_app/models/shops/shop.dart';
import 'package:vegan_app/models/shops/shop_scan_summary.dart';
import 'package:vegan_app/models/product_of_interest.dart';
import 'package:vegan_app/services/api_service.dart';
import 'package:vegan_app/services/products_of_interest_cache.dart';
import 'package:vegan_app/widgets/map/brand_banner.dart';

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
  bool _unscannedExpanded = false;
  final Set<String> _notFoundEans = {};
  final Set<String> _thankedEans = {};
  String? _detailExpandedEan;

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

  Map<String, List<ShopScanSummary>> _groupByCategory() {
    final grouped = <String, List<ShopScanSummary>>{};
    for (final summary in _scanSummaries) {
      final product = _productsMap[summary.ean];
      final category = product?.categoryName.isNotEmpty == true
          ? product!.categoryName
          : 'Autre';
      grouped.putIfAbsent(category, () => []).add(summary);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  List<ProductOfInterest> _getUnscannedProducts() {
    final scannedEans = _scanSummaries.map((s) => s.ean).toSet();
    return _productsMap.values
        .where((p) => !scannedEans.contains(p.ean))
        .toList()
      ..sort((a, b) => a.categoryName.compareTo(b.categoryName));
  }

  List<ProductOfInterest> _getLaVieProducts() {
    final scannedEans = _scanSummaries.map((s) => s.ean).toSet();
    return _productsMap.values
        .where((p) =>
            scannedEans.contains(p.ean) &&
            p.brandName.toLowerCase().contains('la vie'))
        .toList();
  }

  /// Compute a findability score between 0.0 and 1.0.
  /// Based on: days since last scan, scan count, and not-found reports.
  ///
  /// Only not-found events that occurred AFTER the last scan are relevant:
  /// a scan after a "not found" proves the product was restocked.
  /// TODO: pass real notFoundDates from backend
  double _findabilityScore(ShopScanSummary summary,
      {List<DateTime> notFoundDates = const []}) {
    // Freshness: 1.0 if scanned today, decays over 90 days
    final freshness = (1.0 - (summary.daysSinceLastScan / 90)).clamp(0.0, 1.0);

    // Frequency: more scans = more confidence, caps at 10
    final frequency = (summary.scanCount / 10).clamp(0.0, 1.0);

    // Only count "not found" reports that happened after the last scan
    final lastScanDate =
        DateTime.now().subtract(Duration(days: summary.daysSinceLastScan));
    final relevantNotFound =
        notFoundDates.where((d) => d.isAfter(lastScanDate)).toList();

    // Penalty: each recent "not found" reduces score, more recent = heavier
    double notFoundPenalty = 0.0;
    for (final date in relevantNotFound) {
      final daysAgo = DateTime.now().difference(date).inDays;
      // Recent reports (< 7 days) penalize 0.2, older ones fade out over 30 days
      notFoundPenalty += 0.2 * (1.0 - (daysAgo / 30).clamp(0.0, 1.0));
    }

    return ((freshness * 0.6) + (frequency * 0.4) - notFoundPenalty)
        .clamp(0.0, 1.0);
  }

  Color _scoreColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildGroupedList(ScrollController scrollController) {
    final grouped = _groupByCategory();
    final unscanned = _getUnscannedProducts();
    final laVieProducts = _getLaVieProducts();

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      children: [
        // La Vie brand banner
        BrandBanner(
          products: laVieProducts,
          brandName: 'La Vie',
          color: Colors.pink.shade400,
          gradientEnd: Colors.deepPurple.shade400,
          logo: Image.asset(
            'lib/assets/la-vie-logo.png',
            width: 150.r,
            height: 150.r,
            fit: BoxFit.contain,
          ),
        ),
        // Scanned products grouped by category
        if (grouped.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Text(
              'Aucun produit scanné dans ce magasin',
              style: TextStyle(
                fontSize: 50.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final entry in grouped.entries) ...[
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            for (final s in entry.value) ...[
              _buildProductRow(s),
            ],
          ],
        // Unscanned products collapsible section
        if (unscanned.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Divider(height: 1.h),
          GestureDetector(
            onTap: () =>
                setState(() => _unscannedExpanded = !_unscannedExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    _unscannedExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Pas présent ou pas encore scanné (${unscanned.length})',
                    style: TextStyle(
                      fontSize: 46.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_unscannedExpanded) _buildUnscannedGrid(unscanned),
        ],
      ],
    );
  }

  Widget _buildUnscannedGrid(List<ProductOfInterest> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: product.image.isNotEmpty
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
            Text(
              product.name,
              style: TextStyle(
                fontSize: 34.sp,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildScorePill(ShopScanSummary summary) {
    final score = _findabilityScore(summary);
    final color = _scoreColor(score);
    final percent = (score * 100).round();
    final isExpanded = _detailExpandedEan == summary.ean;

    return Row(
      children: [
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'probabilité de présence estimée',
          style: TextStyle(
            fontSize: 42.sp,
            color: Colors.grey[500],
          ),
        ),
        Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          size: 44.r,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  Widget _buildScoreDetails(
      ShopScanSummary summary, bool isNotFound, bool isThanked) {
    // TODO: pass real notFoundDates from backend
    final List<DateTime> notFoundDates = [];

    // Only count reports after the last scan
    final lastScanDate =
        DateTime.now().subtract(Duration(days: summary.daysSinceLastScan));
    final relevantCount =
        notFoundDates.where((d) => d.isAfter(lastScanDate)).length;

    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailLine(
            Icons.schedule,
            'Dernier scan il y a ${summary.daysSinceLastScan} jours',
          ),
          _buildDetailLine(
            Icons.bar_chart,
            'Scanné ${summary.scanCount} fois',
          ),
          _buildDetailLine(
            Icons.search_off,
            relevantCount > 0
                ? '$relevantCount signalement(s) depuis le dernier scan'
                : 'Aucun signalement d\'absence depuis le dernier scan',
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: [
              _ActionChip(
                icon: Icons.search_off,
                label: 'Pas trouvé',
                isActive: isNotFound,
                activeColor: Colors.orange,
                onTap: () {
                  setState(() {
                    if (isNotFound) {
                      _notFoundEans.remove(summary.ean);
                    } else {
                      _notFoundEans.add(summary.ean);
                    }
                  });
                  // TODO: send to backend
                },
              ),
              SizedBox(width: 12.w),
              _ActionChip(
                icon: Icons.favorite_outline,
                label: 'Merci',
                isActive: isThanked,
                activeColor: Colors.pink,
                onTap: () {
                  setState(() {
                    if (isThanked) {
                      _thankedEans.remove(summary.ean);
                    } else {
                      _thankedEans.add(summary.ean);
                    }
                  });
                  // TODO: send to backend
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailLine(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(icon, size: 42.r, color: Colors.grey[500]),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 38.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(ShopScanSummary summary) {
    final product = _productsMap[summary.ean];
    final isNotFound = _notFoundEans.contains(summary.ean);
    final isThanked = _thankedEans.contains(summary.ean);

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
                          fontSize: 52.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (product?.brandName != null &&
                          product!.brandName.isNotEmpty)
                        TextSpan(
                          text: '  ${product.brandName}',
                          style: TextStyle(
                            fontSize: 40.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _detailExpandedEan = _detailExpandedEan == summary.ean
                          ? null
                          : summary.ean;
                    });
                  },
                  child: _buildScorePill(summary),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild:
                      _buildScoreDetails(summary, isNotFound, isThanked),
                  crossFadeState: _detailExpandedEan == summary.ean
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
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
                  : _buildGroupedList(scrollController),
            ),
          ],
        );
      },
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color:
              isActive ? activeColor.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive && icon == Icons.favorite_outline
                  ? Icons.favorite
                  : icon,
              size: 60.r,
              color: isActive ? activeColor : Colors.grey[600],
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 46.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? activeColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
