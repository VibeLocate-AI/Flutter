import 'package:flutter/material.dart';

import '../../core/localization/localization.dart';
import '../../core/theme/app_colors.dart';
import '../../features/home/presentation/pages/home_page.dart';
import 'app_bottom_navigation.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({
    super.key,
  });

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          _NavigationPlaceholder(
            icon: Icons.map_rounded,
            titleKey: 'nav_map',
          ),
          _NavigationPlaceholder(
            icon: Icons.favorite_rounded,
            titleKey: 'nav_favorites',
          ),
          _NavigationPlaceholder(
            icon: Icons.person_rounded,
            titleKey: 'nav_profile',
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _NavigationPlaceholder extends StatelessWidget {
  const _NavigationPlaceholder({
    required this.icon,
    required this.titleKey,
  });

  final IconData icon;
  final String titleKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.blueAccent.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(26),
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: AppColors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  localization.translate(titleKey),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}