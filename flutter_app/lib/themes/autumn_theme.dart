import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/seasonal_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

SeasonalTheme autumnTheme = SeasonalTheme(
  name: 'Automne',
  season: Season.autumn,
  primaryColor: const Color(0xFFEA580C),
  secondaryColor: const Color(0xFFA16207),
  accentColor: const Color(0xFFDC2626),
  waveColor: const Color(0xFFFB923C),
  seasonalIcon: FontAwesomeIcons.canadianMapleLeaf,
  iconBackgroundColor: const Color(0xFFFEF3C7),
  confettiColors: [
    const Color(0xFFF97316),
    const Color(0xFFDC2626),
    const Color(0xFFA16207),
    const Color(0xFFFCD34D),
  ],
  particleType: ParticleType.leaves,
  seasonalAsset: 'lib/assets/images/pumpkin.webp',
  snowGlobeParticleIcon: FontAwesomeIcons.canadianMapleLeaf,
  backgroundGradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF7ED),
      Colors.white,
    ],
  ),
  iconTopPosition: -500.h,
  iconLeftPosition: -50.w,
);
