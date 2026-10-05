import '../../../../core/constants/api_endpoints.dart';
import '../../../home/data/models/property_model.dart';

class FavoritePropertyModel {
  const FavoritePropertyModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.currency,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.actionType,
    required this.typeId,
    required this.propertyType,
    required this.categoryId,
    required this.categoryName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.neighborhoodId,
    required this.neighborhood,
    required this.imageUrl,
    required this.favoritedAt,
    required this.isFavorite,
  });

  final int id;
  final String title;
  final String slug;
  final double price;
  final String currency;
  final int bedrooms;
  final int bathrooms;
  final double areaSqft;
  final String actionType;
  final int typeId;
  final String propertyType;
  final int categoryId;
  final String categoryName;
  final double latitude;
  final double longitude;
  final String address;
  final int? neighborhoodId;
  final String neighborhood;
  final String imageUrl;
  final String? favoritedAt;
  final bool isFavorite;

  factory FavoritePropertyModel.fromProperty(PropertyModel property) {
    final image = property.primaryImage?.imageUrl ??
        (property.images.isNotEmpty ? property.images.first.imageUrl : '');
    final location = property.location;
    return FavoritePropertyModel(
      id: property.id,
      title: property.displayTitle,
      slug: property.slug,
      price: property.price,
      currency: property.currency,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      areaSqft: property.areaSqft,
      actionType: property.listingType.isNotEmpty ? property.listingType : (property.actionType ?? ''),
      typeId: property.typeId,
      propertyType: property.propertyCondition ?? '',
      categoryId: property.categoryId,
      categoryName: '',
      latitude: location?.latitude ?? 0,
      longitude: location?.longitude ?? 0,
      address: location?.addressLine1 ?? '',
      neighborhoodId: location?.neighborhoodId,
      neighborhood: location?.neighborhoodName ?? '',
      imageUrl: _normalizeImage(image),
      favoritedAt: null,
      isFavorite: true,
    );
  }

  factory FavoritePropertyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final image = json['primary_image'] ??
        json['cover_image'] ??
        json['image_url'] ??
        json['image'];

    return FavoritePropertyModel(
      id: _int(json['id']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      price: _double(json['price']),
      currency:
          json['currency']?.toString() ?? '',
      bedrooms: _int(json['bedrooms']),
      bathrooms: _int(json['bathrooms']),
      areaSqft: _double(json['area_sqft']),
      actionType:
          json['action_type']?.toString() ?? '',
      typeId: _int(json['type_id']),
      propertyType:
          json['property_type']?.toString() ?? '',
      categoryId: _int(json['category_id']),
      categoryName:
          json['category_name']?.toString() ?? '',
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      address:
          json['address']?.toString() ?? '',
      neighborhoodId:
          _nullableInt(json['neighborhood_id']),
      neighborhood:
          json['neighborhood']?.toString() ?? '',
      imageUrl: _normalizeImage(image),
      favoritedAt:
          json['favorited_at']?.toString(),
      isFavorite:
          json['is_favorite'] == true ||
          json['is_favorite']?.toString() == '1',
    );
  }

  static String _normalizeImage(dynamic value) {
    String url;
    if (value is Map) {
      url = (value['image_url'] ?? value['url'] ?? value['path'] ?? '')
          .toString()
          .trim();
    } else {
      url = value?.toString().trim() ?? '';
    }
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return '${ApiEndpoints.baseUrl}$url';
    if (url.startsWith('storage/')) return '${ApiEndpoints.baseUrl}/$url';
    return url;
  }

  static int _int(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;

  static int? _nullableInt(dynamic value) =>
      value == null
          ? null
          : int.tryParse(value.toString());

  static double _double(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
}
