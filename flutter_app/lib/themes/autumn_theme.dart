import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme autumnTheme = SeasonalTheme(
  name: 'Automne',
  season: Season.autumn,
  primaryColor: Color(0xFFEA580C), // Orange vif
  secondaryColor: Color(0xFFA16207), // Marron doré
  accentColor: Color(0xFFDC2626), // Rouge feuille
  waveColor: Color(0xFFFB923C), // Orange plus clair pour la vague
  waveAccentColor: Color(0xFFFDE68A), // Jaune ambré
  seasonalIcon: Icons.nature, // Icône de feuille/nature
  iconBackgroundColor: Color(0xFFFEF3C7), // Beige très pâle
  particleColors: [
    Color(0xFFF97316), // Orange
    Color(0xFFDC2626), // Rouge
    Color(0xFFA16207), // Marron
    Color(0xFFFCD34D), // Jaune automnal
  ],
  confettiColors: [
    Color(0xFFF97316),
    Color(0xFFDC2626),
    Color(0xFFA16207),
    Color(0xFFFCD34D),
  ],
  particleType: ParticleType.leaves,
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF7ED), // Orange très pâle
      Colors.white,
    ],
  ),
);
