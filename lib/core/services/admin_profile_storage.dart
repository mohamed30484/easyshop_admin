import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/admin_model.dart';

class AdminProfileStorage {
  static const String profileKey = 'admin_profile';

  Future<void> save(AdminModel admin) async {
    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setString(profileKey, jsonEncode(admin.toJson()));

    if (!saved) {
      throw Exception('Failed to save admin profile.');
    }
  }

  Future<AdminModel?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(profileKey);

    if (profileJson == null || profileJson.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(profileJson);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return AdminModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasProfile() async {
    final admin = await get();

    return admin != null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(profileKey);
  }
}
