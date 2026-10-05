import 'auth_tokens_model.dart';
import 'user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.tokens, this.user});

  final AuthTokensModel tokens;
  final UserModel? user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? (json['data'] as Map).map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};
    final rawUser = json['user'] ?? data['user'] ?? json['profile'] ?? data['profile'];
    final user = rawUser is Map
        ? UserModel.fromJson(rawUser.map((k, v) => MapEntry(k.toString(), v)))
        : null;
    return LoginResponseModel(tokens: AuthTokensModel.fromJson(json), user: user);
  }
}
