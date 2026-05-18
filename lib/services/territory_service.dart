import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../models/territory.dart';
import '../utils/polygon_utils.dart';
import 'supabase_service.dart';
import 'location_service.dart';

class TerritoryService {
  final SupabaseService db = SupabaseService();
  final LocationService locationService;

  TerritoryService(this.locationService);

  /// Attempt to claim a territory from the current tracked path.
  /// Returns the created Territory if successful, otherwise throws.
  Future<Territory> claimTerritory(String zoneType) async {
    final path = List<LatLng>.from(locationService.path);
    if (!PolygonUtils.isLoopClosed(path)) {
      throw Exception('Your path is not a closed loop. Walk back to the start.');
    }

    final area = PolygonUtils.polygonAreaKm2(path);
    if (area < 0.01) {
      throw Exception('Territory too small. Minimum area is 0.01 km².');
    }

    // Simplify the polygon to reduce storage (tolerance ~5 meters)
    final simplified = PolygonUtils.simplify(path, 0.00005); // approx 5m
    // Ensure closed
    if (simplified.first != simplified.last) {
      simplified.add(simplified.first);
    }

    // Build GeoJSON polygon
    final coordinates = simplified.map((p) => [p.longitude, p.latitude]).toList();
    final geoJson = {
      "type": "Polygon",
      "coordinates": [coordinates],
    };

    // Check intersection with existing territories using PostGIS (server-side)
    // We'll call an RPC function that checks overlaps
    final conflict = await db.client.rpc('check_territory_overlap', params: {
      'p_geojson': jsonEncode(geoJson),
    });
    if (conflict != null && (conflict as List).isNotEmpty) {
      throw Exception('This area overlaps an existing territory. Choose a different location.');
    }

    // Determine the zone type based on real land use (for prototype we trust the player)
    final user = db.currentUser!;
    final territory = Territory(
      id: '', // will be generated
      ownerId: user.id,
      name: 'New Territory',
      zoneType: zoneType,
      areaKm2: area,
      geom: geoJson,
    );

    await db.insertTerritory(territory);

    // Award Sovereignty tokens: 1 per 0.01 km², e.g., area*100
    int sovereignty = (area * 100).round();
    await db.addTokens(user.id, 'sovereignty', sovereignty);

    // Clear path after successful claim
    locationService.resetPath();
    return territory;
  }
}