import 'package:flutter/material.dart';

class LocaleManager extends ChangeNotifier {
  LocaleManager._();

  static final LocaleManager instance = LocaleManager._();

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get languageCode => _currentLocale.languageCode;

  bool get isArabic => languageCode == 'ar';

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' &&
        locale.languageCode != 'ar') {
      return;
    }

    if (_currentLocale.languageCode == locale.languageCode) {
      return;
    }

    _currentLocale = Locale(locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    setLocale(
      _currentLocale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en'),
    );
  }
}