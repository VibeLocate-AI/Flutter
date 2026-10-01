import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<Position?> getCurrentLocation({bool allowLastKnown = false}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return allowLastKnown
            ? await Geolocator.getLastKnownPosition()
            : null;
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        return allowLastKnown
            ? await Geolocator.getLastKnownPosition()
            : null;
      }
    } catch (_) {
      return null;
    }
  }
}
