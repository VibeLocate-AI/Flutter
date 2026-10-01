import '../../../../core/network/api_client.dart';
import '../models/agent_property.dart';

class AgentRemoteDataSource {
  Future<List<AgentProperty>> getProperties(String status) async {
    final response = await ApiClient.get(
      '/api/agent/properties',
      queryParameters: {
        'status': status,
        'per_page': 100,
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
      '/api/agent/pois',
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
      '/api/agent/pois',
      authenticated: true,
      body: body,
    );
  }

  Future<void> updatePoi(
    int id,
    Map<String, dynamic> body,
  ) async {
    await ApiClient.put(
      '/api/agent/pois/$id',
      authenticated: true,
      body: body,
    );
  }

  Future<void> deletePoi(int id) async {
    await ApiClient.delete(
      '/api/agent/pois/$id',
      authenticated: true,
    );
  }

  Future<void> submitLicense() async {
    await ApiClient.post(
      '/api/agent/onboarding/license',
      authenticated: true,
    );
  }

  Future<void> approveProperty(int id) async {
    await ApiClient.put(
      '/api/agent/properties/$id/approve',
      authenticated: true,
    );
  }

  Future<void> rejectProperty(int id) async {
    await ApiClient.put(
      '/api/agent/properties/$id/reject',
      authenticated: true,
    );
  }
}
