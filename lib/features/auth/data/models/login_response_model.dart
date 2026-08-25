import 'auth_tokens_model.dart';
import 'user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.tokens,
    this.user,
  });

  final AuthTokensModel tokens;
  final UserModel? user;

  factory LoginResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return LoginResponseModel(
      tokens: AuthTokensModel.fromJson(json),
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(
        json['user'] as Map<String, dynamic>,
      )
          : null,
    );
  }
}