import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme defaultTheme = SeasonalTheme(
  name: 'Défaut',
  season: Season.defaultTheme,
  primaryColor: Color(0xFF166534),
  secondaryColor: Color(0xFF22C55E),
  accentColor: Color(0xFF86EFAC),
  waveColor: Color(0xFF166534),
  seasonalIcon: Icons.sunny,
  iconBackgroundColor: Color(0xFFF0FDF4),
  particleColors: [
    Color(0xFF22C55E),
    Color(0xFF86EFAC),
    Color(0xFF4ADE80),
    Color(0xFFBBF7D0),
  ],
  confettiColors: [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ],
  particleType: ParticleType.sunRays,
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0FDF4),
      Colors.white,
    ],
  ),
);
