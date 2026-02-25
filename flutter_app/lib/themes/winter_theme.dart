import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme winterTheme = SeasonalTheme(
  name: 'Hiver',
  season: Season.winter,
  primaryColor: Color(0xFF0284C7),
  secondaryColor: Color(0xFF64748B),
  accentColor: Color(0xFF06B6D4),
  waveColor: Color(0xFF38BDF8),
  seasonalIcon: Icons.ac_unit,
  iconBackgroundColor: Color(0xFFF0F9FF),
  particleColors: [
    Color(0xFFE0F2FE),
    Color(0xFFFFFFFF),
    Color(0xFFDEEFFD),
    Color(0xFFF0F9FF),
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
      Color(0xFFF0F9FF),
      Colors.white,
    ],
  ),
);
