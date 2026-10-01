import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class MyPropertiesStorage {
  MyPropertiesStorage._();

  static const String _prefix = 'my_property_ids_';

  static Future<Set<int>> getIdsForCurrentUser() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null) return <int>{};

    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('$_prefix$userId') ?? const <String>[];

    return values
        .map((value) => int.tryParse(value))
        .whereType<int>()
        .where((value) => value > 0)
        .toSet();
  }

  static Future<void> remember(int propertyId) async {
    if (propertyId <= 0) return;

    final userId = await TokenStorage.getUserId();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$userId';
    final values = prefs.getStringList(key) ?? <String>[];

    if (!values.contains(propertyId.toString())) {
      values.add(propertyId.toString());
      await prefs.setStringList(key, values);
    }
  }
}
