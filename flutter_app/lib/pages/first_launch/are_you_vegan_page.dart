import 'package:flutter/material.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/helpers/shared_styles.dart';

class AreYouVeganPage extends StatelessWidget {
  const AreYouVeganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset('lib/assets/white_icon.png', width: 400, height: 400),
            Text(
              "Êtes-vous végane ?",
              style: FirstLaunchStyles.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await PreferencesHelper.addSelectedDateToPrefs(null);
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  style: FirstLaunchStyles.buttonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text('Non'),
                ),
                const SizedBox(width: 30.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/datePicker');
                  },
                  style: FirstLaunchStyles.buttonStyle,
                  child: const Text('Oui'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
