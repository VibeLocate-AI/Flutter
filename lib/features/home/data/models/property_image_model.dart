import '../../../../core/constants/api_endpoints.dart';

class PropertyImageModel {
  const PropertyImageModel({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
  });

  final int id;
  final int propertyId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) {
    dynamic rawValue =
        json['image_url'] ??
        json['url'] ??
        json['path'] ??
        json['image'];

    if (rawValue is Map<String, dynamic>) {
      rawValue = rawValue['image_url'] ??
          rawValue['url'] ??
          rawValue['path'] ??
          rawValue['image'];
    }

    final rawUrl = rawValue?.toString().trim() ?? '';

    return PropertyImageModel(
      id: _toInt(json['id']),
      propertyId: _toInt(json['property_id']),
      imageUrl: _normalizeUrl(rawUrl),
      isPrimary: _toBool(json['is_primary']),
      displayOrder: _toInt(json['display_order']),
    );
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
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes';
  }
}
