class TwoFactorModel {
  const TwoFactorModel({
    required this.method,
    required this.isEnabled,
    required this.verifiedAt,
  });

  final String? method;
  final bool isEnabled;
  final String? verifiedAt;

  factory TwoFactorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TwoFactorModel(
      method: json['method']?.toString(),
      isEnabled:
          json['is_enabled'] == true ||
          json['is_enabled']?.toString() == '1',
      verifiedAt:
          json['verified_at']?.toString(),
    );
  }
}

class TwoFactorSetupModel {
  const TwoFactorSetupModel({
    required this.secret,
    required this.otpauthUrl,
    required this.message,
  });

  final String secret;
  final String otpauthUrl;
  final String message;

  factory TwoFactorSetupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TwoFactorSetupModel(
      secret: json['secret']?.toString() ?? '',
      otpauthUrl:
          json['otpauth_url']?.toString() ?? '',
      message:
          json['message']?.toString() ?? '',
    );
  }
}
