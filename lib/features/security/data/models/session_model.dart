class SessionModel {
  const SessionModel({
    required this.id,
    required this.deviceUuid,
    required this.deviceType,
    required this.deviceModel,
    required this.osVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.activeTokens,
  });

  final int id;
  final String deviceUuid;
  final String deviceType;
  final String deviceModel;
  final String osVersion;
  final String? createdAt;
  final String? updatedAt;
  final int activeTokens;

  factory SessionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SessionModel(
      id: _int(json['id']),
      deviceUuid:
          json['device_uuid']?.toString() ?? '',
      deviceType:
          json['device_type']?.toString() ?? '',
      deviceModel:
          json['device_model']?.toString() ?? '',
      osVersion:
          json['os_version']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString(),
      updatedAt:
          json['updated_at']?.toString(),
      activeTokens:
          _int(json['active_tokens']),
    );
  }

  static int _int(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;
}
