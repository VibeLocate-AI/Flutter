import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class PropertyCategories extends StatefulWidget {
  const PropertyCategories({
    super.key,
    required this.onCategorySelected,
  });

  final ValueChanged<int?> onCategorySelected;

  @override
  State<PropertyCategories> createState() =>
      _PropertyCategoriesState();
}

class _PropertyCategoriesState extends State<PropertyCategories> {
  // null = All
  int? _selectedTypeId;

  final List<_PropertyCategory> _categories = const [
    _PropertyCategory(
      id: null,
      labelKey: 'property_all',
      icon: Icons.grid_view_rounded,
    ),
    _PropertyCategory(
      id: 4,
      labelKey: 'property_house',
      icon: Icons.home_outlined,
    ),
    _PropertyCategory(
      id: 2,
      labelKey: 'property_villa',
      icon: Icons.villa_outlined,
    ),
    _PropertyCategory(
      id: 1,
      labelKey: 'property_apartment',
      icon: Icons.apartment_outlined,
    ),
    _PropertyCategory(
      id: 5,
      labelKey: 'property_bungalow',
      icon: Icons.cabin_outlined,
    ),
    _PropertyCategory(
      id: 3,
      labelKey: 'property_penthouse',
      icon: Icons.roofing_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.only(right: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 9);
        },
        itemBuilder: (context, index) {
          final category = _categories[index];

          final selected =
              _selectedTypeId == category.id;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                setState(() {
                  _selectedTypeId = category.id;
                });

                widget.onCategorySelected(category.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 19,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      localization.translate(
                        category.labelKey,
                      ),
                      style:
                      AppTextStyles.labelMedium.copyWith(
                        color: selected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PropertyCategory {
  const _PropertyCategory({
    required this.id,
    required this.labelKey,
    required this.icon,
  });

  final int? id;
  final String labelKey;
  final IconData icon;
}