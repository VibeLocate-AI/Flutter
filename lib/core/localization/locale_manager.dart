import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleManager extends ChangeNotifier {
  LocaleManager._() {
    _load();
  }

  static final LocaleManager instance = LocaleManager._();

  static const String _localeKey = 'app_locale';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get languageCode => _currentLocale.languageCode;

  bool get isArabic => languageCode == 'ar';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_localeKey);

      if (saved == 'ar' || saved == 'en') {
        _currentLocale = Locale(saved!);
        notifyListeners();
      }
    } catch (_) {
      // Keep English as the safe default.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' &&
        locale.languageCode != 'ar') {
      return;
    }

    final next = Locale(locale.languageCode);

    if (_currentLocale.languageCode == next.languageCode) {
      return;
    }

    _currentLocale = next;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, next.languageCode);
    } catch (_) {
      // The UI still changes even if local persistence fails.
    }
  }

  Future<void> toggleLocale() async {
    await setLocale(
      _currentLocale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en'),
    );
  }
}
