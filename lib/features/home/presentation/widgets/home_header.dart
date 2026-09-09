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
    final localization =
    AppLocalization.of(context);

    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius:
            BorderRadius.circular(14),
            onTap: onLocationTap,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme
                          .colorScheme
                          .primary
                          .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .location_on_outlined,
                      color:
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.translate(
                            'current_location',
                          ),
                          style: AppTextStyles
                              .bodySmall
                              .copyWith(
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
                                TextOverflow
                                    .ellipsis,
                                style: AppTextStyles
                                    .labelLarge
                                    .copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
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

        const SizedBox(width: 12),

        InkWell(
          borderRadius:
          BorderRadius.circular(14),
          onTap: onNotificationsTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
              theme.colorScheme.surface,
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: theme
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons
                        .notifications_none_rounded,
                    color: theme
                        .colorScheme
                        .onSurface,
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration:
                    const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}