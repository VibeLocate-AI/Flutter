import '../../data/models/favorite_property_model.dart';

abstract class FavoritesRepository {
  Future<List<FavoritePropertyModel>> getFavorites();

  Future<void> addFavorite(int propertyId);

  Future<void> removeFavorite(int propertyId);
}
