import '../models/brand_score.dart';

class BrandScoreService {
  // Dummy data for demonstration purposes
  // TODO: Replace with actual API call when ready
  static final Map<String, BrandScore> _dummyBrandScores = {
    'bjorg': const BrandScore(
      brandName: 'Bjorg',
      veganismScore: CategoryScore(
        name: 'Véganisme, animaux & impact humains',
        score: ScoreLevel.good,
        description: 'Bons engagements',
        details: [
          'Marque à grande majorité végétale',
          'Aucun test sur les animaux',
          'Partenariats avec des organisations de protection animale',
          'Transparence sur les ingrédients',
        ],
      ),
      environmentalScore: CategoryScore(
        name: 'Impact environnemental',
        score: ScoreLevel.good,
        description: 'Bonne performance environnementale',
        details: [
          'Efforts sur la réduction des émissions de CO2',
          'Utilisation d\'énergies renouvelables',
          'Travail sur le packaging recyclable',
          'Produits bio',
        ],
      ),
      socialScore: CategoryScore(
        name: 'Impact social et économique',
        score: ScoreLevel.moderate,
        description: 'Impact social modéré',
        details: [
          'Conditions de travail correctes',
          'Partenariats avec des agriculteurs locaux',
          'Filliale de Ecotone',
          'Prix accessible pour les consommateurs',
        ],
      ),
      overallScore: ScoreLevel.good,
      additionalInfo:
          'Bjorg est une marque pionnière dans les alternatives végétales',
    ),
  };

  static BrandScore? getBrandScore(String brandName) {
    final normalizedBrand = brandName.toLowerCase().trim();

    // Try exact match first
    if (_dummyBrandScores.containsKey(normalizedBrand)) {
      return _dummyBrandScores[normalizedBrand];
    }

    return null;
  }

  static Future<BrandScore?> fetchBrandScore(String brandName) async {
    // TODO: Implement actual API call
    // For now, simulate network delay and return dummy data
    await Future.delayed(const Duration(milliseconds: 500));
    return getBrandScore(brandName);
  }

  static bool hasBrandScore(String brandName) {
    return getBrandScore(brandName) != null;
  }
}
