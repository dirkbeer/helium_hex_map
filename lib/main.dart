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
  final LatLng _center =
      const LatLng(-34.603684, -58.381559); // Example location
  late final H3 h3;

  @override
  void initState() {
    super.initState();
    h3 = const H3Factory().load(); // Load the H3 instance
    WidgetsBinding.instance?.addPostFrameCallback((_) => _addHexOverlay());
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addHexOverlay() {
    try {
      BigInt h3Index = h3.geoToH3(
          GeoCoord(lon: _center.longitude, lat: _center.latitude),
          8); // Resolution
      List<GeoCoord> boundary = h3.h3ToGeoBoundary(h3Index);

      List<LatLng> polygonLatLngs = boundary.map((geoCoord) {
        return LatLng(geoCoord.lat, geoCoord.lon); // Use 'lon' instead of 'lng'
      }).toList();

      final polygon = Polygon(
        polygonId: PolygonId(h3Index.toString()),
        points: polygonLatLngs,
        fillColor: Colors.red.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.red,
      );

      setState(() {
        polygons.add(polygon);
      });
    } on H3Exception catch (e) {
      debugPrint('Failed to add hex overlay: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        polygons: polygons,
      ),
    );
  }
}
