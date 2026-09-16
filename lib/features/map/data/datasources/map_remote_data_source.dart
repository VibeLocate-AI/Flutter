import '../../../../core/network/api_client.dart';

abstract class MapRemoteDataSource { Future<Map<String, dynamic>> getMap(); }
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  const MapRemoteDataSourceImpl();
  @override Future<Map<String, dynamic>> getMap() => ApiClient.get('/api/map', authenticated: true);
}
