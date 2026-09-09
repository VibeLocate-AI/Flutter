import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/popular_area_model.dart';

class PopularAreaCard extends StatelessWidget {
  const PopularAreaCard({
    super.key,
    required this.area,
  });

  final PopularAreaModel area;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            area.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${area.propertiesCount} properties',
            style: AppTextStyles.bodySmall.copyWith(
              color:
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}