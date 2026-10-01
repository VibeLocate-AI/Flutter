import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/favorites_controller.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/theme_helpers.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../../../core/widgets/no_results_view.dart';
import '../../data/models/favorite_property_model.dart';
import '../../localization/favorites_strings.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  FavoritesController get controller => Get.find<FavoritesController>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchChanged);
    controller.initialize();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _searchChanged() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  Future<void> _load() => controller.reload();

  Future<void> _remove(FavoritePropertyModel item) async {
    try {
      await controller.toggle(item.id);
      if (!mounted) return;
      _message(FavoritesStrings.removed);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  List<FavoritePropertyModel> get _filtered {
    final list = controller.items.toList(growable: false);
    if (_query.isEmpty) return list;
    return list.where((item) {
      final values = [
        item.title, item.slug, item.propertyType, item.categoryName,
        item.actionType, item.neighborhood, item.address,
      ];
      return values.any((value) => value.toLowerCase().contains(_query));
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
      appBar: AppBar(title: Text(FavoritesStrings.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? ListView(children: [SizedBox(height: 500, child: Center(child: CircularProgressIndicator()))])
            : error != null
                ? _errorViewText(error)
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _searchBar(context)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: ThemeHelpers.pagePadding(context).copyWith(top: 4, bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _query.isEmpty ? FavoritesStrings.savedCount(controller.items.length) : FavoritesStrings.resultsCount(items.length),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_query.isNotEmpty)
                                TextButton(onPressed: _clearSearch, child: Text(FavoritesStrings.clear)),
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
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _card(context, items[index]),
                              childCount: items.length,
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns.round(),
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: columns >= 3 ? .76 : .68,
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
    });
  }

  Widget _searchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: ThemeHelpers.pagePadding(context).copyWith(bottom: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: FavoritesStrings.searchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty ? null : IconButton(onPressed: _clearSearch, icon: const Icon(Icons.close_rounded)),
        ),
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  Widget _card(BuildContext context, FavoritePropertyModel item) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/property-details', arguments: item.id),
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
                    Text(item.title.isEmpty ? FavoritesStrings.property : item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
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
        onClear: _clearSearch,
        title: FavoritesStrings.noResults,
        message: FavoritesStrings.noResultsBody,
      );
}
