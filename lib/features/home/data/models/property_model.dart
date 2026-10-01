import '../../../../core/localization/locale_manager.dart';
import 'property_feature_model.dart';
import 'property_image_model.dart';
import 'property_location_model.dart';
import 'property_review_model.dart';

class PropertyModel {
  const PropertyModel({
    required this.id,
    required this.typeId,
    required this.categoryId,
    required this.statusId,
    required this.isFeatured,
    required this.title,
    required this.slug,
    required this.description,
    this.titleEn,
    this.titleAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.price,
    required this.currency,
    required this.rentFrequency,
    required this.areaSqft,
    required this.bedrooms,
    required this.bathrooms,
    required this.isFurnished,
    required this.availabilityDate,
    required this.listingDate,
    required this.primaryImage,
    required this.images,
    required this.location,
    required this.features,
    this.propertyCondition,
    this.listingType = '',
    this.actionType,
    this.virtualTourUrl,
    this.floorNumber,
    this.totalFloors,
    this.yearBuilt,
    this.rating = 0,
    this.reviews = const [],
    this.reviewItems = const [],
    this.isFavorite = false,
    this.owner,
    this.agency,
    this.primaryAction,
  });

  final int id;
  final int typeId;
  final int categoryId;
  final int statusId;
  final bool isFeatured;

  final String title;
  final String slug;
  final String description;

  final String? titleEn;
  final String? titleAr;
  final String? descriptionEn;
  final String? descriptionAr;

  String get displayTitle {
    if (LocaleManager.instance.isArabic &&
        titleAr != null && titleAr!.trim().isNotEmpty) {
      return titleAr!.trim();
    }
    if (!LocaleManager.instance.isArabic &&
        titleEn != null && titleEn!.trim().isNotEmpty) {
      return titleEn!.trim();
    }
    return title;
  }

  String get displayDescription {
    if (LocaleManager.instance.isArabic &&
        descriptionAr != null && descriptionAr!.trim().isNotEmpty) {
      return descriptionAr!.trim();
    }
    if (!LocaleManager.instance.isArabic &&
        descriptionEn != null && descriptionEn!.trim().isNotEmpty) {
      return descriptionEn!.trim();
    }
    return description;
  }


  final double price;
  final String currency;
  final String rentFrequency;

  final double areaSqft;
  final int bedrooms;
  final int bathrooms;

  final bool isFurnished;

  final String? propertyCondition;
  final String listingType;
  final String? actionType;
  final String? virtualTourUrl;
  final int? floorNumber;
  final int? totalFloors;
  final int? yearBuilt;

  final String? availabilityDate;
  final String? listingDate;

  final PropertyImageModel? primaryImage;
  final List<PropertyImageModel> images;
  final PropertyLocationModel? location;
  final List<PropertyFeatureModel> features;

  final double rating;
  final List<String> reviews;
  final List<PropertyReviewModel> reviewItems;
  final bool isFavorite;

  final Map<String, dynamic>? owner;

  int? get ownerId {
    final value = owner?['id'] ??
        owner?['user_id'] ??
        owner?['owner_id'] ??
        owner?['userId'];

    return int.tryParse(value?.toString() ?? '');
  }
  final Map<String, dynamic>? agency;
  final Map<String, dynamic>? primaryAction;

  bool get isForRent {
    final value = (listingType.trim().isNotEmpty ? listingType : (actionType ?? '')).trim().toLowerCase();
    return value == 'rent' || value == 'rental' || value == 'for_rent' || value == 'lease' || value == 'leasing';
  }

  bool get isForSale {
    final value = (listingType.trim().isNotEmpty ? listingType : (actionType ?? '')).trim().toLowerCase();
    return value == 'sale' || value == 'sell' || value == 'for_sale' || value == 'buy' || value == 'purchase';
  }

  bool get isUnderConstruction {
    final condition = propertyCondition?.trim().toLowerCase() ?? '';
    return condition == 'off_plan' ||
        condition == 'off-plan' ||
        condition == 'under_construction' ||
        condition == 'under-construction' ||
        condition == 'underconstruction' ||
        condition == 'construction' ||
        condition == 'under construction';
  }

