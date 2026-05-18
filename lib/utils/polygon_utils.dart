import 'package:latlong2/latlong.dart';
import 'package:turf/turf.dart' as turf;
import 'package:turf/helpers.dart' as turf_helpers;

class PolygonUtils {
  /// Check if the first and last points of a path are within [thresholdMeters] (default 20m),
  /// indicating a closed loop.
  static bool isLoopClosed(List<LatLng> path, {double thresholdMeters = 20}) {
    if (path.length < 3) return false;
    final distance = const Distance().distance(path.first, path.last);
    return distance <= thresholdMeters;
  }

  /// Calculate area of polygon in km² using the Shoelace formula on a plane approximation.
  /// Requires the polygon to be closed (first == last or will auto-close).
  static double polygonAreaKm2(List<LatLng> points) {
    if (points.length < 3) return 0;

    // Convert to a list of Position for turf
    final positions = points.map((p) => turf_helpers.Position(p.latitude, p.longitude)).toList();
    // Ensure closed
    if (positions.first != positions.last) {
      positions.add(positions.first);
    }
    final polygon = turf_helpers.Polygon(coordinates: [positions]);
    final areaM2 = turf.area(polygon); // returns square meters
    return areaM2 / 1e6; // convert to km²
  }

  /// Simplify the path using Douglas-Peucker to reduce number of vertices.
  static List<LatLng> simplify(List<LatLng> path, double tolerance) {
    final line = turf_helpers.LineString(
      coordinates: path.map((p) => turf_helpers.Position(p.latitude, p.longitude)).toList(),
    );
    final simplified = turf.simplify(line, tolerance: tolerance);
    return simplified.coordinates
        .map((c) => LatLng(c.lat, c.lng))
        .toList();
  }

  /// Check if a point is inside a polygon (represented as list of LatLng, closed).
  static bool isPointInside(LatLng point, List<LatLng> polygon) {
    final pt = turf_helpers.Point(coordinates: turf_helpers.Position(point.latitude, point.longitude));
    final polyCoords = polygon.map((p) => turf_helpers.Position(p.latitude, p.longitude)).toList();
    if (polyCoords.first != polyCoords.last) {
      polyCoords.add(polyCoords.first);
    }
    final poly = turf_helpers.Polygon(coordinates: [polyCoords]);
    return turf.booleanPointInPolygon(pt, poly);
  }
}