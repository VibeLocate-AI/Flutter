import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/favorite_property_model.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoritePropertyModel>> getFavorites();
  Future<void> addFavorite(int propertyId);
  Future<void> removeFavorite(int propertyId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  const FavoritesRemoteDataSourceImpl();

  static dynamic _findList(dynamic source) {
    if (source is List) return source;
    if (source is! Map) return null;

    const keys = [
      'favorites',
      'saved_properties',
      'items',
      'properties',
      'results',
      'records',
      'data',
    ];

    for (final key in keys) {
      final value = source[key];
      if (value is List) return value;
      final nested = _findList(value);
      if (nested is List) return nested;
    }

    return null;
  }

  @override
  Future<List<FavoritePropertyModel>> getFavorites() async {
    final response = await ApiClient.get(
      ApiEndpoints.favorites,
      authenticated: true,
    );

    final data = _findList(response);
    if (data is! List) return const [];

    return data
        .whereType<Map>()
        .map(
          (item) => FavoritePropertyModel.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id > 0)
        .toList(growable: false);
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
