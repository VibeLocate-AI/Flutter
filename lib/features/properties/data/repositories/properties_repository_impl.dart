import '../../../home/data/models/property_model.dart';
import '../../domain/repositories/properties_repository.dart';
import '../datasources/properties_remote_data_source.dart';
import '../models/create_property_request.dart';

class PropertiesRepositoryImpl implements PropertiesRepository {
  const PropertiesRepositoryImpl({
    required this.remoteDataSource,
  });

  final PropertiesRemoteDataSource remoteDataSource;

  @override
  Future<List<PropertyModel>> getProperties() async {
    final response = await remoteDataSource.getProperties();

    return _extractPropertyMaps(response)
        .map(PropertyModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<PropertyModel>> getMyProperties() async {
    final response = await remoteDataSource.getMyProperties();
    final maps = _extractPropertyMaps(response);
    return maps.map(PropertyModel.fromJson).toList(growable: false);
  }

  List<Map<String, dynamic>> _extractPropertyMaps(dynamic value) {
    final result = <Map<String, dynamic>>[];
    final seen = <int>{};

    void walk(dynamic node) {
      if (node is List) {
        for (final item in node) {
          walk(item);
        }
        return;
      }
      if (node is! Map) return;
      final map = node.map((key, value) => MapEntry(key.toString(), value));
      final id = int.tryParse(
        (map['id'] ?? map['property_id'] ?? '').toString(),
      );

      final looksLikeProperty = map.containsKey('title') ||
          map.containsKey('price') ||
          map.containsKey('description') ||
          map.containsKey('type_id') ||
          map.containsKey('listing_type') ||
          map.containsKey('property_condition') ||
          map.containsKey('approval_status') ||
          map.containsKey('status') ||
          map.containsKey('bedrooms') ||
          map.containsKey('area_sqft');

      if (id != null && id > 0 && looksLikeProperty) {
        if (seen.add(id)) result.add(map);
        return;
      }
      for (final child in map.values) {
        walk(child);
      }
    }

    walk(value);
    return result;
  }

  @override
  Future<PropertyModel> getPropertyDetails(int id) async {
    Map<String, dynamic>? found;

    // The supplied Postman collection exposes nearby/details-related routes,
    // but not a guaranteed GET /api/properties/{id}. Try the direct route when
    // the deployment supports it, then fall back to the real collection routes
    // instead of failing the Details screen.
    try {
      final response = await remoteDataSource.getPropertyDetails(id);
      found = _findProperty(response, id);
    } catch (_) {
      found = null;
    }

    if (found == null) {
      try {
        final all = await remoteDataSource.getProperties();
        found = _findProperty(all, id);
      } catch (_) {
        found = null;
      }
    }

    if (found == null) {
      try {
        final mine = await remoteDataSource.getMyProperties();
        found = _findProperty(mine, id);
      } catch (_) {
        found = null;
      }
    }

    if (found == null) {
      throw const FormatException('Invalid property details response.');
    }

    return PropertyModel.fromJson(found);
  }

  Map<String, dynamic>? _findProperty(dynamic value, int id) {
    if (value is Map) {
      final map = value.map((key, item) => MapEntry(key.toString(), item));
      final directId = int.tryParse(
        (map['id'] ?? map['property_id'] ?? '').toString(),
      );
      if (directId == id) return map;

      for (final entry in map.values) {
        final found = _findProperty(entry, id);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final item in value) {
        final found = _findProperty(item, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> createProperty(
      CreatePropertyRequest request,
      ) {
    return remoteDataSource.createProperty(request);
  }
}