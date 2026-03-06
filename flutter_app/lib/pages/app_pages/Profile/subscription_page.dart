import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isYearly = false;
  int _selectedTier = 2; // 1, 2, or 3 — default to middle tier
  String? _errorMessage;

  String? get _selectedProductId {
    if (_isYearly) {
      switch (_selectedTier) {
        case 1:
          return SubscriptionService.yearlyId;
        case 2:
          return SubscriptionService.tier1YearlyId;
        case 3:
          return SubscriptionService.tier2YearlyId;
      }
    } else {
      switch (_selectedTier) {
        case 1:
          return SubscriptionService.monthlyId;
        case 2:
          return SubscriptionService.tier1MonthlyId;
        case 3:
          return SubscriptionService.tier2MonthlyId;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    SubscriptionService.onSubscriptionChanged = _onSubscriptionChanged;
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
    final isBypass = AuthService.currentUser?.subscriptionBypass ?? false;
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
              if (isSubscribed && isBypass) ...[
                _buildBypassCard(primaryColor),
                SizedBox(height: 32.h),
              ] else if (isSubscribed && subscription != null) ...[
                _buildActiveSubscriptionCard(subscription, primaryColor),
                SizedBox(height: 16.h),
                _buildManageSubscriptionButton(),
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
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      'Tous les paliers débloquent les mêmes avantages. Choisissez simplement selon vos moyens !',
                      style: TextStyle(
                        fontSize: 32.sp,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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

  Widget _buildBypassCard(Color primaryColor) {
    return Container(
      width: double.infinity,
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
            'Accès accordé',
            style: TextStyle(
              fontSize: 52.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Baloo',
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Tous les thèmes sont débloqués.',
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

  Widget _buildActiveSubscriptionCard(subscription, Color primaryColor) {
    final productName =
        SubscriptionService.getProductDisplayName(subscription.productId);
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
          'Aidez-nous à grandir et à rendre le véganisme facile pour encore plus de monde\net débloquez des thèmes exclusifs !',
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
      (
        'Tous les thèmes débloqués',
        'Printemps, Été, Automne, Hiver',
        Icons.palette
      ),
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

  Widget _buildBillingToggle(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: !_isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: !_isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Par mois',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight:
                        !_isYearly ? FontWeight.bold : FontWeight.normal,
                    color: !_isYearly ? primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: _isYearly
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  'Par an',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: _isYearly ? FontWeight.bold : FontWeight.normal,
                    color: _isYearly ? primaryColor : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards(Color primaryColor) {
    final tiers = [
      (
        tier: 1,
        title: 'Graine',
        icon: Icons.eco,
        monthlyId: SubscriptionService.monthlyId,
        yearlyId: SubscriptionService.yearlyId,
        isPopular: false,
      ),
      (
        tier: 2,
        title: 'Fleur',
        icon: Icons.favorite,
        monthlyId: SubscriptionService.tier1MonthlyId,
        yearlyId: SubscriptionService.tier1YearlyId,
        isPopular: true,
      ),
      (
        tier: 3,
        title: 'Arbre',
        icon: Icons.star,
        monthlyId: SubscriptionService.tier2MonthlyId,
        yearlyId: SubscriptionService.tier2YearlyId,
        isPopular: false,
      ),
    ];

    return Column(
      children: [
        _buildBillingToggle(primaryColor),
        SizedBox(height: 20.h),
        ...tiers.map((t) {
          final productId = _isYearly ? t.yearlyId : t.monthlyId;
          final product = SubscriptionService.getProduct(productId);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildTierCard(
              tier: t.tier,
              title: t.title,
              icon: t.icon,
              price: product?.price,
              isPopular: t.isPopular,
              primaryColor: primaryColor,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTierCard({
    required int tier,
    required String title,
    required IconData icon,
    required String? price,
    required bool isPopular,
    required Color primaryColor,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.04)
                  : Colors.white,
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
                // Icon circle
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.15)
                        : Colors.grey[100],
                  ),
                  child: Icon(
                    icon,
                    size: 48.sp,
                    color: isSelected ? primaryColor : Colors.grey[500],
                  ),
                ),
                SizedBox(width: 16.w),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 44.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : Colors.grey[800],
                    ),
                  ),
                ),
                // Price + period
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price ?? '...',
                      style: TextStyle(
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? primaryColor : Colors.grey[800],
                      ),
                    ),
                    Text(
                      _isYearly ? '/ an' : '/ mois',
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // "Populaire" badge
          if (isPopular)
            Positioned(
              top: -12.h,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade400
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
            ),
        ],
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

  Widget _buildManageSubscriptionButton() {
    return TextButton(
      onPressed: () async {
        final Uri url;
        if (Platform.isIOS) {
          url = Uri.parse('https://apps.apple.com/account/subscriptions');
        } else {
          url =
              Uri.parse('https://play.google.com/store/account/subscriptions');
        }
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 40.sp, color: Colors.grey[500]),
          SizedBox(width: 8.w),
          Text(
            'Gérer mon abonnement',
            style: TextStyle(
              fontSize: 38.sp,
              color: Colors.grey[500],
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
