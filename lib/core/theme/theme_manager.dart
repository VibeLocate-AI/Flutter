import 'package:flutter/material.dart';

import '../storage/theme_storage.dart';

class ThemeManager extends ChangeNotifier {
  ThemeManager._() {
    _load();
  }

  static final ThemeManager instance = ThemeManager._();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isSystem => _themeMode == ThemeMode.system;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> _load() async {
    try {
      final saved = await ThemeStorage.getThemeMode();

      final mode = switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

      if (_themeMode == mode) {
        return;
      }

      _themeMode = mode;
      notifyListeners();
    } catch (_) {
      // Keep system theme as the safe default.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    try {
      await ThemeStorage.saveThemeMode(value);
    } catch (_) {
      // The UI still changes even if local persistence fails.
    }
  }
}
