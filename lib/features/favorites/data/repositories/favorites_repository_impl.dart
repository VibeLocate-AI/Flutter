import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_data_source.dart';
import '../models/favorite_property_model.dart';

class FavoritesRepositoryImpl
    implements FavoritesRepository {
  const FavoritesRepositoryImpl({
    required this.remoteDataSource,
  });

  final FavoritesRemoteDataSource remoteDataSource;

  @override
  Future<List<FavoritePropertyModel>> getFavorites() {
    return remoteDataSource.getFavorites();
  }

  @override
  Future<void> addFavorite(int propertyId) {
    return remoteDataSource.addFavorite(propertyId);
  }

  @override
  Future<void> removeFavorite(int propertyId) {
    return remoteDataSource.removeFavorite(propertyId);
  }
}
