import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/helper.dart';
import 'package:vegan_app/widgets/scaner/info_modal.dart';

class VeganProductInfoCard extends StatelessWidget {
  final Map<dynamic, dynamic>? productInfo;

  const VeganProductInfoCard({
    super.key,
    required this.productInfo,
  });

  // This is a temporary solution to check if the product is on the BDS list.
  // Todo : Find a better solution; like using a json file with more infos for each manufacturer or a database ?
  static const List<String> bdsBrands = [
    // ==== Mars Group ====
    'mars',
    'dove',
    'bounty',
    'ben\'s original',
    'ben\'s',
    'skittles',
    'm&m\'s',
    'snickers',
    'ebly',
    'suzi wan',
    'marmite',
    // ==== Carrefour Group ====
    'carrefour',
    'reflets de france',
    'tex',
    'grand jury',

    // ==== Coca-Cola Company ====
    'coca-cola',
    'coca cola',
    'fanta',
    'sprite',
    'tropico',
    'minute maid',
    'powerade',
    'monster',
    'fuze tea',
    'fuzetea',
    'innocent',
    'vitaminwater',

    // ==== PepsiCo ====
    'pepsico',
    'pepsi',
    'sabra',
    'lays',
    'lay\'s',
    'quaker',
    'doritos',
    'bénénuts',
    'benenuts',
    'rockstar',
    'montain dew',
    '7up',
    'tropicana',
    'lipton',
    'quaker',

    // ==== Nestlé ====
    'nestlé',
    'nestle',
    'maizena',
    'maïzena',
    'marmite',
    'garden gourmet',
    'maggi',
    'nescafé',
    'nesquick',
    'nesquik',
    'perrier',
    'vitel',
    'san pellegrino',

    // ==== Unilever ====
    'unilever',
    'knorr',
    'maille',
    'lipton',
    'amora',
    'hellmann\'s',
    'hellmanns',
    'ben & jerry\'s',
    'ben & jerrys',
    'ben&jerry\'s',
    'elephant',
    'éléphant',
    'eléphant',

    // ==== L'Oréal ====
    'l\'oréal',
    'l\'oreal',
    'loréal',
    'loreal',
    'garnier',

    // ==== Walmart Group ====
    'walmart',

    // ==== Tesco ====
    'tesco',

    // ==== Lidl (and sub-brands) ====
    'lidl',
    'snack day',
    'freshona',
    'favorina',
    'deluxe',
    'cien',
    'solevita',
    'sondey',
    'vemondo',
    'crownfield',

    // ==== Mondelez ====
    'mondelez',
    'oreo',
    'belvita',
    'cote d\'or',
    'côte d\'or',
    'lu',
    'belin',
    'heudebert',
    'poulain',
    'sour patch',

    // ==== Danone ====
    'danone',
    'materne',
    'alpro',
    'volvic',
    'evian',
    'bledina',

    // ==== Others ====
    'starbucks',
    'la grande épicerie paris',
    'osem',
    'ahava',
    'sodastream',
    'oatly',
    'old el paso',
    'redefine meat',
  ];

  bool isOnBDSList() {
    final brand = productInfo?['brand'];
    if (brand != null && brand is String) {
      final brandList =
          brand.split(',').map((e) => e.trim().toLowerCase()).toList();

      return brandList.any((brand) => bdsBrands.contains(brand.toLowerCase()));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool isBDS = isOnBDSList();

    return Container(
      height: 700.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.green,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Helper.truncate(
                (productInfo?['name']?.isNotEmpty ?? false)
                    ? productInfo!['name']
                    : 'Unnamed Product',
                45,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  (() {
                    final brand = productInfo?['brand'];
                    if (brand != null && brand is String && brand.isNotEmpty) {
                      String formattedBrand =
                          '${brand[0].toUpperCase()}${brand.substring(1)}';
                      if (formattedBrand.length > 30) {
                        formattedBrand =
                            '${formattedBrand.substring(0, 30)}...';
                      }
                      return formattedBrand;
                    }
                    return 'Marque inconnue';
                  })(),
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (productInfo?['biodynamie'] != true)
                  TweenAnimationBuilder<double>(
                    key: ValueKey(productInfo?[
                        'name']), // Use a unique key for each product
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.8, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          "Vegan !",
                          style: TextStyle(
                            fontSize: 80.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    },
                  ),

                if (isBDS) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const InfoModal(
                          title: 'Boycott',
                          description:
                              "Les produits notés 'Boycott' sont des produits de marques qui ont des actions néfastes pour l'environnement, la santé, le droits des animaux ou les droits humains. Sont indiqués notamments les produits de marques soutenant le génocide du peuple palestinien. Nous vous encourageons à boycotter ces marques pour soutenir des pratiques éthiques et responsables.",
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '🚫 Boycott',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                // If its biodynamie
                if (!isBDS && productInfo?['biodynamie'] == true) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const InfoModal(
                          title: 'Biodynamie',
                          description:
                              "La biodynamie est une méthode agricole qui utilise des préparations d’origine animale, telles que des cornes de vache ou des organes d’animaux, dans ses pratiques de culture. Cette approche est issue de l’anthroposophie, un courant ésotérique aux dérives parfois considérées comme sectaires. En raison de l’utilisation d’éléments animaux et de son ancrage idéologique, nous ne considérons pas les produits issus de la biodynamie comme compatibles avec les principes du véganisme.",
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🚫 Biodynamie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 60.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
