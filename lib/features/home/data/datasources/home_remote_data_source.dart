import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHome();
}

class HomeRemoteDataSourceImpl
    implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getHome() async {
    final language = _languageCode();

    final position =
        await LocationService.instance
            .getCurrentLocation();

    final query = <String, dynamic>{
      'per_page': 100,
    };

    if (position != null) {
      query['sort'] = 'nearby';
      query['latitude'] = position.latitude;
      query['longitude'] = position.longitude;
    }

    final results = await Future.wait([
      // Aggregate Home endpoint from Laravel.
      _safeGet(ApiEndpoints.home(language)),
      _safeGet(
        ApiEndpoints.homeFeaturedProperties(language),
      ),
      _safeGet(
        ApiEndpoints.homeRecommendedProperties(language),
      ),
      _safeGet(
        ApiEndpoints.homePopularAreas(language),
      ),
      _safeGet(
        ApiEndpoints.homeTopAgents(language),
      ),
    ]);

    final aggregateData = _extractData(results[0]);
    final featuredData = _extractData(results[1]);
    final recommendedData = _extractData(results[2]);
    final popularAreasData = _extractData(results[3]);
    final topAgentsData = _extractData(results[4]);

    final paginatedProperties = await _fetchAllProperties(query);
    final aggregateProperties = _extractPropertyList(
      aggregateData,
      key: 'properties',
    );
    final properties = _uniqueById([
      ...aggregateProperties,
      ...paginatedProperties,
    ]);

    if (results.every((result) => result.isEmpty) && properties.isEmpty) {
      throw const NetworkException(
        'No internet connection. Please try again.',
      );
    }

    final featured = _uniqueById([
      ..._extractPropertyList(aggregateData, key: 'featured_properties'),
      ..._extractPropertyList(featuredData, key: 'featured_properties'),
    ]);

    final recommended = _uniqueById([
      ..._extractPropertyList(aggregateData, key: 'recommended_properties'),
      ..._extractPropertyList(recommendedData, key: 'recommended_properties'),
    ]);

    final popularAreas = <Map<String, dynamic>>[
      ..._extractList(aggregateData['popular_areas']),
      ..._extractList(popularAreasData['popular_areas']),
    ];

    final topAgents = <Map<String, dynamic>>[
      ..._extractList(aggregateData['top_agents']),
      ..._extractList(topAgentsData['top_agents']),
    ];

    return {
      'success': true,
      'data': {
        'language': language,
        'total': properties.length,
        'featured_properties': featured,
        'recommended_properties': recommended,
        'popular_areas': _uniqueMaps(popularAreas),
        'top_agents': _uniqueMaps(topAgents),
        'properties': properties,
        'recommendation_mode': 'recommended',
        'user_location': position == null
            ? null
            : {
                'latitude': position.latitude,
                'longitude': position.longitude,
              },
      },
    };
  }

  Future<List<Map<String, dynamic>>> _fetchAllProperties(
    Map<String, dynamic> query,
  ) async {
    final collected = <Map<String, dynamic>>[];
    final seen = <int>{};
    var page = 1;
    var lastPage = 1;

    while (page <= lastPage && page <= 50) {
      Map<String, dynamic> response;
      try {
        response = await _safeGet(
          ApiEndpoints.properties,
          queryParameters: {
            ...query,
            'page': page,
          },
        );
      } catch (_) {
        break;
      }

      final items = _extractPropertyList(response);
      for (final item in items) {
        final id = _toInt(item['id']);
        if (id == 0 || seen.add(id)) {
          collected.add(item);
        }
      }

      final pagination = _pagination(response);
      lastPage = _toInt(
            pagination?['last_page'] ??
                pagination?['total_pages'],
          )
          .clamp(1, 50)
          .toInt();

      if (pagination == null && items.length < (query['per_page'] as int? ?? 100)) {
        break;
      }
      if (items.isEmpty) break;
      page++;
    }

    return collected;
  }

  Map<String, dynamic>? _pagination(
    Map<String, dynamic> response,
  ) {
    final direct = response['pagination'];
    if (direct is Map<String, dynamic>) return direct;

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nested = data['pagination'];
      if (nested is Map<String, dynamic>) return nested;
    }
    return null;
  }

  Future<Map<String, dynamic>> _safeGet(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await ApiClient.get(
        endpoint,
        queryParameters: queryParameters,
        authenticated: true,
      );
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _languageCode() {
    final code =
        LocaleManager.instance.languageCode
            .toLowerCase();

    return code == 'ar' ? 'ar' : 'en';
  }

  Map<String, dynamic> _extractData(
    Map<String, dynamic> response,
  ) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      return data;
    }

    return response;
  }

  List<Map<String, dynamic>> _extractPropertyList(
    Map<String, dynamic> response, {
    String? key,
  }) {
    dynamic value = key == null
        ? response['data']
        : response[key];

    if (value is Map<String, dynamic>) {
      value =
          value['properties'] ??
          value['data'];
    }

    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> _uniqueById(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <int>{};
    return items.where((item) {
      final id = _toInt(item['id']);
      if (id == 0) return true;
      return seen.add(id);
    }).toList();
  }

  List<Map<String, dynamic>> _uniqueMaps(
    List<Map<String, dynamic>> items,
  ) {
    final seen = <String>{};
    return items.where((item) {
      final id = item['id']?.toString();
      final name = item['name']?.toString() ?? item['title']?.toString() ?? '';
      final key = (id == null || id.isEmpty) ? name : id;
      if (key.isEmpty) return true;
      return seen.add(key);
    }).toList();
  }

  List<Map<String, dynamic>> _extractList(
    dynamic value,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  int _toInt(dynamic value) {
    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
