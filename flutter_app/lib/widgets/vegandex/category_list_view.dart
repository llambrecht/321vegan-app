import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/product_category.dart';
import '../../models/product_of_interest.dart';

class CategoryListView extends StatelessWidget {
  final List<ProductOfInterest> products;
  final Map<String, dynamic> scannedProducts;
  final Function(ProductCategory) onCategoryTap;

  const CategoryListView({
    super.key,
    required this.products,
    required this.scannedProducts,
    required this.onCategoryTap,
  });

  List<ProductCategory> _getUniqueCategories() {
    final Map<int, String> categoriesMap = {};
    for (var product in products) {
      categoriesMap[product.categoryId] = product.categoryName;
    }

    return categoriesMap.entries
        .map((entry) => ProductCategory(id: entry.key, name: entry.value))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  int _getScannedCountForCategory(int categoryId) {
    return products
        .where((p) =>
            p.categoryId == categoryId && scannedProducts.containsKey(p.ean))
        .length;
  }

  int _getTotalCountForCategory(int categoryId) {
    return products.where((p) => p.categoryId == categoryId).length;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getUniqueCategories();

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 120.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucune catégorie disponible',
              style: TextStyle(
                fontSize: 48.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(24.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final scannedCount = _getScannedCountForCategory(category.id);
        final totalCount = _getTotalCountForCategory(category.id);

        return _buildCategoryCard(
          context,
          category,
          scannedCount,
          totalCount,
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    ProductCategory category,
    int scannedCount,
    int totalCount,
  ) {
    return GestureDetector(
      onTap: () => onCategoryTap(category),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Image.asset(
                'lib/assets/categories/${category.name}.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Progress indicator on top left
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 40.sp,
                        color: scannedCount == totalCount
                            ? const Color(0xFF1A722E)
                            : Colors.grey[600],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$scannedCount / $totalCount',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: scannedCount == totalCount
                              ? const Color(0xFF1A722E)
                              : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
