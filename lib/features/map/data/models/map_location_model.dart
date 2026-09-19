class MapLocationModel {
  const MapLocationModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.propertyId,
    this.title = '',
    this.address = '',
    this.price = '',
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
  final String imageUrl;
  final int? typeId;

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      id: _toInt(json['id'] ?? json['property_id']),
      propertyId: _nullableInt(json['property_id'] ?? json['id']),
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(
        json['longitude'] ?? json['lng'] ?? json['lon'],
      ),
      title: (json['title'] ??
              json['name'] ??
              json['property_title'] ??
              '')
          .toString(),
      address: (json['address'] ??
              json['address_line_1'] ??
              '')
          .toString(),
      price: (json['price'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['image'] ?? '').toString(),
      typeId: _nullableInt(json['type_id']),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
