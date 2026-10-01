import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/localization/locale_manager.dart';
import '../models/create_property_request.dart';

abstract class PropertiesRemoteDataSource {
  Future<Map<String, dynamic>> getProperties();

  Future<Map<String, dynamic>> getPropertyDetails(
      int id,
      );

  Future<Map<String, dynamic>> getMyProperties();

  Future<Map<String, dynamic>> createProperty(
      CreatePropertyRequest request,
      );
}

class PropertiesRemoteDataSourceImpl
    implements PropertiesRemoteDataSource {
  const PropertiesRemoteDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getProperties() async {
    final language = LocaleManager.instance.languageCode;
    final collected = <Map<String, dynamic>>[];
    final seenIds = <int>{};

    Future<Map<String, dynamic>> fetch(String endpoint, {int? page}) {
      final queryParameters = <String, dynamic>{
        'lang': language,
        'per_page': 100,
      };
      if (page != null) {
        queryParameters['page'] = page;
      }

      return _get(
        endpoint,
        queryParameters: queryParameters,
      );
    }

    Map<String, dynamic> response;
    try {
      response = await fetch(ApiEndpoints.propertiesPage(1), page: 1);
    } catch (_) {
      response = await fetch(ApiEndpoints.properties, page: 1);
    }
    _appendProperties(response, collected, seenIds);

    final pagination = _pagination(response);
    var lastPage = _toInt(pagination?['last_page']);
    if (lastPage <= 0) {
      lastPage = _toInt(pagination?['total_pages']);
    }

    if (lastPage <= 1 && collected.length >= 100) {
      lastPage = 50;
    }

    if (lastPage > 1) {
      for (var page = 2; page <= lastPage; page++) {
        try {
          response = await fetch(
            ApiEndpoints.propertiesPage(page),
            page: page,
          );
        } catch (_) {
          // Some deployments expose only the first collection route.
          // Keep the properties already collected instead of failing the
          // whole screen when a later page is unavailable.
          break;
        }

        final before = collected.length;
        _appendProperties(response, collected, seenIds);
        if (collected.length == before) break;

        // When pagination metadata is missing, stop once a page contains
        // fewer records than requested.
        final pageItems = _countProperties(response);
        if (pagination == null && pageItems < 100) break;
      }
    }

    if (collected.isNotEmpty) {
      return {
        'success': true,
        'data': collected,
        'properties': collected,
      };
    }

    return response;
  }

  void _appendProperties(
    Map<String, dynamic> response,
    List<Map<String, dynamic>> target,
    Set<int> seenIds,
  ) {
    dynamic value = response['data'];
    if (value is Map<String, dynamic>) {
      value = value['properties'] ?? value['data'];
    }
    value ??= response['properties'];
    if (value is! List) return;

    for (final item in value.whereType<Map<String, dynamic>>()) {
      final id = _toInt(item['id']);
      if (id == 0 || seenIds.add(id)) target.add(item);
    }
  }


  int _countProperties(Map<String, dynamic> response) {
    dynamic value = response['data'];
    if (value is Map<String, dynamic>) {
      value = value['properties'] ?? value['data'];
    }
    value ??= response['properties'];
    return value is List ? value.length : 0;
  }

  Map<String, dynamic>? _pagination(Map<String, dynamic> response) {
    final value = response['pagination'];
    if (value is Map<String, dynamic>) return value;
    final data = response['data'];
    if (data is Map<String, dynamic> && data['pagination'] is Map<String, dynamic>) {
      return data['pagination'] as Map<String, dynamic>;
    }
    return null;
  }

  int _toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  @override
  Future<Map<String, dynamic>> getMyProperties() async {
    final language = LocaleManager.instance.languageCode;
    try {
      return await _get(
        ApiEndpoints.myProperties,
        queryParameters: {
          'lang': language,
          'per_page': 24,
          'page': 1,
        },
      );
    } catch (_) {
      return {
        'success': true,
        'data': const [],
        'properties': const [],
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getPropertyDetails(
      int id,
      ) {
    return _get(
      ApiEndpoints.propertyDetails(id),
      queryParameters: {
        'lang': LocaleManager.instance.languageCode,
      },
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

      if (request.actionType != null &&
          request.actionType!.trim().isNotEmpty) {
        multipartRequest.fields['action_type'] =
            request.actionType!.trim();
      }

      if (request.rentFrequency != null &&
          request.rentFrequency!.trim().isNotEmpty) {
        multipartRequest.fields['rent_frequency'] =
            request.rentFrequency!.trim();
      }

      if (request.virtualTourUrl != null &&
          request.virtualTourUrl!.trim().isNotEmpty) {
        multipartRequest.fields['virtual_tour_url'] =
            request.virtualTourUrl!.trim();
      }

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
      String endpoint, {
      Map<String, dynamic>? queryParameters,
      }) {
    return ApiClient.get(
      endpoint,
      queryParameters: queryParameters,
      authenticated: true,
    );
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