  factory PropertyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final primaryImageJson =
        json['primary_image'] ??
        json['primaryImage'] ??
        json['cover_image'] ??
        json['coverImage'] ??
        json['image_url'] ??
        json['image'];

    final locationJson = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : (json.containsKey('latitude') ||
                json.containsKey('longitude') ||
                json.containsKey('address_line_1') ||
                json.containsKey('building_name')
            ? <String, dynamic>{
                'id': json['location_id'] ?? 0,
                'property_id': json['id'],
                'address_line_1': json['address_line_1'],
                'address_line_2': json['address_line_2'],
                'building_name': json['building_name'],
                'latitude': json['latitude'],
                'longitude': json['longitude'],
                'neighborhood_id': json['neighborhood_id'],
                'street_id': json['street_id'],
                'neighborhood_name': json['neighborhood_name'],
                'neighborhood_en': json['neighborhood_en'],
                'neighborhood_ar': json['neighborhood_ar'],
              }
            : null);

    final rawImages =
        json['images'] ??
        json['gallery_images'] ??
        json['property_images'] ??
        const [];

    final imagesJson = rawImages is List
        ? rawImages
        : const [];

    final featuresJson =
        json['features'] is List
            ? json['features'] as List
            : const [];

    return PropertyModel(
      id: _toInt(json['id']),
      typeId: _toInt(json['type_id']),
      categoryId: _toInt(json['category_id']),
      statusId: _toInt(json['status_id']),
      isFeatured: _toBool(json['is_featured']),
      title: _localizedText(json, 'title', fallback: 'title'),
      slug: json['slug']?.toString() ?? '',
      description: _localizedText(json, 'description', fallback: 'description'),
      titleEn: _localizedVariant(json, 'title', 'en'),
      titleAr: _localizedVariant(json, 'title', 'ar'),
      descriptionEn: _localizedVariant(json, 'description', 'en'),
      descriptionAr: _localizedVariant(json, 'description', 'ar'),
      price: _toDouble(json['price']),
      currency:
          json['currency']?.toString() ?? '',
      rentFrequency:
          json['rent_frequency']?.toString() ?? '',
      areaSqft:
          _toDouble(json['area_sqft']),
      bedrooms:
          _toInt(json['bedrooms']),
      bathrooms:
          _toInt(json['bathrooms']),
      isFurnished:
          _toBool(json['is_furnished']),
      propertyCondition:
          json['property_condition']?.toString(),
      listingType:
          (json['listing_type'] ?? json['listingType'] ?? json['purpose'] ?? '').toString(),
      actionType:
          json['action_type']?.toString(),
      virtualTourUrl:
          json['virtual_tour_url']?.toString(),
      floorNumber:
          _toNullableInt(json['floor_number']),
      totalFloors:
          _toNullableInt(json['total_floors']),
      yearBuilt:
          _toNullableInt(json['year_built']),
      availabilityDate:
          json['availability_date']?.toString(),
      listingDate:
          json['listing_date']?.toString(),
      primaryImage: _parsePrimaryImage(
        primaryImageJson: primaryImageJson,
        imagesJson: imagesJson,
        propertyId: _toInt(json['id']),
      ),
      images: imagesJson
          .map((value) {
            if (value is Map<String, dynamic>) {
              return PropertyImageModel.fromJson(value);
            }
            if (value is String && value.trim().isNotEmpty) {
              return PropertyImageModel.fromJson({
                'id': 0,
                'property_id': _toInt(json['id']),
                'image_url': value,
                'is_primary': false,
                'display_order': 0,
              });
            }
            return null;
          })
          .whereType<PropertyImageModel>()
          .toList(),
      location:
          locationJson is Map<String, dynamic>
              ? PropertyLocationModel.fromJson(
                  locationJson,
                )
              : null,
      features: featuresJson
          .whereType<Map<String, dynamic>>()
          .map(
            PropertyFeatureModel.fromJson,
          )
          .toList(),
      rating:
          _toDouble(json['rating']),
      reviews: json['reviews'] is List
          ? (json['reviews'] as List)
              .map((value) {
                if (value is Map<String, dynamic>) {
                  return (
                    value['review'] ??
                    value['comment'] ??
                    value['content'] ??
                    ''
                  ).toString();
                }
                return value.toString();
              })
              .where((value) => value.trim().isNotEmpty)
              .toList()
          : const [],
      reviewItems: json['reviews'] is List
          ? (json['reviews'] as List)
              .whereType<Map<String, dynamic>>()
              .map(PropertyReviewModel.fromJson)
              .toList()
          : const [],
      isFavorite:
          _toBool(json['is_favorite']),
      owner: _parseOwner(json),
      agency:
          json['agency'] is Map<String, dynamic>
              ? json['agency']
                  as Map<String, dynamic>
              : null,
      primaryAction:
          json['primary_action']
                  is Map<String, dynamic>
              ? json['primary_action']
                  as Map<String, dynamic>
              : null,
    );
  }

  static Map<String, dynamic>? _parseOwner(Map<String, dynamic> json) {
    final rawOwner = json['owner'];
    final owner = rawOwner is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawOwner)
        : <String, dynamic>{};

    final directId = json['user_id'] ??
        json['owner_id'] ??
        json['created_by'] ??
        json['created_by_user_id'];

    if (!owner.containsKey('id') && directId != null) {
      owner['id'] = directId;
    }

    if (owner.isEmpty) {
      return null;
    }

    return owner;
  }

  static String _localizedText(
    Map<String, dynamic> json,
    String key, {
    required String fallback,
  }) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      final preferred = value[LocaleManager.instance.languageCode];
      final english = value['en'];
      final arabic = value['ar'];
      final selected = preferred ?? (LocaleManager.instance.isArabic ? arabic : english);
      if (selected != null && selected.toString().trim().isNotEmpty) {
        return selected.toString();
      }
    }

    final preferredKey = '${key}_${LocaleManager.instance.languageCode}';
    final preferredValue = json[preferredKey];
    if (preferredValue != null && preferredValue.toString().trim().isNotEmpty) {
      return preferredValue.toString();
    }

    final direct = json[fallback];
    return direct?.toString() ?? '';
  }

  static String? _localizedVariant(
    Map<String, dynamic> json,
    String key,
    String language,
  ) {
    final mapValue = json[key];
    if (mapValue is Map<String, dynamic>) {
      final value = mapValue[language];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    final value = json['${key}_$language'];
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }
    return value.toString();
  }

  static PropertyImageModel? _parsePrimaryImage({
    required dynamic primaryImageJson,
    required List imagesJson,
    required int propertyId,
  }) {
    if (primaryImageJson is Map<String, dynamic>) {
      final parsed = PropertyImageModel.fromJson(primaryImageJson);
      if (parsed.imageUrl.isNotEmpty) return parsed;
    }

    if (primaryImageJson is String && primaryImageJson.trim().isNotEmpty) {
      return PropertyImageModel.fromJson({
        'id': 0,
        'property_id': propertyId,
        'image_url': primaryImageJson,
        'is_primary': true,
        'display_order': 0,
      });
    }

    for (final value in imagesJson) {
      if (value is Map<String, dynamic>) {
        final parsed = PropertyImageModel.fromJson(value);
        if (parsed.imageUrl.isNotEmpty && (parsed.isPrimary || parsed.displayOrder == 0)) {
          return parsed;
        }
      } else if (value is String && value.trim().isNotEmpty) {
        return PropertyImageModel.fromJson({
          'id': 0,
          'property_id': propertyId,
          'image_url': value,
          'is_primary': true,
          'display_order': 0,
        });
      }
    }

    return null;
  }

  static int _toInt(dynamic value) {
    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final text =
        value?.toString().toLowerCase();

    return text == '1' ||
        text == 'true' ||
        text == 'yes' ||
        text == 'on' ||
        text == 'furnished';
  }
}
