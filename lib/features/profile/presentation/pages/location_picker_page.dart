import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// نتيجة اختيار الموقع من الخريطة: إحداثيات + عنوان نصي مقروء (إن توفر).
class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}

/// شاشة اختيار موقع المتجر من خريطة مجانية (OpenStreetMap عبر flutter_map)
/// بدل إدخال خط الطول ودائرة العرض يدويًا.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const Color _orange = Color(0xFFFF821D);
  static const Color _textPrimary = Color(0xFF20212B);

  // القاهرة كموقع افتراضي في حال عدم وجود موقع محفوظ من قبل.
  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  late final MapController _mapController;
  late LatLng _selectedLocation;
  String? _address;
  bool _isResolvingAddress = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation ?? _defaultLocation;
    _resolveAddress(_selectedLocation);
  }

  Future<void> _resolveAddress(LatLng location) async {
    setState(() => _isResolvingAddress = true);

    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((part) => part != null && part.trim().isNotEmpty).toList();

        setState(() {
          _address = parts.isNotEmpty ? parts.join('، ') : null;
          _isResolvingAddress = false;
        });
        return;
      }
    } catch (_) {
      // نتجاهل خطأ تحويل الإحداثيات للعنوان ونعرض الإحداثيات كحل بديل فقط.
    }

    if (!mounted) return;
    setState(() {
      _address = null;
      _isResolvingAddress = false;
    });
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _selectedLocation = camera.center;
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
      _resolveAddress(_selectedLocation);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isLocating = false);
        _showMessage('Location permission is required to use this feature.');
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _isLocating = false);
        _showMessage('Please enable location services and try again.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final current = LatLng(position.latitude, position.longitude);
      _mapController.move(current, 16);

      setState(() {
        _selectedLocation = current;
        _isLocating = false;
      });

      _resolveAddress(current);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      _showMessage('Unable to fetch your current location.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmLocation() {
    Navigator.of(context).pop(
      PickedLocation(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        address: _address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'Store Location',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15,
              onPositionChanged: _onPositionChanged,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.technoprint.easyshop_admin',
              ),
            ],
          ),
          // دبوس ثابت في منتصف الشاشة: تحريك الخريطة يحرك الموقع المختار
          // (نفس أسلوب تطبيقات التوصيل الشائعة)، بدل الاعتماد على سحب Marker.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, color: _orange, size: 46),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 196,
            child: FloatingActionButton(
              heroTag: 'use-current-location',
              backgroundColor: Colors.white,
              foregroundColor: _orange,
              onPressed: _isLocating ? null : _useCurrentLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: _orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isResolvingAddress
                              ? 'جارِ تحديد العنوان...'
                              : (_address ??
                                    '${_selectedLocation.latitude.toStringAsFixed(5)}, '
                                        '${_selectedLocation.longitude.toStringAsFixed(5)}'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
