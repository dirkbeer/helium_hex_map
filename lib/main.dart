import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:location/location.dart';

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

  @override
  void initState() {
    super.initState();
    h3 = const H3Factory().load(); // Load the H3 instance
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

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
      _addHexOverlay(currentLocation);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _addHexOverlay(LocationData currentLocation) async {
    LatLngBounds bounds = await mapController.getVisibleRegion();
    Set<BigInt> h3Indexes = _generateH3IndexesForBounds(bounds, _h3Resolution);

    setState(() {
      polygons.clear();
      for (BigInt h3Index in h3Indexes) {
        List<GeoCoord> boundary = h3.h3ToGeoBoundary(h3Index);
        List<LatLng> polygonLatLngs = boundary
            .map((geoCoord) => LatLng(geoCoord.lat, geoCoord.lon))
            .toList();

        final polygon = Polygon(
          polygonId: PolygonId(h3Index.toString()),
          points: polygonLatLngs,
          fillColor: Colors.blue.withOpacity(0.0),
          strokeWidth: 2,
          strokeColor: Colors.blue.withOpacity(0.5),
        );

        polygons.add(polygon);
      }
    });
  }

  Set<BigInt> _generateH3IndexesForBounds(LatLngBounds bounds, int resolution) {
    final northEast = bounds.northeast;
    final southWest = bounds.southwest;

    Set<BigInt> h3Indexes = {};
    double latStep = (northEast.latitude - southWest.latitude) / 10;
    double lngStep = (northEast.longitude - southWest.longitude) / 10;

    for (double lat = southWest.latitude;
        lat <= northEast.latitude;
        lat += latStep) {
      for (double lng = southWest.longitude;
          lng <= northEast.longitude;
          lng += lngStep) {
        BigInt h3Index = h3.geoToH3(GeoCoord(lon: lng, lat: lat), resolution);
        h3Indexes.add(h3Index);
      }
    }

    return h3Indexes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0), // Will be updated to the user's location
          zoom: 18.0,
        ),
        polygons: polygons,
      ),
    );
  }
}
