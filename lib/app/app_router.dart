import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/legal_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/reset_password_success_page.dart';
import '../features/auth/presentation/pages/verification_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import 'startup_page.dart';

class AppRouter {
  AppRouter._();

  static const String startup = '/startup';

  static const String onboarding = '/onboarding';

  static const String login = '/login';

  static const String register = '/register';

  static const String forgotPassword =
      '/forgot-password';

  static const String verification =
      '/verification';

  static const String resetPassword =
      '/reset-password';

  static const String resetSuccess =
      '/reset-success';

  static const String terms = '/terms';

  static const String privacy = '/privacy';

  static const String home = '/home';

  static Route<dynamic> generateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
      case startup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const StartupPage(),
        );

      case onboarding:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingPage(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );

      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterPage(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
          const ForgotPasswordPage(),
        );

      case verification:
        final args =
        settings.arguments
        as VerificationPageArgs;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerificationPage(
            args: args,
          ),
        );

      case resetPassword:
        final args =
        settings.arguments
        as ResetPasswordArgs;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordPage(
            args: args,
          ),
        );

      case resetSuccess:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
          const ResetPasswordSuccessPage(),
        );

      case terms:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LegalPage(
            type: LegalPageType.terms,
          ),
        );

      case privacy:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LegalPage(
            type: LegalPageType.privacy,
          ),
        );

      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomePage(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Page not found',
              ),
            ),
          ),
        );
    }
  }
}