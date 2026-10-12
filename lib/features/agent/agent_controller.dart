import 'package:get/get.dart';

import 'data/datasources/agent_remote_data_source.dart';
import '../../core/storage/agent_cache_storage.dart';
import 'data/models/agent_property.dart';

class AgentController extends GetxController {
  AgentController({AgentRemoteDataSource? dataSource})
      : dataSource = dataSource ?? AgentRemoteDataSource();

  final AgentRemoteDataSource dataSource;

  final pending = <AgentProperty>[].obs;
  final approved = <AgentProperty>[].obs;
  final rejected = <AgentProperty>[].obs;
  final pois = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final error = RxnString();
  final hasLoaded = false.obs;

  Future<void> load() async {
    if (isLoading.value) return;

    error.value = null;

    // Cache-first: restore the last successful Agent payload before touching
    // the network. The API remains the source of truth and refreshes it below.
    if (!hasLoaded.value &&
        pending.isEmpty &&
        approved.isEmpty &&
        rejected.isEmpty &&
        pois.isEmpty) {
      try {
        final cached = await AgentCacheStorage.read();
        if (cached != null) {
          pending.assignAll(_parseCachedProperties(cached['pending']));
          approved.assignAll(_parseCachedProperties(cached['approved']));
          rejected.assignAll(_parseCachedProperties(cached['rejected']));
          pois.assignAll(cached['pois'] ?? const <Map<String, dynamic>>[]);
          hasLoaded.value = true;
        }
      } catch (_) {}
    }

    isLoading.value =
        pending.isEmpty && approved.isEmpty && rejected.isEmpty && pois.isEmpty;

    try {
      final results = await Future.wait<dynamic>([
        _safeProperties('pending'),
        _safeProperties('approved'),
        _safeProperties('rejected'),
        _safePois(),
      ]);

      final freshPending = results[0] as List<AgentProperty>?;
      final freshApproved = results[1] as List<AgentProperty>?;
      final freshRejected = results[2] as List<AgentProperty>?;
      final freshPois = results[3] as List<Map<String, dynamic>>?;

      if (freshPending != null) pending.assignAll(freshPending);
      if (freshApproved != null) approved.assignAll(freshApproved);
      if (freshRejected != null) rejected.assignAll(freshRejected);
      if (freshPois != null) pois.assignAll(freshPois);
      hasLoaded.value = true;

      // Only overwrite persistent cache with successful endpoint results.
      // A temporary Render/network failure must never erase good cached data.
      await AgentCacheStorage.save(
        pending: pending
            .map((item) => item.raw)
            .where((item) => item.isNotEmpty)
            .toList(),
        approved: approved
            .map((item) => item.raw)
            .where((item) => item.isNotEmpty)
            .toList(),
        rejected: rejected
            .map((item) => item.raw)
            .where((item) => item.isNotEmpty)
            .toList(),
        pois: pois.toList(growable: false),
      );
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  List<AgentProperty> _parseCachedProperties(dynamic value) {
    if (value is! List) return const <AgentProperty>[];
    return value.whereType<Map>().map((item) {
      final json = item.map((key, value) => MapEntry(key.toString(), value));
      return AgentProperty.fromJson(json);
    }).where((item) => item.id > 0).toList(growable: false);
  }

  Future<List<AgentProperty>?> _safeProperties(String status) async {
    try {
      return await dataSource.getProperties(status);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> _safePois() async {
    try {
      return await dataSource.getPois();
    } catch (_) {
      return null;
    }
  }

  Future<void> createPoi(Map<String, dynamic> body) async {
    await dataSource.createPoi(body);
    await load();
  }

  Future<void> updatePoi(
    int id,
    Map<String, dynamic> body,
  ) async {
    await dataSource.updatePoi(id, body);
    await load();
  }

  Future<void> deletePoi(int id) async {
    await dataSource.deletePoi(id);
    pois.removeWhere((poi) {
      final poiId = int.tryParse((poi['id'] ?? poi['osm_id'] ?? '').toString());
      return poiId == id;
    });
    pois.refresh();
  }

  Future<void> submitLicense() => dataSource.submitLicense();

  Future<void> approve(int id) async {
    await dataSource.approveProperty(id);
    await load();
  }

  Future<void> reject(int id, {String? reason}) async {
    await dataSource.rejectProperty(id, reason: reason);
    await load();
  }
}
