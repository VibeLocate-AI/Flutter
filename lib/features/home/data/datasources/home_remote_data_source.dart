import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHome();
}

class HomeRemoteDataSourceImpl
    implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getHome() {
    return ApiClient.get(
      ApiEndpoints.home,
      authenticated: true,
    );
  }
}