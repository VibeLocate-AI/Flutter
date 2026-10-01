import '../../data/models/favorite_property_model.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  const GetFavorites(this.repository);

  final FavoritesRepository repository;

  Future<List<FavoritePropertyModel>> call() {
    return repository.getFavorites();
  }
}

class AddFavorite {
  const AddFavorite(this.repository);

  final FavoritesRepository repository;

  Future<void> call(int propertyId) {
    return repository.addFavorite(propertyId);
  }
}

class RemoveFavorite {
  const RemoveFavorite(this.repository);

  final FavoritesRepository repository;

  Future<void> call(int propertyId) {
    return repository.removeFavorite(propertyId);
  }
}
