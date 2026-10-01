import 'package:get/get.dart';
import '../../features/map/data/models/map_location_model.dart';
import '../../features/map/map_dependencies.dart';

class MapControllerX extends GetxController {
  final locations = <MapLocationModel>[].obs;
  final query = ''.obs;
  final isLoading = false.obs;
  final error = RxnString();
  bool hasLoaded = false;

  Future<void> initialize() async {
    if (hasLoaded) return;
    await reload();
  }

  Future<void> reload() async {
    isLoading.value = locations.isEmpty;
    error.value = null;
    try {
      locations.assignAll(await MapDependencies.getLocations());
      hasLoaded = true;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void setQuery(String value) => query.value = value.trim().toLowerCase();
  List<MapLocationModel> get filtered => query.value.isEmpty
      ? locations.toList(growable: false)
      : locations.where((l) =>
          l.title.toLowerCase().contains(query.value) ||
          l.address.toLowerCase().contains(query.value) ||
          l.price.toLowerCase().contains(query.value)).toList(growable: false);
}
