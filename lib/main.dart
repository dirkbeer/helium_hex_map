import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:location/location.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  final Set<Polygon> polygons = {};
  late final H3 h3;
  final Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  final int _h3Resolution = 11; // Adjust the resolution as needed
  final List<Map<String, dynamic>> hexRecords =
      []; // Data structure to hold hex records
  double _currentAccuracy = 0.0;

  @override
  void initState() {
    super.initState();
    h3 = const H3Factory().load(); // Load the H3 instance
    _initLocationService();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _initLocationService() async {
    // Check for location service
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check for location permission
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Enable background mode for location updates
    await location.enableBackgroundMode(
        enable: true); // Added line for background location updates

    // Listen for location changes
    location.onLocationChanged.listen((LocationData currentLocation) async {
      final currentZoomLevel = await mapController.getZoomLevel();
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: currentZoomLevel,
          ),
        ),
      );
      _addHexRecordAndOverlay(currentLocation);
      setState(() {
        _currentAccuracy = currentLocation.accuracy!;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _addHexRecordAndOverlay(LocationData currentLocation) async {
    final h3Index = h3.geoToH3(
        GeoCoord(
            lon: currentLocation.longitude!, lat: currentLocation.latitude!),
        _h3Resolution);
    final currentTime = DateTime.now();

    // Add a new record for the current location
    hexRecords.add({
      'h3Index': h3Index,
      'time': currentTime,
      'status': 'current',
    });

    // Clear existing polygons and create new ones based on hexRecords
    setState(() {
      polygons.clear();
      for (var record in hexRecords) {
        final recordTime = record['time'] as DateTime;
        final recordDuration = currentTime.difference(recordTime);
        if (recordDuration.inMinutes > 15) {
          record['status'] = 'counted';
        }
        if (recordDuration.inMinutes > 60) {
          record['status'] = 'available';
        }

        List<GeoCoord> boundary = h3.h3ToGeoBoundary(record['h3Index']);
        List<LatLng> polygonLatLngs = boundary
            .map((geoCoord) => LatLng(geoCoord.lat, geoCoord.lon))
            .toList();

        Color fillColor;
        Color strokeColor;
        int strokeWidth;
        // Default style (should never show)
        fillColor = Colors.grey.withOpacity(0.5);
        strokeColor = Colors.grey.withOpacity(0.8);
        strokeWidth = 2;
        // Set color based on status
        if (record['status'] == 'current') {
          fillColor = Colors.blue.withOpacity(0.5); // Current location
          strokeColor = Colors.blue.withOpacity(0.8);
        } else if (record['status'] == 'counted') {
          fillColor = Colors.green.withOpacity(0.5); // Available location
          strokeColor = Colors.green.withOpacity(0.8);
        } else if (record['status'] == 'available') {
          fillColor = Colors.green.withOpacity(0.25); // Available location
          strokeWidth = 0;
        }

        final polygon = Polygon(
          polygonId: PolygonId(record['h3Index'].toString()),
          points: polygonLatLngs,
          fillColor: fillColor, // Adjust opacity as needed
          strokeWidth: strokeWidth,
          strokeColor: strokeColor,
        );

        polygons.add(polygon);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target:
                  LatLng(0.0, 0.0), // Will be updated to the user's location
              zoom: 18.0,
            ),
            polygons: polygons,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                'Accuracy: ${_currentAccuracy.toStringAsFixed(1)}m',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
