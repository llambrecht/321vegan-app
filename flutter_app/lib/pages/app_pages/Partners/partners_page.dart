import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

// HOW TO SHOW "NEW CONTENT" NOTIFICATION:
// When you add new partners or update this page, call this in initState or build:
// PreferencesHelper.setPartnersLastUpdate(DateTime.now());
//
// This will show an animated red dot on the "Promos" tab icon until the user visits the page.
// Users who have already visited will see the notification again after you update.

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with legend
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: Theme.of(context).colorScheme.primary,
                          size: 56.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Codes Promos Partenaires',
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Legend
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 48.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Les codes avec une étoile sont des codes affiliés qui me donnent une commission. Les utiliser permet de soutenir 321 Vegan !',
                            style: TextStyle(
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                children: [
                  // Cosmétiques & Entretien
                  _buildCategoryTitle('🧴 Cosmétiques & Entretien'),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Comme Avant',
                    logoName: 'logo-comme-avant.png',
                    discountCode: 'VEGAN10',
                    discountAmount: '10% de réduction (1/ personne)',
                    websiteUrl: 'https://www.comme-avant.bio/?ae=1379',
                    description:
                        'Des cosmétiques et produits d\'entretiens 100% vegan, éthiques, fabriqués à la main en France par une entreprise engagée. Vend aussi quelques vêtements durables',
                    hasCommission: true,
                  ),
                  // Nutrition & Suppléments
                  _buildCategoryTitle('🥗 Nutrition & Suppléments'),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Maison Protéine',
                    logoName: 'logo-maisonprot.png',
                    discountCode: '321MAISON10',
                    discountAmount: '10% sur la première commande',
                    websiteUrl: 'https://maisonproteine.com/fr/',
                    description:
                        'Des protéines en poudre véganes, bio, fabriquées en france, avec des ingrédients simples et sains',
                    hasCommission: true,
                  ),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Reify',
                    logoName: 'logo-reify.webp',
                    discountCode: '321VEGAN',
                    discountAmount: '10% de réduction',
                    websiteUrl: 'https://reifynutrition.com/discount/321vegan',
                    description:
                        'Barres salées protéinées. Un snack français audacieux : salé, sain et plein de bons nutriments.',
                    hasCommission: true,
                  ),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Pulse Protein',
                    logoName: 'logo-pulse.png',
                    discountCode: '321VEGAN10',
                    discountAmount: '10% de réduction',
                    websiteUrl:
                        'https://pulseprotein.co?sca_ref=10392739.eblIYTrBBL&utm_source=affiliate&utm_medium=affiliate&utm_campaign=influence',
                    description:
                        'Marque française de produits protéinés sains et gourmands. Véganes, sans gluten et sans soja.',
                    hasCommission: true,
                  ),
                  _buildCategoryTitle('🛍️ Mode & Lifestyle'),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Zebra Vegan Shop',
                    logoName: 'logo-zebra.png',
                    discountCode: '321-ZEBRA5',
                    discountAmount: '5% de réduction',
                    websiteUrl: 'https://www.zebraveganshop.com/?ref=8EC73D',
                    description:
                        'La boutique en ligne qui regroupe la plus belle sélection de marques de mode vegan. Fabriqués en Europe à partir de matériaux éco-responsables',
                    hasCommission: true,
                  ),
                  _buildCategoryTitle("🥚 Alternatives aux oeufs"),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Yumgo',
                    logoName: 'logo-yumgo.webp',
                    discountCode: '321VEGAN10',
                    discountAmount: '10% de réduction',
                    websiteUrl: 'https://yumgo.fr/discount/321VEGAN10',
                    description:
                        'Alternatives végétales aux oeufs. Même texture, même gourmandise et sans allergènes. Fabriqué en France à partir d\'ingrédients simples et naturels.',
                    hasCommission: true,
                  ),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Le Papondu',
                    logoName: 'logo-papondu.png',
                    discountCode: 'PAPON10',
                    discountAmount: '10% sur la première commande',
                    websiteUrl: 'https://papondu.fr/acheter/',
                    description:
                        'Alternatives végétales aux oeufs. Ingrédients d\'origine naturelle. Permet de substituer les oeufs dans toutes vos recettes',
                  ),

                  _buildCategoryTitle("🥤 Boissons énergisantes"),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Ragnarok',
                    logoName: 'logo-ragna.png',
                    discountCode: '321VEGAN20',
                    discountAmount: '20% de réduction',
                    websiteUrl:
                        'https://www.ragnarok-store.fr?sca_ref=10220957.G2u78D4maJ39',
                    description:
                        'Marque française d’énergie, regroupe RAGNADRINK (boissons énergisantes) et RAGNABOOST (pastilles énergisantes).',
                    hasCommission: true,
                  ),
                  _buildCategoryTitle('🍽️ Alimentation générale'),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Official Vegan Shop ',
                    logoName: 'logo-ovs.png',
                    discountCode: '321VEGANOVS',
                    discountAmount: '5% de réduction (hors promos)',
                    websiteUrl: 'https://www.officialveganshop.com/',
                    description:
                        'Boutique en ligne entièrement végane avec de très nombreuses références.',
                  ),
                  _buildPartnerCard(
                    context: context,
                    brandName: 'Terroirs Véganes',
                    logoName: 'logo-terroirs.png',
                    discountCode: '321VEGAN10',
                    discountAmount: '10% de réduction (hors promos)',
                    websiteUrl: 'https://www.terroirs-veganes.fr',
                    description:
                        'Des produits du terroir, innovants, essentiellement français. Véganes militantes, Lisa & Florence sont également les fondatrices du sanctuaire la Pondation de Félicie',
                  ),

                  _buildPartnerCard(
                    context: context,
                    brandName: 'Vegetal Food',
                    logoName: 'logo-vegetalfood.png',
                    discountCode: '321VEGAN10',
                    discountAmount: '10% de réduction (hors promos)',
                    websiteUrl: 'https://vegetalfood.fr',
                    description:
                        'Boutique de produits alimentaires véganes en ligne avec un très large choix !',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 24.h, 8.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 48.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPartnerCard({
    required BuildContext context,
    required String brandName,
    required String logoName,
    required String discountCode,
    required String discountAmount,
    required String websiteUrl,
    required String description,
    bool hasCommission = false,
  }) {
    return Card(
      margin: EdgeInsets.all(16.h),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _launchWebsite(context, websiteUrl),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Logo container
              SizedBox(
                width: 250.w,
                height: 250.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    'lib/assets/partners/$logoName',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.store,
                        size: 100.w,
                        color: Colors.grey[600],
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand name with optional commission star
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            brandName,
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (hasCommission)
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 48.sp,
                          ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 38.sp,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Discount amount
                    Text(
                      discountAmount,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Discount code
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Code: $discountCode',
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 50.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWebsite(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir le lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
