import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small persistent JSON cache used as a cache-first layer.
///
/// The cache is never treated as the source of truth: screens render it first
/// and then refresh from the API in the background. This keeps the UI fast
/// after an app restart without changing the data returned by the backend.
class JsonCacheStorage {
  JsonCacheStorage._();

  static Future<void> write(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  static Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;

    try {
      return jsonDecode(raw);
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> readMap(String key) async {
    final value = await read(key);
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static Future<List<dynamic>?> readList(String key) async {
    final value = await read(key);
    return value is List ? value : null;
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
