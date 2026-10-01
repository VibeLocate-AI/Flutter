import 'package:get/get.dart';
import '../../features/home/data/models/property_model.dart';
import '../../features/properties/properties_dependencies.dart';

class MyPropertiesController extends GetxController {
  final properties = <PropertyModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  final query = ''.obs;
  final selectedTypeId = RxnInt();
  bool hasLoaded = false;

  Future<void> initialize() async {
    if (hasLoaded) return;
    await reload();
  }

  Future<void> reload() async {
    isLoading.value = properties.isEmpty;
    error.value = null;
    try {
      final result = await PropertiesDependencies.loadMyProperties();
      properties.assignAll(result);
      hasLoaded = true;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void setQuery(String value) => query.value = value.trim().toLowerCase();
  void setType(int? value) => selectedTypeId.value = value;

  List<PropertyModel> get filtered => properties.where((property) {
    final type = selectedTypeId.value;
    if (type != null && property.typeId != type) return false;
    final q = query.value;
    if (q.isEmpty) return true;
    final location = [
      property.location?.addressLine1 ?? '',
      property.location?.neighborhoodEn ?? '',
      property.location?.neighborhoodAr ?? '',
    ].join(' ').toLowerCase();
    return property.displayTitle.toLowerCase().contains(q) ||
      property.title.toLowerCase().contains(q) ||
      property.displayDescription.toLowerCase().contains(q) ||
      location.contains(q);
  }).toList(growable: false);

  void prepend(PropertyModel property) {
    properties.removeWhere((p) => p.id == property.id);
    properties.insert(0, property);
    properties.refresh();
  }
}
