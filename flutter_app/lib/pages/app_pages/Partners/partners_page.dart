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
                  // Introduction text
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Row(
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
                            'Avec les codes affiliés 321 Vegan, vous bénéficiez de réductions dans certaines boutiques en ligne.\nUtiliser ces codes permet de soutenir l\'application !',
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
                          brandName: 'PlantJoy',
                          logoName: 'logo-plantjoy.png',
                          discountCode: '321VEGAN10',
                          discountAmount: '10% de réduction',
                          websiteUrl: 'https://plantjoy.fr',
                          description:
                              'Produits végans à réhydrater (Steaks, nuggets, haché, ...)',
                        ),
                        _buildPartnerCard(
                          context: context,
                          brandName: 'Official Vegan Shop',
                          logoName: 'logo-ovs.png',
                          discountCode: '321VEGAN5',
                          discountAmount: '5% de réduction',
                          websiteUrl: 'https://officialveganshop.com',
                          description:
                              'Boutique de produits véganes en ligne avec un très large choix ! ',
                        ),
                        _buildPartnerCard(
                          context: context,
                          brandName: 'Véganie',
                          logoName: 'logo-veganie.png',
                          discountCode: 'PARTNER321',
                          discountAmount: '15€ offerts (dès 50€ d\'achat)',
                          websiteUrl: 'https://veganie.com/',
                          description: 'Vêtements éthiques et durables',
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
                    // Brand name
                    Text(
                      brandName,
                      style: TextStyle(
                        fontSize: 52.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
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
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'ouverture du lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
