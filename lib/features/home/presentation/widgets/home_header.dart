import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.onLocationTap,
    this.onNotificationsTap,
  });

  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final iconBoxSize = width < 360 ? 40.0 : 44.0;
    final notificationSize = width < 360 ? 44.0 : 48.0;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onLocationTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: width < 360 ? 20 : 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.translate(
                            'current_location',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                          AppTextStyles.bodySmall.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                localization.translate(
                                  'home_location',
                                ),
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style:
                                AppTextStyles.labelLarge
                                    .copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurface,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                              size: 18,
                              color: theme
                                  .colorScheme
                                  .onSurface,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onNotificationsTap,
            child: Container(
              width: notificationSize,
              height: notificationSize,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}