import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng; // user’s chosen point
  bool _loading = true;

  /// Permission + GPS fetch
  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    // Ensure location services ON
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      setState(() => _loading = false);
      return;
    }

    // Ask permission if needed
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        setState(() => _loading = false);
        return;
      }
    }

    // Get GPS
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
      _loading = false;
    });
  }

  /// Save to SharedPreferences
  Future<void> _saveLocation() async {
    if (_currentLatLng == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', _currentLatLng!.latitude);
    await prefs.setDouble('longitude', _currentLatLng!.longitude);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location saved')));
    }
  }

  /// Build Google Map with a single draggable marker
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentLatLng == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Set Delivery Location')),
        body: const Center(child: Text('Unable to fetch GPS location')),
      );
    }

    final marker = Marker(
      markerId: const MarkerId('selected'),
      position: _currentLatLng!,
      draggable: true,
      onDragEnd: (newPos) => setState(() => _currentLatLng = newPos),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Delivery Location'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 16,
            ),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {marker},
            onTap: (latLng) => setState(() => _currentLatLng = latLng),
          ),

          /// Save button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Save This Location',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
