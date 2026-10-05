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
    final nested = json['data'] is Map ? (json['data'] as Map) : null;
    final raw = json['user'] ?? nested?['user'] ?? json['profile'] ?? nested?['profile'] ?? json;
    final source = raw is Map<String, dynamic>
        ? raw
        : raw is Map
            ? raw.map((key, value) => MapEntry(key.toString(), value))
            : json;

    final fullName = source['full_name']?.toString().trim() ?? '';
    final nameParts = fullName.isEmpty ? const <String>[] : fullName.split(RegExp(r'\s+'));
    return UserModel(
      id: _toInt(source['id']),
      firstName: source['first_name']?.toString() ?? (nameParts.isNotEmpty ? nameParts.first : null),
      lastName: source['last_name']?.toString() ?? (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null),
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