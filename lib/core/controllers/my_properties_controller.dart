import 'package:get/get.dart';

import '../../features/home/data/models/property_model.dart';
import '../../features/home/presentation/widgets/property_filter_sheet.dart';
import '../../features/properties/properties_dependencies.dart';
import '../storage/my_properties_storage.dart';

class MyPropertiesController extends GetxController {
  final properties = <PropertyModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  final filters = const PropertyFilterValues().obs;
  final selectedTypeId = RxnInt();
  bool hasLoaded = false;

  Future<void> initialize() async {
    // Show a newly-added property immediately from local cache while the
    // Laravel endpoint catches up.
    await _restoreCache();
    await reload();
  }

  Future<void> _restoreCache() async {
    try {
      final cached = await MyPropertiesStorage.getCachedProperties();
      if (cached.isEmpty) return;

      final restored = <PropertyModel>[];
      for (final map in cached) {
        try {
          final property = PropertyModel.fromJson(map);
          if (property.id > 0 || property.localPendingSync) restored.add(property);
        } catch (_) {}
      }

      if (restored.isNotEmpty) {
        properties.assignAll(restored);
        hasLoaded = true;
      }
    } catch (_) {}
  }

  Future<void> reload() async {
    if (properties.isEmpty) {
      isLoading.value = true;
    }
    error.value = null;

    try {
      // Restore cache again before every reload so a property added in the
      // previous screen is never lost during the network request.
      final cachedMaps = await MyPropertiesStorage.getCachedProperties();
      final merged = <int, PropertyModel>{};

      for (final map in cachedMaps) {
        try {
          final property = PropertyModel.fromJson(map);
          if (property.id != 0) merged[property.id] = property;
        } catch (_) {}
      }

      // Keep any optimistic record already painted by Add Property while
      // Laravel catches up. These temporary records use id <= 0 and must not
      // disappear just because the collection endpoint is eventually
      // consistent. Positive IDs are reconciled with the server below.
      final localPending = properties
          .where((item) => item.id <= 0 || item.localPendingSync)
          .toList(growable: true);

      final result = await PropertiesDependencies.loadMyProperties();

      // /api/my-properties is the backend source of truth. It should return
      // every property owned by the authenticated user, including pending,
      // approved and rejected records.
      for (final item in result) {
        if (item.id <= 0) continue;

        // Once the API returns the real ID, reconcile a previously cached
        // temporary row using title + price so the user does not see duplicates.
        final matchingTemporary = localPending.where((local) {
          if (!local.localPendingSync || local.id >= 0) return false;
          final sameTitle = local.displayTitle.trim().toLowerCase() ==
              item.displayTitle.trim().toLowerCase();
          final samePrice = (local.price - item.price).abs() < 0.01;
          return sameTitle && samePrice;
        }).toList(growable: false);
        for (final local in matchingTemporary) {
          localPending.removeWhere((candidate) => candidate.id == local.id);
          await MyPropertiesStorage.removeCachedProperty(local.id);
        }
        merged[item.id] = item;
      }

      // Keep temporary local rows first, then reconcile all server/cache rows
      // by ID so pending properties are never duplicated.
      final orderedById = <int, PropertyModel>{};
      for (final item in localPending) {
        orderedById[item.id] = item;
      }
      for (final item in merged.values) {
        orderedById[item.id] = item;
      }
      final ordered = orderedById.values.toList(growable: false);
      properties.assignAll(ordered);

      // Persist the latest backend representation so the next open is
      // instant and keeps the same approval status.
      for (final item in ordered) {
        await MyPropertiesStorage.cacheProperty(_propertyToCache(item));
      }

      hasLoaded = true;
    } catch (e) {
      // Do not replace a valid cached list with an error screen.
      if (properties.isEmpty) {
        error.value = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      isLoading.value = false;
    }
  }


  Map<String, dynamic> _propertyToCache(PropertyModel property) {
    final map = <String, dynamic>{
      'id': property.id,
      'type_id': property.typeId,
      'category_id': property.categoryId,
      'status_id': property.statusId,
      'approval_status': property.approvalStatus,
      'local_pending_sync': property.localPendingSync,
      'is_featured': property.isFeatured,
      'title': property.title,
      'slug': property.slug,
      'description': property.description,
      'title_en': property.titleEn,
      'title_ar': property.titleAr,
      'description_en': property.descriptionEn,
      'description_ar': property.descriptionAr,
      'price': property.price,
      'currency': property.currency,
      'rent_frequency': property.rentFrequency,
      'area_sqft': property.areaSqft,
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'is_furnished': property.isFurnished,
      'property_condition': property.propertyCondition,
      'listing_type': property.listingType,
      'action_type': property.actionType,
      'virtual_tour_url': property.virtualTourUrl,
      'floor_number': property.floorNumber,
      'total_floors': property.totalFloors,
      'year_built': property.yearBuilt,
      'availability_date': property.availabilityDate,
      'listing_date': property.listingDate,
      'is_favorite': property.isFavorite,
    };

    if (property.owner != null) map['owner'] = property.owner;
    if (property.agency != null) map['agency'] = property.agency;

    if (property.location != null) {
      map['location'] = {
        'id': property.location!.id,
        'property_id': property.location!.propertyId,
        'address_line_1': property.location!.addressLine1,
        'address_line_2': property.location!.addressLine2,
        'building_name': property.location!.buildingName,
        'latitude': property.location!.latitude,
        'longitude': property.location!.longitude,
        'neighborhood_id': property.location!.neighborhoodId,
        'street_id': property.location!.streetId,
        'neighborhood_name': property.location!.neighborhoodName,
        'neighborhood_en': property.location!.neighborhoodEn,
        'neighborhood_ar': property.location!.neighborhoodAr,
      };
    }

    if (property.primaryImage != null) {
      map['primary_image'] = {
        'id': property.primaryImage!.id,
        'property_id': property.primaryImage!.propertyId,
        'image_url': property.primaryImage!.imageUrl,
        'is_primary': property.primaryImage!.isPrimary,
        'display_order': property.primaryImage!.displayOrder,
      };
    }

    map['images'] = property.images
        .map(
          (image) => {
            'id': image.id,
            'property_id': image.propertyId,
            'image_url': image.imageUrl,
            'is_primary': image.isPrimary,
            'display_order': image.displayOrder,
          },
        )
        .toList();

    return map;
  }

  void setFilters(PropertyFilterValues value) => filters.value = value;

  void setTypeId(int? typeId) => selectedTypeId.value = typeId;

  List<PropertyModel> get filtered => properties.where((property) {
        final f = filters.value;
        final typeId = selectedTypeId.value;
        if (typeId != null && property.typeId != typeId) {
          return false;
        }
        if (f.categoryId != null && property.categoryId != f.categoryId) {
          return false;
        }
        if (f.listingType != null) {
          if (f.listingType == 'under_construction' &&
              !property.isUnderConstruction) {
            return false;
          }
          if (f.listingType == 'rent' && !property.isForRent) {
            return false;
          }
          if (f.listingType == 'sale' && !property.isForSale) {
            return false;
          }
        }
        if (f.minPrice != null && property.price < f.minPrice!) return false;
        if (f.maxPrice != null && property.price > f.maxPrice!) return false;
        if (f.minBedrooms != null &&
            property.bedrooms < f.minBedrooms!) {
          return false;
        }
        if (f.minBathrooms != null &&
            property.bathrooms < f.minBathrooms!) {
          return false;
        }
        if (f.minArea != null && property.areaSqft < f.minArea!) return false;
        if (f.maxArea != null && property.areaSqft > f.maxArea!) return false;
        if (f.furnished != null) {
          if (f.furnished == 'furnished' && !property.isFurnished) return false;
          if (f.furnished == 'unfurnished' && property.isFurnished) return false;
        }
        if (f.rentFrequency != null &&
            property.rentFrequency.toLowerCase() !=
                f.rentFrequency!.toLowerCase()) {
          return false;
        }
        if (f.featuredOnly && !property.isFeatured) return false;
        return true;
      }).toList(growable: false);

  void prepend(PropertyModel property) {
    properties.removeWhere((p) => p.id == property.id);
    properties.insert(0, property);
    properties.refresh();
  }
}
