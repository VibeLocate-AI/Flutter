import 'package:flutter/material.dart';

import '../core/storage/onboarding_storage.dart';
import '../core/storage/token_storage.dart';
import 'app_router.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() =>
      _StartupPageState();
}

class _StartupPageState
    extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    final hasSeenOnboarding =
    await OnboardingStorage
        .hasSeenOnboarding();

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

    if (!mounted) {
      return;
    }

    if (hasAccessToken) {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.home,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.login,
      );
    }
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