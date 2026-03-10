import 'package:upgrader/upgrader.dart';
import 'package:vegan_app/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'helpers/first_time_launch.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/b12_reminder_service.dart';
import 'services/notification_service.dart';
import 'services/products_of_interest_cache.dart';
import 'models/b12_reminder_settings.dart';

/// Global navigator key for showing dialogs from notification handlers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DatabaseHelper.instance.database;
  await DatabaseHelper.instance.cosmeticsDatabase;
  await AuthService.init();
  await NotificationService().initialize();
  await _migrateBiweeklyReminderIfNeeded();

  // Pre-load products of interest cache at app startup (when likely to have internet)
  ProductsOfInterestCache.initializeAtStartup();

  runApp(const MyApp());
}

/// One-time migration: cancel the old daily-repeating biweekly notification
/// (scheduled with matchDateTimeComponents: time) and replace it with a
/// correct one-shot notification.
Future<void> _migrateBiweeklyReminderIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('biweekly_migration_v1') == true) return;

  final settings = await B12ReminderService.getSettings();
  if (settings.enabled && settings.frequency == ReminderFrequency.biweekly) {
    await B12ReminderService.scheduleReminder(settings);
  }

  await prefs.setBool('biweekly_migration_v1', true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    return ScreenUtilInit(
      designSize: const Size(1170, 2532),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.0)),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: '321 Vegan',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF166534)),
            useMaterial3: true,
          ),
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
