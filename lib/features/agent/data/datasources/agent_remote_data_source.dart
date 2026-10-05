import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/agent_property.dart';

class AgentRemoteDataSource {
  Future<List<AgentProperty>> getProperties(String status) async {
    final response = await ApiClient.get(
      ApiEndpoints.agentProperties,
      queryParameters: {
        'status': status,
      },
      authenticated: true,
    );

    dynamic data = response['data'] ?? response['properties'];
    if (data is Map) {
      data = data['properties'] ?? data['data'] ?? data['items'];
    }

    if (data is! List) return const [];

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

    dynamic data = response['data'] ?? response['pois'];
    if (data is Map) {
      data = data['pois'] ?? data['items'] ?? data['data'];
    }

    if (data is! List) return const [];

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

  Future<void> updatePoi(
    int id,
    Map<String, dynamic> body,
  ) async {
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
}
