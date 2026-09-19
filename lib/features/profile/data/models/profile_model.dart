class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.country,
    required this.bio,
    required this.avatarUrl,
    required this.preferredLanguage,
    required this.currency,
    required this.role,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String country;
  final String bio;
  final String? avatarUrl;
  final String preferredLanguage;
  final String currency;
  final String role;

  factory ProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final data = _map(json['data']) ?? json;

    final user =
        _map(data['user']) ??
            _map(data['profile']) ??
            data;

    final profile = _map(data['profile']);

    final preferences =
        _map(data['preferences']) ??
            _map(profile?['preferences']) ??
            <String, dynamic>{};

    final fullName =
    (user['full_name'] ??
        user['name'] ??
        _buildFullName(user))
        .toString()
        .trim();

    return ProfileModel(
      id: _toInt(
        user['id'] ??
            data['id'],
      ),
      fullName: fullName,
      email: (user['email'] ?? '').toString(),
      phone: (user['phone'] ?? '').toString(),
      city: (user['city'] ?? '').toString(),
      country: (user['country'] ?? '').toString(),
      bio: (user['bio'] ?? '').toString(),
      avatarUrl: _nullableString(
        user['avatar_url'] ??
            user['avatar'] ??
            user['profile_photo_url'] ??
            profile?['avatar_url'] ??
            data['avatar_url'],
      ),
      preferredLanguage:
      (
          preferences['preferred_language'] ??
              user['preferred_language'] ??
              data['preferred_language'] ??
              'en'
      ).toString(),
      currency:
      (
          preferences['currency'] ??
              user['currency'] ??
              data['currency'] ??
              'AED'
      ).toString(),
      role:
      (
          user['role'] ??
              user['role_slug'] ??
              data['role'] ??
              ''
      ).toString(),
    );
  }

  static Map<String, dynamic>?
  _map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return null;
  }

  static String _buildFullName(
      Map<String, dynamic> user,
      ) {
    return [
      user['first_name'],
      user['last_name'],
    ]
        .where(
          (value) =>
      value != null &&
          value.toString().trim().isNotEmpty,
    )
        .map(
          (value) => value.toString().trim(),
    )
        .join(' ');
  }

  static int _toInt(dynamic value) {
    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static String? _nullableString(
      dynamic value,
      ) {
    final text =
        value?.toString().trim() ?? '';

    return text.isEmpty ? null : text;
  }
}