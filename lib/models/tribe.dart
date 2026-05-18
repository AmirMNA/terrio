class Tribe {
  final String id;
  final String name;
  final String? iconUrl;
  final String color;
  final String? leaderId;
  final DateTime? createdAt;

  Tribe({
    this.id = '',
    required this.name,
    this.iconUrl,
    this.color = '#FF5722',
    this.leaderId,
    this.createdAt,
  });

  factory Tribe.fromMap(Map<String, dynamic> map) {
    return Tribe(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      iconUrl: map['icon_url'],
      color: map['color'] ?? '#FF5722',
      leaderId: map['leader_id']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon_url': iconUrl,
      'color': color,
      'leader_id': leaderId,
    };
  }
}