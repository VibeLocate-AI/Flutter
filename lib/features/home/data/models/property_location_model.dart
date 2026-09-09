class PropertyLocationModel {
  const PropertyLocationModel({
    required this.id,
    required this.propertyId,
    required this.addressLine1,
    required this.addressLine2,
    required this.buildingName,
    required this.latitude,
    required this.longitude,
    required this.neighborhoodId,
    required this.streetId,
  });

  final int id;
  final int propertyId;
  final String addressLine1;
  final String? addressLine2;
  final String? buildingName;
  final double? latitude;
  final double? longitude;
  final int? neighborhoodId;
  final int? streetId;

  factory PropertyLocationModel.fromJson(Map<String, dynamic> json) {
    return PropertyLocationModel(
      id: _toInt(json['id']),
      propertyId: _toInt(json['property_id']),
      addressLine1: json['address_line_1']?.toString() ?? '',
      addressLine2: json['address_line_2']?.toString(),
      buildingName: json['building_name']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      neighborhoodId: _toNullableInt(json['neighborhood_id']),
      streetId: _toNullableInt(json['street_id']),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
