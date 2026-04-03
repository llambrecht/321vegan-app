import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vegan_app/models/shops/shop.dart';
import 'package:vegan_app/services/api_service.dart';
import 'package:vegan_app/services/auth_service.dart';
import 'package:vegan_app/services/subscription_service.dart';
import 'package:vegan_app/widgets/map/map_access_overlay.dart';
import 'package:vegan_app/widgets/map/map_filter_sheet.dart';
import 'package:vegan_app/widgets/map/shop_detail_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  List<Shop> _shops = [];
  bool _isLoading = true;
  Set<String> _selectedEans = {};
  LatLng? _initialCenter;
  LatLng? _userLocation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 8, end: 20).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // Fallback center in the center of hexagon
    LatLng center = const LatLng(46.231604072873, 2.495977205153891);

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
        center = LatLng(position.latitude, position.longitude);
        if (mounted) setState(() => _userLocation = center);
      }
    } catch (_) {
      // Keep France fallback
    }

    if (mounted) {
      if (_initialCenter == null) {
        setState(() => _initialCenter = center);
      } else {
        _mapController.move(center, 16);
        _loadShops();
      }
    }
  }

  Future<void> _loadShops() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final bounds = _mapController.camera.visibleBounds;
    final List<Shop> shops;

    if (_selectedEans.isNotEmpty) {
      shops = await ApiService.getShopsFilteredByProducts(
        eans: _selectedEans.toList(),
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
      );
    } else {
      shops = await ApiService.getShopsInArea(
        minLat: bounds.south,
        maxLat: bounds.north,
        minLng: bounds.west,
        maxLng: bounds.east,
      );
    }

    if (mounted) {
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: MapFilterSheet(
          selectedEans: _selectedEans,
          onApply: (newSelection) {
            setState(() => _selectedEans = newSelection);
            _loadShops();
          },
        ),
      ),
    );
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      _loadShops();
    }
  }

  void _onMapReady() {
    _loadShops();
  }

  Widget _buildMarkerIcon(Shop shop) {
    final isVegan = shop.shopType == 'vegan';
    return Container(
      decoration: BoxDecoration(
        color: isVegan ? Colors.green : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isVegan
              ? Colors.green.shade700
              : Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isVegan ? Icons.eco : Icons.storefront,
          color: isVegan ? Colors.white : Theme.of(context).colorScheme.primary,
          size: 22,
        ),
      ),
    );
  }

  void _onShopTap(Shop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ShopDetailSheet(shop: shop),
    );
  }

  void _recenterMap() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 16);
      _loadShops();
    } else {
      _initLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialCenter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter!,
              initialZoom: 16,
              onMapEvent: _onMapEvent,
              onMapReady: _onMapReady,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'fr.321vegan.app',
              ),
              const RichAttributionWidget(
                showFlutterMapAttribution: false,
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                  TextSourceAttribution('CARTO'),
                  TextSourceAttribution('Made with FlutterMap'),
                ],
              ),
              if (_userLocation != null)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) => CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _userLocation!,
                        radius: _pulseAnimation.value,
                        color: Theme.of(context).colorScheme.primary.withValues(
                          alpha: 0.3 * (1 - (_pulseAnimation.value - 8) / 12),
                        ),
                        borderStrokeWidth: 0,
                      ),
                      CircleMarker(
                        point: _userLocation!,
                        radius: 7,
                        color: Theme.of(context).colorScheme.primary,
                        borderColor: Colors.white,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 80,
                  size: const Size(40, 40),
                  markers: _shops.map((shop) {
                    return Marker(
                      point: LatLng(shop.latitude, shop.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _onShopTap(shop),
                        child: _buildMarkerIcon(shop),
                      ),
                    );
                  }).toList(),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 24.w,
            bottom: 100,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, color: Theme.of(context).colorScheme.primary, size: 100.sp),
                          SizedBox(height: 2.h),
                          Text('Rechercher', style: TextStyle(fontSize: 28.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  Container(height: 1, width: 36.w, color: Colors.grey.shade300),
                  GestureDetector(
                    onTap: _recenterMap,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.my_location, color: Colors.grey, size: 100.sp),
                          SizedBox(height: 2.h),
                          Text('Recentrer', style: TextStyle(fontSize: 28.sp, color: Colors.grey, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_selectedEans.isNotEmpty)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list,
                            size: 42.sp, color: Colors.white),
                        SizedBox(width: 6.w),
                        Text(
                          '${_selectedEans.length} filtre${_selectedEans.length > 1 ? 's' : ''} actif${_selectedEans.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 42.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedEans = {});
                            _loadShops();
                          },
                          child: Icon(Icons.close,
                              size: 42.sp, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!AuthService.isLoggedIn || !SubscriptionService.isSubscribed)
            MapAccessOverlay(
              onAccessGranted: () => setState(() {}),
            ),
        ],
      ),
    );
  }
}
