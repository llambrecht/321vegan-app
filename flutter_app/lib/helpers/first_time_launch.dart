import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegan_app/pages/app_pages/home.dart';
import 'package:vegan_app/pages/first_launch/are_you_vegan_page.dart';

class FirstLaunchChecker extends StatefulWidget {
  const FirstLaunchChecker({super.key});

  @override
  FirstLaunchCheckerState createState() => FirstLaunchCheckerState();
}

class FirstLaunchCheckerState extends State<FirstLaunchChecker> {
  bool _firstLaunch = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('firstLaunch') ?? true;
    if (isFirstLaunch) {
      await prefs.setBool('firstLaunch', false);
      setState(() {
        _firstLaunch = true;
        _loading = false;
      });
    } else {
      setState(() {
        _firstLaunch = false;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Show a loading indicator while checking
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_firstLaunch) {
      return const AreYouVeganPage();
    } else {
      return const MyHomePage();
    }
  }
}
