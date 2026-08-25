import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final source =
    json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AuthTokensModel(
      accessToken:
      source['access_token']?.toString() ?? '',
      refreshToken:
      source['refresh_token']?.toString() ?? '',
    );
  }
}