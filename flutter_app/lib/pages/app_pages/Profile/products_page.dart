import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/database_helper.dart';
import 'package:vegan_app/helpers/preference_helper.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  // This is the sent products page.
  List<String> sentCodes = [];
  List<Map<String, dynamic>> productDatas = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSentCodes();
    await _searchSentCodesInDb(sentCodes);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSentCodes() async {
    List<String> codes =
        await PreferencesHelper.getSuccessfulCodesFromPreferences();
    sentCodes = codes.reversed.toList();
  }

  Future<void> _searchSentCodesInDb(List<String> codes) async {
    final Map<String, Map<String, dynamic>> processedCodes = {};
    for (String code in codes) {
      processedCodes[code] = {
        'code': code,
        'name': 'Nom inconnu',
        'brand': 'Marque inconnue',
        'status': 'En cours',
      };
    }

    for (String code in codes) {
      final dbResult = await DatabaseHelper.instance.queryProduct(code);
      if (dbResult.isNotEmpty) {
        for (var product in dbResult) {
          var status = product['status'] == "V"
              ? "Validé"
              : product['status'] == "R"
                  ? "Refusé"
                  : product['status'] == "M"
                      ? "En attente"
                      : product['status'] == "N"
                          ? "Introuvable"
                          : "En cours";
          processedCodes[code] = {
            'code': product['code'],
            'name': product['name'] ?? 'Nom inconnu',
            'brand': product['brand'] ?? 'Marque inconnue',
            'status': status,
            'problem': product['problem'],
          };
        }
      }
    }

    if (mounted) {
      setState(() {
        productDatas = processedCodes.values.toList();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Validé':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'En attente':
        return Colors.purple;
      case 'Refusé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Vos produits identifiés (${productDatas.length})',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 50.sp,
                ),
          ),
        ),
        if (productDatas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Aucun produit pour le moment. Vous pouvez scanner des codes-barres pour en ajouter.',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          SizedBox(
            height: 0.50.sh,
            child: ListView.builder(
              itemCount: productDatas.length,
              itemBuilder: (context, index) {
                final product = productDatas[index];
                final status = product['status'];
                final brand = product['brand'];
                final reason = product['problem'];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product information section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['code'],
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product['name'],
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                brand,
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Status and reason section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40.sp,
                                ),
                              ),
                            ),
                            if (reason != null && reason.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, right: 8),
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
