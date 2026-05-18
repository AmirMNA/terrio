import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/supabase_service.dart';
import '../services/territory_service.dart';
import '../models/territory.dart';
import '../widgets/tracking_button.dart';
import 'territory_info.dart';
import 'tribe_screen.dart';
import 'token_display.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  late TerritoryService _territoryService;
  List<Territory> _territories = [];
  LatLng? _currentPosition;
  List<LatLng> _trackedPath = [];

  @override
  void initState() {
    super.initState();
    _territoryService = TerritoryService(_locationService);
    _initApp();
  }

  Future<void> _initApp() async {
    // Sign in anonymously
    if (SupabaseService.currentUser == null) {
      await SupabaseService.signInAnonymously();
      // Create profile
      await SupabaseService.upsertProfile(/* default profile */);
    }
    // Request GPS
    final granted = await _locationService.requestPermission();
    if (granted) {
      _locationService.startTracking(onNewPosition: (pos) {
        setState(() {
          _currentPosition = pos;
          _trackedPath = List.from(_locationService.path);
        });
      });
    }
    // Load territories
    _loadTerritories();
  }

  Future<void> _loadTerritories() async {
    final territories = await SupabaseService.getTerritories();
    setState(() { _territories = territories; });
  }

  void _finishCapture() async {
    try {
      // For prototype, zone selection can be a dialog – we use 'green'
      final territory = await _territoryService.claimTerritory('green');
      _loadTerritories(); // refresh
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Territory "${territory.name}" claimed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Territory: Footprint'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TribeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.monetization_on),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TokenDisplay())),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: _currentPosition ?? const LatLng(51.5, -0.09),
              zoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.territory.footprint',
              ),
              // Territory polygons
              PolygonLayer(
                polygons: _territories.map((t) {
                  // Convert GeoJSON coordinates to List<LatLng>
                  final coords = (t.geom['coordinates'][0] as List)
                      .map((c) => LatLng(c[1] as double, c[0] as double))
                      .toList();
                  return Polygon(
                    points: coords,
                    color: _zoneColor(t.zoneType).withOpacity(0.3),
                    borderStrokeWidth: 2,
borderColor: _zoneColor(t.zoneType),
                    label: t.name,
                    onTap: () => _showTerritoryInfo(t),
                  );
                }).toList(),
              ),
              // Tracked path while walking
              if (_trackedPath.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _trackedPath,
                      color: Colors.orangeAccent,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              // Current location marker
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                    ),
                  ],
                ),
            ],
          ),
          // Tracking controls
          Positioned(
            bottom: 20,
            right: 20,
            child: TrackingButton(
              onFinish: _finishCapture,
              isTracking: true, // for simplicity
            ),
          ),
        ],
      ),
    );
  }

  Color _zoneColor(String type) {
    switch (type) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'gold': return Colors.amber;
      case 'purple': return Colors.purple;
      default: return Colors.grey;
    }
  }

  void _showTerritoryInfo(Territory t) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TerritoryInfo(territory: t)),
    );
  }
}