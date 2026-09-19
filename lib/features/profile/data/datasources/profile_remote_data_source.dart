import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body,
      );

  Future<Map<String, dynamic>> completeProfile(
      Map<String, dynamic> body,
      );

  Future<Map<String, dynamic>> uploadAvatar(
      String filePath,
      );
}

class ProfileRemoteDataSourceImpl
    implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getProfile() {
    return _request(
          () async {
        return http.get(
          Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.profile}',
          ),
          headers: await _headers(),
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> body,
      ) {
    return _request(
          () async {
        return http.put(
          Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.profile}',
          ),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>> completeProfile(
      Map<String, dynamic> body,
      ) {
    return _request(
          () async {
        return http.post(
          Uri.parse(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.completeProfile}',
          ),
          headers: await _headers(),
          body: jsonEncode(body),
        );
      },
    );
  }

  @override
  Future<Map<String, dynamic>> uploadAvatar(
      String filePath,
      ) async {
    try {
      final token =
      await TokenStorage.getAccessToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.profile}/avatar',
        ),
      );

      request.headers['Accept'] =
      'application/json';

      if (token != null &&
          token.isNotEmpty) {
        request.headers['Authorization'] =
        'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          filePath,
        ),
      );

      final streamedResponse =
      await request.send();

      final response =
      await http.Response.fromStream(
        streamedResponse,
      );

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (error) {
      throw NetworkException(
        error.message,
      );
    } catch (error) {
      throw NetworkException(
        error.toString(),
      );
    }
  }

  Future<Map<String, String>> _headers() async {
    final token =
    await TokenStorage.getAccessToken();

    return {
      'Accept':
      'application/json',
      'Content-Type':
      'application/json',
      if (token != null &&
          token.isNotEmpty)
        'Authorization':
        'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _request(
      Future<http.Response> Function()
      action,
      ) async {
    try {
      final response =
      await action().timeout(
        const Duration(
          seconds: 45,
        ),
      );

      return _decodeResponse(
        response,
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const NetworkException(
        'Request timed out. Please try again.',
      );
    } on http.ClientException catch (error) {
      throw NetworkException(
        error.message,
      );
    }
  }

  Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    Map<String, dynamic> data =
    <String, dynamic>{};

    if (response.body.isNotEmpty) {
      try {
        final decoded =
        jsonDecode(response.body);

        if (decoded
        is Map<String, dynamic>) {
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

    if (response.statusCode ==
        401) {
      throw UnauthorizedException(
        message,
      );
    }

    if (response.statusCode ==
        422) {
      throw ValidationException(
        message,
        errors: data['errors'],
      );
    }

    if (response.statusCode >= 400 &&
        response.statusCode < 500) {
      throw ApiException(
        message,
        statusCode:
        response.statusCode,
      );
    }

    throw ServerException(
      message,
      statusCode:
      response.statusCode,
    );
  }
}