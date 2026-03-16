import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/product_of_interest.dart';
import '../../services/api_service.dart';

class ShopConfirmationModal extends StatefulWidget {
  final String shopName;
  final int scanEventId;
  final ProductOfInterest product;
  final List<Map<String, dynamic>> nearbyShops;

  const ShopConfirmationModal({
    super.key,
    required this.shopName,
    required this.scanEventId,
    required this.product,
    this.nearbyShops = const [],
  });

  @override
  State<ShopConfirmationModal> createState() => _ShopConfirmationModalState();
}

class _ShopConfirmationModalState extends State<ShopConfirmationModal>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _thanksController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _thanksScaleAnimation;
  late Animation<double> _thanksFadeAnimation;
  bool _showThanks = false;
  bool _showAlternatives = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Thanks animation controller
    _thanksController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _thanksScaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: _thanksController,
        curve: Curves.easeOut,
      ),
    );

    _thanksFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _thanksController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _thanksController.dispose();
    super.dispose();
  }

  Future<void> _showThanksAndClose() async {
    setState(() {
      _showThanks = true;
    });

    // Wait for the animation to complete before closing
    await _thanksController.forward();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleNo() async {
    if (widget.nearbyShops.isNotEmpty) {
      // Show alternative shops instead of nullifying
      setState(() {
        _showAlternatives = true;
      });
    } else {
      // No alternatives available - nullify as before
      await ApiService.updateScanEvent(scanEventId: widget.scanEventId);
      await _showThanksAndClose();
    }
  }

  Future<void> _handleYes() async {
    // User confirms - do nothing, location is already saved
    await _showThanksAndClose();
  }

  Future<void> _handleSelectShop(int shopId) async {
    // User selected an alternative shop
    await ApiService.updateScanEvent(
      scanEventId: widget.scanEventId,
      shopId: shopId,
    );
    await _showThanksAndClose();
  }

  Future<void> _handleNoneOfThese() async {
    // User says none of the shops match - nullify
    await ApiService.updateScanEvent(scanEventId: widget.scanEventId);
    await _showThanksAndClose();
  }

  @override
  Widget build(BuildContext context) {
    final decodedShopName = widget.shopName;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Dark overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),

          // Modal content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: _showAlternatives
                    ? _buildAlternativesContent()
                    : _buildConfirmationContent(decodedShopName),
              ),
            ),
          ),

          // "Merci !" animation overlay
          if (_showThanks)
            Center(
              child: ScaleTransition(
                scale: _thanksScaleAnimation,
                child: FadeTransition(
                  opacity: _thanksFadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 48.w,
                      vertical: 24.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A722E),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A722E).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      'Merci !',
                      style: TextStyle(
                        fontSize: 72.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent(String decodedShopName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A722E).withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.store,
            size: 70.sp,
            color: const Color(0xFF1A722E),
          ),
        ),

        SizedBox(height: 24.h),

        // Title
        Text(
          'Confirmation du magasin',
          style: TextStyle(
            fontSize: 52.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A722E),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 20.h),

        // Product name highlight
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            widget.product.name,
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        SizedBox(height: 20.h),

        // Question text
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 44.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
            children: [
              const TextSpan(
                  text: 'Avez-vous trouvé ce produit à\n'),
              TextSpan(
                text: decodedShopName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A722E),
                  fontSize: 46.sp,
                ),
              ),
              const TextSpan(text: ' ?'),
            ],
          ),
        ),

        SizedBox(height: 32.h),

        // Buttons row
        Row(
          children: [
            // No button
            Expanded(
              child: ElevatedButton(
                onPressed: _handleNo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[800],
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Non',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Yes button
            Expanded(
              child: ElevatedButton(
                onPressed: _handleYes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A722E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Oui',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlternativesContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A722E).withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.store_mall_directory,
            size: 70.sp,
            color: const Color(0xFF1A722E),
          ),
        ),

        SizedBox(height: 24.h),

        // Title
        Text(
          'Autres magasins à proximité',
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A722E),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 16.h),

        Text(
          'Étiez-vous dans l\'un de ces magasins ?',
          style: TextStyle(
            fontSize: 40.sp,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 24.h),

        // Shop list
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300.h),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: widget.nearbyShops.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final shop = widget.nearbyShops[index];
              final name = shop['name'] as String? ?? 'Magasin inconnu';
              final address = shop['address'] as String?;
              final city = shop['city'] as String?;
              final subtitle = [address, city]
                  .where((s) => s != null && s.isNotEmpty)
                  .join(', ');

              return InkWell(
                onTap: () => _handleSelectShop(shop['id'] as int),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF1A722E).withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 40.sp,
                        color: const Color(0xFF1A722E),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 36.sp,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 20.h),

        // "None of these" button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleNoneOfThese,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.grey[800],
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
            ),
            child: Text(
              'Aucun de ceux-ci',
              style: TextStyle(
                fontSize: 44.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
