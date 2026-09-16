import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient._();

  static const Duration _timeout = Duration(seconds: 45);

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
    };

    if (authenticated) {
      final token = await TokenStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
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
        _buildUri(endpoint),
        headers: await _headers(
          authenticated: authenticated,
        ),
        body: body == null ? null : jsonEncode(body),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  static Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        bool authenticated = false,
      }) async {
    try {
      final response = await http
          .get(
        _buildUri(
          endpoint,
          queryParameters: queryParameters,
        ),
        headers: await _headers(
          authenticated: authenticated,
        ),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    }
  }

  static Map<String, dynamic> _handleResponse(
      http.Response response,
      ) {
    Map<String, dynamic> data = {};

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);

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

    final message = data['message']?.toString() ??
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