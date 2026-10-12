import '../../../../core/localization/locale_manager.dart';

class NearbyPoiModel {
  const NearbyPoiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.latitude,
    required this.longitude,
    required this.icon,
    this.nameAr,
  });

  final int id;
  final String name;
  final String category;
  final String subcategory;
  final double latitude;
  final double longitude;
  final String icon;
  final String? nameAr;

  String get displayName {
    if (LocaleManager.instance.isArabic && nameAr != null && nameAr!.trim().isNotEmpty) {
      return nameAr!.trim();
    }
    return name;
  }

  factory NearbyPoiModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name_en'] ?? json['name'] ?? '').toString().trim();
    return NearbyPoiModel(
      id: int.tryParse('${json['osm_id'] ?? json['id'] ?? 0}') ?? 0,
      name: name,
      nameAr: (json['name_ar'] ?? '').toString().trim().isEmpty ? null : json['name_ar'].toString().trim(),
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
