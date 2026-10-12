import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../agent_controller.dart';
import 'agent_dashboard_page.dart';
import 'agent_profile_page.dart';

/// Agent Center contains only features backed by the Laravel Agent contract.
///
/// Deliberately removed from the previous design:
/// - Saved Properties
/// - Settings
/// - the large API/cache placeholder card
/// - generic profile/search/alerts screens that are not Agent endpoints
class AgentCenterPage extends StatefulWidget {
  const AgentCenterPage({super.key});

  @override
  State<AgentCenterPage> createState() => _AgentCenterPageState();
}

class _AgentCenterPageState extends State<AgentCenterPage> {
  late final AgentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AgentController>()
        ? Get.find<AgentController>()
        : Get.put(AgentController(), permanent: true);
    controller.load();
  }

  Future<void> _open(BuildContext context, Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) controller.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.dashboard_customize_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 9),
            const Text('Agent Center'),
          ],
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Refresh Agent data',
              onPressed: controller.isLoading.value ? null : controller.load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final hasData = controller.pending.isNotEmpty ||
            controller.approved.isNotEmpty ||
            controller.rejected.isNotEmpty ||
            controller.pois.isNotEmpty;

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 34),
            children: [
              const _AgentHeader(),
              const SizedBox(height: 14),
              _BackendSummary(controller: controller),
              const SizedBox(height: 22),
              Text(
                'Agent Tools',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 9),
              _AgentToolTile(
                icon: Icons.dashboard_rounded,
                title: 'My Dashboard',
                subtitle: 'Live properties, statuses and agency POIs',
                onTap: () => _open(context, const AgentDashboardPage()),
              ),
              _AgentToolTile(
                icon: Icons.home_work_rounded,
                title: 'Property Management',
                subtitle: 'Pending, approved and rejected properties',
                onTap: () => _open(context, const AgentDashboardPage()),
              ),
              _AgentToolTile(
                icon: Icons.location_on_rounded,
                title: 'Agency POIs',
                subtitle: 'Create, update, delete and view backend POIs',
                onTap: () => _open(context, const AgentDashboardPage()),
              ),
              _AgentToolTile(
                icon: Icons.verified_user_rounded,
                title: 'Profile & Verification',
                subtitle: 'Agent license and verification submission',
                onTap: () => _open(context, const AgentProfilePage()),
              ),
              if (controller.error.value != null && hasData) ...[
                const SizedBox(height: 14),
                _SoftError(message: controller.error.value!),
              ],
              if (controller.isLoading.value && !hasData) ...[
                const SizedBox(height: 18),
                const Center(child: CircularProgressIndicator()),
              ],
              if (controller.error.value != null && !hasData) ...[
                const SizedBox(height: 18),
                _ErrorCard(
                  message: controller.error.value!,
                  onRetry: controller.load,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _AgentHeader extends StatelessWidget {
  const _AgentHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.16),
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.real_estate_agent_rounded,
              color: theme.colorScheme.primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent workspace',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Connected to the Laravel Agent backend',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  'Live data is loaded from the Agent endpoints.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendSummary extends StatelessWidget {
  const _BackendSummary({required this.controller});

  final AgentController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <_SummaryItem>[
      _SummaryItem(
        label: 'Pending',
        value: controller.pending.length,
        icon: Icons.hourglass_top_rounded,
      ),
      _SummaryItem(
        label: 'Approved',
        value: controller.approved.length,
        icon: Icons.check_circle_rounded,
      ),
      _SummaryItem(
        label: 'Rejected',
        value: controller.rejected.length,
        icon: Icons.cancel_rounded,
      ),
      _SummaryItem(
        label: 'POIs',
        value: controller.pois.length,
        icon: Icons.location_on_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live backend data',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            mainAxisExtent: 82,
          ),
          itemBuilder: (_, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(item.icon, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.value}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;
}

class _AgentToolTile extends StatelessWidget {
  const _AgentToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        minVerticalPadding: 11,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: onTap,
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.primary,
        ),
        ),
      ),
    );
  }
}

class _SoftError extends StatelessWidget {
  const _SoftError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Some Agent data could not be refreshed. Cached data is still shown.\n$message',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontSize: 12,
          ),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, size: 34),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
}
