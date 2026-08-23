import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/localization.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import 'app_router.dart';

class VibeLocateApp extends StatelessWidget {
  const VibeLocateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'VibeLocate AI',

      theme: AppTheme.light(),

      locale: const Locale('en'),

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

      home: const OnboardingPage(),
    );
  }
}