import '../../../../core/constants/api_endpoints.dart';

class MapLocationModel {
  const MapLocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.propertyId,
    this.title = '',
    this.address = '',
    this.price = '',
    this.currency = 'AED',
    this.priceAmount,
    this.imageUrl = '',
    this.typeId,
  });

  final int id;
  final int? propertyId;
  final double latitude;
  final double longitude;
  final String title;
  final String address;
  final String price;
  final String currency;
  final double? priceAmount;
  final String imageUrl;
  final int? typeId;

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    final property = _asMap(json['property']);

    final id = _toInt(
      json['id'] ??
          json['property_id'] ??
          property?['id'],
    );

    final rawImage = _firstImageValue([
      json['cover_image'],
      json['coverImage'],
      json['primary_image'],
      json['primaryImage'],
      json['image_url'],
      json['image'],
      property?['cover_image'],
      property?['coverImage'],
      property?['primary_image'],
      property?['primaryImage'],
      property?['image_url'],
      property?['image'],
      _firstListValue(json['images']),
      _firstListValue(json['gallery_images']),
      _firstListValue(property?['images']),
    ]);

    final location = _asMap(json['location']);

    return MapLocationModel(
      id: id,
      propertyId: _nullableInt(
        json['property_id'] ?? property?['id'] ?? json['id'],
      ),
      latitude: _toDouble(
        json['latitude'] ??
            json['lat'] ??
            property?['latitude'] ??
            location?['latitude'],
      ),
      longitude: _toDouble(
        json['longitude'] ??
            json['lng'] ??
            json['lon'] ??
            property?['longitude'] ??
            location?['longitude'],
      ),
      title: _text(
        json['title'] ??
            json['name'] ??
            json['property_title'] ??
            property?['title'] ??
            property?['name'],
      ),
      address: _text(
        json['address'] ??
            json['address_line_1'] ??
            location?['address_line_1'] ??
            location?['address'] ??
            property?['address'],
      ),
      price: _text(json['price'] ?? property?['price']),
      currency: _text(
            json['currency'] ?? property?['currency'],
          ).isEmpty
          ? 'AED'
          : _text(json['currency'] ?? property?['currency'])
              .toUpperCase(),
      priceAmount: _toDoubleOrNull(
        json['price'] ?? property?['price'],
      ),
      imageUrl: _normalizeUrl(rawImage),
      typeId: _nullableInt(
        json['type_id'] ?? property?['type_id'],
      ),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  static String _text(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static dynamic _firstListValue(dynamic value) {
    if (value is! List || value.isEmpty) return null;
    return value.first;
  }

  static String _firstImageValue(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }

      final map = _asMap(value);
      if (map == null) continue;

      final nested = map['image_url'] ??
          map['url'] ??
          map['path'] ??
          map['image'] ??
          map['cover_image'] ??
          map['primary_image'];

      if (nested is String && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }

    return '';
  }

  static String _normalizeUrl(String value) {
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('//')) {
      return 'https:$value';
    }
    if (value.startsWith('/')) {
      return '${ApiEndpoints.baseUrl}$value';
    }
    if (value.startsWith('storage/')) {
      return '${ApiEndpoints.baseUrl}/$value';
    }
    return value;
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value is num) return value.toDouble();
    final text = value?.toString() ?? '';
    if (text.trim().isEmpty) return null;
    final normalized = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(normalized);
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
