import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';

class PropertyFilterValues {
  const PropertyFilterValues({
    this.categoryId,
    this.listingType,
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
  final String? listingType;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? minBathrooms;
  final double? minArea;
  final double? maxArea;
  final String? furnished;
  final String? rentFrequency;
  final bool featuredOnly;

  bool get hasAnyFilter =>
      categoryId != null ||
      listingType != null ||
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

class PropertyFilterSheet extends StatefulWidget {
  const PropertyFilterSheet({
    super.key,
    required this.initialValues,
    required this.onApply,
  });

  final PropertyFilterValues initialValues;
  final ValueChanged<PropertyFilterValues> onApply;

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late int? _categoryId = widget.initialValues.categoryId;
  late String? _listingType = widget.initialValues.listingType;
  late double? _minPrice = widget.initialValues.minPrice;
  late double? _maxPrice = widget.initialValues.maxPrice;
  late int? _minBedrooms = widget.initialValues.minBedrooms;
  late int? _minBathrooms = widget.initialValues.minBathrooms;
  late double? _minArea = widget.initialValues.minArea;
  late double? _maxArea = widget.initialValues.maxArea;
  late String? _furnished = widget.initialValues.furnished;
  late String? _rentFrequency = widget.initialValues.rentFrequency;
  late bool _featuredOnly = widget.initialValues.featuredOnly;

  late final TextEditingController _minPriceController = TextEditingController(
    text: _minPrice?.toStringAsFixed(0) ?? '',
  );
  late final TextEditingController _maxPriceController = TextEditingController(
    text: _maxPrice?.toStringAsFixed(0) ?? '',
  );
  late final TextEditingController _minAreaController = TextEditingController(
    text: _minArea?.toStringAsFixed(0) ?? '',
  );
  late final TextEditingController _maxAreaController = TextEditingController(
    text: _maxArea?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localization.translate('filters_title'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: Text(localization.translate('clear')),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  _sectionTitle(context, localization.translate('filter_category')),
                  _categorySelector(context, localization),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('filter_listing_type')),
                  _singleChoice(
                    values: const ['rent', 'sale', 'under_construction'],
                    selectedValue: _listingType,
                    labels: {
                      'rent': localization.translate('for_rent'),
                      'sale': localization.translate('for_sale'),
                      'under_construction': localization.translate('under_construction'),
                    },
                    anyLabel: localization.translate('any'),
                    onSelected: (value) => setState(() => _listingType = value),
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('filter_price')),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          controller: _minPriceController,
                          label: localization.translate('minimum'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _maxPriceController,
                          label: localization.translate('maximum'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('filter_area')),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          controller: _minAreaController,
                          label: localization.translate('minimum'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _numberField(
                          controller: _maxAreaController,
                          label: localization.translate('maximum'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('bedrooms')),
                  _choiceRow(
                    values: const [1, 2, 3, 4, 5],
                    selectedValue: _minBedrooms,
                    suffix: '+',
                    anyLabel: localization.translate('any'),
                    onSelected: (value) => setState(() => _minBedrooms = value),
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('bathrooms')),
                  _choiceRow(
                    values: const [1, 2, 3, 4, 5],
                    selectedValue: _minBathrooms,
                    suffix: '+',
                    anyLabel: localization.translate('any'),
                    onSelected: (value) => setState(() => _minBathrooms = value),
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('furnishing')),
                  _singleChoice(
                    values: const ['unfurnished', 'semi-furnished', 'furnished'],
                    selectedValue: _furnished,
                    labels: {
                      'unfurnished': localization.translate('unfurnished'),
                      'semi-furnished': localization.translate('semi_furnished'),
                      'furnished': localization.translate('furnished'),
                    },
                    anyLabel: localization.translate('any'),
                    onSelected: (value) => setState(() => _furnished = value),
                  ),
                  const SizedBox(height: 22),
                  _sectionTitle(context, localization.translate('rent_frequency')),
                  _singleChoice(
                    values: const ['yearly', 'monthly', 'weekly', 'daily'],
                    selectedValue: _rentFrequency,
                    labels: {
                      'yearly': localization.translate('yearly'),
                      'monthly': localization.translate('monthly'),
                      'weekly': localization.translate('weekly'),
                      'daily': localization.translate('daily'),
                    },
                    anyLabel: localization.translate('any'),
                    onSelected: (value) => setState(() => _rentFrequency = value),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      localization.translate('featured_only'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: _featuredOnly,
                    onChanged: (value) => setState(() => _featuredOnly = value),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _apply,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(localization.translate('apply_filters')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _categorySelector(BuildContext context, AppLocalization localization) {
    const categories = <(int, String)>[
      (1, 'residential_long_term'),
      (2, 'short_term'),
      (3, 'luxury'),
      (4, 'for_sale'),
      (5, 'for_rent'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: _categoryId == null,
          label: Text(localization.translate('any')),
          onSelected: (_) => setState(() => _categoryId = null),
        ),
        ...categories.map((category) {
          final selected = _categoryId == category.$1;
          return ChoiceChip(
            selected: selected,
            label: Text(localization.translate(category.$2)),
            onSelected: (_) => setState(
              () => _categoryId = selected ? null : category.$1,
            ),
          );
        }),
      ],
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _choiceRow({
    required List<int> values,
    required int? selectedValue,
    required String suffix,
    required String anyLabel,
    required ValueChanged<int?> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: selectedValue == null,
          label: Text(anyLabel),
          onSelected: (_) => onSelected(null),
        ),
        ...values.map((value) {
          final selected = selectedValue == value;
          return ChoiceChip(
            selected: selected,
            label: Text('$value$suffix'),
            onSelected: (_) => onSelected(selected ? null : value),
          );
        }),
      ],
    );
  }

  Widget _singleChoice({
    required List<String> values,
    required String? selectedValue,
    required Map<String, String> labels,
    required String anyLabel,
    required ValueChanged<String?> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          selected: selectedValue == null,
          label: Text(anyLabel),
          onSelected: (_) => onSelected(null),
        ),
        ...values.map((value) {
          final selected = selectedValue == value;
          return ChoiceChip(
            selected: selected,
            label: Text(labels[value] ?? value),
            onSelected: (_) => onSelected(selected ? null : value),
          );
        }),
      ],
    );
  }

  void _clearAll() {
    setState(() {
      _categoryId = null;
      _listingType = null;
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
    widget.onApply(
      PropertyFilterValues(
        categoryId: _categoryId,
        listingType: _listingType,
        minPrice: double.tryParse(_minPriceController.text.trim()),
        maxPrice: double.tryParse(_maxPriceController.text.trim()),
        minBedrooms: _minBedrooms,
        minBathrooms: _minBathrooms,
        minArea: double.tryParse(_minAreaController.text.trim()),
        maxArea: double.tryParse(_maxAreaController.text.trim()),
        furnished: _furnished,
        rentFrequency: _rentFrequency,
        featuredOnly: _featuredOnly,
      ),
    );
    Navigator.of(context).pop();
  }
}
