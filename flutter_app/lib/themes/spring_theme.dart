import 'package:flutter/material.dart';
import '../models/seasonal_theme.dart';

const SeasonalTheme springTheme = SeasonalTheme(
  name: 'Printemps',
  season: Season.spring,
  primaryColor: Color(0xFF34D399), // Vert clair vif
  secondaryColor: Color(0xFFFDA4AF), // Rose pâle
  accentColor: Color(0xFFFDE047), // Jaune tendre
  waveColor: Color(0xFF86EFAC), // Vert plus clair pour la vague
  waveAccentColor: Color(0xFFD9F99D), // Vert lime très clair
  seasonalIcon: Icons.local_florist, // Icône de fleur
  iconBackgroundColor: Color(0xFFFEF3C7), // Jaune très pâle
  particleColors: [
    Color(0xFFFDA4AF), // Rose
    Color(0xFFFDE047), // Jaune
    Color(0xFFDDD6FE), // Lavande
    Color(0xFFBFDBFE), // Bleu clair
  ],
  confettiColors: [
    Color(0xFFFDA4AF),
    Color(0xFFFDE047),
    Color(0xFF86EFAC),
    Color(0xFFDDD6FE),
  ],
  particleType: ParticleType.petals,
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFECFDF5), // Vert très pâle
      Colors.white,
    ],
  ),
);
