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
  bool get hasCurrentLocation =>
      _hasFreshLocation && _latitude != null && _longitude != null;

  /// Displays the detected city and country, for example:
  /// "Dubai, United Arab Emirates".
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
      // Cached coordinates are immediately usable in the UI. A fresh GPS
      // request still runs from Home/Profile when needed.
      _hasFreshLocation = _latitude != null && _longitude != null;

      if (_locationName.isEmpty && _latitude != null && _longitude != null) {
        // Resolve cached coordinates in the background. It must never delay
        // application startup or the Home screen.
        _resolveCachedName(_latitude!, _longitude!, prefs);
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> _resolveCachedName(
    double latitude,
    double longitude,
    SharedPreferences prefs,
  ) async {
    final name = await _reverseGeocode(latitude, longitude);
    if (name.isEmpty) return;
    _locationName = name;
    await prefs.setString(_nameKey, name);
    notifyListeners();
  }

  Future<bool> updateCurrentLocation() async {
    if (_updating) return false;

    _updating = true;
    notifyListeners();

    try {
      final position = await LocationService.instance
          .getCurrentLocation(allowLastKnown: false);

      if (position == null) {
        _hasFreshLocation = false;
        notifyListeners();
        return false;
      }

      // Coordinates are available immediately. Do not wait for reverse
      // geocoding before returning to the UI; this keeps location updates fast.
      _latitude = position.latitude;
      _longitude = position.longitude;
      _hasFreshLocation = true;
      _locationName = '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, _latitude!);
      await prefs.setDouble(_lngKey, _longitude!);
      await prefs.remove(_nameKey);

      notifyListeners();

      // City/country resolution runs in the background and updates the header
      // as soon as the result is available.
      _resolveFreshName(position.latitude, position.longitude, prefs);

      return true;
    } catch (_) {
      return false;
    } finally {
      _updating = false;
      notifyListeners();
    }
  }

  Future<void> _resolveFreshName(
    double latitude,
    double longitude,
    SharedPreferences prefs,
  ) async {
    final name = await _reverseGeocode(latitude, longitude);
    if (name.isEmpty) return;

    // Ignore a stale geocoding result if the user has already moved again.
    if (_latitude != latitude || _longitude != longitude) return;

    _locationName = name;
    await prefs.setString(_nameKey, name);
    notifyListeners();
  }

  Future<String> _reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 3));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = _firstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.subLocality,
        ]);
        final country = place.country?.trim() ?? '';

        final parts = <String>[
          if (city.isNotEmpty) city,
          if (country.isNotEmpty && country != city) country,
        ];
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Use the network fallback below.
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
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode != 200) return '';

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) return '';

      final address = json['address'];
      if (address is! Map) return '';

      final city = _firstNonEmpty([
        address['city']?.toString(),
        address['town']?.toString(),
        address['municipality']?.toString(),
        address['village']?.toString(),
        address['county']?.toString(),
        address['state']?.toString(),
      ]);
      final country = address['country']?.toString().trim() ?? '';

      final parts = <String>[
        if (city.isNotEmpty) city,
        if (country.isNotEmpty && country != city) country,
      ];
      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
