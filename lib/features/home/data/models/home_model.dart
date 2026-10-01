import 'popular_area_model.dart';
import 'property_model.dart';
import 'top_agent_model.dart';

class HomeModel {
  const HomeModel({
    required this.total,
    required this.popularAreas,
    required this.featuredProperties,
    required this.recommendationMode,
    required this.userLocation,
    required this.recommendedProperties,
    required this.topAgents,
    required this.properties,
  });

  final int total;

  final List<PopularAreaModel> popularAreas;

  final List<PropertyModel> featuredProperties;

  final String recommendationMode;

  final dynamic userLocation;

  final List<PropertyModel> recommendedProperties;

  final List<TopAgentModel> topAgents;

  final List<PropertyModel> properties;

  factory HomeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return HomeModel(
      total: _toInt(json['total']),

      popularAreas: _parseList(
        json['popular_areas'],
        PopularAreaModel.fromJson,
      ),

      featuredProperties: _parseList(
        json['featured_properties'],
        PropertyModel.fromJson,
      ),

      recommendationMode:
      json['recommendation_mode']?.toString() ??
          'recommended',

      userLocation:
      json['user_location'],

      recommendedProperties: _parseList(
        json['recommended_properties'],
        PropertyModel.fromJson,
      ),

      topAgents: _parseList(
        json['top_agents'],
        TopAgentModel.fromJson,
      ),

      properties: _parseList(
        json['properties'],
        PropertyModel.fromJson,
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static List<T> _parseList<T>(
      dynamic value,
      T Function(Map<String, dynamic>) parser,
      ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(parser)
        .toList();
  }
}