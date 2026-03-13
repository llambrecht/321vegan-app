import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/seasonal_theme.dart';

SeasonalTheme winterTheme = SeasonalTheme(
  name: 'Hiver',
  season: Season.winter,
  primaryColor: const Color(0xFF0284C7),
  secondaryColor: const Color(0xFF64748B),
  accentColor: const Color(0xFF06B6D4),
  waveColor: const Color(0xFF38BDF8),
  seasonalIcon: Icons.ac_unit,
  iconBackgroundColor: const Color(0xFFF0F9FF),
  confettiColors: [
    const Color(0xFFE0F2FE),
    const Color(0xFFFFFFFF),
    const Color(0xFF38BDF8),
    const Color(0xFFBAE6FD),
  ],
  particleType: ParticleType.snowflakes,
  backgroundGradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F9FF),
      Colors.white,
    ],
  ),
  iconTopPosition: -200.h,
  iconLeftPosition: -100.w,
);
