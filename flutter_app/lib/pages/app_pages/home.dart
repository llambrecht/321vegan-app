import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/pages/app_pages/Partners/partners_page.dart';
import 'package:vegan_app/pages/app_pages/Scan/scan.dart';
import 'package:vegan_app/pages/app_pages/profile.dart';
import 'package:vegan_app/pages/app_pages/search.dart';
import 'package:vegan_app/pages/app_pages/Profile/b12_reminder_settings_page.dart';
import 'package:vegan_app/helpers/time_counter/time_counter.dart';
import 'package:vegan_app/widgets/homepage/stat_card.dart';
import 'package:vegan_app/widgets/homepage/draggable_profile_bubble.dart';
import 'package:confetti/confetti.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vegan_app/services/auth_service.dart';
import 'package:vegan_app/services/badge_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  DateTime? targetDate;
  late MotionTabBarController motionTabBarController;
  late Map<String, int> _savings;
  late Timer _timer;
  late ConfettiController _confettiController;
  final TextEditingController _dateController = TextEditingController();
  bool _hasNewPartners = false;
  late AnimationController _partnersAnimationController;
  String? _currentAvatar;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _timer = Timer.periodic(
        const Duration(minutes: 1), (Timer t) => _updateSavings());

    // Initialize with default home tab, then update based on preference
    motionTabBarController = MotionTabBarController(
      initialIndex: 1, // Default to home tab
      length: 5,
      vsync: this,
    );

    _initializeTabController();

    _savings = {};
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 6));

    _partnersAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _loadData();
    _checkNewPartners();
    _loadAvatar();
  }

  Future<void> _initializeTabController() async {
    final shouldOpenOnScanPage =
        await PreferencesHelper.getOpenOnScanPagePref();
    if (shouldOpenOnScanPage && mounted) {
      // Update to scan tab if preference is set
      setState(() {
        motionTabBarController.index = 3;
      });
    }
  }

  @override
  void dispose() {
    motionTabBarController.dispose();
    _confettiController.dispose();
    _partnersAnimationController.dispose();
    _timer.cancel();
    _dateController.dispose();
    super.dispose();
  }

  void _loadData() async {
    await loadTargetDate();
    final savings = computeSavings(targetDate);
    setState(() {
      _savings = savings;
    });

    // Check for new badges on initial load
    _checkForNewBadges();

    // Check and show B12 popup if needed
    _checkAndShowB12Popup();
  }

  void _onDateSaved(DateTime date) {
    setState(() {
      targetDate = date;
      _savings = computeSavings(targetDate);
    });
  }

  Future<void> _onLoginSuccess() async {
    // Reload target date from preferences after login
    await loadTargetDate();
    // Reload avatar after login
    await _loadAvatar();
    // Check and show B12 popup if needed after login
    _checkAndShowB12Popup();
  }

  Future<void> _checkNewPartners() async {
    final hasNew = await PreferencesHelper.hasNewPartners();
    if (mounted) {
      setState(() {
        _hasNewPartners = hasNew;
      });
    }
  }

  Future<void> _loadAvatar() async {
    if (AuthService.isLoggedIn) {
      final avatar = await PreferencesHelper.getAvatar();
      if (mounted) {
        setState(() {
          _currentAvatar = avatar;
        });
      }
    } else {
      setState(() {
        _currentAvatar = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: targetDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != targetDate) {
      setState(() {
        targetDate = picked;
        _dateController.text = DateFormat.yMMMd('fr_FR').format(targetDate!);
      });

      await PreferencesHelper.addSelectedDateToPrefs(targetDate!);
      _onDateSaved(targetDate!);
    }
  }

  Future<void> loadTargetDate() async {
    final DateTime? dateFromPrefs =
        await PreferencesHelper.getSelectedDateFromPrefs();
    setState(() {
      targetDate = dateFromPrefs;
      if (targetDate != null) {
        _dateController.text = DateFormat.yMMMd('fr_FR').format(targetDate!);
      } else {
        _dateController.clear();
      }
      _savings = computeSavings(targetDate);
    });
  }

  void _updateSavings() {
    setState(() {
      _savings = computeSavings(targetDate);
    });
  }

  Future<void> _checkForNewBadges() async {
    // Check if user is logged in and get current user
    if (AuthService.isLoggedIn && mounted) {
      final result = await AuthService.getCurrentUser();
      if (result.isSuccess && result.data != null && mounted) {
        await BadgeService.checkAndShowNewBadges(
          context,
          result.data!,
          mounted: mounted,
        );
      }
    }
  }

  Future<void> _checkAndShowB12Popup() async {
    // Only show for logged-in users who haven't seen it yet
    if (AuthService.isLoggedIn && mounted) {
      final hasBeenShown = await PreferencesHelper.hasB12PopupBeenShown();
      if (!hasBeenShown && mounted) {
        // Delay to show after page is fully loaded
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showB12ReminderPopup();
          }
        });
      }
    }
  }

  void _showB12ReminderPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '💊',
                    style: TextStyle(fontSize: 100.sp),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Rappel pour votre B12 !',
                  style: TextStyle(
                    fontSize: 56.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Vous pouvez maintenant configurer un rappel pour ne jamais oublier de prendre votre B12',
                  style: TextStyle(
                    fontSize: 42.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await PreferencesHelper.markB12PopupAsShown();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[300]!, width: 2),
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Plus tard',
                          style: TextStyle(
                            fontSize: 44.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await PreferencesHelper.markB12PopupAsShown();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const B12ReminderSettingsPage(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Configurer',
                          style: TextStyle(
                            fontSize: 44.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int animalUnit = _savings['animalUnit'] ?? 0;
    int co2Unit = _savings['co2Unit'] ?? 0;
    int waterUnit = _savings['waterUnit'] ?? 0;
    int forestUnit = _savings['forestUnit'] ?? 0;
    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              TabBarView(
                controller: motionTabBarController,
                children: [
                  const PartnersPage(),
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
                            SizedBox(height: 200.h),
                            Text(
                              "Vous êtes végane depuis",
                              style: TextStyle(
                                  fontSize: 90.sp,
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
                            bottom: 100.h,
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
                          )
                        else
                          Positioned(
                            bottom: 120.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat.yMd('fr_FR').format(targetDate!),
                                    style: TextStyle(
                                      fontSize: 50.sp,
                                      fontFamily: 'Baloo',
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(width: 20.w),
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Modifier",
                                            style: TextStyle(
                                              fontSize: 45.sp,
                                              fontFamily: 'Baloo',
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                            size: 40.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                  ScanPage(
                    onNavigateToProfile: () {
                      setState(() {
                        motionTabBarController.index = 4;
                      });
                    },
                  ),
                  ProfilePage(
                    onDateSaved: _onDateSaved,
                    onLoginSuccess: _onLoginSuccess,
                  ),
                ],
              ),
              // Draggable profile bubble. only when logged in and on home tab
              if (AuthService.isLoggedIn && motionTabBarController.index == 1)
                DraggableProfileBubble(
                  avatar: _currentAvatar,
                  onTap: () {
                    setState(() {
                      motionTabBarController.index = 4;
                    });
                  },
                ),
            ],
          ),
          bottomNavigationBar: Stack(
            children: [
              MotionTabBar(
                controller: motionTabBarController,
                labels: const [
                  "Promos",
                  "Accueil",
                  "Recherche",
                  "Scan",
                  "Profil"
                ],
                initialSelectedTab: "Accueil",
                tabIconColor: Colors.grey,
                tabSelectedColor: Theme.of(context).colorScheme.primary,
                onTabItemSelected: (int value) async {
                  setState(() {
                    motionTabBarController.index = value;
                  });
                  // Check for new badges when Accueil tab is selected
                  if (value == 1) {
                    _checkForNewBadges();
                    // Reload avatar when returning to home tab
                    _loadAvatar();
                  }
                  // Mark partners as visited when tab is selected
                  if (value == 0 && _hasNewPartners) {
                    await PreferencesHelper.markPartnersAsVisited();
                    await _checkNewPartners();
                  }
                },
                icons: const [
                  Icons.percent,
                  Icons.home,
                  Icons.search,
                  Icons.qr_code_scanner,
                  Icons.person_sharp
                ],
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              // Animated notification badge for partners tab
              if (_hasNewPartners)
                Positioned(
                  left: 100.w,
                  top: 30.h,
                  child: AnimatedBuilder(
                    animation: _partnersAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withValues(
                            alpha: 0.7 +
                                (_partnersAnimationController.value * 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(
                                alpha: 0.5 * _partnersAnimationController.value,
                              ),
                              blurRadius:
                                  8 * _partnersAnimationController.value,
                              spreadRadius:
                                  2 * _partnersAnimationController.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
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
