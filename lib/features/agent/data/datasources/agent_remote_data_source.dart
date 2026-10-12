import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/agent_property.dart';

/// Laravel Agent API only.
///
/// The parsers deliberately keep every map returned by the backend in
/// AgentProperty.raw / the POI map. The UI can therefore render fields even
/// when Laravel adds a new field that this Flutter version does not know about.
class AgentRemoteDataSource {
  Future<List<AgentProperty>> getProperties(String status) async {
    final response = await ApiClient.get(
      ApiEndpoints.agentProperties,
      queryParameters: {'status': status},
      authenticated: true,
    );

    final data = _findFirstList(response, const [
      'data',
      'properties',
      'items',
      'results',
    ]);

    return data
        .whereType<Map>()
        .map(
          (item) => AgentProperty.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id != 0)
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getPois() async {
    final response = await ApiClient.get(
      ApiEndpoints.agentPois,
      authenticated: true,
    );

    final data = _findFirstList(response, const [
      'data',
      'pois',
      'items',
      'results',
    ]);

    return data
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  Future<void> createPoi(Map<String, dynamic> body) async {
    await ApiClient.post(
      ApiEndpoints.agentPois,
      authenticated: true,
      body: body,
    );
  }

  Future<void> updatePoi(int id, Map<String, dynamic> body) async {
    await ApiClient.put(
      '${ApiEndpoints.agentPois}/$id',
      authenticated: true,
      body: body,
    );
  }

  Future<void> deletePoi(int id) async {
    await ApiClient.delete(
      '${ApiEndpoints.agentPois}/$id',
      authenticated: true,
    );
  }

  Future<void> submitLicense() async {
    await ApiClient.post(
      ApiEndpoints.agentLicense,
      authenticated: true,
    );
  }

  Future<void> approveProperty(int id) async {
    await ApiClient.put(
      '${ApiEndpoints.agentProperties}/$id/approve',
      authenticated: true,
    );
  }

  Future<void> rejectProperty(int id, {String? reason}) async {
    await ApiClient.put(
      '${ApiEndpoints.agentProperties}/$id/reject',
      authenticated: true,
      body: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
  }

  /// Finds a list through the common Laravel envelopes without dropping
  /// nested response data. If a future backend response adds another wrapper,
  /// the recursive fallback still finds the first list.
  List<dynamic> _findFirstList(dynamic value, List<String> preferredKeys) {
    if (value is List) return value;
    if (value is! Map) return const [];

    final map = value.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    for (final key in preferredKeys) {
      final candidate = map[key];
      if (candidate is List) return candidate;
      final nested = _findFirstList(candidate, preferredKeys);
      if (nested.isNotEmpty) return nested;
    }

    for (final entry in map.entries) {
      final nested = _findFirstList(entry.value, preferredKeys);
      if (nested.isNotEmpty) return nested;
    }

    return const [];
  }
}
