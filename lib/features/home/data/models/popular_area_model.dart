import '../../../../core/localization/locale_manager.dart';

class PopularAreaModel {
  const PopularAreaModel({
    required this.id,
    required this.name,
    required this.propertiesCount,
    this.imageUrl,
    this.nameEn,
    this.nameAr,
  });

  final int id;
  final String name;
  final int propertiesCount;
  final String? imageUrl;
  final String? nameEn;
  final String? nameAr;

  String get displayName {
    if (LocaleManager.instance.isArabic && nameAr?.trim().isNotEmpty == true) return nameAr!.trim();
    if (!LocaleManager.instance.isArabic && nameEn?.trim().isNotEmpty == true) return nameEn!.trim();
    return name;
  }

  factory PopularAreaModel.fromJson(Map<String, dynamic> json) {
    return PopularAreaModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] ?? json['name_en'] ?? json['name_ar'] ?? '').toString(),
      nameEn: (json['name_en'] ?? json['nameEn'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? json['nameAr'] ?? '').toString(),
      propertiesCount: int.tryParse(json['properties_count']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString(),
    );
  }
}
