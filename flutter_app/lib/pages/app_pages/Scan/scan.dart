import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/pages/app_pages/Scan/history_modal.dart';
import 'package:vegan_app/pages/app_pages/Scan/sent_products_modal.dart';
import 'package:vegan_app/pages/app_pages/Scan/settings_modal.dart';
import 'package:vegan_app/pages/app_pages/Scan/product_info_helper.dart';
import 'package:vegan_app/widgets/scaner/card_product.dart';
import 'package:vegan_app/widgets/scaner/pending_product_info_card.dart';
import 'package:vegan_app/widgets/scaner/report_error_button.dart';
import 'package:vegan_app/widgets/scaner/vegan_product_info_card.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  ScanPageState createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.ean13, // EAN-13 for international products
      BarcodeFormat.ean8, // EAN-8 for smaller packages
      BarcodeFormat.upcA, // UPC-A for US and Canadian products
      BarcodeFormat.upcE, // UPC-E for compressed barcodes
    ],
  );
  StreamSubscription<BarcodeCapture>? _subscription;
  Map<dynamic, dynamic>? productInfo;
  List<Map<String, dynamic>> scanHistory = [];
  String? _lastScannedBarcode = '';
  String? _pendingBarcode;
  int _barcodeStabilityCount = 0;
  late ConfettiController _confettiController;
  final nonVeganCardKey = GlobalKey<NonVeganProductInfoCardState>();
  bool _openOnScanPage = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _subscription?.cancel();
        _subscription = null;
        controller.stop();
        break;
      case AppLifecycleState.resumed:
        _subscription?.cancel();
        _subscription = controller.barcodes.listen(_handleBarcode);
        controller.start();
        break;
      case AppLifecycleState.inactive:
        _subscription?.cancel();
        _subscription = null;
        controller.stop();
        break;
    }
  }

  @override
  void initState() {
    controller.stop();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _loadScanHistory();
    _loadOpenOnScanPagePref();

    controller.start();
  }

  Future<void> _loadScanHistory() async {
    final history = await PreferencesHelper.getScanHistory();
    setState(() {
      scanHistory = history;
    });
  }

  Future<void> _loadOpenOnScanPagePref() async {
    final value = await PreferencesHelper.getOpenOnScanPagePref();
    setState(() {
      _openOnScanPage = value;
    });
  }

  void _showSettingsModal() {
    controller.stop(); // Stop the scanner when opening the modal
    setState(() {
      productInfo = null;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SettingsModal(
            initialOpenOnScanPage: _openOnScanPage,
            onOpenOnScanPageChanged: (value) {
              setState(() {
                _openOnScanPage = value;
              });
            },
          ),
        );
      },
    ).then((_) {
      controller.start(); // Restart the scanner when the modal is closed
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkVeganStatusOffline(String barcode) async {
    final product = await ProductInfoHelper.getProductInfo(barcode);
    setState(() {
      productInfo = product;
    });
  }

  bool isValidEAN13(String barcode) {
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcode[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }
    int checksum = (10 - (sum % 10)) % 10;
    return checksum == int.parse(barcode[12]);
  }

  void _handleBarcode(BarcodeCapture event) {
    final barcode = event.barcodes.first;
    var barcodeValue = barcode.rawValue;
    // If there is 12 digits, add a 0 at the beginning
    // This is a workaround for EAN-13 barcodes that are sometimes scanned as 12 digits by the scan module
    // This happens when the barcode starts with 0
    if (barcodeValue != null && barcodeValue.length == 12) {
      barcodeValue = '0$barcodeValue';
    }
    if (barcodeValue != _pendingBarcode) {
      _pendingBarcode = barcodeValue;
      _barcodeStabilityCount = 1;
      return;
    }

    // We want to make sure the barcode is stable before processing it
    // So we wait for 2 consecutive scans of the same barcode
    _barcodeStabilityCount++;
    if (_barcodeStabilityCount < 3) return;

    // The barcode is stable, so we can process it
    _barcodeStabilityCount = 0;
    _pendingBarcode = null;

    if (barcodeValue != null && barcodeValue.length == 13) {
      if (!isValidEAN13(barcodeValue)) {
        return;
      }
    }

    if (barcodeValue != null && _lastScannedBarcode != barcodeValue) {
      _lastScannedBarcode = barcodeValue;

      // Reset the button disabled state in NonVeganProductInfoCardState
      nonVeganCardKey.currentState?.resetButton();

      PreferencesHelper.addBarcodeToHistory(barcodeValue.toString()).then((_) {
        // Reload the history after adding the barcode
        _loadScanHistory();
      });

      setState(() {
        productInfo = null; // Reset product info for the new scan
      });
      _checkVeganStatusOffline(barcodeValue.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: SizedBox(
                  height: 0.55.sh,
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (BarcodeCapture capture) {
                      _handleBarcode(capture);
                    },
                  ),
                ),
              ),
            ],
          ),
          // Add the floating button for scan history
          Positioned(
            top: 0.36.sh,
            left: 20,
            child: SizedBox(
              width: 0.20.sw,
              height: 0.05.sh,
              child: FloatingActionButton(
                onPressed: () {
                  // TODO : It seems that the scanner is not completely stopped when the modal is opened (TO FIX)
                  controller.stop(); // Stop the scanner when opening the modal
                  setState(() {
                    productInfo = null;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 0.70.sh,
                                child: HistoryModal(
                                  scanHistory: scanHistory,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).then((_) {
                    controller
                        .start(); // Restart the scanner when the modal is closed
                  });
                },
                backgroundColor: const Color(0xFF1A722E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Historique",
                      style: TextStyle(color: Colors.white, fontSize: 30.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Add the floating button for sent products
          Positioned(
            top: 0.36.sh,
            right: 20,
            child: SizedBox(
              width: 0.20.sw,
              height: 0.05.sh,
              child: FloatingActionButton(
                onPressed: () {
                  // Stop the scanner when opening the modal
                  controller.stop();
                  setState(() {
                    productInfo = null;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 0.70.sh,
                                child: const SentProductsModal(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).then((_) {
                    controller
                        .start(); // Restart the scanner when the modal is closed
                  });
                },
                backgroundColor: const Color(0xFF1A722E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.switch_access_shortcut_add_outlined,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Mes envois",
                      style: TextStyle(color: Colors.white, fontSize: 30.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Result card with bottom margin
          if (productInfo != null)
            Positioned(
              top: 1100.h,
              left: 16,
              right: 16,
              child: productInfo?['is_vegan'] == 'true'
                  ? VeganProductInfoCard(productInfo: productInfo)
                  : (productInfo?['is_vegan'] == 'waiting')
                      ? PendingProductInfoCard(productInfo: productInfo)
                      : productInfo?['is_vegan'] == 'already_scanned'
                          ? AlreadyScannedProductInfoCard(
                              productInfo: productInfo)
                          : (productInfo?['is_vegan'] == 'not_found')
                              ? NotFoundProductInfoCard(
                                  productInfo: productInfo)
                              : (productInfo?['is_vegan'] == 'unknown')
                                  ? NonVeganProductInfoCard(
                                      key: nonVeganCardKey,
                                      productInfo: productInfo,
                                      confettiController: _confettiController)
                                  : RejectedProductInfoCard(
                                      productInfo: productInfo),
            )
          else // Show prompt when not loading and no data
            Positioned(
              top: 1100.h,
              left: 16,
              right: 16,
              child: const NoResultCard(),
            ),
          if (productInfo != null && productInfo?['is_vegan'] != "unknown")
            Positioned(
              bottom: 240.h,
              left: 0,
              right: 0,
              child: Center(
                child: ReportErrorButton(barcode: productInfo?['code'] ?? ''),
              ),
            ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 20,
                maxBlastForce: 100.r,
                minBlastForce: 20.r,
                gravity: 0.1,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                ], // Confetti colors
              ),
            ),
          ),
          // Settings button (positioned last to be on top)
          Positioned(
            top: 200.h,
            left: 60.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  _showSettingsModal();
                },
                child: Icon(
                  Icons.settings,
                  color: Colors.black54,
                  size: 80.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
