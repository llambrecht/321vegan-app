import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme summerTheme = SeasonalTheme(
  name: 'Été',
  season: Season.summer,
  primaryColor: Color(0xFF166534), // Vert vif (couleur actuelle)
  secondaryColor: Color(0xFFFCD34D), // Jaune doré
  accentColor: Color(0xFF60A5FA), // Bleu ciel
  waveColor: Color(0xFF22C55E), // Vert plus vif pour la vague
  waveAccentColor: Color(0xFF4ADE80), // Vert lumineux
  seasonalIcon: Icons.sunny, // Icône de soleil (actuelle)
  iconBackgroundColor: Color(0xFFFEF9C3), // Jaune très pâle
  particleColors: [
    Color(0xFFFCD34D), // Jaune
    Color(0xFFFCA311), // Orange vif
    Color(0xFF60A5FA), // Bleu
    Color(0xFFFBBF24), // Jaune doré
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
      Color(0xFFFEF3C7), // Jaune très pâle
      Colors.white,
    ],
  ),
);
