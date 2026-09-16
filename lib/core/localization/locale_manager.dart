import 'dart:ui';

import 'package:flutter/material.dart';

class LocaleManager extends ChangeNotifier {
  LocaleManager._() {
    _currentLocale = _deviceLocale();
  }

  static final LocaleManager instance = LocaleManager._();

  late Locale _currentLocale;

  Locale get currentLocale => _currentLocale;

  String get languageCode => _currentLocale.languageCode;

  Locale _deviceLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;

    if (deviceLocale.languageCode == 'ar') {
      return const Locale('ar');
    }

    return const Locale('en');
  }

  void refreshFromDevice() {
    final nextLocale = _deviceLocale();

    if (nextLocale == _currentLocale) {
      return;
    }

    _currentLocale = nextLocale;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' &&
        locale.languageCode != 'ar') {
      return;
    }

    if (locale.languageCode == _currentLocale.languageCode) {
      return;
    }

    _currentLocale = Locale(locale.languageCode);
    notifyListeners();
  }
}