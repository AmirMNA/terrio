class Territory {
  final String id;
  final String ownerId;
  String name;
  final String zoneType;
  final double areaKm2;
  final Map<String, dynamic> geom; // GeoJSON Polygon

  Territory({
    this.id = '',
    required this.ownerId,
    required this.name,
    required this.zoneType,
    required this.areaKm2,
    required this.geom,
  });

  factory Territory.fromMap(Map<String, dynamic> map) {
    return Territory(
      id: map['id'],
      ownerId: map['owner_id'],
      name: map['name'],
      zoneType: map['zone_type'],
      areaKm2: map['area_km2'],
      geom: map['geom'], // Supabase returns GeoJSON directly
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'name': name,
      'zone_type': zoneType,
      'area_km2': areaKm2,
      'geom': geom,
    };
  }
}
