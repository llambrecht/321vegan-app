import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme winterTheme = SeasonalTheme(
  name: 'Hiver',
  season: Season.winter,
  primaryColor: Color(0xFF0284C7), // Bleu glacier
  secondaryColor: Color(0xFF64748B), // Gris argenté
  accentColor: Color(0xFF06B6D4), // Cyan clair
  waveColor: Color(0xFF38BDF8), // Bleu ciel pour la vague
  waveAccentColor: Color(0xFFBAE6FD), // Bleu très clair
  seasonalIcon: Icons.ac_unit, // Icône de flocon
  iconBackgroundColor: Color(0xFFF0F9FF), // Bleu glacé très pâle
  particleColors: [
    Color(0xFFE0F2FE), // Bleu très pâle
    Color(0xFFFFFFFF), // Blanc
    Color(0xFFDEEFFD), // Bleu glacier
    Color(0xFFF0F9FF), // Bleu glacé
  ],
  confettiColors: [
    Color(0xFFE0F2FE),
    Color(0xFFFFFFFF),
    Color(0xFF38BDF8),
    Color(0xFFBAE6FD),
  ],
  particleType: ParticleType.snowflakes,
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F9FF), // Bleu glacé très pâle
      Colors.white,
    ],
  ),
);
