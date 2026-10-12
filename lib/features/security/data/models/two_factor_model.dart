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
    String? findString(dynamic value, List<String> keys) {
      if (value is Map) {
        for (final key in keys) {
          final candidate = value[key];
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
        }
        for (final nestedKey in const ['data', 'setup', 'two_factor', 'result', 'payload']) {
          final found = findString(value[nestedKey], keys);
          if (found != null) return found;
        }
      }
      return null;
    }

    final secret = findString(
          json,
          const ['secret', 'two_factor_secret', 'otp_secret'],
        ) ??
        '';

    final uri = findString(
      json,
      const [
        'otpauth_url',
        'otpauth',
        'provisioning_uri',
        'uri',
        'otp_auth_url',
        'otp_uri',
        'qr_code',
        'qr_url',
      ],
    ) ?? '';

    return TwoFactorSetupModel(
      secret: secret,
      otpauthUrl: uri,
      message: findString(json, const ['message']) ?? '',
    );
  }
}
