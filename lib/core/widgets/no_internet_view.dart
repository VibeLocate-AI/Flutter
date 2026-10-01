import 'package:flutter/material.dart';

import '../localization/localization.dart';

class NoInternetView extends StatelessWidget {
  const NoInternetView({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 190,
                height: 170,
                child: Image.asset(
                  'assets/images/states/no_internet.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 88,
                        color: theme.colorScheme.primary,
                      ),
                      Positioned(
                        right: 28,
                        top: 28,
                        child: Icon(
                          Icons.close_rounded,
                          size: 30,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localization.translate('no_internet_title'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localization.translate('no_internet_message'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalization.of(context).translate('try_again_short')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
