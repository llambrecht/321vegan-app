import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  // Launch Instagram function
  void _launchInstagram(BuildContext context) async {
    const instagramUrl = 'instagram://user?username=321vegan.app';
    const fallbackUrl = 'https://instagram.com/321vegan.app';

    try {
      // Try to open Instagram app first
      bool launched = await launchUrl(
        Uri.parse(instagramUrl),
        mode: LaunchMode.externalApplication,
      );

      // If Instagram app failed to launch, try the web URL
      if (!launched) {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // If both attempts fail, try one more time with platform default
      try {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.platformDefault,
        );
      } catch (e2) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Impossible d\'ouvrir Instagram. Veuillez vérifier votre connexion internet.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Launch App Store Review function
  void _launchAppStoreReview(BuildContext context) async {
    String reviewUrl;
    if (Platform.isIOS) {
      reviewUrl = 'https://apps.apple.com/fr/app/321-vegan/id6736880006';
    } else if (Platform.isAndroid) {
      reviewUrl =
          'https://play.google.com/store/apps/details?id=com.app321vegan.veganapp';
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avis non disponible sur cette plateforme'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await launchUrl(Uri.parse(reviewUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir la page d\'avis'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          _buildAboutCard(),
          SizedBox(height: 32.h),
          _buildSocialSection(),
          SizedBox(height: 32.h),
          _buildReviewSection(),
          SizedBox(height: 32.h),
          _buildContactSection(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 46.sp,
                color: Colors.grey[700],
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              children: const [
                TextSpan(text: '321 Vegan est une application entièrement '),
                TextSpan(
                  text: 'gratuite',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        ' développée pour aider la communauté végane à identifier plus facilement les produits végétaliens.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        SizedBox(height: 28.h),
        GestureDetector(
          onTap: () => _launchInstagram(context),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _launchInstagram(context),
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.blue.withValues(alpha: 0.2),
              highlightColor: Colors.blue.withValues(alpha: 0.1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'lib/assets/logo_instagram.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejoignez moi sur Instagram',
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@321vegan.app',
                          style: TextStyle(
                            fontSize: 50.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 28.h),
        ElevatedButton.icon(
          onPressed: () {
            Share.share(
              'Télécharge l\'application 321 Vegan (scan de produits, recherche d\'additifs, suivi de votre impact), sur Android et iOS ! https://linktr.ee/321vegan',
              subject: '321Vegan App',
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Partager l\'application'),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return _buildCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (index) => Icon(
                      Icons.star,
                      size: 48.sp,
                      color: Colors.amber,
                    )),
          ),
          SizedBox(height: 16.h),
          Text(
            'Vous aimez 321 Vegan ?',
            style: TextStyle(
              fontSize: 52.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            'Mettre un avis nous aide à améliorer l\'application et à la faire découvrir à d\'autres personnes. C\'est un moyen simple et gratuit de nous soutenir !',
            style: TextStyle(
              fontSize: 42.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _launchAppStoreReview(context),
            icon: Icon(
              Platform.isIOS ? Icons.apple : Icons.android,
              size: 80.sp,
            ),
            label: Text(
              Platform.isIOS
                  ? 'Noter sur l\'App Store'
                  : 'Noter sur Google Play',
              style: TextStyle(fontSize: 44.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        SizedBox(height: 28.h),
        Text(
          'Vous pouvez aussi me contacter sur',
          style: TextStyle(
            fontSize: 38.sp,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        SelectableText(
          'contact@321vegan.fr',
          style: TextStyle(
            fontSize: 44.sp,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
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
      child: child,
    );
  }
}
