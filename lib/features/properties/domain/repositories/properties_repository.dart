import '../../../home/data/models/property_model.dart';
import '../../data/models/create_property_request.dart';

abstract class PropertiesRepository {
  Future<List<PropertyModel>> getProperties();

  Future<PropertyModel> getPropertyDetails(
      int id,
      );

  Future<Map<String, dynamic>> createProperty(
      CreatePropertyRequest request,
      );
}