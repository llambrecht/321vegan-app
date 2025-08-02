import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/models/vegan_status.dart';
import 'package:vegan_app/pages/app_pages/Scan/product_info_helper.dart';
import 'package:vegan_app/pages/app_pages/helpers/product.helper.dart';

class HistoryModal extends StatefulWidget {
  final List<Map<String, dynamic>> scanHistory;

  const HistoryModal({
    super.key,
    required this.scanHistory,
  });

  @override
  State<HistoryModal> createState() => _HistoryModalState();
}

class _HistoryModalState extends State<HistoryModal> {
  late List<Map<String, dynamic>> _history;

  @override
  void initState() {
    super.initState();
    _history = List<Map<String, dynamic>>.from(widget.scanHistory);
  }

  Future<void> _clearHistory() async {
    await PreferencesHelper.clearScanHistory();
    setState(() {
      _history.clear();
    });
  }

  // Update history
  void _updateHistory() async {
    final newHistory = await PreferencesHelper.getScanHistory();
    setState(() {
      _history = newHistory;
    });
  }

  Future<Map<String, dynamic>> _fetchProductDetails(String barcode) async {
    return await ProductInfoHelper.getProductInfo(barcode);
  }

  // Function to check if the product is in personal database
  Future<bool> _isProductAlredySent(String barcode) async {
    final result = await PreferencesHelper.isCodeInPreferences(barcode);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A722E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 40.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(50 derniers scans)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 35.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearHistory,
                  icon: Icon(Icons.delete, color: Colors.white, size: 40.sp),
                  label: Text(
                    'Effacer',
                    style: TextStyle(
                      fontSize: 40.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _history.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      final barcode = item['barcode'];
                      final timestamp = item['timestamp'];

                      return FutureBuilder<List<dynamic>>(
                        future: Future.wait([
                          _fetchProductDetails(
                              barcode), // Fetch product details
                          _isProductAlredySent(
                              barcode), // Check if the product is already sent
                        ]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return _buildProductCard(
                              context: context,
                              name: 'Erreur',
                              brand: 'Impossible de charger le produit',
                              scannedDate: timestamp,
                              isVegan: null,
                              problem: null, // No problem for error case
                            );
                          } else {
                            final productDetails =
                                snapshot.data![0] as Map<String, dynamic>;
                            final isAlreadySent = snapshot.data![1] as bool;

                            return _buildProductCard(
                              context: context,
                              name: (productDetails['name']?.isNotEmpty ??
                                      false)
                                  ? productDetails['name']
                                  : productDetails['code'] ?? 'Produit inconnu',
                              brand:
                                  productDetails['brand'] ?? 'Marque inconnue',
                              scannedDate: timestamp,
                              isVegan: productDetails['is_vegan'],
                              problem: productDetails['problem'],
                              biodynamie: productDetails['biodynamie'],
                              alreadySent: isAlreadySent,
                            );
                          }
                        },
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 80.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Aucun historique',
                            style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Scannez des produits pour les voir apparaître dans cet historique',
                            style: TextStyle(
                              fontSize: 40.sp,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String brand,
    required String scannedDate,
    required String? isVegan,
    String? problem, // Add problem parameter
    bool biodynamie = false,
    required BuildContext context,
    bool alreadySent = false,
  }) {
    Color badgeColor;
    String badgeText;

    switch (isVegan) {
      case 'true':
        badgeColor = Colors.green;
        badgeText = 'Vegan';
        break;
      case 'false':
        badgeColor = Colors.red;
        badgeText = 'Pas Vegan';
        break;
      case 'waiting':
        badgeColor = Colors.orange;
        badgeText = 'En attente';
        break;
      case 'not_found':
        badgeColor = Colors.grey;
        badgeText = 'Introuvable';
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Inconnu';
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 0),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontSize: 40.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4.h),
                      Text(
                        brand,
                        style:
                            TextStyle(fontSize: 40.sp, color: Colors.grey[700]),
                      ),
                      if (problem != null && problem.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          problem,
                          style: TextStyle(
                              fontSize: 36.sp, color: Colors.red[700]),
                        ),
                      ],
                      SizedBox(height: 2.h),
                      Text(
                        DateTime.parse(scannedDate)
                            .toLocal()
                            .toString()
                            .split('.')[0]
                            .split(':')
                            .sublist(0, 2)
                            .join('h'),
                        style: TextStyle(fontSize: 40.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    border: Border.all(color: badgeColor),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (biodynamie)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 50.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Agriculture biodynamique',
                          style: TextStyle(
                            fontSize: 36.sp,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (badgeText == 'Inconnu')
              if (!alreadySent)
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await ProductHelper.tryAddDocument(
                                context,
                                {
                                  'code': name,
                                  'name': name,
                                },
                                VeganStatus.vegan,
                              );
                              _updateHistory();
                            },
                            icon: const Icon(Icons.check_circle,
                                color: Colors.white),
                            label: Text(
                              'Vegan',
                              style: TextStyle(
                                fontSize: 40.sp,
                                color: Colors.white, // Make text white
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await ProductHelper.tryAddDocument(
                                context,
                                {
                                  'code': name,
                                  'name': name,
                                },
                                VeganStatus.nonVegan,
                              );
                              _updateHistory();
                            },
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            label: Text(
                              'Pas Vegan',
                              style: TextStyle(
                                fontSize: 40.sp,
                                color: Colors.white, // Make text white
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else // Product already sent
                Padding(
                  padding: EdgeInsets.only(top: 16.h),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        SizedBox(width: 8.w),
                        Text(
                          'Produit déjà envoyé',
                          style: TextStyle(
                            fontSize: 40.sp,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
