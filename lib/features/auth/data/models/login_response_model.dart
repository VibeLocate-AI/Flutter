import 'auth_tokens_model.dart';
import 'user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.tokens, this.user});

  final AuthTokensModel tokens;
  final UserModel? user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final rawUser = _findUserMap(json);
    final user = rawUser == null ? null : UserModel.fromJson(rawUser);
    return LoginResponseModel(
      tokens: AuthTokensModel.fromJson(json),
      user: user,
    );
  }

  static Map<String, dynamic>? _findUserMap(dynamic value) {
    if (value is! Map) return null;

    final map = value.map((key, value) => MapEntry(key.toString(), value));
    for (final key in const ['user', 'profile', 'account']) {
      final candidate = map[key];
      if (candidate is Map) {
        return candidate.map((key, value) => MapEntry(key.toString(), value));
      }
    }

    for (final key in const ['data', 'result', 'payload']) {
      final nested = _findUserMap(map[key]);
      if (nested != null) return nested;
    }

    // Some responses put the user fields directly at the root.
    if (map['id'] != null ||
        map['email'] != null ||
        map['first_name'] != null ||
        map['full_name'] != null ||
        map['role'] != null ||
        map['role_slug'] != null) {
      return map;
    }

    return null;
  }
}
