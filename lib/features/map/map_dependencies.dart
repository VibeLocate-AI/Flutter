import 'data/datasources/map_remote_data_source.dart';
import 'data/repositories/map_repository_impl.dart';
import 'domain/usecases/get_map_locations.dart';

class MapDependencies {
  MapDependencies._();

  static final MapRemoteDataSource remoteDataSource =
      MapRemoteDataSourceImpl();

  static final MapRepositoryImpl repository =
      MapRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

  static final GetMapLocations getLocations =
      GetMapLocations(repository);
}
