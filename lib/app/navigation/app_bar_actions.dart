import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/localization.dart';
import '../../features/agent/presentation/pages/agent_center_page.dart';
import '../../features/notifications/notifications_dependencies.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../core/storage/token_storage.dart';

class AgentAppBarAction extends StatelessWidget {
  const AgentAppBarAction({super.key});

  Future<bool> _isAgent() async {
    final role = (await TokenStorage.getRole() ?? '').trim().toLowerCase();
    return role == 'agent' || role == 'real_estate_agent';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAgent(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return IconButton(
          tooltip: AppLocalization.of(context).translate('nav_agent'),
          onPressed: () => Get.to(() => const AgentCenterPage()),
          icon: const Icon(Icons.real_estate_agent_outlined),
        );
      },
    );
  }
}

class NotificationAppBarAction extends StatelessWidget {
  const NotificationAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<NotificationBadgeController>(
      init: Get.isRegistered<NotificationBadgeController>() ? null : NotificationBadgeController(),
      builder: (controller) {
        final count = controller.count.value;
        return IconButton(
          tooltip: AppLocalization.of(context).translate('notifications'),
          onPressed: () => Get.to(() => const NotificationsPage()),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded),
              if (count > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationBadgeController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshCount();
  }

  Future<void> refreshCount() async {
    try {
      count.value = await NotificationsDependencies.getUnreadCount();
    } catch (_) {}
  }
}
