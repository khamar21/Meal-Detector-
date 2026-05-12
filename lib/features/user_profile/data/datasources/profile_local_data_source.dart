import 'dart:convert';

import 'package:food_calorie_frontend/core/architecture/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';

/// Local data source for user profile
class ProfileLocalDataSource extends LocalDataSource {
  const ProfileLocalDataSource();

  static const String _profileKey = 'user_profile_v1';

  /// Load user profile from local storage
  Future<UserProfileModel?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_profileKey);

      if (raw == null || raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return UserProfileModel.fromJson(decoded);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to load profile from local storage',
        originalError: e,
      );
    }
  }

  /// Save user profile to local storage
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(profile.toJson());
      await prefs.setString(_profileKey, encoded);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to save profile to local storage',
        originalError: e,
      );
    }
  }

  /// Delete user profile
  Future<void> deleteProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (e) {
      throw CacheFailure(message: 'Failed to delete profile', originalError: e);
    }
  }

  /// Check if profile exists
  Future<bool> profileExists() async {
    try {
      final profile = await loadProfile();
      return profile != null;
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to check if profile exists',
        originalError: e,
      );
    }
  }
}
