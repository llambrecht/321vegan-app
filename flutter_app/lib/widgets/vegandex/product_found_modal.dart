import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_of_interest.dart';

class ProductFoundModal extends StatefulWidget {
  final ProductOfInterest product;
  final bool isNewDiscovery;
  final VoidCallback? onClose;

  const ProductFoundModal({
    super.key,
    required this.product,
    this.isNewDiscovery = true,
    this.onClose,
  });

  @override
  State<ProductFoundModal> createState() => _ProductFoundModalState();
}

class _ProductFoundModalState extends State<ProductFoundModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final baseUrl = dotenv.env['API_BASE_URL'];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Start animations
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title text
                    Text(
                      widget.isNewDiscovery
                          ? '🎉 Nouveau produit trouvé !'
                          : '✨ Produit Vegandex !',
                      style: TextStyle(
                        fontSize: 52.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A722E),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24.h),

                    // Product image with glow effect
                    Container(
                      width: 240.w,
                      height: 240.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF1A722E),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1A722E).withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: CachedNetworkImage(
                            imageUrl: '$baseUrl/${widget.product.image}',
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: const Color(0xFF1A722E),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return Icon(
                                Icons.catching_pokemon,
                                size: 120.sp,
                                color: const Color(0xFF1A722E),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Product name
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 54.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // Brand name
                    Text(
                      widget.product.brandName,
                      style: TextStyle(
                        fontSize: 46.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),

                    // Message
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A722E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        widget.isNewDiscovery
                            ? 'Vous avez trouvé un nouveau produit pour votre Vegandex ! 🌱'
                            : 'Ce produit fait partie du Vegandex ! 🌱',
                        style: TextStyle(
                          fontSize: 42.sp,
                          color: const Color(0xFF1A722E),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Close button
                    ElevatedButton(
                      onPressed: () {
                        widget.onClose?.call();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A722E),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 48.w,
                          vertical: 20.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Génial !',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
