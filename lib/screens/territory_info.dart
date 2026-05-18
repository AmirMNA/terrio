import 'package:flutter/material.dart';
import '../models/territory.dart';
import '../models/beacon.dart';
import '../services/supabase_service.dart';
import 'beacon_placement.dart';

class TerritoryInfo extends StatelessWidget {
  final Territory territory;
  const TerritoryInfo({super.key, required this.territory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(territory.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: ${territory.ownerId.substring(0,8)}...'),
            Text('Zone: ${territory.zoneType}'),
            Text('Area: ${territory.areaKm2.toStringAsFixed(3)} km²'),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                // Check if user is owner
                if (SupabaseService.currentUser?.id == territory.ownerId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BeaconPlacement(territoryId: territory.id)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Only the Governor can place beacons.')),
                  );
                }
              },
              child: const Text('Place Beacon'),
            ),
            // Show beacons (simplified – fetch from Supabase)
          ],
        ),
      ),
    );
  }
}
