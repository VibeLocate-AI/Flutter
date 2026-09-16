import 'package:flutter/material.dart';

import '../../core/localization/localization.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final height = width < 360 ? 72.0 : 78.0;

    final items = [
      _NavigationItem(
        label: localization.translate('nav_home'),
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      _NavigationItem(
        label: localization.translate('nav_map'),
        icon: Icons.map_outlined,
        selectedIcon: Icons.map_rounded,
      ),
      _NavigationItem(
        label: localization.translate('nav_favorites'),
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
      ),
      _NavigationItem(
        label: localization.translate('nav_profile'),
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant
                .withValues(alpha: 0.55),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: theme.brightness == Brightness.dark
                  ? 0.30
                  : 0.08,
            ),
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width < 360 ? 6 : 10,
            vertical: 6,
          ),
          child: Row(
            children: List.generate(
              items.length,
                  (index) {
                return Expanded(
                  child: _NavigationItemView(
                    item: items[index],
                    selected: currentIndex == index,
                    onTap: () {
                      onItemSelected(index);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItemView extends StatelessWidget {
  const _NavigationItemView({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final iconSize = width < 360 ? 21.0 : 23.0;
    final itemHeight = width < 360 ? 54.0 : 58.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: itemHeight,
            constraints: const BoxConstraints(
              minWidth: 68,
              maxWidth: 94,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.navyDark
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                      ) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    selected
                        ? item.selectedIcon
                        : item.icon,
                    key: ValueKey(
                      selected
                          ? item.selectedIcon
                          : item.icon,
                    ),
                    size: iconSize,
                    color: selected
                        ? AppColors.blueAccent
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    fontSize: width < 360 ? 9 : 10,
                    height: 1.1,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? AppColors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
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

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}