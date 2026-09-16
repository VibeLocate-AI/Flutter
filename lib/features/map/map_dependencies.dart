import 'data/datasources/map_remote_data_source.dart';
import 'data/models/map_location_model.dart';
import 'data/repositories/map_repository_impl.dart';
import 'domain/repositories/map_repository.dart';
import 'domain/usecases/get_map_locations.dart';
abstract final class MapDependencies {
  static final MapRepository _repository = MapRepositoryImpl(remoteDataSource: const MapRemoteDataSourceImpl());
  static Future<List<MapLocationModel>> getLocations() => GetMapLocations(_repository).call();
}
