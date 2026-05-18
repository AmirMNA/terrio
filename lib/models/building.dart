import 'dart:convert';

class Building {
  final String id;
  final String territoryId;
  final String buildingType;
  final Map<String, dynamic> location;
  final DateTime? placedAt;

  Building({
    this.id = '',
    required this.territoryId,
    required this.buildingType,
    required this.location,
    this.placedAt,
  });

  factory Building.fromMap(Map<String, dynamic> map) {
    return Building(
      id: map['id']?.toString() ?? '',
      territoryId: map['territory_id']?.toString() ?? '',
      buildingType: map['building_type'] ?? '',
      location: map['location'] is String 
          ? jsonDecode(map['location']) 
          : Map<String, dynamic>.from(map['location'] ?? {}),
      placedAt: map['placed_at'] != null ? DateTime.parse(map['placed_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'territory_id': territoryId,
      'building_type': buildingType,
      'location': location,
      'placed_at': placedAt?.toIso8601String(),
    };
  }
}