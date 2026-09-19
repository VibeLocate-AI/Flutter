import '../../../home/data/models/property_model.dart';
import '../../data/models/create_property_request.dart';
import '../repositories/properties_repository.dart';

class GetProperties {
  const GetProperties(
      this.repository,
      );

  final PropertiesRepository repository;

  Future<List<PropertyModel>> call() {
    return repository.getProperties();
  }
}

class GetPropertyDetails {
  const GetPropertyDetails(
      this.repository,
      );

  final PropertiesRepository repository;

  Future<PropertyModel> call(int id) {
    return repository.getPropertyDetails(
      id,
    );
  }
}

class CreateProperty {
  const CreateProperty(
      this.repository,
      );

  final PropertiesRepository repository;

  Future<Map<String, dynamic>> call(
      CreatePropertyRequest request,
      ) {
    return repository.createProperty(
      request,
    );
  }
}