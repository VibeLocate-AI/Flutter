import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/state/location_manager.dart';

class SettingsController extends GetxController {
  static const _notificationsKey = 'notifications_enabled';

  final notificationsEnabled = true.obs;
  final isLoading = true.obs;
  final isUpdatingLocation = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      notificationsEnabled.value = prefs.getBool(_notificationsKey) ?? true;
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> updateCurrentLocation() async {
    if (isUpdatingLocation.value) return false;
    isUpdatingLocation.value = true;
    try {
      return await LocationManager.instance.updateCurrentLocation();
    } finally {
      isUpdatingLocation.value = false;
    }
  }

  Future<void> setNotifications(bool enabled) async {
    final previous = notificationsEnabled.value;
    notificationsEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    try {
      await ApiClient.put(
        ApiEndpoints.profilePreferences,
        authenticated: true,
        body: {
          'email_notifications': enabled,
          'browser_notifications': enabled,
        },
      );
    } catch (_) {
      // Keep the local switch usable even when the remote preference endpoint
      // is temporarily unavailable.
      notificationsEnabled.value = previous;
      await prefs.setBool(_notificationsKey, previous);
    }
  }
}
