import 'package:get/get.dart';
import '../../features/home/data/models/property_model.dart';
import '../../features/map/data/models/map_location_model.dart';
import '../../features/properties/properties_dependencies.dart';

class PropertyDetailsController extends GetxController {
  final cache = <int, PropertyModel>{}.obs;
  final loading = <int>{}.obs;
  final errors = <int, String>{}.obs;

  PropertyModel? getCached(int id) => cache[id];

  Future<PropertyModel> load(int id, {bool force = false}) async {
    if (!force && cache.containsKey(id)) return cache[id]!;
    if (loading.contains(id)) {
      while (loading.contains(id)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      final value = cache[id];
      if (value != null) return value;
    }
    loading.add(id);
    errors.remove(id);
    try {
      final value = await PropertiesDependencies.getPropertyDetails(id);
      cache[id] = value;
      return value;
    } catch (e) {
      errors[id] = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      loading.remove(id);
      loading.refresh();
      cache.refresh();
    }
  }

  void seedFromMap(MapLocationModel location) {
    final id = location.propertyId ?? location.id;
    if (id <= 0 || cache.containsKey(id)) return;
    cache[id] = PropertyModel.fromJson({
      'id': id,
      'type_id': location.typeId ?? 0,
      'category_id': location.categoryId ?? 0,
      'status_id': 0,
      'title': location.title,
      'description': '',
      'price': location.priceAmount ?? 0,
      'currency': location.currency,
      'cover_image': location.imageUrl,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address_line_1': location.address,
      'bedrooms': location.bedrooms,
      'bathrooms': location.bathrooms,
      'area_sqft': location.areaSqft,
      'listing_type': location.listingType,
      'rent_frequency': location.rentFrequency,
      'is_furnished': location.isFurnished,
      'is_featured': location.isFeatured,
    });
    cache.refresh();
  }

  void setProperty(PropertyModel value) {
    cache[value.id] = value;
    cache.refresh();
  }
}
