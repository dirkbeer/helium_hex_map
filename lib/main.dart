import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h3_flutter/h3_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  final Set<Polygon> polygons = {};
  late final H3 h3;
  final int _h3Resolution = 8; // Resolution of H3, adjust based on needs
  bool _isCameraMoving = false;

  @override
  void initState() {
    super.initState();
    h3 = const H3Factory().load(); // Load the H3 instance
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _isCameraMoving = true;
  }

  void _onCameraIdle() async {
    if (_isCameraMoving) {
      _isCameraMoving = false;
      await _addHexOverlay();
    }
  }

  Future<void> _addHexOverlay() async {
    LatLngBounds bounds = await mapController.getVisibleRegion();
    Set<BigInt> h3Indexes = _generateH3IndexesForBounds(bounds, _h3Resolution);

    setState(() {
      polygons.clear(); // Clear existing polygons to avoid overlay duplication
      for (BigInt h3Index in h3Indexes) {
        List<GeoCoord> boundary = h3.h3ToGeoBoundary(h3Index);
        List<LatLng> polygonLatLngs = boundary
            .map((geoCoord) => LatLng(geoCoord.lat, geoCoord.lon))
            .toList();

        final polygon = Polygon(
            polygonId: PolygonId(h3Index.toString()),
            points: polygonLatLngs,
            fillColor: Colors.red.withOpacity(0.0),
            strokeWidth: 2,
            strokeColor: Colors.red.withOpacity(0.25));

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
        try {
          BigInt h3Index = h3.geoToH3(GeoCoord(lon: lng, lat: lat), resolution);
          h3Indexes.add(h3Index);
        } catch (e) {
          debugPrint("Error generating H3 index: $e");
        }
      }
    }

    return h3Indexes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onCameraMove: _onCameraMove,
        onCameraIdle: _onCameraIdle,
        initialCameraPosition: CameraPosition(
          target: const LatLng(-34.603684, -58.381559), // Example location
          zoom: 11.0,
        ),
        polygons: polygons,
      ),
    );
  }
}
