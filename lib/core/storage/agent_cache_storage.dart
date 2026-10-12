import 'json_cache_storage.dart';

class AgentCacheStorage {
  AgentCacheStorage._();

  static const _pendingKey = 'agent_cache_pending_v1';
  static const _approvedKey = 'agent_cache_approved_v1';
  static const _rejectedKey = 'agent_cache_rejected_v1';
  static const _poisKey = 'agent_cache_pois_v1';

  static Future<void> save({
    required List<Map<String, dynamic>> pending,
    required List<Map<String, dynamic>> approved,
    required List<Map<String, dynamic>> rejected,
    required List<Map<String, dynamic>> pois,
  }) async {
    await Future.wait([
      JsonCacheStorage.write(_pendingKey, pending),
      JsonCacheStorage.write(_approvedKey, approved),
      JsonCacheStorage.write(_rejectedKey, rejected),
      JsonCacheStorage.write(_poisKey, pois),
    ]);
  }

  static Future<Map<String, List<Map<String, dynamic>>>?> read() async {
    final values = await Future.wait([
      JsonCacheStorage.readList(_pendingKey),
      JsonCacheStorage.readList(_approvedKey),
      JsonCacheStorage.readList(_rejectedKey),
      JsonCacheStorage.readList(_poisKey),
    ]);

    final lists = values.map((value) {
      if (value == null) return <Map<String, dynamic>>[];
      return value.whereType<Map>().map((item) {
        return item.map((key, value) => MapEntry(key.toString(), value));
      }).toList(growable: false);
    }).toList();

    final hasAny = lists.any((items) => items.isNotEmpty);
    if (!hasAny) return null;

    return {
      'pending': lists[0],
      'approved': lists[1],
      'rejected': lists[2],
      'pois': lists[3],
    };
  }
}
