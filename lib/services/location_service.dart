import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Stream<Position>? _positionStream;
  List<LatLng> path = [];

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void startTracking({required void Function(LatLng) onNewPosition}) {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters
      ),
    );
    _positionStream!.listen((pos) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      path.add(latLng);
      onNewPosition(latLng);
    });
  }

  void stopTracking() {
    _positionStream?.drain();
    _positionStream = null;
  }

  void resetPath() {
    path.clear();
  }
}