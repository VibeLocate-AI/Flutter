import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final source = _findTokenMap(json) ?? json;

    final access = source['access_token'] ??
        source['accessToken'] ??
        source['token'] ??
        source['access'];

    final refresh = source['refresh_token'] ??
        source['refreshToken'] ??
        source['refresh'];

    return AuthTokensModel(
      accessToken: access?.toString().trim() ?? '',
      refreshToken: refresh?.toString().trim() ?? '',
    );
  }

  static Map<String, dynamic>? _findTokenMap(dynamic value) {
    if (value is! Map) return null;

    final map = value.map((key, value) => MapEntry(key.toString(), value));
    final hasAccess = map['access_token'] != null ||
        map['accessToken'] != null ||
        map['token'] != null ||
        map['access'] != null;

    if (hasAccess) return map;

    for (final key in const ['data', 'tokens', 'auth', 'result', 'payload']) {
      final nested = _findTokenMap(map[key]);
      if (nested != null) return nested;
    }

    return null;
  }
}
