import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/localization/locale_manager.dart';
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
    this.isFurnished = false,
    this.rentFrequency = '',
    this.isFeatured = false,
    this.titleEn,
    this.titleAr,
    this.description = '',
    this.descriptionEn,
    this.descriptionAr,
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
  final bool isFurnished;
  final String rentFrequency;
  final bool isFeatured;
  final String? titleEn;
  final String? titleAr;
  final String description;
  final String? descriptionEn;
  final String? descriptionAr;

  String get displayTitle {
    final isArabic = LocaleManager.instance.isArabic;
    final localized = isArabic ? titleAr : titleEn;
    if (localized != null && localized.trim().isNotEmpty) {
      return localized.trim();
    }
    return title;
  }

  String get displayDescription {
    final isArabic = LocaleManager.instance.isArabic;
    final localized = isArabic ? descriptionAr : descriptionEn;
    if (localized != null && localized.trim().isNotEmpty) {
      return localized.trim();
    }
    return description;
  }

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
      isFurnished: property.isFurnished,
      rentFrequency: property.rentFrequency,
      isFeatured: property.isFeatured,
      titleEn: property.titleEn,
      titleAr: property.titleAr,
      description: property.description,
      descriptionEn: property.descriptionEn,
      descriptionAr: property.descriptionAr,
    );
  }

  factory FavoritePropertyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final nested = json['property'];
    final source = nested is Map
        ? nested.map((key, value) => MapEntry(key.toString(), value))
        : json;
    final image = source['primary_image'] ??
        source['cover_image'] ??
        source['image_url'] ??
        source['image'] ??
        json['primary_image'] ??
        json['cover_image'];

    return FavoritePropertyModel(
      id: _int(source['id'] ?? json['property_id'] ?? json['id']),
      title: _localized(source, 'title'),
      slug: source['slug']?.toString() ?? '',
      price: _double(source['price']),
      currency: source['currency']?.toString() ?? '',
      bedrooms: _int(source['bedrooms']),
      bathrooms: _int(source['bathrooms']),
      areaSqft: _double(source['area_sqft']),
      actionType: (source['action_type'] ?? source['listing_type'] ?? source['purpose'] ?? '').toString(),
      typeId: _int(source['type_id']),
      propertyType: (source['property_type'] ?? source['property_condition'] ?? '').toString(),
      categoryId: _int(source['category_id']),
      categoryName: source['category_name']?.toString() ?? '',
      latitude: _double(source['latitude']),
      longitude: _double(source['longitude']),
      address: (source['address'] ?? source['address_line_1'] ?? '').toString(),
      neighborhoodId: _nullableInt(source['neighborhood_id']),
      neighborhood: (source['neighborhood'] ?? source['neighborhood_name'] ?? '').toString(),
      imageUrl: _normalizeImage(image),
      favoritedAt: json['favorited_at']?.toString(),
      isFavorite: true,
      isFurnished: _bool(source['is_furnished']),
      rentFrequency: source['rent_frequency']?.toString() ?? '',
      isFeatured: _bool(source['is_featured']),
      titleEn: _localizedVariant(source, 'title', 'en'),
      titleAr: _localizedVariant(source, 'title', 'ar'),
      description: _localized(source, 'description'),
      descriptionEn: _localizedVariant(source, 'description', 'en'),
      descriptionAr: _localizedVariant(source, 'description', 'ar'),
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

  static String _localized(Map<String, dynamic> source, String key) {
    final ar = _localizedVariant(source, key, 'ar');
    final en = _localizedVariant(source, key, 'en');
    return en ?? ar ?? source[key]?.toString() ?? '';
  }

  static String? _localizedVariant(
    Map<String, dynamic> source,
    String key,
    String language,
  ) {
    final raw = source[key];
    if (raw is Map) {
      final value = raw[language] ?? raw[language == 'ar' ? 'arabic' : 'english'];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
    }
    for (final name in [
      '${key}_$language',
      '${key}${language.toUpperCase()}',
      '${key}_${language.toUpperCase()}',
    ]) {
      final value = source[name];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
    }
    final translations = source['translations'];
    if (translations is Map) {
      final field = translations[key];
      if (field is Map) {
        final value = field[language];
        if (value != null && value.toString().trim().isNotEmpty) return value.toString().trim();
      }
    }
    return null;
  }

  static int _int(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;

  static int? _nullableInt(dynamic value) =>
      value == null
          ? null
          : int.tryParse(value.toString());

  static double _double(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes' || text == 'furnished';
  }
}
