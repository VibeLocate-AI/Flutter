class NearbyPoiModel {
  const NearbyPoiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.latitude,
    required this.longitude,
    required this.icon,
  });

  final int id;
  final String name;
  final String category;
  final String subcategory;
  final double latitude;
  final double longitude;
  final String icon;

  factory NearbyPoiModel.fromJson(Map<String, dynamic> json) {
    return NearbyPoiModel(
      id: int.tryParse('${json['osm_id'] ?? json['id'] ?? 0}') ?? 0,
      name: (json['name'] ?? '').toString().trim(),
      category: (json['category'] ?? '').toString().trim(),
      subcategory: (json['subcategory'] ?? '').toString().trim(),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      icon: (json['icon'] ?? '📍').toString(),
    );
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
