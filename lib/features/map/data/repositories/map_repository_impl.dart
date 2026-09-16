import '../datasources/map_remote_data_source.dart';
import '../models/map_location_model.dart';
import '../../domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  const MapRepositoryImpl({required this.remoteDataSource});
  final MapRemoteDataSource remoteDataSource;
  @override Future<List<MapLocationModel>> getLocations() async {
    final response = await remoteDataSource.getMap();
    dynamic value = response['data'];
    if (value is Map<String,dynamic>) value = value['locations'] ?? value['properties'] ?? value['markers'] ?? value['data'];
    value ??= response['locations'] ?? response['properties'] ?? response['markers'];
    if (value is! List) return const [];
    return value.whereType<Map<String,dynamic>>().map(MapLocationModel.fromJson).where((m) => m.latitude != 0 && m.longitude != 0).toList();
  }
}
