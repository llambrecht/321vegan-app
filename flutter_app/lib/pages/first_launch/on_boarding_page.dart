import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:intl/intl.dart';
import '../app_pages/home.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  DateTime? selectedDate;

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

  final TextEditingController _dateController = TextEditingController();

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
          title: "Consultez vos envois",
          body:
              "Consultez l'historique de vos produits envoyés pour suivre leur statut.",
          image: Image.asset('lib/assets/intro/profil.gif'),
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
          title: "Prêt·e ?",
          body: "Commençons maintenant ! 😁",
          footer: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Pour calculer votre impact, indiquez depuis quand vous êtes végane. Sinon, laissez vide.",
                  style: TextStyle(
                    fontSize: 40.sp,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Sélectionnez une date',
                          labelStyle: const TextStyle(color: Colors.black),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today,
                                color: Colors.black),
                            onPressed: _pickDate,
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(color: Colors.black),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        _onIntroEnd(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Continuer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          image: Image.asset('lib/assets/app_icon.png', height: 175),
          decoration: getLastPageDecoration(),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Passer"),
      next: const Icon(Icons.arrow_forward),
      showDoneButton: false,
      dotsDecorator: getDotsDecorator(),
    );
  }

  PageDecoration getPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 80.sp, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 50.sp),
        imagePadding: const EdgeInsets.all(24),
        pageColor: Colors.white,
      );

  PageDecoration getLastPageDecoration() => PageDecoration(
        titleTextStyle: TextStyle(fontSize: 80.sp, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 50.sp),
        imagePadding: const EdgeInsets.all(24),
        imageFlex: 2,
        bodyFlex: 0,
        pageColor: Colors.white,
        footerPadding: const EdgeInsets.only(top: 0),
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
