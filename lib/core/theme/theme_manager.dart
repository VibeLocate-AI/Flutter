import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  ThemeManager._();

  static final ThemeManager instance = ThemeManager._();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
  }
}