import '../../../../core/constants/api_endpoints.dart';

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

  ProfileModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? country,
    String? bio,
    String? avatarUrl,
    String? preferredLanguage,
    String? currency,
    String? role,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currency: currency ?? this.currency,
      role: role ?? this.role,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final root = _stringMap(json);
    final source = _findProfileMap(root);
    final preferences = _findMapByKeys(
          root,
          const ['preferences', 'profile_preferences', 'settings'],
        ) ??
        _findMapByKeys(source, const ['preferences']) ??
        const <String, dynamic>{};

    final firstName = _firstText(source, const ['first_name', 'firstName']);
    final lastName = _firstText(source, const ['last_name', 'lastName']);
    final directName = _firstText(
      source,
      const ['full_name', 'fullName', 'name', 'display_name', 'displayName'],
    );

    final fullName = directName.isNotEmpty
        ? directName
        : [firstName, lastName].where((v) => v.isNotEmpty).join(' ');

    final avatar = _firstText(
      source,
      const [
        'avatar_url',
        'avatarUrl',
        'avatar',
        'profile_photo_url',
        'profilePhotoUrl',
        'photo_url',
        'photoUrl',
        'image_url',
        'imageUrl',
        'photo',
        'profile_image',
        'profileImage',
      ],
    );

    return ProfileModel(
      id: _toInt(_firstValue(source, const ['id', 'user_id', 'userId'])),
      fullName: fullName,
      email: _firstText(source, const ['email', 'email_address']),
      phone: _firstText(source, const ['phone', 'phone_number', 'mobile']),
      city: _firstText(source, const ['city', 'city_name']),
      country: _firstText(source, const ['country', 'country_name']),
      bio: _firstText(source, const ['bio', 'about', 'description']),
      avatarUrl: avatar.isEmpty
          ? null
          : _normalizeImage(avatar),
      preferredLanguage: _firstText(
        preferences,
        const ['preferred_language', 'preferredLanguage', 'language'],
      ).isNotEmpty
          ? _firstText(
              preferences,
              const ['preferred_language', 'preferredLanguage', 'language'],
            )
          : _firstText(
              source,
              const ['preferred_language', 'preferredLanguage', 'language'],
            ),
      currency: _firstText(
        preferences,
        const ['currency', 'currency_code'],
      ).isNotEmpty
          ? _firstText(preferences, const ['currency', 'currency_code'])
          : _firstText(source, const ['currency', 'currency_code']),
      role: _firstText(
        source,
        const ['role_slug', 'roleSlug', 'role', 'user_role'],
      ),
    );
  }

  static Map<String, dynamic> _stringMap(Map<dynamic, dynamic> value) =>
      value.map((key, item) => MapEntry(key.toString(), item));

  static Map<String, dynamic> _findProfileMap(Map<String, dynamic> root) {
    final data = root['data'];
    final dataMap = data is Map ? _stringMap(data) : null;

    final nested = _findMapByKeys(
      dataMap ?? root,
      const ['user', 'profile', 'current_user', 'currentUser', 'account'],
    );
    if (nested != null) {
      final deeper = _findMapByKeys(nested, const ['user', 'profile']);
      return deeper ?? nested;
    }

    return dataMap ?? root;
  }

  static Map<String, dynamic>? _findMapByKeys(
    Map<String, dynamic>? source,
    List<String> keys,
  ) {
    if (source == null) return null;
    for (final key in keys) {
      final value = source[key];
      if (value is Map) return _stringMap(value);
    }
    return null;
  }

  static dynamic _firstValue(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value != null) return value;
    }
    return null;
  }

  static String _firstText(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      if (value is Map) {
        final map = _stringMap(value);
        final nested = _firstText(
          map,
          const ['slug', 'name', 'title', 'label', 'value', 'code'],
        );
        if (nested.isNotEmpty) return nested;
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }

  static String _normalizeImage(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('//')) return 'https:$raw';
    final base = ApiEndpoints.baseUrl.replaceFirst(RegExp(r'/$'), '');
    if (raw.startsWith('/')) return '$base$raw';
    if (raw.startsWith('storage/')) return '$base/$raw';
    if (raw.startsWith('uploads/')) return '$base/$raw';
    return raw;
  }

  static int _toInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;
}
