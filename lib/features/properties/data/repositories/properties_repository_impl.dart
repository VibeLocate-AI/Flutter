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

    dynamic value = response['data'];

    if (value is Map<String, dynamic>) {
      value = value['properties'] ?? value['data'];
    }

    value ??= response['properties'];

    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(PropertyModel.fromJson)
        .toList();
  }

  @override
  Future<List<PropertyModel>> getMyProperties() async {
    final response = await remoteDataSource.getMyProperties();

    dynamic value = response['data'];

    if (value is Map<String, dynamic>) {
      value = value['properties'] ?? value['data'];
    }

    value ??= response['properties'];

    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(PropertyModel.fromJson)
        .toList();
  }

  @override
  Future<PropertyModel> getPropertyDetails(int id) async {
    final response = await remoteDataSource.getPropertyDetails(id);

    Map<String, dynamic>? found = _findProperty(response, id);
    if (found == null) {
      // Some Laravel deployments return the property collection envelope
      // even for a single-property request. Fall back to the collection and
      // select the requested ID instead of showing a false "invalid response".
      final all = await remoteDataSource.getProperties();
      found = _findProperty(all, id);
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