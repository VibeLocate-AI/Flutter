import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';

class PropertyFilterValues {
  const PropertyFilterValues({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minBathrooms,
    this.minArea,
    this.maxArea,
    this.furnished,
    this.rentFrequency,
    this.featuredOnly = false,
  });

  final int? categoryId;

  final double? minPrice;
  final double? maxPrice;

  final int? minBedrooms;
  final int? minBathrooms;

  final double? minArea;
  final double? maxArea;

  final String? furnished;
  final String? rentFrequency;

  final bool featuredOnly;

  bool get hasAnyFilter {
    return categoryId != null ||
        minPrice != null ||
        maxPrice != null ||
        minBedrooms != null ||
        minBathrooms != null ||
        minArea != null ||
        maxArea != null ||
        furnished != null ||
        rentFrequency != null ||
        featuredOnly;
  }
}

class PropertyFilterSheet
    extends StatefulWidget {
  const PropertyFilterSheet({
    super.key,
    required this.initialValues,
    required this.onApply,
  });

  final PropertyFilterValues
  initialValues;

  final ValueChanged<
      PropertyFilterValues>
  onApply;

  @override
  State<PropertyFilterSheet>
  createState() =>
      _PropertyFilterSheetState();
}

class _PropertyFilterSheetState
    extends State<PropertyFilterSheet> {
  late int? _categoryId;

  late double? _minPrice;
  late double? _maxPrice;

  late int? _minBedrooms;
  late int? _minBathrooms;

  late double? _minArea;
  late double? _maxArea;

  late String? _furnished;
  late String? _rentFrequency;

  late bool _featuredOnly;

  late final TextEditingController
  _minPriceController;

  late final TextEditingController
  _maxPriceController;

  late final TextEditingController
  _minAreaController;

  late final TextEditingController
  _maxAreaController;

  @override
  void initState() {
    super.initState();

    _categoryId =
        widget.initialValues.categoryId;

    _minPrice =
        widget.initialValues.minPrice;

    _maxPrice =
        widget.initialValues.maxPrice;

    _minBedrooms =
        widget.initialValues.minBedrooms;

    _minBathrooms =
        widget.initialValues.minBathrooms;

    _minArea =
        widget.initialValues.minArea;

    _maxArea =
        widget.initialValues.maxArea;

    _furnished =
        widget.initialValues.furnished;

    _rentFrequency =
        widget.initialValues.rentFrequency;

    _featuredOnly =
        widget.initialValues.featuredOnly;

    _minPriceController =
        TextEditingController(
          text:
          _minPrice?.toStringAsFixed(0) ??
              '',
        );

    _maxPriceController =
        TextEditingController(
          text:
          _maxPrice?.toStringAsFixed(0) ??
              '',
        );

    _minAreaController =
        TextEditingController(
          text:
          _minArea?.toStringAsFixed(0) ??
              '',
        );

    _maxAreaController =
        TextEditingController(
          text:
          _maxArea?.toStringAsFixed(0) ??
              '',
        );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(
      context,
    );

    final theme =
    Theme.of(context);

    final isArabic =
        Localizations.localeOf(
          context,
        ).languageCode ==
            'ar';

    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _translate(
                      localization,
                      'more_filters',
                      'Filters',
                    ),
                    style: theme
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                  _clearAll,
                  child: Text(
                    _translate(
                      localization,
                      'clear',
                      'Clear',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding:
                const EdgeInsets.only(
                  bottom: 20,
                ),
                children: [
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'الفئة'
                        : 'Category',
                  ),
                  _categorySelector(
                    context,
                    isArabic,
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'السعر'
                        : 'Price',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:
                        _numberField(
                          controller:
                          _minPriceController,
                          label:
                          isArabic
                              ? 'من'
                              : 'Min',
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child:
                        _numberField(
                          controller:
                          _maxPriceController,
                          label:
                          isArabic
                              ? 'إلى'
                              : 'Max',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'المساحة'
                        : 'Area sqft',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:
                        _numberField(
                          controller:
                          _minAreaController,
                          label:
                          isArabic
                              ? 'من'
                              : 'Min',
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child:
                        _numberField(
                          controller:
                          _maxAreaController,
                          label:
                          isArabic
                              ? 'إلى'
                              : 'Max',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'غرف النوم'
                        : 'Bedrooms',
                  ),
                  _choiceRow(
                    values: const [
                      1,
                      2,
                      3,
                      4,
                      5,
                    ],
                    selectedValue:
                    _minBedrooms,
                    suffix: '+',
                    onSelected:
                        (value) {
                      setState(() {
                        _minBedrooms =
                            value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'الحمامات'
                        : 'Bathrooms',
                  ),
                  _choiceRow(
                    values: const [
                      1,
                      2,
                      3,
                      4,
                      5,
                    ],
                    selectedValue:
                    _minBathrooms,
                    suffix: '+',
                    onSelected:
                        (value) {
                      setState(() {
                        _minBathrooms =
                            value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'التأثيث'
                        : 'Furnishing',
                  ),
                  _singleChoice(
                    values: const [
                      'unfurnished',
                      'semi-furnished',
                      'furnished',
                    ],
                    selectedValue:
                    _furnished,
                    labels: isArabic
                        ? const {
                      'unfurnished':
                      'غير مفروش',
                      'semi-furnished':
                      'نصف مفروش',
                      'furnished':
                      'مفروش',
                    }
                        : const {
                      'unfurnished':
                      'Unfurnished',
                      'semi-furnished':
                      'Semi-furnished',
                      'furnished':
                      'Furnished',
                    },
                    onSelected:
                        (value) {
                      setState(() {
                        _furnished =
                            value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  _sectionTitle(
                    context,
                    isArabic
                        ? 'تكرار الإيجار'
                        : 'Rent Frequency',
                  ),
                  _singleChoice(
                    values: const [
                      'yearly',
                      'monthly',
                      'weekly',
                      'daily',
                    ],
                    selectedValue:
                    _rentFrequency,
                    labels: isArabic
                        ? const {
                      'yearly':
                      'سنوي',
                      'monthly':
                      'شهري',
                      'weekly':
                      'أسبوعي',
                      'daily':
                      'يومي',
                    }
                        : const {
                      'yearly':
                      'Yearly',
                      'monthly':
                      'Monthly',
                      'weekly':
                      'Weekly',
                      'daily':
                      'Daily',
                    },
                    onSelected:
                        (value) {
                      setState(() {
                        _rentFrequency =
                            value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  SwitchListTile.adaptive(
                    contentPadding:
                    EdgeInsets.zero,
                    title: Text(
                      isArabic
                          ? 'العقارات المميزة فقط'
                          : 'Featured only',
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    value:
                    _featuredOnly,
                    onChanged:
                        (value) {
                      setState(() {
                        _featuredOnly =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _apply,
                style:
                FilledButton.styleFrom(
                  minimumSize:
                  const Size.fromHeight(
                    52,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child: Text(
                  isArabic
                      ? 'تطبيق الفلاتر'
                      : 'Apply Filters',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
      BuildContext context,
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        )
            .textTheme
            .titleMedium
            ?.copyWith(
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  Widget _categorySelector(
      BuildContext context,
      bool isArabic,
      ) {
    const categories = [
      _CategoryOption(
        1,
        'Residential Long Term',
        'سكني طويل الأجل',
      ),
      _CategoryOption(
        2,
        'Short Term',
        'قصير الأجل',
      ),
      _CategoryOption(
        3,
        'Luxury',
        'فاخر',
      ),
      _CategoryOption(
        4,
        'For Sale',
        'للبيع',
      ),
      _CategoryOption(
        5,
        'For Rent',
        'للإيجار',
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected:
          _categoryId == null,
          label: Text(
            isArabic
                ? 'الكل'
                : 'Any',
          ),
          onSelected: (_) {
            setState(() {
              _categoryId =
              null;
            });
          },
        ),
        ...categories.map(
              (category) {
            final selected =
                _categoryId ==
                    category.id;

            return ChoiceChip(
              selected:
              selected,
              label: Text(
                isArabic
                    ? category.ar
                    : category.en,
              ),
              onSelected: (_) {
                setState(() {
                  _categoryId =
                  selected
                      ? null
                      : category.id;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _numberField({
    required
    TextEditingController
    controller,
    required String label,
  }) {
    return TextField(
      controller:
      controller,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration:
      InputDecoration(
        labelText:
        label,
        border:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  Widget _choiceRow({
    required List<int> values,
    required int? selectedValue,
    required String suffix,
    required ValueChanged<int?>
    onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected:
          selectedValue == null,
          label:
          const Text('Any'),
          onSelected: (_) {
            onSelected(
              null,
            );
          },
        ),
        ...values.map(
              (value) {
            final selected =
                selectedValue ==
                    value;

            return ChoiceChip(
              selected:
              selected,
              label: Text(
                '$value$suffix',
              ),
              onSelected:
                  (_) {
                onSelected(
                  selected
                      ? null
                      : value,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _singleChoice(
      {
        required List<String>
        values,
        required String?
        selectedValue,
        required Map<String, String>
        labels,
        required ValueChanged<String?>
        onSelected,
      }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected:
          selectedValue == null,
          label:
          const Text('Any'),
          onSelected: (_) {
            onSelected(
              null,
            );
          },
        ),
        ...values.map(
              (value) {
            final selected =
                selectedValue ==
                    value;

            return ChoiceChip(
              selected:
              selected,
              label: Text(
                labels[value] ??
                    value,
              ),
              onSelected:
                  (_) {
                onSelected(
                  selected
                      ? null
                      : value,
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _clearAll() {
    setState(() {
      _categoryId = null;
      _minPrice = null;
      _maxPrice = null;
      _minBedrooms = null;
      _minBathrooms = null;
      _minArea = null;
      _maxArea = null;
      _furnished = null;
      _rentFrequency = null;
      _featuredOnly = false;

      _minPriceController.clear();
      _maxPriceController.clear();
      _minAreaController.clear();
      _maxAreaController.clear();
    });
  }

  void _apply() {
    final values =
    PropertyFilterValues(
      categoryId:
      _categoryId,
      minPrice:
      double.tryParse(
        _minPriceController.text
            .trim(),
      ),
      maxPrice:
      double.tryParse(
        _maxPriceController.text
            .trim(),
      ),
      minBedrooms:
      _minBedrooms,
      minBathrooms:
      _minBathrooms,
      minArea:
      double.tryParse(
        _minAreaController.text
            .trim(),
      ),
      maxArea:
      double.tryParse(
        _maxAreaController.text
            .trim(),
      ),
      furnished:
      _furnished,
      rentFrequency:
      _rentFrequency,
      featuredOnly:
      _featuredOnly,
    );

    widget.onApply(
      values,
    );

    Navigator.of(
      context,
    ).pop();
  }

  String _translate(
      AppLocalization localization,
      String key,
      String fallback,
      ) {
    final value =
    localization.translate(
      key,
    );

    return value == key
        ? fallback
        : value;
  }
}

class _CategoryOption {
  const _CategoryOption(
      this.id,
      this.en,
      this.ar,
      );

  final int id;
  final String en;
  final String ar;
}