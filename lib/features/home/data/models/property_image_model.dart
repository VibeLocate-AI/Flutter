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
    return PropertyImageModel(
      id: _toInt(json['id']),
      propertyId: _toInt(json['property_id']),
      imageUrl: json['image_url']?.toString() ?? '',
      isPrimary: _toBool(json['is_primary']),
      displayOrder: _toInt(json['display_order']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    return value?.toString() == '1';
  }
}