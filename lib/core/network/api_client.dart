import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../localization/locale_manager.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient._();

  static const Duration _timeout = Duration(seconds: 20);

  static Future<bool>? _refreshing;

  static Uri _buildUri(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$endpoint',
    );

    if (queryParameters == null ||
        queryParameters.isEmpty) {
      return uri;
    }

    final mergedQueryParameters = <String, String>{
      ...uri.queryParameters,
      ...queryParameters.map(
            (key, value) => MapEntry(
          key,
          value.toString(),
        ),
      ),
    };

    return uri.replace(
      queryParameters: mergedQueryParameters,
    );
  }

  static Future<Map<String, String>> _headers({
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': LocaleManager.instance.languageCode,
    };

    if (authenticated) {
      final token =
      await TokenStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] =
        'Bearer $token';
      }
    }

    return headers;
  }

  static Future<bool> refreshSession() {
    return _refreshOnce();
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    return _send(
          () async => http.post(
        _buildUri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool authenticated = false,
      }) async {
    return _send(
          () async => http.get(
        _buildUri(
          endpoint,
          queryParameters: queryParameters,
        ),
        headers: await _headers(
          authenticated: authenticated,
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    return _send(
          () async => http.put(
        _buildUri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    return _send(
          () async => http.delete(
        _buildUri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  static Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request,
      ) async {
    try {
      var response = await request().timeout(
        _timeout,
      );

      if (response.statusCode == 401) {
        final refreshed =
        await _refreshOnce();

        if (refreshed) {
          response = await request().timeout(
            _timeout,
          );
        }
      }

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (error) {
      throw NetworkException(error.message);
    }
  }

  static Future<bool> _refreshOnce() {
    final current = _refreshing;
    if (current != null) {
      return current;
    }

    final future = _tryRefreshToken();
    _refreshing = future;

    return future.whenComplete(() {
      _refreshing = null;
    });
  }

  static Future<bool> _tryRefreshToken() async {
    final refreshToken =
        await TokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http
          .post(
            _buildUri(ApiEndpoints.refreshToken),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refresh_token': refreshToken,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.body.isEmpty) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final source = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded;

      final accessToken = (source['access_token'] ??
              source['accessToken'] ??
              source['token'])
          ?.toString();

      final newRefreshToken =
          (source['refresh_token'] ??
                  source['refreshToken'])
              ?.toString() ??
              refreshToken;

      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );

      // The Laravel refresh endpoint rotates the refresh token and currently
      // gives the rotated token a 7-day lifetime. Re-apply the user's
      // Remember Me preference so a remembered session stays remembered.
      if (await TokenStorage.getRememberMe()) {
        try {
          await http.post(
            _buildUri(ApiEndpoints.rememberMe),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'remember_me': true,
              'refresh_token': newRefreshToken,
            }),
          ).timeout(_timeout);
        } catch (_) {
          // Token refresh itself already succeeded. Do not log the user out
          // only because the optional remember-me extension failed.
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _handleResponse(
      http.Response response,
      ) {
    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded =
        jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        throw const ServerException(
          'Invalid response from server.',
        );
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    final message =
        data['message']?.toString() ??
            data['error']?.toString() ??
            'Something went wrong.';

    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    }

    if (response.statusCode == 422) {
      throw ValidationException(
        message,
        errors: data['errors'],
      );
    }

    if (response.statusCode >= 400 &&
        response.statusCode < 500) {
      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    throw ServerException(
      message,
      statusCode: response.statusCode,
    );
  }
}
