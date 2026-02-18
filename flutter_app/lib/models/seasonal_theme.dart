import 'package:flutter/material.dart';

enum Season {
  defaultTheme,
  spring,
  summer,
  autumn,
  winter,
}

enum ParticleType {
  petals,
  sunRays,
  leaves,
  snowflakes,
}

class SeasonalTheme {
  final String name;
  final Season season;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color waveColor;
  final Color waveAccentColor;
  final IconData seasonalIcon;
  final List<Color> particleColors;
  final List<Color> confettiColors;
  final ParticleType particleType;
  final Color iconBackgroundColor;
  final LinearGradient? backgroundGradient;

  const SeasonalTheme({
    required this.name,
    required this.season,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.waveColor,
    required this.waveAccentColor,
    required this.seasonalIcon,
    required this.particleColors,
    required this.confettiColors,
    required this.particleType,
    required this.iconBackgroundColor,
    this.backgroundGradient,
  });

  // Create a ColorScheme from this theme
  ColorScheme toColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      brightness: Brightness.light,
    );
  }

  // Create a ThemeData from this theme
  ThemeData toThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: toColorScheme(),
      useMaterial3: true,
      primaryColor: primaryColor,
    );
  }
}
