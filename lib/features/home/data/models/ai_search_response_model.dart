import 'property_model.dart';

class AiSearchResponseModel {
  const AiSearchResponseModel({
    required this.success,
    required this.query,
    required this.searchMode,
    required this.understood,
    required this.exactMatches,
    required this.totalResults,
    required this.properties,
  });

  final bool success;
  final String query;
  final String searchMode;
  final AiSearchUnderstandingModel understood;
  final int exactMatches;
  final int totalResults;
  final List<AiSearchPropertyModel> properties;

  factory AiSearchResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final source = _deepestDataMap(json);
    final understoodJson =
        source['understood'] ??
        source['ai_understanding'] ??
        json['understood'] ??
        json['ai_understanding'];

    final propertiesJson =
        source['properties'] ??
        source['results'] ??
        source['items'] ??
        json['properties'] ??
        json['results'] ??
        json['items'];

    final properties = propertiesJson is List
        ? propertiesJson
            .whereType<Map>()
            .map((item) => AiSearchPropertyModel.fromJson(
                  item.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList()
        : const <AiSearchPropertyModel>[];

    return AiSearchResponseModel(
      success: source['success'] == true ||
          json['success'] == true ||
          properties.isNotEmpty,
      query: (source['query'] ?? json['query'])?.toString() ?? '',
      searchMode: (source['search_mode'] ?? json['search_mode'])?.toString() ?? '',
      understood: understoodJson is Map
          ? AiSearchUnderstandingModel.fromJson(
              understoodJson.map((key, value) => MapEntry(key.toString(), value)),
            )
          : const AiSearchUnderstandingModel(),
      exactMatches: _toInt(
        source['exact_matches'] ??
            source['exact_matches_count'] ??
            json['exact_matches'] ??
            json['exact_matches_count'],
      ),
      totalResults: _toInt(
        source['total_results'] ??
            (properties.isNotEmpty ? properties.length : json['total_results']),
      ),
      properties: properties,
    );
  }

  static Map<String, dynamic> _deepestDataMap(Map<String, dynamic> json) {
    dynamic current = json;
    for (var i = 0; i < 5; i++) {
      if (current is Map) {
        final next = current['data'] ?? current['result'] ?? current['response'];
        if (next is Map) {
          current = next;
          continue;
        }
      }
      break;
    }
    if (current is Map) {
      return current.map((key, value) => MapEntry(key.toString(), value));
    }
    return json;
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AiSearchUnderstandingModel {
  const AiSearchUnderstandingModel({
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.neighborhood,
    this.minPrice,
    this.maxPrice,
    this.features = const [],
  });

  final String? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final String? neighborhood;
  final double? minPrice;
  final double? maxPrice;
  final List<String> features;

  factory AiSearchUnderstandingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AiSearchUnderstandingModel(
      propertyType: _nullableString(
        json['property_type'],
      ),
      bedrooms: _nullableInt(
        json['bedrooms'],
      ),
      bathrooms: _nullableInt(
        json['bathrooms'],
      ),
      neighborhood: _nullableString(
        json['neighborhood'],
      ),
      minPrice: _nullableDouble(
        json['min_price'],
      ),
      maxPrice: _nullableDouble(
        json['max_price'],
      ),
      features: json['features'] is List
          ? (json['features'] as List)
          .map((value) => value.toString())
          .toList()
          : const [],
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    return double.tryParse(value.toString());
  }
}

class AiSearchPropertyModel {
  const AiSearchPropertyModel({
    required this.property,
    required this.matchScore,
    required this.matched,
    required this.missing,
    required this.isExactMatch,
  });

  final PropertyModel property;
  final int matchScore;
  final List<String> matched;
  final List<String> missing;
  final bool isExactMatch;

  factory AiSearchPropertyModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final rawProperty = json['property'];
    final propertyJson = rawProperty is Map<String, dynamic>
        ? rawProperty
        : json;

    return AiSearchPropertyModel(
      property: PropertyModel.fromJson(propertyJson),
      matchScore: int.tryParse(
        (json['match_score'] ?? json['score'] ?? 0).toString(),
      ) ?? 0,
      matched: json['matched'] is List
          ? (json['matched'] as List)
          .map((value) => value.toString())
          .toList()
          : const [],
      missing: json['missing'] is List
          ? (json['missing'] as List)
          .map((value) => value.toString())
          .toList()
          : const [],
      isExactMatch: json['is_exact_match'] == true,
    );
  }
}