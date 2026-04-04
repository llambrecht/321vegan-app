class ProductScores {
  /// Nutriscore grade: 'a'–'e', or null if unavailable.
  final String? nutriscoreGrade;

  /// Green-score grade: 'a-plus', 'a'–'f', or null if unavailable.
  final String? ecoscoreGrade;

  const ProductScores({
    this.nutriscoreGrade,
    this.ecoscoreGrade,
  });

  factory ProductScores.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) return const ProductScores();

    final nutriscore = product['nutriscore_grade'] as String?;
    final ecoscore = product['ecoscore_grade'] as String?;

    return ProductScores(
      nutriscoreGrade: _normalizeNutriscore(nutriscore),
      ecoscoreGrade: _normalizeEcoscore(ecoscore),
    );
  }

  static const _nutriscoreGrades = {'a', 'b', 'c', 'd', 'e'};

  // Green-score® has 7 levels: A+, A, B, C, D, E, F
  static const _ecoscoreGrades = {'a-plus', 'a', 'b', 'c', 'd', 'e', 'f'};

  static String? _normalizeNutriscore(String? raw) {
    if (raw == null) return null;
    final grade = raw.toLowerCase().trim();
    return _nutriscoreGrades.contains(grade) ? grade : null;
  }

  static String? _normalizeEcoscore(String? raw) {
    if (raw == null) return null;
    final grade = raw.toLowerCase().trim();
    return _ecoscoreGrades.contains(grade) ? grade : null;
  }

  bool get hasNutriscore => nutriscoreGrade != null;
  bool get hasEcoscore => ecoscoreGrade != null;
}
