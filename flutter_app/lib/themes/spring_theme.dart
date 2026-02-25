import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/seasonal_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

SeasonalTheme springTheme = SeasonalTheme(
  name: 'Printemps',
  season: Season.spring,
  primaryColor: const Color(0xFFBA5A86),
  secondaryColor: const Color(0xFFFDA4AF),
  accentColor: const Color(0xFFFDE047),
  waveColor: const Color.fromARGB(255, 234, 115, 168),
  seasonalIcon: FontAwesomeIcons.dove,
  iconBackgroundColor: const Color(0xFFFEF3C7),
  particleColors: [
    const Color(0xFFFDA4AF),
    const Color(0xFFFDE047),
    const Color(0xFFDDD6FE),
    const Color(0xFFBFDBFE),
  ],
  confettiColors: [
    const Color(0xFFFDA4AF),
    const Color(0xFFFDE047),
    const Color(0xFF86EFAC),
    const Color(0xFFDDD6FE),
  ],
  particleType: ParticleType.petals,
  iconTopPosition: -400.h,
  iconLeftPosition: -100.w,
  backgroundGradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFECFDF5),
      Colors.white,
    ],
  ),
);
