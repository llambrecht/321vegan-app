import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme summerTheme = SeasonalTheme(
  name: 'Été',
  season: Season.summer,
  primaryColor: Color(0xFF166534),
  secondaryColor: Color(0xFFFCD34D),
  accentColor: Color(0xFF60A5FA),
  waveColor: Color(0xFF22C55E),
  seasonalIcon: Icons.sunny,
  iconBackgroundColor: Color(0xFFFEF9C3),
  particleColors: [
    Color(0xFFFCD34D),
    Color(0xFFFCA311),
    Color(0xFF60A5FA),
    Color(0xFFFBBF24),
  ],
  confettiColors: [
    Color(0xFFFCD34D),
    Color(0xFF60A5FA),
    Color(0xFF22C55E),
    Color(0xFFFCA311),
  ],
  particleType: ParticleType.sunRays,
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFEF3C7),
      Colors.white,
    ],
  ),
);
