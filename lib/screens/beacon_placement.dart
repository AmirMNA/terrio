import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/supabase_service.dart';
import '../models/beacon.dart';

class BeaconPlacement extends StatefulWidget {
  final String territoryId;
  const BeaconPlacement({super.key, required this.territoryId});

  @override
  State<BeaconPlacement> createState() => _BeaconPlacementState();
}

class _BeaconPlacementState extends State<BeaconPlacement> {
  int _level = 1;

  void _placeBeacon() async {
    // Get current location
    Position pos = await Geolocator.getCurrentPosition();
    // Check if within territory? In prototype we trust user's intent.
    // Build beacon
    final beacon = Beacon(
      territoryId: widget.territoryId,
      ownerId: SupabaseService.currentUser!.id,
      level: _level,
      location: {
        'type': 'Point',
        'coordinates': [pos.longitude, pos.latitude],
      },
      placedAt: DateTime.now(),
      expiresAt: _level == 4 ? null : DateTime.now().add(Duration(hours: _durationHours)),
      siegeSlowPercent: _siegeSlow,
      attackWarningHours: _attackWarning,
    );
    await SupabaseService.placeBeacon(beacon);
    // Deduct tokens (not shown for brevity)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Beacon placed!')));
    Navigator.pop(context);
  }

  int get _durationHours {
    switch (_level) {
      case 1: return 24;
      case 2: return 24*7;
      case 3: return 24*30;
      default: return 0; // permanent
    }
  }

  int get _siegeSlow {
    switch (_level) {
      case 1: return 0;
      case 2: return 20;
      case 3: return 40;
      case 4: return 60;
      default: return 0;
    }
  }

  int get _attackWarning {
    if (_level == 3) return 48;
    if (_level == 4) return 72;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Place Beacon')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: _level,
              items: [1,2,3,4].map((l) => DropdownMenuItem(value: l, child: Text('Level $l'))).toList(),
              onChanged: (v) => setState(() => _level = v!),
            ),
            ElevatedButton(onPressed: _placeBeacon, child: const Text('Place Here')),
          ],
        ),
      ),
    );
  }
}