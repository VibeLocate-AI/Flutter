import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_manager.dart';
import 'app_router.dart';
import 'startup_page.dart';

class VibeLocateApp extends StatelessWidget {
  const VibeLocateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;

    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'VibeLocate AI',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeManager.themeMode,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizationDelegate(),
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: AppRouter.generateRoute,
          home: const StartupPage(),
        );
      },
    );
  }
}