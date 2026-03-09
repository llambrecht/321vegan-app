import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/seasonal_theme.dart';

SeasonalTheme summerTheme = SeasonalTheme(
  name: 'Été',
  season: Season.summer,
  primaryColor: const Color.fromARGB(255, 228, 176, 8),
  secondaryColor: const Color(0xFF166534),
  accentColor: const Color(0xFF60A5FA),
  waveColor: const Color.fromARGB(255, 228, 176, 8),
  seasonalIcon: Icons.sunny,
  iconBackgroundColor: const Color(0xFFFEF9C3),
  particleColors: [
    const Color(0xFFFCD34D),
    const Color(0xFFFCA311),
    const Color(0xFF60A5FA),
    const Color(0xFFFBBF24),
  ],
  confettiColors: [
    const Color(0xFFFCD34D),
    const Color(0xFF60A5FA),
    const Color(0xFF22C55E),
    const Color(0xFFFCA311),
  ],
  particleType: ParticleType.sunRays,
  backgroundGradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFEF3C7),
      Colors.white,
    ],
  ),
  iconTopPosition: -700.h,
  iconLeftPosition: 100.w,
);
