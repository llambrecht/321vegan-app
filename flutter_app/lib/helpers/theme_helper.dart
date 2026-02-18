import 'package:shared_preferences/shared_preferences.dart';
import '../models/seasonal_theme.dart';
import '../themes/default_theme.dart';
import '../themes/spring_theme.dart';
import '../themes/summer_theme.dart';
import '../themes/autumn_theme.dart';
import '../themes/winter_theme.dart';

class ThemeHelper {
  static const String _themePreferenceKey = 'selected_theme';
  static const String _autoThemeKey = 'auto_theme';

  // Get all available themes
  static List<SeasonalTheme> getAllThemes() {
    return [
      defaultTheme,
      springTheme,
      summerTheme,
      autumnTheme,
      winterTheme,
    ];
  }

  // Detect current season based on date
  // TODO : Better season detect (days of season, not just month)
  static Season getCurrentSeason() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    if (month >= 3 && month <= 5) {
      return Season.spring;
    } else if (month >= 6 && month <= 8) {
      return Season.summer;
    } else if (month >= 9 && month <= 11) {
      return Season.autumn;
    } else {
      return Season.winter;
    }
  }

  // Get theme by season
  static SeasonalTheme getThemeBySeason(Season season) {
    switch (season) {
      case Season.defaultTheme:
        return defaultTheme;
      case Season.spring:
        return springTheme;
      case Season.summer:
        return summerTheme;
      case Season.autumn:
        return autumnTheme;
      case Season.winter:
        return winterTheme;
    }
  }

  // Save theme preference
  static Future<void> saveThemePreference(Season? season) async {
    final prefs = await SharedPreferences.getInstance();
    if (season == null) {
      await prefs.remove(_themePreferenceKey);
    } else {
      await prefs.setString(_themePreferenceKey, season.name);
    }
  }

  // Save auto theme preference
  static Future<void> saveAutoThemePreference(bool isAuto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoThemeKey, isAuto);
  }

  // Check if auto theme is enabled
  static Future<bool> isAutoThemeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoThemeKey) ??
        false; // Default to false (manual with default theme)
  }

  // Get saved theme preference
  static Future<Season?> getSavedThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final seasonName = prefs.getString(_themePreferenceKey);
    if (seasonName == null) return null;

    try {
      return Season.values.firstWhere((s) => s.name == seasonName);
    } catch (e) {
      return null;
    }
  }

  // Get current active theme
  static Future<SeasonalTheme> getCurrentTheme() async {
    final isAuto = await isAutoThemeEnabled();

    if (isAuto) {
      // Use season-based theme
      final season = getCurrentSeason();
      return getThemeBySeason(season);
    } else {
      // Use user's saved preference
      final savedSeason = await getSavedThemePreference();
      if (savedSeason != null) {
        return getThemeBySeason(savedSeason);
      } else {
        // Fallback to default theme
        return defaultTheme;
      }
    }
  }

  // Get theme name for display
  static String getThemeDisplayName(Season season) {
    switch (season) {
      case Season.defaultTheme:
        return 'Défaut';
      case Season.spring:
        return 'Printemps';
      case Season.summer:
        return 'Été';
      case Season.autumn:
        return 'Automne';
      case Season.winter:
        return 'Hiver';
    }
  }
}
