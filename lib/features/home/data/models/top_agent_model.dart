import '../../../../core/localization/locale_manager.dart';

class TopAgentModel {
  const TopAgentModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.isManager,
    required this.agencyId,
    required this.agencyName,
    required this.agencyLogoUrl,
    this.nameEn,
    this.nameAr,
    this.agencyNameEn,
    this.agencyNameAr,
  });

  final int userId;
  final String name;
  final String phone;
  final String? avatarUrl;
  final bool isManager;
  final int? agencyId;
  final String agencyName;
  final String? agencyLogoUrl;
  final String? nameEn;
  final String? nameAr;
  final String? agencyNameEn;
  final String? agencyNameAr;

  String get displayName {
    if (LocaleManager.instance.isArabic && nameAr?.trim().isNotEmpty == true) return nameAr!.trim();
    if (!LocaleManager.instance.isArabic && nameEn?.trim().isNotEmpty == true) return nameEn!.trim();
    return name;
  }

  String get displayAgencyName {
    if (LocaleManager.instance.isArabic && agencyNameAr?.trim().isNotEmpty == true) return agencyNameAr!.trim();
    if (!LocaleManager.instance.isArabic && agencyNameEn?.trim().isNotEmpty == true) return agencyNameEn!.trim();
    return agencyName;
  }

  factory TopAgentModel.fromJson(Map<String, dynamic> json) {
    final agency = json['agency'] is Map<String, dynamic> ? json['agency'] as Map<String, dynamic> : <String, dynamic>{};
    return TopAgentModel(
      userId: int.tryParse((json['user_id'] ?? json['id']).toString()) ?? 0,
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      nameEn: (json['name_en'] ?? json['nameEn'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? json['nameAr'] ?? '').toString(),
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      isManager: json['is_manager'] == true || json['is_manager']?.toString() == '1',
      agencyId: int.tryParse(agency['id']?.toString() ?? ''),
      agencyName: agency['name']?.toString() ?? json['agency_name']?.toString() ?? '',
      agencyNameEn: (agency['name_en'] ?? json['agency_name_en'] ?? '').toString(),
      agencyNameAr: (agency['name_ar'] ?? json['agency_name_ar'] ?? '').toString(),
      agencyLogoUrl: agency['logo_url']?.toString(),
    );
  }
}
