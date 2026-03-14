import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vegan_app/models/shops/shop.dart';
import 'package:vegan_app/services/api_service.dart';
import 'package:vegan_app/widgets/map/shop_detail_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  List<Shop> _shops = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Fallback center in the center of hexagon
    LatLng center = const LatLng(48.58079475665418, 7.757090271210848);

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
        // TODO : Use real center
        //center = LatLng(position.latitude, position.longitude);
        center = const LatLng(48.58079475665418, 7.757090271210848);
      }
    } catch (_) {
      // Keep France fallback
    }

    if (mounted) {
      _mapController.move(center, 16);
    }
  }

  Future<void> _loadShops() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final bounds = _mapController.camera.visibleBounds;
    final shops = await ApiService.getShopsInArea(
      minLat: bounds.south,
      maxLat: bounds.north,
      minLng: bounds.west,
      maxLng: bounds.east,
    );

    if (mounted) {
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    }
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
    _initLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(48.58079475665418, 7.757090271210848),
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
          if (_isLoading)
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 60.h),
        child: FloatingActionButton(
          onPressed: _recenterMap,
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
