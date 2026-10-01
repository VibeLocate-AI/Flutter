import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class PropertySectionHeader extends StatelessWidget {
  const PropertySectionHeader({
    super.key,
    required this.titleKey,
    this.subtitleKey,
    this.onSeeAll,
  });

  final String titleKey;
  final String? subtitleKey;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.translate(titleKey),
                style: AppTextStyles.headingSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitleKey != null) ...[
                const SizedBox(height: 4),
                Text(
                  localization.translate(subtitleKey!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 38),
            ),
            child: Text(localization.translate('see_all')),
          ),
      ],
    );
  }
}
