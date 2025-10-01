import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';

class PartnersPage extends StatelessWidget {
  const PartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Wave header
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    color: Theme.of(context).colorScheme.primary,
                    height: 0.19.sh,
                  ),
                ),
              ),
              CustomPaint(
                size: Size.fromHeight(0.190.sh),
                painter: WaveTextPainter("Partenaires"),
              ),
            ],
          ),

          SizedBox(height: 60.h),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red[400],
                              size: 48.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                'Avec les codes promos de nos partenaires, vous bénéficiez de réductions dans certaines boutiques en ligne.',
                                style: TextStyle(
                                  fontSize: 42.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
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
                                'Les étoiles indiquent que c\'est un code affilié, qui me donne une petite commission. Les utiliser permet de soutenir 321 Vegan, merci !',
                                style: TextStyle(
                                  fontSize: 42.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Partners list
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
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
                          brandName: 'Vegetal Food',
                          logoName: 'logo-vegetalfood.png',
                          discountCode: '321VEGAN10',
                          discountAmount: '10% de réduction (hors promos)',
                          websiteUrl: 'https://vegetalfood.fr',
                          description:
                              'Boutique de produits alimentaires véganes en ligne avec un très large choix !',
                        ),
                        _buildPartnerCard(
                          context: context,
                          brandName: 'Zebra Vegan Shop',
                          logoName: 'logo-zebra.png',
                          discountCode: '321VEGANZEBRA',
                          discountAmount: '10% de réduction',
                          websiteUrl: 'https://www.zebraveganshop.com/',
                          description:
                              'La boutique en ligne qui regroupe la plus belle sélection de marques de mode vegan. Fabriqués en Europe à partir de matériaux éco-responsables',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
