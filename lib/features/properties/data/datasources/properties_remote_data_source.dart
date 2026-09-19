import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/create_property_request.dart';

abstract class PropertiesRemoteDataSource {
  Future<Map<String, dynamic>> getProperties();

  Future<Map<String, dynamic>> getPropertyDetails(
      int id,
      );

  Future<Map<String, dynamic>> createProperty(
      CreatePropertyRequest request,
      );
}

class PropertiesRemoteDataSourceImpl
    implements PropertiesRemoteDataSource {
  const PropertiesRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getProperties() {
    return _get(
      ApiEndpoints.properties,
    );
  }

  @override
  Future<Map<String, dynamic>> getPropertyDetails(
      int id,
      ) {
    return _get(
      ApiEndpoints.propertyDetails(id),
    );
  }

  @override
  Future<Map<String, dynamic>> createProperty(
      CreatePropertyRequest request,
      ) async {
    try {
      final token =
      await TokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw const UnauthorizedException(
          'Authentication token is missing.',
        );
      }

      final multipartRequest =
      http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiEndpoints.baseUrl}'
              '${ApiEndpoints.properties}',
        ),
      );

      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        'Authorization':
        'Bearer $token',
      });

      multipartRequest.fields['title'] =
          request.title;

      multipartRequest.fields['type_id'] =
          request.typeId.toString();

      multipartRequest.fields['listing_type'] =
          request.listingType;

      multipartRequest.fields['price'] =
          request.price.toStringAsFixed(2);

      multipartRequest.fields['currency'] =
          request.currency;

      multipartRequest.fields['description'] =
          request.description;

      multipartRequest.fields['neighborhood_id'] =
          request.neighborhoodId.toString();

      multipartRequest.fields['address_line_1'] =
          request.addressLine1;

      multipartRequest.fields['latitude'] =
          request.latitude.toStringAsFixed(8);

      multipartRequest.fields['longitude'] =
          request.longitude.toStringAsFixed(8);

      multipartRequest.fields['area_sqft'] =
          request.areaSqft.toStringAsFixed(2);

      multipartRequest.fields['bedrooms'] =
          request.bedrooms.toString();

      multipartRequest.fields['bathrooms'] =
          request.bathrooms.toString();

      multipartRequest.fields['property_condition'] =
          request.propertyCondition;

      if (request.addressLine2 != null &&
          request.addressLine2!
              .trim()
              .isNotEmpty) {
        multipartRequest.fields[
        'address_line_2'] =
            request.addressLine2!.trim();
      }

      if (request.buildingName != null &&
          request.buildingName!
              .trim()
              .isNotEmpty) {
        multipartRequest.fields[
        'building_name'] =
            request.buildingName!.trim();
      }

      for (final featureId
      in request.featureIds) {
        multipartRequest.fields[
        'features[]'] =
            featureId.toString();
      }

      if (request.coverImagePath != null &&
          request.coverImagePath!
              .trim()
              .isNotEmpty) {
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            'cover_image',
            request.coverImagePath!,
          ),
        );
      }

      for (final imagePath
      in request.detailImagePaths.values) {
        if (imagePath.trim().isEmpty) {
          continue;
        }

        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            'gallery_images[]',
            imagePath,
          ),
        );
      }

      final streamedResponse =
      await multipartRequest.send().timeout(
        const Duration(
          seconds: 60,
        ),
      );

      final response =
      await http.Response.fromStream(
        streamedResponse,
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
    } on http.ClientException catch (
    error) {
      throw NetworkException(
        error.message,
      );
    }
  }

  Future<Map<String, dynamic>> _get(
      String endpoint,
      ) async {
    try {
      final token =
      await TokenStorage.getAccessToken();

      final headers =
      <String, String>{
        'Accept': 'application/json',
        if (token != null &&
            token.isNotEmpty)
          'Authorization':
          'Bearer $token',
      };

      final response = await http
          .get(
        Uri.parse(
          '${ApiEndpoints.baseUrl}'
              '$endpoint',
        ),
        headers: headers,
      )
          .timeout(
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
    } on http.ClientException catch (
    error) {
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

    if (response.statusCode == 401) {
      throw UnauthorizedException(
        message,
      );
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