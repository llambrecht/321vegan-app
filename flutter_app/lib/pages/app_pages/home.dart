import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/pages/app_pages/Scan/scan.dart';
import 'package:vegan_app/pages/app_pages/profile.dart';
import 'package:vegan_app/pages/app_pages/search.dart';
import 'package:vegan_app/helpers/time_counter/time_counter.dart';
import 'package:vegan_app/widgets/homepage/stat_card.dart';
import 'package:confetti/confetti.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  DateTime? targetDate;
  SubPage selectedSubPage = SubPage.aboutMe; // Default subpage
  late MotionTabBarController motionTabBarController;
  late Map<String, int> _savings;
  late Timer _timer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) => _updateSavings());
    motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );
    _savings = {};
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 6));

    _loadData();
  }

  @override
  void dispose() {
    motionTabBarController.dispose();
    _confettiController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _loadData() async {
    await loadTargetDate();
    final savings = computeSavings(targetDate);
    setState(() {
      _savings = savings;
    });
  }

  void _onDateSaved(DateTime date) {
    setState(() {
      targetDate = date;
      _savings = computeSavings(targetDate);
    });
  }

  Future<void> loadTargetDate() async {
    final DateTime? dateFromPrefs =
        await PreferencesHelper.getSelectedDateFromPrefs();
    if (dateFromPrefs != null) {
      setState(() {
        targetDate = dateFromPrefs;
      });
    }
  }

  void _updateSavings() {
    setState(() {
      _savings = computeSavings(targetDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    int animalUnit = _savings['animalUnit'] ?? 0;
    int co2Unit = _savings['co2Unit'] ?? 0;
    int waterUnit = _savings['waterUnit'] ?? 0;
    int forestUnit = _savings['forestUnit'] ?? 0;
    return Scaffold(
      body: TabBarView(
        controller: motionTabBarController,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        height: 480.h),
                  ),
                ),
                Positioned(
                  top: 42.h,
                  left: -72.w,
                  child: Opacity(
                    opacity: 1.0,
                    child: Icon(
                      Icons.sunny,
                      size: 889.r,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 100.h),
                    Text(
                      "Vous êtes végane depuis",
                      style: TextStyle(
                          fontSize: 94.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Baloo'),
                    ),
                    Center(
                      child: TimeCounter(targetDate: targetDate),
                    ),
                    buildStatCard(
                      context,
                      'Animaux épargnés',
                      animalUnit,
                      '',
                      Icons.favorite,
                      const Color.fromARGB(247, 255, 103, 153),
                      Colors.pinkAccent,
                      info:
                          "L'industrie de l'élevage cause d'immenses souffrances aux animaux en les considérant comme des objets. Choisir le véganisme, c’est refuser cette exploitation. Ici, on souligne l’effet positif que chacun peut avoir pour un monde plus juste et durable.",
                    ),
                    buildStatCard(
                      context,
                      'CO₂ non émis',
                      co2Unit,
                      'KG',
                      Icons.arrow_downward_sharp,
                      const Color.fromARGB(255, 255, 133, 133),
                      Colors.redAccent,
                      info:
                          "L'alimentation végétale a aussi un impact sur l'environnement et permet de réduire considérablement son empreinte carbone. La quantité de CO2 économisée vient du fait que l'élevage est l'une des principales sources d'émission de gaz à effet de serre, de déforestation, de pollution de l'air et de pollution de l'eau.",
                    ),
                    buildStatCard(
                      context,
                      'Forêt préservée',
                      forestUnit,
                      'm²',
                      Icons.forest_sharp,
                      const Color.fromARGB(127, 105, 240, 175),
                      const Color.fromARGB(197, 36, 139, 87),
                      info:
                          "L'élevage est l'une des principales causes de déforestation. Il faut en effet énormément de place pour cultiver les céréales (notamment soja et maïs) destinés à nourrir les animaux d'élevage. Cette déforestation a des conséquences désastreuses sur la biodiversité et les communautés locales. Adopter une alimentation végétale c'est réduire la pression sur les forêts et à encourager une agriculture plus durable.",
                    ),
                    buildStatCard(
                      context,
                      'Eau économisée',
                      waterUnit,
                      'm³',
                      Icons.water_drop,
                      const Color.fromARGB(255, 97, 166, 250),
                      Colors.blueAccent,
                      info:
                          "En choisissant d'être végétalien, vous aidez à économiser de précieuses ressources en eau. La production de produits animaux nécessite une gigantesque quantité d'eau, notamment pour l'irrigation des cultures pour les animaux d'élevage. Et cela sans parler de la polution de l'eau due aux déjections qu'ils produisent.",
                    ),
                  ],
                ),
                if (targetDate == null)
                  Positioned(
                    bottom: 150.h,
                    child: ElevatedButton(
                      onPressed: launchCounter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 12.h),
                        textStyle: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'Baloo',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text('Démarrer le compteur',
                          style: TextStyle(fontSize: 60.sp)),
                    ),
                  ),
                ConfettiWidget(
                  numberOfParticles: 20,
                  maxBlastForce: 50.r,
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                  ],
                ),
              ],
            ),
          ),
          const SearchPage(),
          const ScanPage(),
          ProfilePage(
            onDateSaved: _onDateSaved,
            selectedInitialSubPage: selectedSubPage,
          ),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        controller: motionTabBarController,
        labels: const ["Accueil", "Recherche", "Scan", "Profile"],
        initialSelectedTab: "Accueil",
        tabIconColor: Colors.grey,
        tabSelectedColor: Theme.of(context).colorScheme.primary,
        onTabItemSelected: (int value) {
          setState(() {
            motionTabBarController.index = value;
          });
        },
        icons: const [
          Icons.home,
          Icons.search,
          Icons.qr_code_scanner,
          Icons.person
        ],
        textStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Map<String, int> computeSavings(DateTime? targetTime) {
    // Constant values for each unit, per day.
    const double animalPer = 1.3;
    const double co2Per = 9.0;
    const double waterPer = 2.271;
    const double forestPer = 2.7;

    Duration duration = Duration.zero;
    if (targetTime != null) {
      duration = DateTime.now().difference(targetTime);
    }
    final int days = duration.inDays;
    final int animalUnit = (days * animalPer).toInt();
    final int co2Unit = (days * co2Per).toInt();
    final int waterUnit = (days * waterPer).toInt();
    final int forestUnit = (days * forestPer).toInt();

    return {
      'animalUnit': animalUnit,
      'co2Unit': co2Unit,
      'waterUnit': waterUnit,
      'forestUnit': forestUnit,
    };
  }

  void launchCounter() async {
    final DateTime now = DateTime.now();
    await PreferencesHelper.addSelectedDateToPrefs(now);

    setState(() {
      targetDate = now;
      _savings = computeSavings(targetDate);
    });

    _confettiController.play();
  }
}
