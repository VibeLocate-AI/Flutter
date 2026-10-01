import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/network/api_client.dart';

abstract class MapRemoteDataSource {
  Future<Map<String, dynamic>> getMap();
}

class MapRemoteDataSourceImpl
    implements MapRemoteDataSource {
  const MapRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getMap() async {
    final position =
        await LocationService.instance
            .getCurrentLocation();

    final query = <String, dynamic>{};

    if (position != null) {
      query['latitude'] = position.latitude;
      query['longitude'] = position.longitude;
    }

    return ApiClient.get(
      ApiEndpoints.map,
      queryParameters: query,
      authenticated: true,
    );
  }
}
