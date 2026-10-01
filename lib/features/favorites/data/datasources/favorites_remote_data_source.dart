import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/favorite_property_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoritePropertyModel>> getFavorites();

  Future<void> addFavorite(int propertyId);

  Future<void> removeFavorite(int propertyId);
}

class FavoritesRemoteDataSourceImpl
    implements FavoritesRemoteDataSource {
  const FavoritesRemoteDataSourceImpl();

  @override
  Future<List<FavoritePropertyModel>> getFavorites() async {
    final response = await ApiClient.get(
      ApiEndpoints.favorites,
      authenticated: true,
    );

    dynamic data = response['data'];
    if (data is Map<String, dynamic>) {
      data = data['favorites'] ?? data['saved_properties'] ?? data['items'] ?? data['data'];
    }
    data ??= response['favorites'] ?? response['saved_properties'] ?? response['items'];

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map>()
        .map((item) => FavoritePropertyModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ))
        .toList();
  }

  @override
  Future<void> addFavorite(int propertyId) async {
    await ApiClient.post(
      ApiEndpoints.favorite(propertyId),
      authenticated: true,
    );
  }

  @override
  Future<void> removeFavorite(int propertyId) async {
    await ApiClient.delete(
      ApiEndpoints.favorite(propertyId),
      authenticated: true,
    );
  }
}
