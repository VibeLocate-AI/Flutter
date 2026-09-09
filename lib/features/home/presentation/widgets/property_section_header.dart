import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class PropertySectionHeader extends StatelessWidget {
  const PropertySectionHeader({
    super.key,
    required this.titleKey,
    this.onSeeAll,
  });

  final String titleKey;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            localization.translate(titleKey),
            style: AppTextStyles.headingSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            localization.translate('see_all'),
          ),
        ),
      ],
    );
  }
}