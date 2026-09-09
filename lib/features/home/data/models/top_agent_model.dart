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
  });

  final int userId;
  final String name;
  final String phone;
  final String? avatarUrl;
  final bool isManager;

  final int? agencyId;
  final String agencyName;
  final String? agencyLogoUrl;

  factory TopAgentModel.fromJson(Map<String, dynamic> json) {
    final agency = json['agency'] is Map<String, dynamic>
        ? json['agency'] as Map<String, dynamic>
        : <String, dynamic>{};

    return TopAgentModel(
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      isManager: json['is_manager'] == true ||
          json['is_manager']?.toString() == '1',
      agencyId: int.tryParse(agency['id']?.toString() ?? ''),
      agencyName: agency['name']?.toString() ?? '',
      agencyLogoUrl: agency['logo_url']?.toString(),
    );
  }
}