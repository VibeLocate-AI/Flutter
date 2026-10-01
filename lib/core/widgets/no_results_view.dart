import 'package:flutter/material.dart';

import '../localization/localization.dart';

class NoResultsView extends StatelessWidget {
  const NoResultsView({
    super.key,
    this.onClear,
    this.title,
    this.message,
  });

  final VoidCallback? onClear;
  final String? title;
  final String? message;

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
                width: 220,
                height: 170,
                child: Image.asset(
                  'assets/images/states/no_search_results.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.person_search_rounded,
                        size: 110,
                        color: theme.colorScheme.primary.withValues(alpha: .90),
                      ),
                      Positioned(
                        right: 20,
                        top: 10,
                        child: Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 8,
                        child: Icon(
                          Icons.question_mark_rounded,
                          size: 38,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title ??
                    localization.translate('no_results_title'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message ??
                    localization.translate('no_results_message'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onClear,
                    child: Text(
                      localization.translate('clear_filters'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onClear,
                    child: Text(
                      localization.translate('go_back_to_explore'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
