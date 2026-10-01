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
      roleSlug: _roleSlug(source),
    );
  }

  static String? _roleSlug(Map<String, dynamic> source) {
    final raw = source['role_slug'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString().trim();
    }
    final role = source['role'];
    if (role is String && role.trim().isNotEmpty) return role.trim();
    if (role is Map) {
      final slug = role['slug'] ?? role['role_slug'] ?? role['name'];
      if (slug != null && slug.toString().trim().isNotEmpty) {
        return slug.toString().trim();
      }
    }
    return null;
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