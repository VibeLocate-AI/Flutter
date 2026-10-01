import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/state/location_manager.dart';
import '../../../notifications/notifications_dependencies.dart';

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
                        AnimatedBuilder(
                          animation: LocationManager.instance,
                          builder: (context, _) {
                            final manager = LocationManager.instance;
                            final current = manager.displayLocation;
                            final displayText = manager.isUpdating
                                ? localization.translate('location_detecting')
                                : (current.isEmpty
                                    ? localization.translate('location_unavailable')
                                    : current);

                            return Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ],
                            );
                          },
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
              child: GetX<_UnreadNotificationsController>(
                init: Get.isRegistered<_UnreadNotificationsController>()
                    ? null
                    : _UnreadNotificationsController(),
                builder: (controller) {
                  final count = controller.count.value;
                  return Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (count > 0)
                        PositionedDirectional(
                          top: 5,
                          end: 5,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnreadNotificationsController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshCount();
  }

  Future<void> refreshCount() async {
    try {
      count.value = await NotificationsDependencies.getUnreadCount();
    } catch (_) {
      // Notification availability must not block the Home screen.
    }
  }
}
