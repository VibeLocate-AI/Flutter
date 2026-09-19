import '../home/data/models/property_model.dart';
import 'data/datasources/properties_remote_data_source.dart';
import 'data/models/create_property_request.dart';
import 'data/repositories/properties_repository_impl.dart';
import 'domain/usecases/properties_usecases.dart';

class PropertiesDependencies {
  PropertiesDependencies._();

  static final PropertiesRemoteDataSource
  remoteDataSource =
  const PropertiesRemoteDataSourceImpl();

  static final PropertiesRepositoryImpl
  repository =
  PropertiesRepositoryImpl(
    remoteDataSource:
    remoteDataSource,
  );

  static final GetProperties
  getProperties =
  GetProperties(repository);

  static final GetPropertyDetails
  getPropertyDetails =
  GetPropertyDetails(repository);

  static final CreateProperty
  createProperty =
  CreateProperty(repository);

  static Future<List<PropertyModel>>
  loadProperties() {
    return getProperties();
  }

  static Future<PropertyModel>
  loadPropertyDetails(
      int id,
      ) {
    return getPropertyDetails(id);
  }

  static Future<Map<String, dynamic>>
  addProperty(
      CreatePropertyRequest request,
      ) {
    return createProperty(request);
  }
}