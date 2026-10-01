import '../../../../core/localization/locale_manager.dart';
class PropertyFeatureModel {
  const PropertyFeatureModel({
    required this.propertyId,
    required this.id,
    required this.name,
    required this.category,
    required this.featureValue,
    this.nameEn,
    this.nameAr,
  });

  final int propertyId;
  final int id;
  final String name;
  final String category;
  final String featureValue;
  final String? nameEn;
  final String? nameAr;

  String get displayName {
    if (LocaleManager.instance.isArabic && nameAr?.trim().isNotEmpty == true) {
      return nameAr!.trim();
    }
    if (!LocaleManager.instance.isArabic && nameEn?.trim().isNotEmpty == true) {
      return nameEn!.trim();
    }
    return name;
  }

  factory PropertyFeatureModel.fromJson(Map<String, dynamic> json) {
    return PropertyFeatureModel(
      propertyId: _toInt(json['property_id']),
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      featureValue: json['feature_value']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      nameAr: json['name_ar']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}