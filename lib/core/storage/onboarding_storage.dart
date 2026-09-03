import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  OnboardingStorage._();

  static const String _seenKey = 'onboarding_seen';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_seenKey) ?? false;
  }

  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _seenKey,
      true,
    );
  }

  // استخدميها فقط إذا أردتِ إعادة إظهار الـ Onboarding
  // أثناء التطوير أو من Settings.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_seenKey);
  }
}