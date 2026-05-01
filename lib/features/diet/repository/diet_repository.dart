import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/diet_models.dart';

class DietRepository {
  static const _entriesKey = 'diet_entries_v1';
  static const _profileKey = 'diet_profile_v1';

  Future<List<DietEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_entriesKey);
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => DietEntry.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> saveEntries(List<DietEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = entries
        .map((item) => item.toJson())
        .toList(growable: false);
    await prefs.setString(_entriesKey, jsonEncode(payload));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    return UserProfile.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
