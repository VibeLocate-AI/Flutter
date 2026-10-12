import 'json_cache_storage.dart';
import 'token_storage.dart';

/// Persistent cache for favorites.
///
/// `overrides` stores the user's last explicit add/remove action. This is
/// important because the Laravel list endpoint can be eventually consistent:
/// an item that was just added must not disappear from the UI just because a
/// background GET still returns the old list.
class FavoritesCacheStorage {
  FavoritesCacheStorage._();

  static const _keyPrefix = 'favorites_cache_v4_';

  static Future<String?> _userKey() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null && userId > 0) return userId.toString();

    final email = await TokenStorage.getEmail();
    if (email != null && email.trim().isNotEmpty) {
      return email.trim().toLowerCase();
    }

    return null;
  }

  static Future<String?> _keyForCurrentUser() async {
    final userKey = await _userKey();
    if (userKey == null) return null;
    return '$_keyPrefix$userKey';
  }

  static Future<void> save({
    required List<int> ids,
    required List<Map<String, dynamic>> items,
    required Map<int, bool> overrides,
  }) async {
    final key = await _keyForCurrentUser();
    if (key == null) return;
    await JsonCacheStorage.write(key, {
      'ids': ids,
      'items': items,
      'overrides': overrides.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    });
  }

  static Future<Map<String, dynamic>?> read() async {
    final key = await _keyForCurrentUser();
    if (key == null) return null;
    return JsonCacheStorage.readMap(key);
  }
}
