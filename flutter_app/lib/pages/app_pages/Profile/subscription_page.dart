import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../services/subscription_service.dart';
import '../../../services/auth_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isLoading = false;
  bool _isRestoring = false;
  String? _selectedProductId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SubscriptionService.onSubscriptionChanged = _onSubscriptionChanged;
    // Pre-select yearly as default
    if (SubscriptionService.yearlyProduct != null) {
      _selectedProductId = SubscriptionService.yearlyProductId;
    } else if (SubscriptionService.monthlyProduct != null) {
      _selectedProductId = SubscriptionService.monthlyProductId;
    }
  }

  @override
  void dispose() {
    SubscriptionService.onSubscriptionChanged = null;
    super.dispose();
  }

  void _onSubscriptionChanged() {
    if (mounted) {
      setState(() {});
      if (SubscriptionService.isSubscribed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Merci pour votre soutien !',
              style: TextStyle(fontSize: 44.sp, fontFamily: 'Baloo'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _purchase() async {
    if (!AuthService.isLoggedIn) {
      setState(() {
        _errorMessage = 'Vous devez être connecté pour vous abonner.';
      });
      return;
    }

    if (_selectedProductId == null) return;

    final product = SubscriptionService.products
        .where((p) => p.id == _selectedProductId)
        .firstOrNull;

    if (product == null) {
      setState(() {
        _errorMessage = 'Produit non disponible. Réessayez plus tard.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SubscriptionService.buyProduct(product);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'achat. Réessayez plus tard.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restore() async {
    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      await SubscriptionService.restorePurchases();
      // Give a moment for the purchase stream to process
      await Future.delayed(const Duration(seconds: 2));
      await SubscriptionService.checkSubscriptionStatus();

      if (mounted) {
        if (SubscriptionService.isSubscribed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Abonnement restauré avec succès !',
                style: TextStyle(fontSize: 44.sp, fontFamily: 'Baloo'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Aucun abonnement trouvé à restaurer.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la restauration.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = SubscriptionService.isSubscribed;
    final subscription = SubscriptionService.currentSubscription;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800], size: 60.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Soutenir 321 Vegan',
          style: TextStyle(
            fontSize: 52.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
          child: Column(
            children: [
              // Already subscribed banner
              if (isSubscribed && subscription != null) ...[
                _buildActiveSubscriptionCard(subscription, primaryColor),
                SizedBox(height: 32.h),
              ],

              // Header illustration
              if (!isSubscribed) ...[
                _buildHeader(primaryColor),
                SizedBox(height: 32.h),

                // Benefits list
                _buildBenefits(primaryColor),
                SizedBox(height: 32.h),

                // Plan cards
                if (SubscriptionService.products.isNotEmpty) ...[
                  _buildPlanCards(primaryColor),
                  SizedBox(height: 24.h),

                  // Error message
                  if (_errorMessage != null) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 38.sp,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Purchase button
                  _buildPurchaseButton(primaryColor),
                  SizedBox(height: 20.h),

                  // Restore button
                  _buildRestoreButton(),
                ] else ...[
                  _buildProductsUnavailable(),
                ],

                SizedBox(height: 32.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(
      subscription, Color primaryColor) {
    final productName = subscription.productId ==
            SubscriptionService.yearlyProductId
        ? 'Annuel'
        : 'Mensuel';
    final expiresAt = subscription.expiresAt;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 120.sp),
          SizedBox(height: 16.h),
          Text(
            'Abonnement actif',
            style: TextStyle(
              fontSize: 52.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Baloo',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Forfait $productName',
            style: TextStyle(
              fontSize: 40.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (expiresAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Valide jusqu\'au ${_formatDate(expiresAt)}',
              style: TextStyle(
                fontSize: 36.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Text(
            'Merci pour votre soutien ! Tous les thèmes sont débloqués.',
            style: TextStyle(
              fontSize: 38.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.1),
                primaryColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite,
            size: 160.sp,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Soutenez le projet',
          style: TextStyle(
            fontSize: 60.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Aidez-nous à améliorer 321 Vegan\net débloquez des thèmes exclusifs !',
          style: TextStyle(
            fontSize: 40.sp,
            color: Colors.grey[500],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefits(Color primaryColor) {
    final benefits = [
      ('Thèmes saisonniers', 'Printemps, Été, Automne, Hiver', Icons.palette),
      ('Thème automatique', 'Change selon la saison', Icons.auto_awesome),
      ('Badge soutien', 'Badge exclusif sur votre profil', Icons.military_tech),
      ('Soutenir le projet', 'Aidez-nous à continuer', Icons.favorite),
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ce que vous obtenez',
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          ...benefits.map((benefit) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        benefit.$3,
                        size: 48.sp,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            benefit.$1,
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            benefit.$2,
                            style: TextStyle(
                              fontSize: 34.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: primaryColor,
                      size: 48.sp,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPlanCards(Color primaryColor) {
    final monthly = SubscriptionService.monthlyProduct;
    final yearly = SubscriptionService.yearlyProduct;

    return Column(
      children: [
        if (yearly != null)
          _buildPlanCard(
            productDetails: yearly,
            title: 'Annuel',
            subtitle: 'Le meilleur rapport qualité-prix',
            primaryColor: primaryColor,
            isRecommended: true,
          ),
        if (yearly != null && monthly != null) SizedBox(height: 16.h),
        if (monthly != null)
          _buildPlanCard(
            productDetails: monthly,
            title: 'Mensuel',
            subtitle: 'Flexibilité maximale',
            primaryColor: primaryColor,
            isRecommended: false,
          ),
      ],
    );
  }

  Widget _buildPlanCard({
    required ProductDetails productDetails,
    required String title,
    required String subtitle,
    required Color primaryColor,
    required bool isRecommended,
  }) {
    final isSelected = _selectedProductId == productDetails.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = productDetails.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 28.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 16.w),
            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 46.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (isRecommended) ...[
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Populaire',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 34.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Price
            Text(
              productDetails.price,
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _purchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 22.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
        ),
        child: _isLoading
            ? SizedBox(
                height: 48.sp,
                width: 48.sp,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'S\'abonner',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _isRestoring ? null : _restore,
      child: _isRestoring
          ? SizedBox(
              height: 40.sp,
              width: 40.sp,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[500],
              ),
            )
          : Text(
              'Restaurer un achat existant',
              style: TextStyle(
                fontSize: 38.sp,
                color: Colors.grey[500],
                decoration: TextDecoration.underline,
              ),
            ),
    );
  }

  Widget _buildProductsUnavailable() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 80.sp),
          SizedBox(height: 12.h),
          Text(
            'Abonnements non disponibles',
            style: TextStyle(
              fontSize: 44.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Les abonnements ne sont pas disponibles pour le moment. Veuillez réessayer plus tard.',
            style: TextStyle(
              fontSize: 38.sp,
              color: Colors.orange[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
