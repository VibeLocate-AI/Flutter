import 'package:flutter/material.dart';

import '../../core/localization/localization.dart';

class AppBottomNavigation
    extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onAddProperty,
  });

  final int currentIndex;
  final ValueChanged<int>
  onItemSelected;
  final VoidCallback
  onAddProperty;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final localization =
    AppLocalization.of(
      context,
    );

    final width =
        MediaQuery.sizeOf(
          context,
        ).width;

    final compact =
        width < 360;

    return Container(
      decoration:
      BoxDecoration(
        color:
        theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme
                .colorScheme
                .outlineVariant
                .withValues(
              alpha: 0.45,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: theme.brightness ==
                  Brightness.dark
                  ? 0.24
                  : 0.07,
            ),
            blurRadius: 20,
            offset:
            const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
          EdgeInsets.fromLTRB(
            compact ? 3 : 7,
            8,
            compact ? 3 : 7,
            8,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _NavItem(
                  label:
                  localization
                      .translate(
                    'nav_home',
                  ),
                  icon:
                  Icons.home_outlined,
                  activeIcon:
                  Icons.home_rounded,
                  selected:
                  currentIndex == 0,
                  onTap: () =>
                      onItemSelected(
                        0,
                      ),
                  compact:
                  compact,
                ),
              ),
              Expanded(
                child: _NavItem(
                  label:
                  localization
                      .translate(
                    'nav_map',
                  ),
                  icon:
                  Icons.map_outlined,
                  activeIcon:
                  Icons.map_rounded,
                  selected:
                  currentIndex == 1,
                  onTap: () =>
                      onItemSelected(
                        1,
                      ),
                  compact:
                  compact,
                ),
              ),
              Expanded(
                child:
                _AddPropertyItem(
                  label:
                  Localizations
                      .localeOf(
                    context,
                  ).languageCode ==
                      'ar'
                      ? 'إضافة عقار'
                      : 'Add Property',
                  onTap:
                  onAddProperty,
                  compact:
                  compact,
                ),
              ),
              Expanded(
                child: _NavItem(
                  label:
                  localization
                      .translate(
                    'nav_favorites',
                  ),
                  icon: Icons
                      .favorite_border_rounded,
                  activeIcon:
                  Icons.favorite_rounded,
                  selected:
                  currentIndex == 3,
                  onTap: () =>
                      onItemSelected(
                        3,
                      ),
                  compact:
                  compact,
                ),
              ),
              Expanded(
                child: _NavItem(
                  label:
                  localization
                      .translate(
                    'nav_profile',
                  ),
                  icon: Icons
                      .person_outline_rounded,
                  activeIcon:
                  Icons.person_rounded,
                  selected:
                  currentIndex == 4,
                  onTap: () =>
                      onItemSelected(
                        4,
                      ),
                  compact:
                  compact,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem
    extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final activeColor =
        theme.colorScheme.primary;

    final inactiveColor = theme
        .colorScheme
        .onSurfaceVariant;

    return Material(
      color:
      Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        child: Padding(
          padding:
          EdgeInsets.symmetric(
            vertical:
            compact ? 4 : 5,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected
                    ? 1.08
                    : 1,
                duration:
                const Duration(
                  milliseconds: 180,
                ),
                child: Icon(
                  selected
                      ? activeIcon
                      : icon,
                  size:
                  compact ? 20 : 22,
                  color: selected
                      ? activeColor
                      : inactiveColor,
                ),
              ),
              SizedBox(
                height:
                compact ? 3 : 4,
              ),
              Text(
                label,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize:
                  compact ? 8 : 9.5,
                  height: 1,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected
                      ? activeColor
                      : inactiveColor,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 180,
                ),
                width:
                selected ? 5 : 0,
                height:
                selected ? 5 : 0,
                decoration:
                BoxDecoration(
                  color: selected
                      ? activeColor
                      : Colors.transparent,
                  shape:
                  BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPropertyItem
    extends StatelessWidget {
  const _AddPropertyItem({
    required this.label,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Transform.translate(
      offset:
      const Offset(0, -8),
      child: Material(
        color:
        Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder:
          const CircleBorder(),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width:
                compact ? 54 : 60,
                height:
                compact ? 54 : 60,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color: theme
                      .colorScheme
                      .primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme
                          .colorScheme
                          .primary
                          .withValues(
                        alpha: 0.30,
                      ),
                      blurRadius: 18,
                      offset:
                      const Offset(
                        0,
                        7,
                      ),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  size:
                  compact ? 29 : 32,
                  color: theme
                      .colorScheme
                      .onPrimary,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                label,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize:
                  compact ? 7.5 : 9,
                  height: 1,
                  fontWeight:
                  FontWeight.w700,
                  color: theme
                      .colorScheme
                      .primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}