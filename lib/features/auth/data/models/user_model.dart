import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    super.id,
    super.firstName,
    super.lastName,
    super.email,
    super.phone,
    super.roleSlug,
  });

  factory UserModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final source =
    json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return UserModel(
      id: _toInt(source['id']),
      firstName: source['first_name']?.toString(),
      lastName: source['last_name']?.toString(),
      email: source['email']?.toString(),
      phone: source['phone']?.toString(),
      roleSlug: source['role_slug']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }
}