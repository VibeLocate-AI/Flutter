import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

abstract class AiSearchRemoteDataSource {
  Future<Map<String, dynamic>> search(String query);
}

class AiSearchRemoteDataSourceImpl
    implements AiSearchRemoteDataSource {
  const AiSearchRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> search(String query) {
    return ApiClient.post(
      ApiEndpoints.aiContextualSearch,
      body: {
        'query': query,
      },
    );
  }
}