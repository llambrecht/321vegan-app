import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:intl/intl.dart';
import '../app_pages/home.dart';
import '../../widgets/auth/register_form.dart';
import '../../widgets/auth/login_form.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSelectedDate();
  }

  Future<void> _loadSelectedDate() async {
    selectedDate = await PreferencesHelper.getSelectedDateFromPrefs();
    if (selectedDate != null) {
      _dateController.text = DateFormat.yMMMd('fr_FR').format(selectedDate!);
    }
    setState(() {});
  }

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyHomePage()),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMMMd('fr_FR').format(selectedDate!);
        PreferencesHelper.addSelectedDateToPrefs(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Bienvenue sur \n321 Vegan !",
          body:
              "Cette appli vous aide à facilement savoir si un produit est végane ou non. Fini de se prendre la tête devant une liste d'ingrédients incompréhensible !",
          image: Image.asset('lib/assets/app_icon.png', height: 175),
          decoration: getPageDecoration(),
        ),
        PageViewModel(
          title: "Recherchez les additifs",
          body:
              "Parmis les centaines d'additifs, vérifiez s'ils sont d'origine animale ou non. \n - Même sans connexion internet ! -",
          image: Image.asset('lib/assets/intro/additifs.gif'),
          decoration: getPageDecorationWithGif(),
        ),
        PageViewModel(
          title: "Et les cosmétiques",
          body:
              "Vérifiez les marques de cosmétiques pour être sûr·e qu'elles ne testent pas sur les animaux.",
          image: Image.asset('lib/assets/intro/cosmetics.gif'),
          decoration: getPageDecorationWithGif(),
        ),
        PageViewModel(
          title: "Scannez les produits",
          body:
              "Vérifiez directement les produits en scannant leur code-barres.",
          image: Image.asset('lib/assets/intro/scan.gif'),
          decoration: getPageDecorationWithGif(),
        ),
        PageViewModel(
          title: "Participez",
          body:
              "Si un produit n'est pas reconnu, signalez-le pour qu'il soit ajouté à la base de données.",
          image: Image.asset('lib/assets/intro/scan_unknown.gif'),
          decoration: getPageDecorationWithGif(),
        ),
        PageViewModel(
          title: "Suivez votre impact",
          body:
              "Constatez l'impact de vos choix sur l'environnement et les animaux.",
          image: Image.asset('lib/assets/intro/accueil.gif'),
          decoration: getPageDecorationWithGif(),
        ),
        PageViewModel(
          titleWidget: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Column(
              children: [
                Icon(Icons.person_add_alt_1, size: 60.sp, color: Colors.green),
                SizedBox(height: 10.h),
                Text(
                  "Créez votre compte",
                  style:
                      TextStyle(fontSize: 80.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          bodyWidget: Column(
            children: [
              SizedBox(height: 16.h),
              Text(
                "Créez un compte pour profiter de toutes les fonctionnalités de l'application",
                style: TextStyle(fontSize: 45.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Végane depuis quand ? (optionnel)",
                  style: TextStyle(fontSize: 40.sp, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Sélectionnez une date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                readOnly: true,
                onTap: _pickDate,
              ),
              SizedBox(height: 24.h),
              RegisterForm(
                onRegisterSuccess: () => _onIntroEnd(context),
                onSwitchToLogin: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Scaffold(
                        backgroundColor: Colors.white,
                        body: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(ctx).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 24,
                          ),
                          child: SingleChildScrollView(
                            child: LoginForm(
                              onLoginSuccess: () {
                                Navigator.pop(ctx);
                                _onIntroEnd(context);
                              },
                              onSwitchToRegister: () => Navigator.pop(ctx),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              // Button to pass
              TextButton.icon(
                onPressed: () => _onIntroEnd(context),
                icon: Icon(Icons.arrow_forward,
                    size: 40.sp, color: Colors.grey[500]),
                label: Text(
                  "Continuer sans compte",
                  style: TextStyle(
                    fontSize: 40.sp,
                    color: Colors.grey[500],
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          decoration: PageDecoration(
            titlePadding: EdgeInsets.zero,
            bodyAlignment: Alignment.center,
            pageColor: Colors.white,
            contentMargin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Passer"),
      next: const Icon(Icons.arrow_forward),
      showDoneButton: true,
      done: Text(
        "Passer",
        style: TextStyle(
          fontSize: 40.sp,
          color: Colors.grey[500],
        ),
      ),
      dotsDecorator: getDotsDecorator(),
      controlsMargin: EdgeInsets.only(bottom: 80.h),
      controlsPadding: const EdgeInsets.all(16),
    );
  }

  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 80.sp, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 50.sp),
        imagePadding: const EdgeInsets.all(24),
        pageColor: Colors.white,
      );

  PageDecoration getPageDecorationWithGif() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 80.sp, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 50.sp),
        imagePadding: EdgeInsets.fromLTRB(0, 0.1.sh, 0, 0),
        pageColor: Colors.white,
        imageFlex: 5,
        bodyFlex: 2,
        imageAlignment: Alignment.topCenter,
        contentMargin:
            EdgeInsets.only(top: 0.05.sh, left: 0.03.sw, right: 0.03.sw),
      );

  DotsDecorator getDotsDecorator() => const DotsDecorator(
        size: Size(5, 5),
        spacing: EdgeInsets.symmetric(horizontal: 3.0),
        activeSize: Size(14, 10),
        activeColor: Colors.green,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      );
}
