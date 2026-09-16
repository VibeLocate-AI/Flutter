class PropertyFeatureModel {
  const PropertyFeatureModel({
    required this.propertyId,
    required this.id,
    required this.name,
    required this.category,
    required this.featureValue,
  });

  final int propertyId;
  final int id;
  final String name;
  final String category;
  final String featureValue;

  factory PropertyFeatureModel.fromJson(Map<String, dynamic> json) {
    return PropertyFeatureModel(
      propertyId: _toInt(json['property_id']),
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      featureValue: json['feature_value']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}