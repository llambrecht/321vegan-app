import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/models/product_of_interest.dart';
import 'package:vegan_app/services/products_of_interest_cache.dart';

class MapFilterSheet extends StatefulWidget {
  final Set<String> selectedEans;
  final ValueChanged<Set<String>> onApply;

  const MapFilterSheet({
    super.key,
    required this.selectedEans,
    required this.onApply,
  });

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late Set<String> _selected;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  List<ProductOfInterest> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedEans);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ProductsOfInterestCache.loadProductsOfInterest();
    if (mounted) {
      setState(() {
        _products = products..shuffle();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductOfInterest> get _sponsored =>
      _products.where((p) => p.type == 'sponsored').toList();

  List<ProductOfInterest> get _regular {
    final q = _search.toLowerCase();
    return _products
        .where((p) => p.type != 'sponsored')
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q) || p.brandName.toLowerCase().contains(q))
        .toList();
  }

  List<ProductOfInterest> get _sponsoredFiltered {
    final q = _search.toLowerCase();
    return _sponsored
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q) || p.brandName.toLowerCase().contains(q))
        .toList();
  }

  void _toggle(ProductOfInterest product) {
    setState(() {
      if (_selected.contains(product.ean)) {
        _selected.remove(product.ean);
      } else {
        _selected.add(product.ean);
      }
    });
  }

  Widget _buildProductCard(ProductOfInterest product, {bool sponsored = false}) {
    final isSelected = _selected.contains(product.ean);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => _toggle(product),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: product.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl:
                              '${dotenv.env['API_BASE_URL']}/${product.image}',
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.grey[400],
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.shopping_bag_outlined,
                            size: 64.w,
                            color: Colors.grey[300],
                          ),
                        )
                      : Icon(
                          Icons.shopping_bag_outlined,
                          size: 64.w,
                          color: Colors.grey[300],
                        ),
                ),
                if (sponsored)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.amber[600],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '★',
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              product.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey[800],
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final sponsored = _sponsoredFiltered;
    final regular = _regular;
    final hasResults = sponsored.isNotEmpty || regular.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Text(
                'Filtrer par produit',
                style: TextStyle(
                  fontSize: 46.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              if (_selected.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selected.clear()),
                  child: Text(
                    'Effacer',
                    style: TextStyle(fontSize: 34.sp, color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        // Search field
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un produit (nom, marque)...',
              hintStyle: TextStyle(fontSize: 45.sp, color: Colors.grey[400]),
              prefixIcon: Icon(
                Icons.search,
                size: 60.sp,
                color: Colors.grey[400],
              ),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 36.sp),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _search = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Product grid
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: CircularProgressIndicator(color: Colors.grey[400]),
                  ),
                )
              else if (!hasResults)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Text(
                      'Aucun produit trouvé',
                      style: TextStyle(
                        fontSize: 38.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              if (sponsored.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Produits mis en avant',
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: sponsored.length,
                  itemBuilder: (_, i) =>
                      _buildProductCard(sponsored[i], sponsored: true),
                ),
              ],
              if (regular.isNotEmpty) ...[
                if (sponsored.isNotEmpty)
                  Text(
                    'Tous les produits',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                if (sponsored.isNotEmpty) SizedBox(height: 10.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: regular.length,
                  itemBuilder: (_, i) => _buildProductCard(regular[i]),
                ),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        ),
        // Apply button
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(Set.from(_selected));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                _selected.isEmpty
                    ? 'Voir tous les commerces'
                    : 'Appliquer · ${_selected.length} produit${_selected.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 42.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
