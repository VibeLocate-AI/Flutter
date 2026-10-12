import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();

  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _accessTokenKey =
      'access_token';

  static const String _refreshTokenKey =
      'refresh_token';

  static const String _userIdKey =
      'user_id';

  static const String _deviceUuidKey =
      'device_uuid';

  static const String _emailKey =
      'email';

  static const String _roleKey = 'role_slug';
  static const String _nameKey = 'profile_name';
  static const String _phoneKey = 'profile_phone';
  static const String _cityKey = 'profile_city';
  static const String _countryKey = 'profile_country';

  static const String _rememberMeKey =
      'remember_me';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );
  }

  static Future<String?> getAccessToken() {
    return _storage.read(
      key: _accessTokenKey,
    );
  }

  static Future<String?> getRefreshToken() {
    return _storage.read(
      key: _refreshTokenKey,
    );
  }

  static Future<bool> hasAccessToken() async {
    final token = await getAccessToken();

    return token != null &&
        token.trim().isNotEmpty;
  }

  static Future<bool> hasSession() async {
    final access = await getAccessToken();
    if (access != null && access.trim().isNotEmpty) {
      return true;
    }

    final refresh = await getRefreshToken();
    return refresh != null && refresh.trim().isNotEmpty;
  }

  static Future<void> saveUserId(int id) async {
    await _storage.write(
      key: _userIdKey,
      value: id.toString(),
    );
  }

  static Future<int?> getUserId() async {
    final value = await _storage.read(
      key: _userIdKey,
    );

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  static Future<void> saveEmail(
      String email,
      ) async {
    await _storage.write(
      key: _emailKey,
      value: email,
    );
  }

  static Future<String?> getEmail() {
    return _storage.read(
      key: _emailKey,
    );
  }


  static Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getRole() => _storage.read(key: _roleKey);

  static Future<void> saveRememberMe(
      bool value,
      ) async {
    await _storage.write(
      key: _rememberMeKey,
      value: value.toString(),
    );
  }

  static Future<bool> getRememberMe() async {
    final value = await _storage.read(
      key: _rememberMeKey,
    );

    return value == 'true';
  }

  static Future<void> saveDeviceUuid(
      String uuid,
      ) async {
    await _storage.write(
      key: _deviceUuidKey,
      value: uuid,
    );
  }

  static Future<String?> getDeviceUuid() {
    return _storage.read(
      key: _deviceUuidKey,
    );
  }


  static Future<void> saveLocalProfile({String? name, String? phone, String? city, String? country}) async {
    if (name != null) await _storage.write(key: _nameKey, value: name);
    if (phone != null) await _storage.write(key: _phoneKey, value: phone);
    if (city != null) await _storage.write(key: _cityKey, value: city);
    if (country != null) await _storage.write(key: _countryKey, value: country);
  }

  static Future<String?> getLocalProfileName() => _storage.read(key: _nameKey);
  static Future<String?> getLocalProfilePhone() => _storage.read(key: _phoneKey);
  static Future<String?> getLocalProfileCity() => _storage.read(key: _cityKey);
  static Future<String?> getLocalProfileCountry() => _storage.read(key: _countryKey);


  static Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: _cityKey);
    await _storage.delete(key: _countryKey);
    await _storage.delete(key: _rememberMeKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(
      key: _accessTokenKey,
    );

    await _storage.delete(
      key: _refreshTokenKey,
    );

    await _storage.delete(key: _rememberMeKey);
    await _storage.delete(key: _roleKey);
  }

  static Future<void> clearAll() {
    return _storage.deleteAll();
  }
}