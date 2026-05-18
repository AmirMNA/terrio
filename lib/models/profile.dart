class Profile {
  final String id;
  String username;
  String gameMode;
  String? tribeId;
  int sovereigntyTokens;
  int careTokens;
  int artTokens;
  int communityTokens;
  DateTime? createdAt;

  Profile({
    required this.id,
    this.username = 'Player',
    this.gameMode = 'conqueror',
    this.tribeId,
    this.sovereigntyTokens = 0,
    this.careTokens = 0,
    this.artTokens = 0,
    this.communityTokens = 0,
    this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id']?.toString() ?? '',
      username: map['username'] ?? 'Player',
      gameMode: map['game_mode'] ?? 'conqueror',
      tribeId: map['tribe_id']?.toString(),
      sovereigntyTokens: map['sovereignty_tokens'] ?? 0,
      careTokens: map['care_tokens'] ?? 0,
      artTokens: map['art_tokens'] ?? 0,
      communityTokens: map['community_tokens'] ?? 0,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'game_mode': gameMode,
      'tribe_id': tribeId,
      'sovereignty_tokens': sovereigntyTokens,
      'care_tokens': careTokens,
      'art_tokens': artTokens,
      'community_tokens': communityTokens,
    };
  }
}