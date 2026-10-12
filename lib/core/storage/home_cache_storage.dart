import 'json_cache_storage.dart';

class HomeCacheStorage {
  HomeCacheStorage._();

  static const _prefix = 'home_cache_v2_';

  static String _key(String language) => '$_prefix$language';

  static Future<void> save(
    String language,
    Map<String, dynamic> data,
  ) {
    return JsonCacheStorage.write(_key(language), data);
  }

  static Future<Map<String, dynamic>?> read(String language) {
    return JsonCacheStorage.readMap(_key(language));
  }
}
