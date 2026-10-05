import 'dart:async';

import 'package:flutter/material.dart';

import '../core/storage/onboarding_storage.dart';
import '../core/storage/token_storage.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import 'app_router.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final hasSeenOnboarding =
        await OnboardingStorage.hasSeenOnboarding();

    if (!mounted) {
      return;
    }

    if (!hasSeenOnboarding) {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.onboarding,
      );
      return;
    }

    final hasAccessToken =
        await TokenStorage.hasAccessToken();

    if (!hasAccessToken) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.login,
      );
      return;
    }

    // If the user enabled Remember Me, refresh the session before
    // opening the app so an expired access token does not break startup.
    final rememberMe =
        await TokenStorage.getRememberMe();
    final refreshToken =
        await TokenStorage.getRefreshToken();

    if (rememberMe &&
        refreshToken != null &&
        refreshToken.isNotEmpty) {
      try {
        final refreshed = await ApiClient.refreshSession().timeout(
          const Duration(seconds: 7),
        );
        if (!refreshed) {
          throw const UnauthorizedException('Session expired.');
        }
      } on TimeoutException {
        // Render can cold-start. Do not leave the user on a blank startup
        // screen just because refresh took longer than the first frame.
      } catch (_) {
        await TokenStorage.clearTokens();

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRouter.login,
        );
        return;
      }
    }

    if (!mounted) {
      return;
    }

    // Always open the shared user shell. MainNavigationPage reads the role and
    // adds the Agent tab without changing the regular-user navigation.
    Navigator.pushReplacementNamed(context, AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
