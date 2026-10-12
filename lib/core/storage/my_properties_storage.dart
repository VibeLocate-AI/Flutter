import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class MyPropertiesStorage {
  MyPropertiesStorage._();

  static const String _prefix = 'my_property_ids_';
  static const String _cachePrefix = 'my_properties_cache_v2_';

  static Future<String?> _userKey() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null && userId > 0) return userId.toString();

    final email = await TokenStorage.getEmail();
    if (email != null && email.trim().isNotEmpty) {
      return email.trim().toLowerCase();
    }

    return null;
  }

  static Future<Set<int>> getIdsForCurrentUser() async {
    final userKey = await _userKey();
    if (userKey == null) return <int>{};

    final prefs = await SharedPreferences.getInstance();
    final values =
        prefs.getStringList('$_prefix$userKey') ?? const <String>[];

    return values
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .where((value) => value > 0)
        .toSet();
  }

  static Future<void> remember(int propertyId) async {
    if (propertyId <= 0) return;

    final userKey = await _userKey();
    if (userKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$userKey';
    final values = prefs.getStringList(key) ?? <String>[];

    if (!values.contains(propertyId.toString())) {
      values.add(propertyId.toString());
      await prefs.setStringList(key, values);
    }
  }

  /// Stores the complete property payload returned by the add/list API.
  /// This is an optimistic first-paint cache only; the backend remains the
  /// source of truth whenever /api/my-properties returns the property.
  static Future<void> cacheProperty(Map<String, dynamic> property) async {
    final rawId = property['id'] ?? property['property_id'];
    final propertyId = int.tryParse(rawId?.toString() ?? '');
    if (propertyId == null || propertyId == 0) return;

    final userKey = await _userKey();
    if (userKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_cachePrefix$userKey';

    final existing = await getCachedProperties();
    final normalized = Map<String, dynamic>.from(property);
    normalized['id'] = propertyId;

    final merged = <int, Map<String, dynamic>>{
      for (final item in existing)
        if (_propertyId(item) > 0) _propertyId(item): item,
    };

    merged[propertyId] = {
      ...(merged[propertyId] ?? const <String, dynamic>{}),
      ...normalized,
    };

    final values = merged.values.toList();
    if (values.length > 100) {
      values.removeRange(100, values.length);
    }

    await prefs.setStringList(
      key,
      values
          .map((item) => jsonEncode(item))
          .toList(growable: false),
    );

    await remember(propertyId);
  }

  static Future<void> removeCachedProperty(int propertyId) async {
    if (propertyId == 0) return;
    final userKey = await _userKey();
    if (userKey == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_cachePrefix$userKey';
    final values = prefs.getStringList(key) ?? const <String>[];
    final kept = <String>[];
    for (final value in values) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final map = decoded.map((k, v) => MapEntry(k.toString(), v));
          if (_propertyId(map) != propertyId) kept.add(value);
        }
      } catch (_) {
        // Drop malformed entries while normalizing this user's cache.
      }
    }
    await prefs.setStringList(key, kept);
  }

  static Future<List<Map<String, dynamic>>> getCachedProperties() async {
    final userKey = await _userKey();
    if (userKey == null) return const [];

    final prefs = await SharedPreferences.getInstance();
    final values =
        prefs.getStringList('$_cachePrefix$userKey') ?? const <String>[];

    final result = <Map<String, dynamic>>[];
    for (final value in values) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          final map = decoded.map(
            (key, item) => MapEntry(key.toString(), item),
          );
          if (_propertyId(map) != 0) result.add(map);
        }
      } catch (_) {
        // Ignore one malformed cache entry and keep the rest.
      }
    }

    return result;
  }

  static int _propertyId(Map<String, dynamic> property) {
    return int.tryParse(
          (property['id'] ?? property['property_id'] ?? '').toString(),
        ) ??
        0;
  }
}
