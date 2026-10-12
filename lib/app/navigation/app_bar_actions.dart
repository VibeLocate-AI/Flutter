import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/localization.dart';
import '../../core/auth/auth_role.dart';
import '../../core/storage/token_storage.dart';
import '../../features/agent/presentation/pages/agent_center_page.dart';
import '../../features/notifications/notifications_dependencies.dart';

/// Agent is intentionally hidden unless a screen explicitly opts in.
/// The normal app only opts in from Home.
class AgentAppBarAction extends StatelessWidget {
  const AgentAppBarAction({
    super.key,
    this.showOnHome = false,
  });

  final bool showOnHome;

  @override
  Widget build(BuildContext context) {
    if (!showOnHome) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<String?>(
      future: TokenStorage.getRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !AuthRole.isAgent(snapshot.data)) {
          return const SizedBox.shrink();
        }

        return IconButton(
      tooltip: AppLocalization.of(context).translate('nav_agent'),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const AgentCenterPage(),
          ),
        );
          },
          icon: const Icon(Icons.real_estate_agent_outlined),
        );
      },
    );
  }
}

/// Kept for old pages so they compile, but the action itself is hidden.
/// Home owns its notification button because it also needs the unread badge.
class NotificationAppBarAction extends StatelessWidget {
  const NotificationAppBarAction({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
