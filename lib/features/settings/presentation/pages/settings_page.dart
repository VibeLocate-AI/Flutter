import 'package:flutter/material.dart';
import '../../../../app/navigation/app_bar_actions.dart';
import 'package:get/get.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../security/presentation/pages/change_password_page.dart';
import '../../../security/presentation/pages/sessions_page.dart';
import '../../../security/presentation/pages/two_factor_page.dart';
import '../../settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController(), permanent: true);
    return AnimatedBuilder(
      animation: Listenable.merge([LocaleManager.instance, ThemeManager.instance]),
      builder: (context, _) {
        final l10n = AppLocalization.of(context);
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(l10n.translate('settings')),
            actions: const [AgentAppBarAction(), NotificationAppBarAction()],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              children: [
                _Section(
                  title: l10n.translate('preferences'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: Text(l10n.translate('language')),
                      subtitle: Text(LocaleManager.instance.isArabic ? l10n.translate('arabic') : l10n.translate('english')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showLanguageSheet(context),
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      value: controller.notificationsEnabled.value,
                      onChanged: controller.setNotifications,
                      secondary: const Icon(Icons.notifications_active_outlined),
                      title: Text(l10n.translate('notifications')),
                      subtitle: Text(controller.notificationsEnabled.value ? l10n.translate('notifications_enabled') : l10n.translate('notifications_disabled')),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(ThemeManager.instance.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                      title: Text(l10n.translate('appearance')),
                      subtitle: Text(ThemeManager.instance.isDark ? l10n.translate('dark') : l10n.translate('light')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _showThemeSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: l10n.translate('security'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline_rounded),
                      title: Text(l10n.translate('change_password')),
                      subtitle: Text(l10n.translate('change_password_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.devices_rounded),
                      title: Text(l10n.translate('sessions_devices')),
                      subtitle: Text(l10n.translate('sessions_devices_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionsPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security_rounded),
                      title: Text(l10n.translate('two_factor_security')),
                      subtitle: Text(l10n.translate('two_factor_security_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TwoFactorPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(l10n.translate('update_current_location')),
                      subtitle: Text(l10n.translate('update_current_location_subtitle')),
                      trailing: Obx(
                        () => controller.isUpdatingLocation.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.chevron_right_rounded),
                      ),
                      onTap: controller.isUpdatingLocation.value
                          ? null
                          : () async {
                              final success = await controller.updateCurrentLocation();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? l10n.translate('location_updated_successfully')
                                        : l10n.translate('location_update_failed'),
                                  ),
                                ),
                              );
                            },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(l10n.translate('safety_security')),
                      subtitle: Text(l10n.translate('safety_security_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pushNamed(context, AppRouter.safetySecurity),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help_outline_rounded),
                      title: Text(l10n.translate('help_center')),
                      subtitle: Text(l10n.translate('help_center_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pushNamed(context, AppRouter.helpCenter),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(l10n.translate('terms_title')),
                      subtitle: Text(l10n.translate('terms_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pushNamed(context, AppRouter.terms),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(l10n.translate('privacy_title')),
                      subtitle: Text(l10n.translate('privacy_subtitle')),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pushNamed(context, AppRouter.privacy),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: l10n.translate('settings_about'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
                      title: const Text('VibeLocate AI'),
                      subtitle: Text(l10n.translate('settings_about_subtitle')),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }
}


Future<void> _showLanguageSheet(BuildContext context) async {
  final localization = AppLocalization.of(context);
  final current = LocaleManager.instance.currentLocale;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localization.translate('choose_language'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(localization.translate('english')),
              trailing: current.languageCode == 'en'
                  ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.pop(sheetContext);
                await LocaleManager.instance.setLocale(const Locale('en'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(localization.translate('arabic')),
              trailing: current.languageCode == 'ar'
                  ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () async {
                Navigator.pop(sheetContext);
                await LocaleManager.instance.setLocale(const Locale('ar'));
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showThemeSheet(BuildContext context) async {
  final localization = AppLocalization.of(context);
  final current = ThemeManager.instance.themeMode;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localization.translate('appearance'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              icon: Icons.brightness_auto_rounded,
              title: localization.translate('system'),
              selected: current == ThemeMode.system,
              onTap: () {
                ThemeManager.instance.setThemeMode(ThemeMode.system);
                Navigator.pop(sheetContext);
              },
            ),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              title: localization.translate('light'),
              selected: current == ThemeMode.light,
              onTap: () {
                ThemeManager.instance.setThemeMode(ThemeMode.light);
                Navigator.pop(sheetContext);
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              title: localization.translate('dark'),
              selected: current == ThemeMode.dark,
              onTap: () {
                ThemeManager.instance.setThemeMode(ThemeMode.dark);
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          ...children,
        ],
      ),
    );
  }
}
