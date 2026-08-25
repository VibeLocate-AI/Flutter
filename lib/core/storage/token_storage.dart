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

  static Future<void> clearTokens() async {
    await _storage.delete(
      key: _accessTokenKey,
    );

    await _storage.delete(
      key: _refreshTokenKey,
    );
  }

  static Future<void> clearAll() {
    return _storage.deleteAll();
  }
}