import 'package:flutter/material.dart';

import '../../core/localization/localization.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final compact = MediaQuery.sizeOf(context).width < 370;
    final background = theme.brightness == Brightness.dark
        ? AppColors.navigationDark
        : AppColors.navigationLight;

    final items = <_NavEntry>[
      _NavEntry(Icons.home_rounded, localization.translate('nav_home')),
      _NavEntry(Icons.map_outlined, localization.translate('nav_map')),
      _NavEntry(
        Icons.home_work_outlined,
        localization.translate('nav_my_properties'),
      ),
      _NavEntry(
        Icons.favorite_border_rounded,
        localization.translate('nav_favorites'),
      ),
      _NavEntry(
        Icons.person_outline_rounded,
        localization.translate('nav_profile'),
      ),
    ];

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        compact ? 10 : 14,
        0,
        compact ? 10 : 14,
        compact ? 8 : 10,
      ),
      child: Container(
        height: compact ? 72 : 80,
        decoration: BoxDecoration(
          color: background.withValues(alpha: .98),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: .16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? .34 : .10,
              ),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: 6,
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = widget.currentIndex == index;

            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => widget.onItemSelected(index),
                  child: SizedBox(
                    height: compact ? 60 : 66,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('${widget.currentIndex}-$index'),
                        tween: Tween<double>(
                          begin: selected ? 0 : 0,
                          end: selected ? -7 : 0,
                        ),
                        duration: const Duration(milliseconds: 560),
                        curve: Curves.elasticOut,
                        builder: (context, bounce, child) {
                          final scale = selected
                              ? (1.0 + (((-bounce - 2) / 5).clamp(0.0, 1.0) * .08))
                              : 1.0;
                          return Transform.translate(
                            offset: Offset(0, bounce),
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              width: selected ? 46 : 34,
                              height: selected ? 46 : 30,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.navyPrimary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.navyPrimary
                                              .withValues(alpha: .30),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  selected
                                      ? _selectedIcon(index)
                                      : item.icon,
                                  size: selected ? 22 : 20,
                                  color: selected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: compact ? 11 : 12,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: compact ? 8 : 9,
                                  height: 1.05,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  IconData _selectedIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.map_rounded;
      case 2:
        return Icons.home_work_rounded;
      case 3:
        return Icons.favorite_rounded;
      case 4:
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }
}

class _NavEntry {
  const _NavEntry(this.icon, this.label);

  final IconData icon;
  final String label;
}
