import 'property_feature_model.dart';
import 'property_image_model.dart';
import 'property_location_model.dart';

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
  });

  final int id;
  final int typeId;
  final int categoryId;
  final int statusId;
  final bool isFeatured;

  final String title;
  final String slug;
  final String description;

  final double price;
  final String currency;
  final String rentFrequency;

  final double areaSqft;
  final int bedrooms;
  final int bathrooms;

  final String isFurnished;

  final String? availabilityDate;
  final String? listingDate;

  final PropertyImageModel? primaryImage;
  final List<PropertyImageModel> images;

  final PropertyLocationModel? location;

  final List<PropertyFeatureModel> features;

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final primaryImageJson = json['primary_image'];
    final locationJson = json['location'];

    final imagesJson = json['images'] is List
        ? json['images'] as List
        : const [];

    final featuresJson = json['features'] is List
        ? json['features'] as List
        : const [];

    return PropertyModel(
      id: _toInt(json['id']),
      typeId: _toInt(json['type_id']),
      categoryId: _toInt(json['category_id']),
      statusId: _toInt(json['status_id']),
      isFeatured: _toBool(json['is_featured']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? '',
      rentFrequency: json['rent_frequency']?.toString() ?? '',
      areaSqft: _toDouble(json['area_sqft']),
      bedrooms: _toInt(json['bedrooms']),
      bathrooms: _toInt(json['bathrooms']),
      isFurnished: json['is_furnished']?.toString() ?? '',
      availabilityDate: json['availability_date']?.toString(),
      listingDate: json['listing_date']?.toString(),
      primaryImage: primaryImageJson is Map<String, dynamic>
          ? PropertyImageModel.fromJson(primaryImageJson)
          : null,
      images: imagesJson
          .whereType<Map<String, dynamic>>()
          .map(PropertyImageModel.fromJson)
          .toList(),
      location: locationJson is Map<String, dynamic>
          ? PropertyLocationModel.fromJson(locationJson)
          : null,
      features: featuresJson
          .whereType<Map<String, dynamic>>()
          .map(PropertyFeatureModel.fromJson)
          .toList(),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    return value?.toString() == '1';
  }
}