import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/locale_manager.dart';

import '../location/location_service.dart';

class LocationManager extends ChangeNotifier {
  LocationManager._() {
    _load();
  }

  static final LocationManager instance = LocationManager._();

  static const _latKey = 'location_latitude';
  static const _lngKey = 'location_longitude';
  static const _nameKey = 'location_name';

  double? _latitude;
  double? _longitude;
  String _locationName = '';
  bool _updating = false;
  bool _hasFreshLocation = false;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isUpdating => _updating;
  bool get hasCurrentLocation => _hasFreshLocation && _latitude != null && _longitude != null;

  /// Human-readable area when reverse geocoding succeeds; otherwise a GPS
  /// coordinate fallback is shown so the UI never pretends that location is
  /// unavailable after a valid position has been acquired.
  String get displayLocation {
    if (!hasCurrentLocation) return '';
    if (_locationName.trim().isNotEmpty) return _locationName.trim();
    return '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
  }

  String get lastKnownLocation {
    if (_locationName.trim().isNotEmpty) return _locationName.trim();
    if (_latitude != null && _longitude != null) {
      return '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
    }
    return '';
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _latitude = prefs.getDouble(_latKey);
      _longitude = prefs.getDouble(_lngKey);
      _locationName = prefs.getString(_nameKey) ?? '';
      _hasFreshLocation = false;

      if (_locationName.isEmpty &&
          _latitude != null &&
          _longitude != null) {
        _locationName = await _reverseGeocode(
          _latitude!,
          _longitude!,
        );
        if (_locationName.isNotEmpty) {
          await prefs.setString(_nameKey, _locationName);
        }
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateCurrentLocation() async {
    if (_updating) return false;

    _updating = true;
    notifyListeners();

    try {
      final position =
          await LocationService.instance.getCurrentLocation(allowLastKnown: false);

      if (position == null) {
        _hasFreshLocation = false;
        notifyListeners();
        return false;
      }

      final name = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      // Save locally first so the UI remains useful even if the profile API
      // is temporarily unavailable.
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationName = name;
      _hasFreshLocation = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, _latitude!);
      await prefs.setDouble(_lngKey, _longitude!);
      await prefs.setString(_nameKey, _locationName);

      notifyListeners();

      // The supplied Postman collection does not define a profile-location
      // endpoint, so keep location state local until that backend route exists.
      return true;
    } catch (_) {
      return false;
    } finally {
      _updating = false;
      notifyListeners();
    }
  }

  Future<String> _reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final values = <String?>[
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
        ];

        for (final value in values) {
          if (value != null && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    } catch (_) {
      // Fall back to OpenStreetMap reverse geocoding below.
    }

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'jsonv2',
          'zoom': '14',
          'addressdetails': '1',
          'accept-language': LocaleManager.instance.isArabic ? 'ar,en' : 'en',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'VibeLocate/1.0',
          'Accept-Language': LocaleManager.instance.isArabic
              ? 'ar,en;q=0.8'
              : 'en',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return '';

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return '';

      final address = json['address'];
      if (address is! Map) return '';

      // Prefer the smallest useful area and never return raw coordinates.
      final values = <String>[
        address['neighbourhood']?.toString() ?? '',
        address['suburb']?.toString() ?? '',
        address['quarter']?.toString() ?? '',
        address['city_district']?.toString() ?? '',
        address['city']?.toString() ?? '',
        address['town']?.toString() ?? '',
        address['municipality']?.toString() ?? '',
      ];

      for (final value in values) {
        if (value.trim().isNotEmpty) return value.trim();
      }

      return '';
    } catch (_) {
      return '';
    }
  }
}
