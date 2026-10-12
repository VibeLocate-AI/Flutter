import 'package:get/get.dart';
import '../../features/home/presentation/widgets/property_filter_sheet.dart';
import '../../features/map/data/models/map_location_model.dart';
import '../../features/map/map_dependencies.dart';

class MapControllerX extends GetxController {
  final locations = <MapLocationModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  final filters = const PropertyFilterValues().obs;
  final selectedTypeId = RxnInt();
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

  void setFilters(PropertyFilterValues value) => filters.value = value;

  void setTypeId(int? typeId) => selectedTypeId.value = typeId;

  List<MapLocationModel> get filtered => locations.where((property) {
    final f = filters.value;
    final typeId = selectedTypeId.value;
    if (typeId != null && property.typeId != typeId) return false;
    if (f.categoryId != null && property.categoryId != f.categoryId) return false;
    if (f.listingType != null) {
      final listing = property.listingType.toLowerCase();
      if (f.listingType == 'rent' && listing != 'rent' && listing != 'rental' && listing != 'for_rent') return false;
      if (f.listingType == 'sale' && listing != 'sale' && listing != 'sell' && listing != 'for_sale' && listing != 'buy') return false;
      if (f.listingType == 'under_construction' && !['off_plan','off-plan','under_construction','under-construction','underconstruction','construction','under construction'].contains(property.propertyCondition.toLowerCase())) return false;
    }
    if (f.minPrice != null && (property.priceAmount ?? 0) < f.minPrice!) return false;
    if (f.maxPrice != null && (property.priceAmount ?? 0) > f.maxPrice!) return false;
    if (f.minBedrooms != null && property.bedrooms < f.minBedrooms!) return false;
    if (f.minBathrooms != null && property.bathrooms < f.minBathrooms!) return false;
    if (f.minArea != null && property.areaSqft < f.minArea!) return false;
    if (f.maxArea != null && property.areaSqft > f.maxArea!) return false;
    if (f.furnished != null) {
      if (f.furnished == 'furnished' && !property.isFurnished) return false;
      if (f.furnished == 'unfurnished' && property.isFurnished) return false;
    }
    if (f.rentFrequency != null && property.rentFrequency.toLowerCase() != f.rentFrequency!.toLowerCase()) return false;
    if (f.featuredOnly && !property.isFeatured) return false;
    return true;
  }).toList(growable: false);
}
