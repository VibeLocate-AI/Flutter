import 'package:flutter/material.dart';

import '../../core/localization/localization.dart';

class AppBottomNavigation
    extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;

  final ValueChanged<int>
  onItemSelected;

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

    final items = [
      _NavigationItem(
        label:
        localization.translate(
          'nav_home',
        ),
        icon:
        Icons.home_outlined,
        selectedIcon:
        Icons.home_rounded,
      ),
      _NavigationItem(
        label:
        localization.translate(
          'nav_map',
        ),
        icon:
        Icons.map_outlined,
        selectedIcon:
        Icons.map_rounded,
      ),
      _NavigationItem(
        label:
        localization.translate(
          'nav_favorites',
        ),
        icon:
        Icons.favorite_border_rounded,
        selectedIcon:
        Icons.favorite_rounded,
      ),
      _NavigationItem(
        label:
        localization.translate(
          'nav_profile',
        ),
        icon:
        Icons.person_outline_rounded,
        selectedIcon:
        Icons.person_rounded,
      ),
    ];

    return Container(
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .surface,
        border:
        Border(
          top: BorderSide(
            color: theme
                .colorScheme
                .outlineVariant
                .withValues(
              alpha: 0.60,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: theme
                  .brightness ==
                  Brightness.dark
                  ? 0.25
                  : 0.08,
            ),
            blurRadius: 18,
            offset:
            const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            8,
            6,
            8,
            6,
          ),
          child: Row(
            children:
            List.generate(
              items.length,
                  (index) {
                return Expanded(
                  child:
                  _NavigationItemView(
                    item:
                    items[index],
                    selected:
                    currentIndex ==
                        index,
                    onTap: () {
                      onItemSelected(
                        index,
                      );
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

class _NavigationItemView
    extends StatelessWidget {
  const _NavigationItemView({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;

  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final width =
        MediaQuery.sizeOf(
          context,
        ).width;

    final iconSize =
    width < 360
        ? 20.0
        : 22.0;

    final fontSize =
    width < 360
        ? 9.0
        : 10.0;

    return Material(
      color:
      Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        child:
        AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 200,
          ),
          curve:
          Curves.easeOutCubic,
          constraints:
          const BoxConstraints(
            minHeight: 54,
            maxHeight: 58,
          ),
          padding:
          const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 4,
          ),
          decoration:
          BoxDecoration(
            color: selected
                ? theme
                .colorScheme
                .primary
                : Colors.transparent,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? item.selectedIcon
                    : item.icon,
                size:
                iconSize,
                color: selected
                    ? theme
                    .colorScheme
                    .onPrimary
                    : theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                item.label,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize:
                  fontSize,
                  height: 1,
                  fontWeight:
                  selected
                      ? FontWeight
                      .w700
                      : FontWeight
                      .w500,
                  color: selected
                      ? theme
                      .colorScheme
                      .onPrimary
                      : theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
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