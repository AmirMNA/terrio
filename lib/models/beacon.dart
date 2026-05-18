import 'dart:convert';

class Beacon {
  final String id;
  final String territoryId;
  final String ownerId;
  final int level;
  final Map<String, dynamic> location; // GeoJSON Point
  final DateTime? placedAt;
  final DateTime? expiresAt;
  final int siegeSlowPercent;
  final int attackWarningHours;

  Beacon({
    this.id = '',
    required this.territoryId,
    required this.ownerId,
    required this.level,
    required this.location,
    this.placedAt,
    this.expiresAt,
    this.siegeSlowPercent = 0,
    this.attackWarningHours = 0,
  });

  factory Beacon.fromMap(Map<String, dynamic> map) {
    return Beacon(
      id: map['id']?.toString() ?? '',
      territoryId: map['territory_id']?.toString() ?? '',
      ownerId: map['owner_id']?.toString() ?? '',
      level: map['level'] ?? 1,
      location: map['location'] is String 
          ? jsonDecode(map['location']) 
          : Map<String, dynamic>.from(map['location'] ?? {}),
      placedAt: map['placed_at'] != null ? DateTime.parse(map['placed_at']) : null,
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      siegeSlowPercent: map['siege_slow_percent'] ?? 0,
      attackWarningHours: map['attack_warning_hours'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'territory_id': territoryId,
      'owner_id': ownerId,
      'level': level,
      'location': location,
      'placed_at': placedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'siege_slow_percent': siegeSlowPercent,
      'attack_warning_hours': attackWarningHours,
    };
  }
}