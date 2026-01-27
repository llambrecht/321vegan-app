import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vegan_app/widgets/map/shop_detail_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng? _userLocation;
  bool _isLoadingLocation = false;
  double _selectedRadius = 5.0; // Default radius in km
  List<_ShopMarker> _shops = []; // Will be populated from API later

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Les services de localisation sont désactivés'),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission de localisation refusée'),
              ),
            );
          }
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Permission de localisation refusée définitivement. Veuillez l\'activer dans les paramètres.'),
            ),
          );
        }
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move map to user location
      _mapController.move(_userLocation!, 13.0);

      // TODO: Fetch nearby shops from API based on user location
      _loadNearbyShops();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la récupération de la position: $e')),
        );
      }
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _loadNearbyShops() {
    // TODO: Replace with actual API call
    // For now, using dummy data for UI demonstration
    setState(() {
      _shops = [
        _ShopMarker(
          name: 'Carrefour Bio',
          address: '123 Rue de la Paix, Paris',
          latitude: _userLocation!.latitude + 0.01,
          longitude: _userLocation!.longitude + 0.01,
          products: ['Tofu nature', 'Lait d\'amande', 'Steaks végétaux'],
        ),
        _ShopMarker(
          name: 'Naturalia',
          address: '456 Avenue des Champs, Paris',
          latitude: _userLocation!.latitude - 0.015,
          longitude: _userLocation!.longitude + 0.02,
          products: ['Fromage végétal', 'Yaourt soja'],
        ),
        _ShopMarker(
          name: 'BioCoop',
          address: '789 Boulevard Voltaire, Paris',
          latitude: _userLocation!.latitude + 0.02,
          longitude: _userLocation!.longitude - 0.01,
          products: [],
        ),
      ];
    });
  }

  void _onMarkerTapped(_ShopMarker shop) {
    // Calculate distance from user to shop
    double distance = 0;
    if (_userLocation != null) {
      distance = Geolocator.distanceBetween(
            _userLocation!.latitude,
            _userLocation!.longitude,
            shop.latitude,
            shop.longitude,
          ) /
          1000; // Convert to km
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShopDetailBottomSheet(
        shopName: shop.name,
        address: shop.address,
        distance: distance,
        latitude: shop.latitude,
        longitude: shop.longitude,
        products: shop.products,
      ),
    );
  }

  void _onSearchChanged(String query) {
    // TODO: Implement product search functionality
    // This will search for shops carrying a specific product
  }

  void _centerOnUserLocation() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 13.0);
    } else {
      _getUserLocation();
    }
  }

  void _onRadiusChanged(double value) {
    setState(() {
      _selectedRadius = value;
    });
    // TODO: Reload shops with new radius
    _loadNearbyShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(48.8566, 2.3522), // Default to Paris
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vegandex.app',
              ),

              // Radius circle around user
              if (_userLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _userLocation!,
                      radius: _selectedRadius * 1000, // Convert km to meters
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.1),
                      borderColor: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // Shop markers
              MarkerLayer(
                markers: _shops.map((shop) {
                  return Marker(
                    point: LatLng(shop.latitude, shop.longitude),
                    width: 40.w,
                    height: 40.h,
                    child: GestureDetector(
                      onTap: () => _onMarkerTapped(shop),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // User location marker
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 20.w,
                      height: 20.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search bar at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit Vegandex',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
          ),

          // Radius selector
          Positioned(
            top: MediaQuery.of(context).padding.top + 80.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: _selectedRadius,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: [1.0, 5.0, 10.0, 25.0].map((double value) {
                    return DropdownMenuItem<double>(
                      value: value,
                      child: Text(
                        '${value.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _onRadiusChanged(value);
                    }
                  },
                ),
              ),
            ),
          ),

          // Find Nearby button (FAB)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton(
              onPressed: _centerOnUserLocation,
              tooltip: 'Trouver à proximité',
              child: _isLoadingLocation
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Loading indicator
          if (_isLoadingLocation && _userLocation == null)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// Helper class for shop markers (temporary, will be replaced with proper model)
class _ShopMarker {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> products;

  _ShopMarker({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.products = const [],
  });
}
