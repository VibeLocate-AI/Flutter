import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class PropertyCategories
    extends StatefulWidget {
  const PropertyCategories({
    super.key,
    required this.onCategorySelected,
    required this.onMoreFilters,
  });

  final ValueChanged<int?>
  onCategorySelected;

  final VoidCallback
  onMoreFilters;

  @override
  State<PropertyCategories>
  createState() =>
      _PropertyCategoriesState();
}

class _PropertyCategoriesState
    extends State<PropertyCategories> {
  int? _selectedTypeId;

  static const List<
      _PropertyCategory> _categories = [
    _PropertyCategory(
      id: null,
      en: 'All',
      ar: 'الكل',
      icon: Icons.grid_view_rounded,
    ),
    _PropertyCategory(
      id: 1,
      en: 'Apartment',
      ar: 'شقة',
      icon: Icons.apartment_rounded,
    ),
    _PropertyCategory(
      id: 2,
      en: 'Villa',
      ar: 'فيلا',
      icon: Icons.villa_rounded,
    ),
    _PropertyCategory(
      id: 3,
      en: 'Penthouse',
      ar: 'بنتهاوس',
      icon: Icons.roofing_rounded,
    ),
    _PropertyCategory(
      id: 4,
      en: 'Townhouse',
      ar: 'تاون هاوس',
      icon: Icons.home_work_rounded,
    ),
    _PropertyCategory(
      id: 5,
      en: 'House',
      ar: 'منزل',
      icon: Icons.home_rounded,
    ),
    _PropertyCategory(
      id: 6,
      en: 'Office',
      ar: 'مكتب',
      icon: Icons.business_center_rounded,
    ),
    _PropertyCategory(
      id: 7,
      en: 'Warehouse',
      ar: 'مستودع',
      icon: Icons.warehouse_rounded,
    ),
    _PropertyCategory(
      id: 8,
      en: 'Land',
      ar: 'أرض',
      icon: Icons.landscape_rounded,
    ),
    _PropertyCategory(
      id: 9,
      en: 'Restaurant',
      ar: 'مطعم',
      icon: Icons.restaurant_rounded,
    ),
    _PropertyCategory(
      id: 10,
      en: 'Hotel',
      ar: 'فندق',
      icon: Icons.hotel_rounded,
    ),
    _PropertyCategory(
      id: 11,
      en: 'Building',
      ar: 'مبنى',
      icon: Icons.domain_rounded,
    ),
    _PropertyCategory(
      id: 12,
      en: 'Commercial Shop',
      ar: 'محل تجاري',
      icon: Icons.storefront_rounded,
    ),
    _PropertyCategory(
      id: 13,
      en: 'Clinic',
      ar: 'عيادة',
      icon: Icons.local_hospital_rounded,
    ),
    _PropertyCategory(
      id: 14,
      en: 'School',
      ar: 'مدرسة',
      icon: Icons.school_rounded,
    ),
    _PropertyCategory(
      id: 15,
      en: 'Showroom',
      ar: 'صالة عرض',
      icon: Icons.store_rounded,
    ),
    _PropertyCategory(
      id: 16,
      en: 'Cafe',
      ar: 'مقهى',
      icon: Icons.local_cafe_rounded,
    ),
  ];

  @override
  Widget build(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(
      context,
    );

    final isArabic =
        Localizations.localeOf(
          context,
        ).languageCode ==
            'ar';

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding:
        const EdgeInsetsDirectional.only(
          start: 20,
          end: 20,
        ),
        scrollDirection:
        Axis.horizontal,
        physics:
        const BouncingScrollPhysics(),
        itemCount:
        _categories.length + 1,
        separatorBuilder:
            (_, _) {
          return const SizedBox(
            width: 8,
          );
        },
        itemBuilder:
            (context, index) {
          if (index ==
              _categories.length) {
            return _buildFiltersButton(
              context,
              localization,
            );
          }

          final category =
          _categories[index];

          final selected =
              _selectedTypeId ==
                  category.id;

          final label =
          isArabic
              ? category.ar
              : category.en;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTypeId =
                      category.id;
                });

                widget
                    .onCategorySelected(
                  category.id,
                );
              },
              borderRadius:
              BorderRadius.circular(
                15,
              ),
              child:
              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 180,
                ),
                curve:
                Curves.easeOutCubic,
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 15,
                ),
                decoration:
                BoxDecoration(
                  color: selected
                      ? Theme.of(
                    context,
                  )
                      .colorScheme
                      .primary
                      : Theme.of(
                    context,
                  )
                      .colorScheme
                      .surface,
                  borderRadius:
                  BorderRadius
                      .circular(
                    15,
                  ),
                  border: Border.all(
                    color: selected
                        ? Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary
                        : Theme.of(
                      context,
                    )
                        .colorScheme
                        .outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: selected
                          ? Theme.of(
                        context,
                      )
                          .colorScheme
                          .onPrimary
                          : Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      AppTextStyles
                          .labelMedium
                          .copyWith(
                        fontSize: 12.5,
                        color: selected
                            ? Theme.of(
                          context,
                        )
                            .colorScheme
                            .onPrimary
                            : Theme.of(
                          context,
                        )
                            .colorScheme
                            .onSurface,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
        widget.onMoreFilters,
        borderRadius:
        BorderRadius.circular(
          15,
        ),
        child: Container(
          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 15,
          ),
          decoration:
          BoxDecoration(
            color: Theme.of(
              context,
            )
                .colorScheme
                .surface,
            borderRadius:
            BorderRadius.circular(
              15,
            ),
            border: Border.all(
              color: Theme.of(
                context,
              )
                  .colorScheme
                  .outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primary,
              ),
              const SizedBox(
                width: 7,
              ),
              Text(
                _translate(
                  localization,
                  'more_filters',
                  'Filters',
                ),
                style:
                AppTextStyles
                    .labelMedium
                    .copyWith(
                  fontSize: 12.5,
                  color: Theme.of(
                    context,
                  )
                      .colorScheme
                      .onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _translate(
      AppLocalization localization,
      String key,
      String fallback,
      ) {
    final value =
    localization.translate(key);

    return value == key
        ? fallback
        : value;
  }
}

class _PropertyCategory {
  const _PropertyCategory({
    required this.id,
    required this.en,
    required this.ar,
    required this.icon,
  });

  final int? id;
  final String en;
  final String ar;
  final IconData icon;
}