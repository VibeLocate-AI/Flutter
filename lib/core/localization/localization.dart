import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalization {
  AppLocalization(this.locale);

  final Locale locale;

  Map<String, String> _localizedStrings = {};

  Future<void> load() async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );

    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map(
          (key, value) => MapEntry(
        key,
        value.toString(),
      ),
    );
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static AppLocalization of(BuildContext context) {
    final localization =
    Localizations.of<AppLocalization>(context, AppLocalization);

    if (localization == null) {
      throw FlutterError(
        'AppLocalization.of() called before localization was initialized.',
      );
    }

    return localization;
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return const ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    final localization = AppLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) {
    return false;
  }
}