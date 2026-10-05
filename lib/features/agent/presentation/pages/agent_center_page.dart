import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../properties/presentation/pages/add_property_page.dart';
import '../../../properties/presentation/pages/properties_page.dart';
import 'agent_dashboard_page.dart';

class AgentCenterPage extends StatelessWidget {
  const AgentCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalization.of(context);
    final theme = Theme.of(context);
    final cards = <_AgentAction>[
      _AgentAction(Icons.dashboard_customize_rounded, l10n.translate('agent_dashboard'), () => Get.to(() => const AgentDashboardPage())),
      _AgentAction(Icons.pending_actions_rounded, l10n.translate('pending'), () => Get.to(() => const AgentDashboardPage())),
      _AgentAction(Icons.verified_rounded, l10n.translate('approved'), () => Get.to(() => const AgentDashboardPage())),
      _AgentAction(Icons.cancel_outlined, l10n.translate('rejected'), () => Get.to(() => const AgentDashboardPage())),
      _AgentAction(Icons.home_work_rounded, l10n.translate('my_properties'), () => Get.to(() => const PropertiesPage())),
      _AgentAction(Icons.add_home_work_rounded, l10n.translate('add_property'), () => Get.to(() => const AddPropertyPage())),
      _AgentAction(Icons.place_rounded, l10n.translate('agent_pois'), () => Get.to(() => const AgentDashboardPage())),
      _AgentAction(Icons.verified_user_outlined, l10n.translate('agent_submit_license'), () => Get.to(() => const AgentDashboardPage())),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('nav_agent')),
        actions: const [
          // Keep notifications and profile on the Agent workspace itself.
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.real_estate_agent_rounded, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.translate('agent_dashboard'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 92,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = cards[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(item.icon, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRouter.settingsPage),
            icon: const Icon(Icons.settings_outlined),
            label: Text(l10n.translate('settings')),
          ),
        ],
      ),
    );
  }
}

class _AgentAction {
  const _AgentAction(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
  final VoidCallback onTap;
}
