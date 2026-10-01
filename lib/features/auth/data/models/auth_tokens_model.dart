import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final source = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final access = source['access_token'] ??
        source['accessToken'] ??
        source['token'];

    final refresh = source['refresh_token'] ??
        source['refreshToken'];

    return AuthTokensModel(
      accessToken: access?.toString() ?? '',
      refreshToken: refresh?.toString() ?? '',
    );
  }
}
