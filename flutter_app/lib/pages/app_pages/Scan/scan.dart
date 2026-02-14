import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/pages/app_pages/Scan/history_modal.dart';
import 'package:vegan_app/pages/app_pages/Scan/sent_products_modal.dart';
import 'package:vegan_app/pages/app_pages/Scan/settings_modal.dart';
import 'package:vegan_app/pages/app_pages/Scan/product_info_helper.dart';
import 'package:vegan_app/models/product_of_interest.dart';
import 'package:vegan_app/services/api_service.dart';
import 'package:vegan_app/services/auth_service.dart';
import 'package:vegan_app/services/offline_scan_service.dart';
import 'package:vegan_app/widgets/scaner/card_product.dart';
import 'package:vegan_app/widgets/scaner/pending_product_info_card.dart';
import 'package:vegan_app/widgets/scaner/report_error_button.dart';
import 'package:vegan_app/widgets/scaner/vegan_product_info_card.dart';
import 'package:vegan_app/widgets/scaner/shop_confirmation_modal.dart';
import 'package:vegan_app/widgets/vegandex/vegandex_modal.dart';
import 'package:vegan_app/widgets/vegandex/product_found_modal.dart';

class ScanPage extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const ScanPage({super.key, this.onNavigateToProfile});

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
  Map<dynamic, dynamic>? productInfo;
  List<Map<String, dynamic>> scanHistory = [];
  String? _lastScannedBarcode = '';
  late ConfettiController _confettiController;
  final nonVeganCardKey = GlobalKey<NonVeganProductInfoCardState>();
  bool _openOnScanPage = false;
  bool _showBoycott = true;
  List<String> _productsOfInterest = [];
  Map<String, ProductOfInterest> _productsOfInterestMap = {};

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    if (!mounted) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        controller.stop();
        break;
      case AppLifecycleState.resumed:
        controller.start();
        // Retry pending scans when app resumes
        _retryPendingScans();
        break;
      case AppLifecycleState.inactive:
        controller.stop();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _loadScanHistory();
    _loadOpenOnScanPagePref();
    _loadShowBoycottPref();
    _loadProductsOfInterest();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationPermission();
      _startScanner();
      _retryPendingScans();
    });
  }

  /// Retry pending scans when app starts
  Future<void> _retryPendingScans() async {
    // First update pending count
    final pendingCount = await OfflineScanService.getPendingCount();

    // If there are pending scans, try to sync them
    if (pendingCount > 0) {
      final (successCount, shopConfirmations) =
          await OfflineScanService.retryPendingScans();

      // Show shop confirmation dialogs for successfully synced scans
      if (successCount > 0 && mounted) {
        // Refresh user data to get updated scanned products
        if (AuthService.isLoggedIn) {
          AuthService.getCurrentUser();
        }

        // Show shop confirmation dialogs sequentially
        for (final confirmation in shopConfirmations) {
          if (!mounted) break;

          final ean = confirmation['ean'] as String;
          final shopName = confirmation['shop_name'] as String;
          final scanEventId = confirmation['scan_event_id'] as int;

          // Get the product info from our cached map
          final product = _productsOfInterestMap[ean];
          if (product != null) {
            _showShopConfirmationDialog(shopName, scanEventId, product);
            // Wait a bit before showing the next dialog
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }
    }
  }

  Future<bool> _checkCameraPermission({bool showDialogOnDenied = true}) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) return true;

    if (showDialogOnDenied) {
      _showPermissionDialog();
    }

    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission requise'),
          content: const Text(
            'L\'accès à la caméra est nécessaire pour scanner les codes-barres. '
            'Veuillez autoriser l\'accès dans les paramètres de l\'application.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Paramètres'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Géolocalisation requise'),
          content: const Text(
            'Vous avez scanné un produit du Vegandex ! Prochainement, une fonctionnalité permettra d\'afficher une carte pour les trouver. \nPour aider la communauté, '
            'nous avons besoin de votre localisation lorsque vous scannez ces produits. '
            'Voulez-vous activer la géolocalisation ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Plus tard'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                LocationPermission permission =
                    await Geolocator.requestPermission();
                if (permission == LocationPermission.deniedForever) {
                  openAppSettings();
                }
              },
              child: const Text('Activer'),
            ),
          ],
        );
      },
    );
  }

  void _showShopConfirmationDialog(
      String shopName, int scanEventId, ProductOfInterest product) {
    // Stop scanner while showing modal
    controller.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return ShopConfirmationModal(
          shopName: shopName,
          scanEventId: scanEventId,
          product: product,
        );
      },
    ).then((_) {
      // Restart scanner when modal closes
      controller.start();
    });
  }

  Future<bool> _checkLocationPermission() async {
    try {
      // Try to check current permission with timeout
      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 3));

      // If denied, try to request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 10));
      }

      final hasPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      // Store the permission state if granted
      if (hasPermission) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('location_permission_granted', true);
      }

      return hasPermission;
    } catch (e) {
      // If check fails (timeout, service unavailable, etc.), use stored state
      final prefs = await SharedPreferences.getInstance();
      final storedPermission =
          prefs.getBool('location_permission_granted') ?? false;
      return storedPermission;
    }
  }

  Future<void> _startScanner() async {
    try {
      // Check camera permission first
      bool hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        return;
      }

      // Wait for the widget to be fully built before starting scanner
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if the controller is properly initialized
      if (!mounted) {
        return;
      }

      await controller.start();
    } catch (e) {
      // Try to restart scanner after a longer delay in debug mode
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        await controller.start();
      }
    }
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

  Future<void> _loadShowBoycottPref() async {
    final value = await PreferencesHelper.getShowBoycottPref();
    setState(() {
      _showBoycott = value;
    });
  }

  Future<void> _loadProductsOfInterest() async {
    final products = await ApiService.getInterestingProducts();
    setState(() {
      _productsOfInterest = products.map((p) => p.ean).toList();
      _productsOfInterestMap = {for (var p in products) p.ean: p};
    });
  }

  Future<void> _sendScanEventIfInteresting(String ean) async {
    // Check if this product is in the products of interest
    if (!_productsOfInterest.contains(ean)) {
      return;
    }

    // Store whether this is a new discovery before updating
    final user = AuthService.currentUser;
    final hadProductBefore =
        user?.scannedProducts?.any((sp) => sp.ean == ean) ?? false;

    // Show modal if product found (don't wait for location)
    final product = _productsOfInterestMap[ean];
    if (product != null && mounted) {
      // Stop scanner while showing modal
      controller.stop();

      // Start fetching location in the background
      final locationFuture = _getLocationForScanEvent();

      await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (context) => ProductFoundModal(
          product: product,
          isNewDiscovery: !hadProductBefore,
        ),
      );

      // Restart scanner after modal is closed
      controller.start();

      // Wait for location to be fetched and send scan event
      final locationData = await locationFuture;
      final latitude = locationData['latitude'];
      final longitude = locationData['longitude'];

      if (latitude == null || longitude == null) {
        // No location, we dont send
        return;
      }

      // Get current user ID
      final userId = AuthService.currentUser?.id;

      // Use offline scan service with automatic retry
      final (success, response, shouldShowDialog) =
          await OfflineScanService.postScanEventWithOfflineSupport(
        ean: ean,
        latitude: latitude,
        longitude: longitude,
        userId: userId,
      );

      if (success && response != null && mounted) {
        // Refresh user data to get updated scanned products
        if (AuthService.isLoggedIn) {
          AuthService.getCurrentUser();
        }

        // Check if a shop was detected and we should show dialog
        if (shouldShowDialog) {
          final shopName = response['shop_name'] as String?;
          final scanEventId = response['id'] as int?;

          if (shopName != null && scanEventId != null) {
            // Show confirmation dialog for shop location
            _showShopConfirmationDialog(shopName, scanEventId, product);
          }
        }
      }
    }
  }

  Future<Map<String, double?>> _getLocationForScanEvent() async {
    double? latitude;
    double? longitude;

    try {
      // Check if we have location permission
      bool hasPermission = await _checkLocationPermission();

      // Get position if permission granted
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      } else {
        // Show dialog to prompt user to enable location
        if (mounted) {
          _showLocationPermissionDialog();
        }
      }
    } catch (e) {
      // Show dialog to prompt user to enable location on error
      if (mounted) {
        _showLocationPermissionDialog();
      }
    }

    return {'latitude': latitude, 'longitude': longitude};
  }

  void _showSettingsModal() {
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
          child: SettingsModal(
            initialOpenOnScanPage: _openOnScanPage,
            onOpenOnScanPageChanged: (value) {
              setState(() {
                _openOnScanPage = value;
              });
            },
            initialShowBoycott: _showBoycott,
            onShowBoycottChanged: (value) {
              setState(() {
                _showBoycott = value;
              });
            },
          ),
        );
      },
    ).then((_) {
      controller.start();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _confettiController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkVeganStatusOffline(String barcode) async {
    final product = await ProductInfoHelper.getProductInfo(barcode);
    // Add EAN-8 warning flag if barcode is 8 digits
    if (barcode.length == 8) {
      product['is_ean8'] = true;
    }
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

      // Send scan event if it's a product of interest (don't wait for it)
      _sendScanEventIfInteresting(barcodeValue.toString());

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
          // EAN-8 Warning Box at top
          if (productInfo != null &&
              productInfo?['is_ean8'] == true &&
              productInfo?['is_vegan'] != 'unknown')
            Positioned(
              top: 300.h,
              left: 16,
              right: 16,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange[800],
                      size: 80.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Code EAN-8 : Ce code-barres peut correspondre à plusieurs produits différents. Vérifiez bien le nom et la marque.',
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Old receipe non vegan warning box at top
          if (productInfo != null &&
              productInfo?['has_non_vegan_old_receipe'] == true)
            Positioned(
              top: productInfo?['is_ean8'] == true ? 450.h : 300.h,
              left: 16,
              right: 16,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange[800],
                      size: 80.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Ancienne recette non vegan : il se peut qu\'il y ait encore du stock avec l\'ancienne recette. Vérifiez les ingrédients.',
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                  controller.stop(); // Stop the scanner when opening the modal
                  setState(() {
                    productInfo = null;
                  });
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: HistoryModal(
                        scanHistory: scanHistory,
                      ),
                    ),
                  ).then((_) {
                    controller
                        .start(); // Restart the scanner when the modal is closed
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: const SentProductsModal(),
                    ),
                  ).then((_) {
                    controller
                        .start(); // Restart the scanner when the modal is closed
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
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
          // Add the floating button for Vegandex
          Positioned(
            top: 200.h,
            right: 20,
            child: Container(
              width: 0.25.sw,
              height: 0.05.sh,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // Gold
                    Color(0xFFFFAF00), // Darker gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(40.r),
                  onTap: () {
                    controller.stop();
                    setState(() {
                      productInfo = null;
                    });
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: VegandexModal(
                          onNavigateToProfile: widget.onNavigateToProfile,
                        ),
                      ),
                    ).then((_) {
                      controller.start();
                    });
                  },
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.catching_pokemon,
                          color: Colors.white,
                          size: 40.sp,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Vegandex",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
                  ? VeganProductInfoCard(
                      productInfo: productInfo,
                      showBoycott: _showBoycott,
                      onBoycottToggleChanged: (value) {
                        setState(() {
                          _showBoycott = value;
                        });
                      },
                    )
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
                                      confettiController: _confettiController,
                                      onNavigateToProfile:
                                          widget.onNavigateToProfile,
                                    )
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
                    color: Colors.black.withValues(alpha: 0.2),
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
