import 'dart:async';

import 'package:flutter/material.dart';

import '../core/storage/onboarding_storage.dart';
import '../core/storage/token_storage.dart';
import '../core/network/api_client.dart';
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

    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();
    final hasAccessToken = accessToken != null && accessToken.isNotEmpty;
    final hasRefreshToken = refreshToken != null && refreshToken.isNotEmpty;

    // A persisted refresh token is a valid local session even when the short
    // lived access token disappeared/expired while the app was closed.
    if (!hasAccessToken && !hasRefreshToken) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.login,
      );
      return;
    }

    // Keep the authenticated session alive with the refresh token.
    // A network timeout must never delete the local session.

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        final refreshed = await ApiClient.refreshSession().timeout(
          const Duration(seconds: 7),
        );

        // A false result can also mean a temporary network/server failure.
        // Never delete the locally persisted session here. ApiClient will
        // retry the refresh when an authenticated request actually needs it.
        if (!refreshed) {
          // Keep the existing access/refresh tokens and continue to Home.
        }
      } on TimeoutException {
        // Cold starts against Render can take longer than the first frame.
        // Keep the session and let the first API request retry normally.
      } catch (_) {
        // Do not log the user out because startup refresh failed for a
        // transient reason. A real 401 will be handled by ApiClient.
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
