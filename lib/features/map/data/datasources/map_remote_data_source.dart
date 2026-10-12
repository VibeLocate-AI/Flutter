import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/state/location_manager.dart';
import '../../../../core/network/api_client.dart';

abstract class MapRemoteDataSource {
  Future<Map<String, dynamic>> getMap();
}

class MapRemoteDataSourceImpl
    implements MapRemoteDataSource {
  const MapRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getMap() async {
    final location = LocationManager.instance;
    final query = <String, dynamic>{};

    if (location.hasCurrentLocation &&
        location.latitude != null &&
        location.longitude != null) {
      query['latitude'] = location.latitude;
      query['longitude'] = location.longitude;
    }

    return ApiClient.get(
      ApiEndpoints.map,
      queryParameters: query,
      authenticated: true,
    );
  }
}
