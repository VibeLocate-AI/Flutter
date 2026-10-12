import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/state/location_manager.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/home_cache_storage.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHome();
  Future<Map<String, dynamic>?> getCachedHome();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>?> getCachedHome() {
    return HomeCacheStorage.read(_languageCode());
  }

  @override
  Future<Map<String, dynamic>> getHome() async {
    final language = _languageCode();
    final location = LocationManager.instance;
    final query = <String, dynamic>{'per_page': 100};

    // Never wait for GPS before loading Home. Cached coordinates are used when
    // available; the location manager can refresh them independently.
    if (location.hasCurrentLocation &&
        location.latitude != null &&
        location.longitude != null) {
      query.addAll({
        'sort': 'nearby',
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
    }

    Map<String, dynamic> aggregate = const {};
    try {
      aggregate = await ApiClient.get(
        ApiEndpoints.home(language),
        queryParameters: query,
        authenticated: false,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      aggregate = const {};
    }

    final data = _extractMap(aggregate['data']) ?? aggregate;

    var properties = _extractPropertyList(data, key: 'properties');
    var featured = _extractPropertyList(data, key: 'featured_properties');
    var recommended =
        _extractPropertyList(data, key: 'recommended_properties');
    var popularAreas = _extractListFromResponse(data, 'popular_areas');
    var topAgents = _extractListFromResponse(data, 'top_agents');

    // Some Laravel endpoints return {data: [...]} instead of
    // {data: {featured_properties: [...]}}. The previous parser ignored those
    // valid responses and Home ended up showing "Unable to load home data".
    // Each endpoint is therefore parsed independently and accepts both forms.
    final requests = <Future<Map<String, dynamic>>>[];

    if (featured.isEmpty) {
      requests.add(
        _safeGet(ApiEndpoints.homeFeaturedProperties(language)),
      );
    }
    if (recommended.isEmpty) {
      requests.add(
        _safeGet(ApiEndpoints.homeRecommendedProperties(language)),
      );
    }
    if (popularAreas.isEmpty) {
      requests.add(
        _safeGet(ApiEndpoints.homePopularAreas(language)),
      );
    }
    if (topAgents.isEmpty) {
      requests.add(
        _safeGet(ApiEndpoints.homeTopAgents(language)),
      );
    }

    if (requests.isNotEmpty) {
      final results = await Future.wait(requests);
      var index = 0;

      if (featured.isEmpty) {
        final response = results[index++];
        featured = _extractPropertyList(response, key: 'featured_properties');
      }
      if (recommended.isEmpty) {
        final response = results[index++];
        recommended =
            _extractPropertyList(response, key: 'recommended_properties');
      }
      if (popularAreas.isEmpty) {
        final response = results[index++];
        popularAreas = _extractListFromResponse(response, 'popular_areas');
      }
      if (topAgents.isEmpty) {
        final response = results[index++];
        topAgents = _extractListFromResponse(response, 'top_agents');
      }
    }

    // If the aggregate endpoint does not include properties, use one page of
    // the normal properties endpoint. Do not crawl dozens of pages on Home.
    if (properties.isEmpty) {
      try {
        final response = await ApiClient.get(
          ApiEndpoints.propertiesPage(1),
          queryParameters: query,
          authenticated: true,
        );
        properties = _extractPropertyList(response);
      } catch (_) {}
    }

    if (properties.isEmpty &&
        featured.isEmpty &&
        recommended.isEmpty &&
        popularAreas.isEmpty &&
        topAgents.isEmpty) {
      throw const NetworkException('Unable to load VibeLocate data.');
    }

    final result = <String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'language': language,
        'total': _toInt(data['total']) > 0
            ? _toInt(data['total'])
            : properties.length,
        'featured_properties': _uniqueById(featured),
        'recommended_properties': _uniqueById(recommended),
        'popular_areas': _uniqueMaps(popularAreas),
        'top_agents': _uniqueMaps(topAgents),
        'properties': _uniqueById(properties),
        'recommendation_mode':
            data['recommendation_mode']?.toString() ?? 'recommended',
        'user_location': location.hasCurrentLocation
            ? {
                'latitude': location.latitude,
                'longitude': location.longitude,
              }
            : null,
      },
    };

    // Save exactly the normalized payload consumed by HomeModel. On the next
    // launch the same structure is rendered immediately before the API call.
    try {
      await HomeCacheStorage.save(
        language,
        result['data'] as Map<String, dynamic>,
      );
    } catch (_) {}

    return result;
  }

  Future<Map<String, dynamic>> _safeGet(String endpoint) async {
    try {
      return await ApiClient.get(
        endpoint,
        authenticated: false,
      );
    } catch (_) {
      return const {};
    }
  }

  Map<String, dynamic>? _extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return null;
  }

  List<Map<String, dynamic>> _extractPropertyList(
    Map<String, dynamic> response, {
    String? key,
  }) {
    dynamic value;

    if (key != null && response[key] != null) {
      value = response[key];
    } else if (key != null && response['data'] is Map) {
      final data = _extractMap(response['data']);
      value = data?[key];
    }

    // Important: Laravel may return a direct list in `data` for endpoints
    // such as /featured-properties and /recommended-properties.
    value ??= response['data'];
    value ??= response['items'];
    value ??= response['results'];
    value ??= response['properties'];

    if (value is Map) {
      final map = _extractMap(value);
      value = map?['properties'] ??
          map?['items'] ??
          map?['results'] ??
          map?['data'];
    }

    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _extractListFromResponse(
    Map<String, dynamic> response,
    String key,
  ) {
    dynamic value = response[key];

    if (value == null && response['data'] is Map) {
      value = _extractMap(response['data'])?[key];
    }

    // Endpoints such as /popular-areas and /top-agents can return
    // {data: [...]} directly.
    value ??= response['data'];
    value ??= response['items'];
    value ??= response['results'];

    if (value is Map) {
      final map = _extractMap(value);
      value = map?['items'] ??
          map?['results'] ??
          map?['data'];
    }

    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _uniqueById(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <int>{};
    return items.where((item) {
      final id = _toInt(
        item['id'] ?? item['property_id'] ?? item['user_id'],
      );
      return id == 0 || seen.add(id);
    }).toList(growable: false);
  }

  List<Map<String, dynamic>> _uniqueMaps(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <String>{};
    return items.where((item) {
      final key =
          '${item['id'] ?? ''}|${item['name'] ?? ''}|${item['title'] ?? ''}';
      return seen.add(key);
    }).toList(growable: false);
  }

  int _toInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;

  String _languageCode() =>
      LocaleManager.instance.isArabic ? 'ar' : 'en';
}
