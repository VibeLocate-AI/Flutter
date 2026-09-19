import '../../../home/data/models/property_model.dart';
import '../../domain/repositories/properties_repository.dart';
import '../datasources/properties_remote_data_source.dart';
import '../models/create_property_request.dart';

class PropertiesRepositoryImpl
    implements PropertiesRepository {
  const PropertiesRepositoryImpl({
    required this.remoteDataSource,
  });

  final PropertiesRemoteDataSource
  remoteDataSource;

  @override
  Future<List<PropertyModel>>
  getProperties() async {
    final response =
    await remoteDataSource.getProperties();

    dynamic value =
    response['data'];

    if (value is Map<String, dynamic>) {
      value =
          value['properties'] ??
              value['data'];
    }

    value ??=
    response['properties'];

    if (value is! List) {
      return const [];
    }

    return value
        .whereType<
        Map<String, dynamic>>()
        .map(
      PropertyModel.fromJson,
    )
        .toList();
  }

  @override
  Future<PropertyModel>
  getPropertyDetails(
      int id,
      ) async {
    final response =
    await remoteDataSource
        .getPropertyDetails(id);

    dynamic value =
    response['data'];

    if (value is Map<String, dynamic>) {
      value =
          value['property'] ??
              value['data'] ??
              value;
    }

    value ??=
    response['property'];

    if (value
    is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid property details response.',
      );
    }

    return PropertyModel.fromJson(
      value,
    );
  }

  @override
  Future<Map<String, dynamic>>
  createProperty(
      CreatePropertyRequest request,
      ) {
    return remoteDataSource
        .createProperty(request);
  }
}