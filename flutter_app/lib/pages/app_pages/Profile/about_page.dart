import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  double? currentAmount = 10;
  double? goalFrais = 45;
  double? goalVivre = 2000;

  @override
  void initState() {
    super.initState();
    fetchDonationGoals();
  }

  Future<void> fetchDonationGoals() async {
    const url =
        'https://raw.githubusercontent.com/llambrecht/321vegan_appcast/main/goals.json';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        currentAmount = (data['currentAmount'] as num).toDouble();
        goalFrais = (data['goalFrais'] as num).toDouble();
        goalVivre = (data['goalVivre'] as num).toDouble();
      });
    } else {
      throw Exception('Failed to load data');
    }
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

  // Launch Buy Me a Coffee function
  void _launchBuyMeACoffee(BuildContext context) async {
    const buyMeACoffeeUrl = 'https://buymeacoffee.com/321vegan';

    try {
      await launchUrl(Uri.parse(buyMeACoffeeUrl),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Buy Me a Coffee'),
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
          _buildHeroSection(),
          SizedBox(height: 32.h),
          _buildDonationGoalSection(),
          SizedBox(height: 24.h),
          _buildSocialSection(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.volunteer_activism_rounded,
              size: 64.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Soutenez 321 Vegan',
            style: TextStyle(
              fontSize: 68.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Baloo',
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text:
                        'Pour nous soutenir, vous pouvez souscrire à un abonnement soutien '),
                TextSpan(
                    text: 'à partir de 1€',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text:
                        ' ou bien faire un don ponctuel. Cet argent me permet de payer les frais liés à l\'application ; et pourquoi pas d\'en vivre un jour ?'),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          _buildBuyMeACoffeeButton(),
        ],
      ),
    );
  }

  Widget _buildDonationGoalSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Objectif de dons mensuels',
                  style: TextStyle(
                    fontSize: 56.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[900],
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildUnifiedGauge(currentAmount!, goalFrais!, goalVivre!),
        ],
      ),
    );
  }

  Widget _buildUnifiedGauge(double current, double goal1, double goal2) {
    // Calculate progress relative to the ultimate goal (goal2)
    final progress = current >= goal2 ? 1.0 : (current / goal2).clamp(0.0, 1.0);
    final progress1 = goal1 / goal2; // Position of first goal marker
    final progress1Reached = current >= goal1;
    final progress2Reached = current >= goal2;

    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Current amount display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${current.toInt()}',
                        style: TextStyle(
                          fontSize: 76.sp,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Baloo',
                          letterSpacing: -1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h, left: 8.w),
                        child: Text(
                          '€',
                          style: TextStyle(
                            fontSize: 52.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
                        child: Text(
                          '/ mois (actuellement)',
                          style: TextStyle(
                            fontSize: 48.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Main progress gauge
          Stack(
            children: [
              // Background progress
              Container(
                width: MediaQuery.of(context).size.width * 0.7 * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),

              // Goal 1 marker (frais)
              Positioned(
                left: MediaQuery.of(context).size.width * 0.7 * progress1 - 3,
                child: Column(
                  children: [
                    Container(
                      width: 6,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange[600]!.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '60€',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Goal 2 marker (vivre)
              Positioned(
                left: MediaQuery.of(context).size.width * 0.7 - 3,
                child: Column(
                  children: [
                    Container(
                      width: 6,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green[600]!.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_rounded,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '2000€',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Current position indicator
              Positioned(
                left: MediaQuery.of(context).size.width * 0.7 * progress - 8,
                top: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: progress2Reached
                          ? Colors.green[600]!
                          : Theme.of(context).primaryColor,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: progress2Reached
                      ? Icon(
                          Icons.check,
                          color: Colors.green[600],
                          size: 12,
                        )
                      : null,
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Goal status summary
          Row(
            children: [
              Expanded(
                child: _buildGoalStatusCard(
                  'Payer les frais',
                  goal1,
                  current,
                  Colors.orange[600]!,
                  progress1Reached,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildGoalStatusCard(
                  'Pour en vivre',
                  goal2,
                  current,
                  Colors.green[600]!,
                  progress2Reached,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStatusCard(
      String title, double goal, double current, Color color, bool isReached) {
    final remaining = goal - current;
    final progress = (current / goal).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            isReached ? '🎉 Atteint !' : '${remaining.toInt()}€ manquants',
            style: TextStyle(
              fontSize: 36.sp,
              color: isReached ? Colors.green[600] : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 6.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.blue.withOpacity(0.1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo inside a circle
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
            color: Colors.black.withOpacity(0.06),
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

  Widget _buildBuyMeACoffeeButton() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _launchBuyMeACoffee(context),
        icon: Icon(
          Icons.favorite,
          color: const Color.fromARGB(247, 255, 103, 153), // Dark brown
          size: 48.sp,
        ),
        label: Text(
          'Je soutiens !',
          style: TextStyle(
            fontSize: 48.sp,
            color: const Color.fromARGB(247, 255, 103, 153), // Dark brown
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }
}
