import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient._();

  static const Duration _timeout =
  Duration(seconds: 45);

  static Uri _uri(String endpoint) {
    return Uri.parse(
      '${ApiEndpoints.baseUrl}$endpoint',
    );
  }

  static Future<Map<String, String>> _headers({
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final accessToken =
      await TokenStorage.getAccessToken();

      if (accessToken != null &&
          accessToken.isNotEmpty) {
        headers['Authorization'] =
        'Bearer $accessToken';
      }
    }

    return headers;
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    try {
      final response = await http
          .post(
        _uri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null
            ? null
            : jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        e.message,
      );
    }
  }

  static Future<Map<String, dynamic>> get(
      String endpoint, {
        bool authenticated = false,
      }) async {
    try {
      final response = await http
          .get(
        _uri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        e.message,
      );
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    try {
      final response = await http
          .put(
        _uri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null
            ? null
            : jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        e.message,
      );
    }
  }

  static Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, dynamic>? body,
        bool authenticated = false,
      }) async {
    try {
      final response = await http
          .delete(
        _uri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null
            ? null
            : jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        e.message,
      );
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
        throw ServerException(
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