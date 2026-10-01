import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class PropertyCategories extends StatefulWidget {
  const PropertyCategories({
    super.key,
    required this.onCategorySelected,
    required this.onMoreFilters,
  });

  final ValueChanged<int?> onCategorySelected;
  final VoidCallback onMoreFilters;

  @override
  State<PropertyCategories> createState() => _PropertyCategoriesState();
}

class _PropertyCategoriesState extends State<PropertyCategories> {
  int? _selectedTypeId;

  static const List<_PropertyCategory> _categories = [
    _PropertyCategory(null, 'property_type_all', Icons.grid_view_rounded),
    _PropertyCategory(1, 'property_type_apartment', Icons.apartment_rounded),
    _PropertyCategory(2, 'property_type_villa', Icons.villa_rounded),
    _PropertyCategory(3, 'property_type_penthouse', Icons.roofing_rounded),
    _PropertyCategory(4, 'property_type_townhouse', Icons.home_work_rounded),
    _PropertyCategory(5, 'property_type_house', Icons.home_rounded),
    _PropertyCategory(6, 'property_type_office', Icons.business_center_rounded),
    _PropertyCategory(7, 'property_type_warehouse', Icons.warehouse_rounded),
    _PropertyCategory(8, 'property_type_land', Icons.landscape_rounded),
    _PropertyCategory(9, 'property_type_restaurant', Icons.restaurant_rounded),
    _PropertyCategory(10, 'property_type_hotel', Icons.hotel_rounded),
    _PropertyCategory(11, 'property_type_building', Icons.domain_rounded),
    _PropertyCategory(12, 'property_type_commercial_shop', Icons.storefront_rounded),
    _PropertyCategory(13, 'property_type_clinic', Icons.local_hospital_rounded),
    _PropertyCategory(14, 'property_type_school', Icons.school_rounded),
    _PropertyCategory(15, 'property_type_showroom', Icons.store_rounded),
    _PropertyCategory(16, 'property_type_cafe', Icons.local_cafe_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == _categories.length) {
            return _buildFiltersButton(context, localization);
          }

          final category = _categories[index];
          final selected = _selectedTypeId == category.id;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _selectedTypeId = category.id);
                widget.onCategorySelected(category.id);
              },
              borderRadius: BorderRadius.circular(15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
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
                      size: 18,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      localization.translate(category.labelKey),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12.5,
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

  Widget _buildFiltersButton(
    BuildContext context,
    AppLocalization localization,
  ) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onMoreFilters,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 7),
              Text(
                localization.translate('more_filters'),
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyCategory {
  const _PropertyCategory(this.id, this.labelKey, this.icon);

  final int? id;
  final String labelKey;
  final IconData icon;
}
