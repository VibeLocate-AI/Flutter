import 'package:flutter/material.dart';

import '../core/localization/localization.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/legal_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/reset_password_success_page.dart';
import '../features/auth/presentation/pages/verification_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/agent/presentation/pages/agent_dashboard_page.dart';
import '../features/agent/presentation/pages/agent_register_page.dart';
import '../features/properties/presentation/pages/properties_page.dart';
import '../features/properties/presentation/pages/property_details_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import 'navigation/main_navigation_page.dart';
import 'startup_page.dart';

class AppRouter {
  AppRouter._();

  static const String startup = '/startup';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verification = '/verification';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String safetySecurity = '/safety-security';
  static const String helpCenter = '/help-center';
  static const String home = '/home';
  static const String agent = '/agent';
  static const String agentRegister = '/agent-register';
  static const String properties = '/properties';
  static const String propertyDetails = '/property-details';
  static const String propertyLocation = '/property-location';

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
          builder: (_) => const ForgotPasswordPage(),
        );

      case verification:
        final args = settings.arguments as VerificationPageArgs;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerificationPage(
            args: args,
          ),
        );

      case resetPassword:
        final args = settings.arguments as ResetPasswordArgs;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordPage(
            args: args,
          ),
        );

      case resetSuccess:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResetPasswordSuccessPage(),
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

      case safetySecurity:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LegalPage(
            type: LegalPageType.safetySecurity,
          ),
        );

      case helpCenter:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LegalPage(
            type: LegalPageType.helpCenter,
          ),
        );

      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavigationPage(),
        );

      case agent:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AgentDashboardPage(),
        );

      case agentRegister:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AgentRegisterPage(),
        );

      case properties:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PropertiesPage(),
        );

      case propertyDetails:
        final propertyId = settings.arguments as int;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PropertyDetailsPage(
            propertyId: propertyId,
          ),
        );

      case propertyLocation:
        final propertyId = settings.arguments as int;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MapPage(
            initialPropertyId: propertyId,
          ),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            final localization = AppLocalization.of(context);

            return Scaffold(
              body: Center(
                child: Text(
                  localization.translate('page_not_found'),
                ),
              ),
            );
          },
        );
    }
  }
}