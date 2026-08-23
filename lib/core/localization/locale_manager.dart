import 'package:flutter/material.dart';

class LocaleManager {
  LocaleManager._();

  static final LocaleManager instance = LocaleManager._();

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' &&
        locale.languageCode != 'ar') {
      return;
    }

    _currentLocale = locale;
  }

  void toggleLocale() {
    _currentLocale = _currentLocale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
  }
}