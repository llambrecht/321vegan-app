class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final BadgeType type;
  final int requirement;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.requirement,
  });

  // Check if the badge is unlocked based on user data
  bool isUnlocked({
    required int productsSent,
    required DateTime? veganSince,
  }) {
    switch (type) {
      case BadgeType.productsSent:
        return productsSent >= requirement;
      case BadgeType.veganYears:
        if (veganSince == null) return false;
        final years = DateTime.now().difference(veganSince).inDays ~/ 365;
        return years >= requirement;
    }
  }

  String getRequirementText() {
    switch (type) {
      case BadgeType.productsSent:
        if (requirement == 1) {
          return 'Envoyer votre premier produit';
        }
        return 'Envoyer $requirement produits';
      case BadgeType.veganYears:
        if (requirement == 1) {
          return 'Être vegan depuis 1 an';
        }
        return 'Être vegan depuis $requirement ans';
    }
  }
}

enum BadgeType {
  productsSent,
  veganYears,
}

// Predefined badges
class Badges {
  // Using partner logos as temporary badge icons
  static const List<Badge> all = [
    // Vegan years badges
    Badge(
      id: 'vegan_1_year',
      name: '1 an vegan',
      description: 'Vegan depuis 1 an',
      iconPath: 'lib/assets/partners/logo-maisonprot.png',
      type: BadgeType.veganYears,
      requirement: 1,
    ),
    Badge(
      id: 'vegan_2_years',
      name: '2 ans vegan',
      description: 'Vegan depuis 2 ans',
      iconPath: 'lib/assets/partners/logo-zebra.png',
      type: BadgeType.veganYears,
      requirement: 2,
    ),
    Badge(
      id: 'vegan_5_years',
      name: '5 ans vegan',
      description: 'Vegan depuis 5 ans',
      iconPath: 'lib/assets/partners/logo-comme-avant.png',
      type: BadgeType.veganYears,
      requirement: 5,
    ),
    Badge(
      id: 'vegan_10_years',
      name: '10 ans vegan',
      description: 'Vegan depuis 10 ans',
      iconPath: 'lib/assets/partners/logo-petit-veganne.png',
      type: BadgeType.veganYears,
      requirement: 10,
    ),

    // Products sent badges
    Badge(
      id: 'first_product',
      name: 'Premier pas',
      description: 'Premier produit envoyé',
      iconPath: 'lib/assets/partners/logo-comme-avant.png',
      type: BadgeType.productsSent,
      requirement: 1,
    ),
    Badge(
      id: 'products_10',
      name: 'Débutant·e',
      description: '10 produits envoyés',
      iconPath: 'lib/assets/partners/logo-petit-veganne.png',
      type: BadgeType.productsSent,
      requirement: 10,
    ),
    Badge(
      id: 'products_50',
      name: 'Actif·ve',
      description: '50 produits envoyés',
      iconPath: 'lib/assets/partners/logo-maisonprot.png',
      type: BadgeType.productsSent,
      requirement: 50,
    ),
    Badge(
      id: 'products_100',
      name: 'Expert·e',
      description: '100 produits envoyés',
      iconPath: 'lib/assets/partners/logo-zebra.png',
      type: BadgeType.productsSent,
      requirement: 100,
    ),
    Badge(
      id: 'products_500',
      name: 'Ancien·ne',
      description: '500 produits envoyés',
      iconPath: 'lib/assets/partners/logo-comme-avant.png',
      type: BadgeType.productsSent,
      requirement: 500,
    ),
    Badge(
      id: 'products_1000',
      name: 'Légende',
      description: '1000 produits envoyés',
      iconPath: 'lib/assets/partners/logo-petit-veganne.png',
      type: BadgeType.productsSent,
      requirement: 1000,
    ),
  ];
}
