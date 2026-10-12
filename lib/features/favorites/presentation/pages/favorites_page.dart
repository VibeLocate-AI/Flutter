import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/favorites_controller.dart';
import '../../../../core/state/favorites_manager.dart';
import '../../../../core/controllers/property_details_controller.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/theme_helpers.dart';
import '../../../home/presentation/widgets/property_filter_sheet.dart';
import '../../../home/presentation/widgets/property_categories.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../../../core/widgets/no_results_view.dart';
import '../../data/models/favorite_property_model.dart';
import '../../../home/data/models/property_model.dart';
import '../../localization/favorites_strings.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  PropertyFilterValues _filters = const PropertyFilterValues();
  int? _selectedTypeId;

  FavoritesController get controller => Get.find<FavoritesController>();

  @override
  void initState() {
    super.initState();
    controller.initialize();
  }

  Future<void> _showFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .90,
        child: PropertyFilterSheet(
          initialValues: _filters,
          onApply: (value) => setState(() => _filters = value),
        ),
      ),
    );
  }

  Future<void> _load() => controller.reload();

  void _openFavorite(FavoritePropertyModel item) {
    final details = Get.find<PropertyDetailsController>();
    details.setProperty(PropertyModel.fromJson({
      'id': item.id,
      'type_id': item.typeId,
      'category_id': item.categoryId,
      'status_id': 0,
      'title': item.title,
      'title_en': item.titleEn,
      'title_ar': item.titleAr,
      'description': item.description,
      'description_en': item.descriptionEn,
      'description_ar': item.descriptionAr,
      'price': item.price,
      'currency': item.currency,
      'bedrooms': item.bedrooms,
      'bathrooms': item.bathrooms,
      'area_sqft': item.areaSqft,
      'listing_type': item.actionType,
      'property_condition': item.propertyType,
      'cover_image': item.imageUrl,
      'latitude': item.latitude,
      'longitude': item.longitude,
      'address_line_1': item.address,
      'neighborhood_name': item.neighborhood,
      'is_furnished': item.isFurnished,
      'rent_frequency': item.rentFrequency,
      'is_featured': item.isFeatured,
    }));
    Navigator.pushNamed(context, '/property-details', arguments: item.id);
  }

  Future<void> _remove(FavoritePropertyModel item) async {
    try {
      await FavoritesManager.instance.toggle(item.id);
      if (!mounted) return;
      _message(FavoritesStrings.removed);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  List<FavoritePropertyModel> get _filtered {
    final f = _filters;
    return controller.items.where((item) {
      if (_selectedTypeId != null && item.typeId != _selectedTypeId) return false;
      if (f.categoryId != null && item.categoryId != f.categoryId) return false;
      if (f.listingType != null) {
        final listing = item.actionType.toLowerCase();
        if (f.listingType == 'rent' && listing != 'rent' && listing != 'rental' && listing != 'for_rent') return false;
        if (f.listingType == 'sale' && listing != 'sale' && listing != 'sell' && listing != 'for_sale' && listing != 'buy') return false;
        if (f.listingType == 'under_construction' && item.propertyType.toLowerCase() != 'off_plan') return false;
      }
      if (f.minPrice != null && item.price < f.minPrice!) return false;
      if (f.maxPrice != null && item.price > f.maxPrice!) return false;
      if (f.minBedrooms != null && item.bedrooms < f.minBedrooms!) return false;
      if (f.minBathrooms != null && item.bathrooms < f.minBathrooms!) return false;
      if (f.minArea != null && item.areaSqft < f.minArea!) return false;
      if (f.maxArea != null && item.areaSqft > f.maxArea!) return false;
      if (f.furnished == 'furnished' && !item.isFurnished) return false;
      if (f.furnished == 'unfurnished' && item.isFurnished) return false;
      if (f.rentFrequency != null && item.rentFrequency.toLowerCase() != f.rentFrequency!.toLowerCase()) return false;
      if (f.featuredOnly && !item.isFeatured) return false;
      return true;
    }).toList(growable: false);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final items = _filtered;
      final loading = controller.isLoading.value;
      final error = controller.error.value;
      final columns = ThemeHelpers.gridColumns(context);

      return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(FavoritesStrings.title),
        actions: const [],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? ListView(children: [SizedBox(height: 500, child: Center(child: CircularProgressIndicator()))])
            : error != null
                ? _errorViewText(error)
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: PropertyCategories(
                          onCategorySelected: (typeId) {
                            setState(() {
                              _selectedTypeId = typeId;
                              _filters = _filters.copyWith(clearCategoryId: true);
                            });
                          },
                          onMoreFilters: _showFilters,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: ThemeHelpers.pagePadding(context).copyWith(top: 4, bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  FavoritesStrings.savedCount(items.length),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.items.isEmpty)
                        SliverFillRemaining(hasScrollBody: false, child: _emptyState())
                      else if (items.isEmpty)
                        SliverFillRemaining(hasScrollBody: false, child: _noResults())
                      else
                        SliverPadding(
                          padding: ThemeHelpers.pagePadding(context).copyWith(top: 0),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.crossAxisExtent;
                              // Favorites always uses a two-column grid, including
                              // narrow phones; the cards adapt to the available width.
                              const responsiveColumns = 2;
                              final cardWidth = (availableWidth -
                                      ((responsiveColumns - 1) * 14)) /
                                  responsiveColumns;
                              final cardHeight =
                                  (cardWidth * 1.42).clamp(300.0, 500.0);

                              return SliverGrid(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _card(context, items[index]),
                                  childCount: items.length,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: responsiveColumns,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: cardHeight.toDouble(),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
      ),
    );
    });
  }



  Widget _card(BuildContext context, FavoritePropertyModel item) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openFavorite(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _image(context, item.imageUrl),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Material(
                      color: theme.colorScheme.surface.withValues(alpha: .92),
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: FavoritesStrings.remove,
                        onPressed: () => _remove(item),
                        icon: Icon(Icons.favorite_rounded, color: theme.colorScheme.error, size: 20),
                      ),
                    ),
                  ),
                  if (item.actionType.isNotEmpty)
                    Positioned(
                      left: 9,
                      bottom: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _actionLabel(item.actionType),
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.displayTitle.isEmpty ? FavoritesStrings.property : item.displayTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Row(children: [Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.onSurfaceVariant), const SizedBox(width: 3), Expanded(child: Text(item.neighborhood.isEmpty ? item.address : item.neighborhood, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)))]),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.bedrooms > 0) _miniStat(context, Icons.bed_outlined, '${item.bedrooms}'),
                        if (item.bathrooms > 0) _miniStat(context, Icons.bathtub_outlined, '${item.bathrooms}'),
                        if (item.areaSqft > 0) _miniStat(context, Icons.square_foot_rounded, '${item.areaSqft.round()}'),
                      ],
                    ),
                    const Spacer(),
                    _price(context, item),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(BuildContext context, IconData icon, String value) {
    final theme = Theme.of(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant), const SizedBox(width: 2), Text(value, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]);
  }

  Widget _image(BuildContext context, String url) {
    final theme = Theme.of(context);
    if (url.isEmpty) return ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.home_work_outlined, color: theme.colorScheme.onSurfaceVariant, size: 38));
    return Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest, child: Icon(Icons.home_work_outlined, color: theme.colorScheme.onSurfaceVariant, size: 38)));
  }

  String _actionLabel(String value) {
    switch (value.toLowerCase().trim()) {
      case 'rent': return FavoritesStrings.forRent;
      case 'sale': return FavoritesStrings.forSale;
      case 'buy': return FavoritesStrings.buy;
      default: return value;
    }
  }

  Widget _price(BuildContext context, FavoritePropertyModel item) {
    return CurrencyPrice(
      amount: item.price,
      sourceCurrency: item.currency,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _errorViewText(String message) => ListView(
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _load,
                      child: Text(FavoritesStrings.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Widget _emptyState() {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stateImage(
              assetPath: 'assets/images/states/no_favorites.png',
              fallback: Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              FavoritesStrings.noFavoritesTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              FavoritesStrings.noFavoritesBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              localization.translate('favorites_empty_hint'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stateImage({
    required String assetPath,
    required Widget fallback,
  }) {
    return Image.asset(
      assetPath,
      width: 180,
      height: 150,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  Widget _noResults() => NoResultsView(
        onClear: () => _showFilters(),
        title: FavoritesStrings.noResults,
        message: FavoritesStrings.noResultsBody,
      );
}
