import 'package:flutter/material.dart';

enum ScoreLevel {
  excellent(5, Color(0xFF4CAF50), 'Excellent'),
  good(4, Color(0xFF8BC34A), 'Bon'),
  moderate(3, Color(0xFFFFC107), 'Modéré'),
  poor(2, Color(0xFFFF9800), 'Mauvais'),
  veryPoor(1, Color(0xFFE53935), 'Très mauvais');

  const ScoreLevel(this.value, this.color, this.label);

  final int value;
  final Color color;
  final String label;

  static ScoreLevel fromValue(int value) {
    return ScoreLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => ScoreLevel.moderate,
    );
  }
}

class CategoryScore {
  final String name;
  final ScoreLevel score;
  final String description;
  final List<String> details;

  const CategoryScore({
    required this.name,
    required this.score,
    required this.description,
    required this.details,
  });
}

class BrandScore {
  final String brandName;
  final CategoryScore veganismScore;
  final CategoryScore environmentalScore;
  final CategoryScore socialScore;
  final ScoreLevel overallScore;
  final String? additionalInfo;

  const BrandScore({
    required this.brandName,
    required this.veganismScore,
    required this.environmentalScore,
    required this.socialScore,
    required this.overallScore,
    this.additionalInfo,
  });

  // Calculate overall score based on individual categories
  static ScoreLevel calculateOverallScore(List<ScoreLevel> scores) {
    double average =
        scores.map((s) => s.value).reduce((a, b) => a + b) / scores.length;
    return ScoreLevel.fromValue(average.round());
  }
}
