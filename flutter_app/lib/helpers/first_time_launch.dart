import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegan_app/pages/app_pages/home.dart';
import 'package:vegan_app/pages/first_launch/on_boarding_page.dart';

class FirstLaunchChecker extends StatelessWidget {
  const FirstLaunchChecker({super.key});

  Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('hasSeenOnboarding') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: shouldShowOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const OnboardingPage();
        } else {
          return const MyHomePage();
        }
      },
    );
  }
}
