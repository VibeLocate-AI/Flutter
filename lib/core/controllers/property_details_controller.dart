import 'package:get/get.dart';
import '../../features/home/data/models/property_model.dart';
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

  void setProperty(PropertyModel value) {
    cache[value.id] = value;
    cache.refresh();
  }
}
