import 'data/datasources/favorites_remote_data_source.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'domain/usecases/favorites_usecases.dart';

class FavoritesDependencies {
  FavoritesDependencies._();

  static final FavoritesRemoteDataSource remoteDataSource =
      const FavoritesRemoteDataSourceImpl();

  static final FavoritesRepositoryImpl repository =
      FavoritesRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

  static final GetFavorites getFavorites =
      GetFavorites(repository);

  static final AddFavorite addFavorite =
      AddFavorite(repository);

  static final RemoveFavorite removeFavorite =
      RemoveFavorite(repository);
}
