import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/territory.dart';
import '../models/beacon.dart';
import '../models/tribe.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ---------- Auth ----------
  static Future<AuthResponse> signInAnonymously() async {
    return await client.auth.signInAnonymously();
  }

  static User? get currentUser => client.auth.currentUser;

  // ---------- Profiles ----------
  static Future<Profile?> getProfile(String userId) async {
    final data = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    if (data == null) return null;
    return Profile.fromMap(data);
  }

  static Future<void> upsertProfile(Profile profile) async {
    await client.from('profiles').upsert(profile.toMap());
  }

  // ---------- Territories ----------
  static Future<List<Territory>> getTerritories() async {
    final response = await client.from('territories').select();
    return (response as List).map((e) => Territory.fromMap(e)).toList();
  }

  static Future<void> insertTerritory(Territory territory) async {
    await client.from('territories').insert(territory.toMap());
  }

  // ---------- Beacons ----------
  static Future<List<Beacon>> getBeaconsForTerritory(String territoryId) async {
    final response = await client
        .from('beacons')
        .select()
        .eq('territory_id', territoryId);
    return (response as List).map((e) => Beacon.fromMap(e)).toList();
  }

  static Future<void> placeBeacon(Beacon beacon) async {
    await client.from('beacons').insert(beacon.toMap());
  }

  // ---------- Tribes ----------
  static Future<Tribe?> createTribe(String name, String leaderId) async {
    final data = await client.from('tribes').insert({
      'name': name,
      'leader_id': leaderId,
    }).select().single();
    return Tribe.fromMap(data);
  }

  static Future<void> joinTribe(String profileId, String tribeId) async {
    await client.from('tribe_members').insert({
      'profile_id': profileId,
      'tribe_id': tribeId,
    });
  }

  // ---------- Token updates (increment) ----------
  static Future<void> addTokens(String profileId, String tokenType, int amount) async {
    final field = tokenType == 'sovereignty'
        ? 'sovereignty_tokens'
        : tokenType == 'care'
            ? 'care_tokens'
            : tokenType == 'art'
                ? 'art_tokens'
                : 'community_tokens';
    await client.rpc('increment_tokens', params: {
      'p_profile_id': profileId,
      'p_field': field,
      'p_amount': amount,
    });
  }

  // Get token balances from profile
  static Future<Map<String, int>> getTokenBalances(String profileId) async {
    final data = await client.from('profiles').select('sovereignty_tokens, care_tokens, art_tokens, community_tokens').eq('id', profileId).single();
    if (data == null) return {};
    return {
      'sovereignty': data['sovereignty_tokens'] as int,
      'care': data['care_tokens'] as int,
      'art': data['art_tokens'] as int,
      'community': data['community_tokens'] as int,
    };
  }
}