import 'package:upgrader/upgrader.dart';
import 'package:vegan_app/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'helpers/first_time_launch.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'helpers/theme_helper.dart';
import 'models/seasonal_theme.dart';
import 'themes/default_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.cosmeticsDatabase;
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  SeasonalTheme? _currentTheme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await ThemeHelper.getCurrentTheme();
    setState(() {
      _currentTheme = theme;
    });
  }

  Future<void> updateTheme() async {
    await _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    const appcastURL =
        'https://raw.githubusercontent.com/llambrecht/321vegan_appcast/main/appcast.xml';
    final upgrader = Upgrader(
      storeController: UpgraderStoreController(
        onAndroid: () => UpgraderAppcastStore(appcastURL: appcastURL),
        oniOS: () => UpgraderAppcastStore(appcastURL: appcastURL),
      ),
    );

    // Use default theme while loading
    final themeData =
        _currentTheme?.toThemeData() ?? defaultTheme.toThemeData();

    return ScreenUtilInit(
      designSize: const Size(1170, 2532),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.0)),
        child: MaterialApp(
          title: '321 Vegan',
          debugShowCheckedModeBanner: false,
          theme: themeData,
          home: UpgradeAlert(
            upgrader: upgrader,
            child: const FirstLaunchChecker(),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'),
          ],
        ),
      ),
    );
  }
}
