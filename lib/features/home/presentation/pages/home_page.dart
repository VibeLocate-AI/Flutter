import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/home_controller.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../app/app_router.dart';
import '../../../../core/widgets/no_internet_view.dart';
import '../../../../core/widgets/no_results_view.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/state/location_manager.dart';
import '../../../../core/location/location_service.dart';
import '../../data/models/home_model.dart';
import '../../data/models/ai_search_response_model.dart';
import '../../data/models/property_model.dart';
import '../../../properties/presentation/pages/all_properties_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../widgets/featured_property_card.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_header.dart';
import '../widgets/home_loading_view.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/popular_area_card.dart';
import '../widgets/property_categories.dart';
import '../widgets/property_filter_sheet.dart';
import '../widgets/property_section_header.dart';
import '../widgets/recommended_property_card.dart';
import '../widgets/top_agent_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.highlightPropertyId,
  });

  final int? highlightPropertyId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController =
  TextEditingController();

  HomeModel? _home;

  String? _errorMessage;

  bool _isLoading = true;

  int? _selectedTypeId;

  String _searchQuery = '';

  bool _isAiSearching = false;
  String? _aiSearchError;

  AiSearchResponseModel? _aiSearchResponse;
  PropertyModel? _highlightedProperty;

  PropertyFilterValues _filterValues =
  const PropertyFilterValues();

  @override
  void initState() {
    super.initState();
    LocaleManager.instance.addListener(_onLocaleChanged);
    _loadHome(force: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final manager = LocationManager.instance;
      if (!manager.isUpdating) {
        // Always try to refresh the GPS position once when the Home tab
        // is created. The IndexedStack keeps Home alive, so switching
        // between tabs will not trigger a page refresh.
        manager.updateCurrentLocation();
      }
    });
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    _clearSearch();
    _loadHome(force: true);
  }

  @override
  void dispose() {
    LocaleManager.instance.removeListener(_onLocaleChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHome({bool force = true}) async {
    final controller = Get.find<HomeController>();
    if (force) {
      await controller.load(
        force: true,
        highlightPropertyId: widget.highlightPropertyId,
      );
    } else {
      await controller.initialize(
        highlightPropertyId: widget.highlightPropertyId,
      );
    }
    if (!mounted) return;
    setState(() {
      _home = controller.home;
      _highlightedProperty = controller.highlightedProperty;
      _errorMessage = controller.errorMessage;
      _aiSearchResponse = controller.aiSearchResponse;
      _aiSearchError = controller.aiSearchError;
      _isAiSearching = controller.isAiSearching;
    });
  }

  void _onCategorySelected(int? typeId) {
    setState(() {
      _selectedTypeId = typeId;
      _searchQuery = '';
      _aiSearchResponse = null;
      _aiSearchError = null;
      _searchController.clear();
      _isAiSearching = false;
    });
  }

  Future<void> _showFilters() async {
    final currentValues = _filterValues;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor:
      Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SizedBox(
          height:
          MediaQuery.sizeOf(context).height * 0.90,
          child: PropertyFilterSheet(
            initialValues: currentValues,
            onApply: (values) {
              setState(() {
                _filterValues = values;
              });
            },
          ),
        );
      },
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();

      if (_searchQuery.isEmpty) {
        _aiSearchResponse = null;
        _isAiSearching = false;
      }
    });
  }

  Future<void> _performAiSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final controller = Get.find<HomeController>();
    setState(() {
      _searchQuery = query;
    });
    await controller.searchAi(query);
    if (!mounted) return;
    setState(() {
      _aiSearchResponse = controller.aiSearchResponse;
      _aiSearchError = controller.aiSearchError;
      _isAiSearching = controller.isAiSearching;
    });
  }

  void _openProperty(int propertyId) {
    Navigator.pushNamed(
      context,
      AppRouter.propertyDetails,
      arguments: propertyId,
    );
  }


  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _aiSearchResponse = null;
      _aiSearchError = null;
      _isAiSearching = false;
    });
  }

  List<PropertyModel> _filterProperties(
      List<PropertyModel> properties, {
        bool applyTypeFilter = true,
      }) {
    return properties.where((property) {
      final matchesType =
          !applyTypeFilter ||
              _selectedTypeId == null ||
              property.typeId == _selectedTypeId;

      if (!matchesType) {
        return false;
      }

      final filter = _filterValues;

      if (filter.categoryId != null &&
          property.categoryId != filter.categoryId) {
        return false;
      }

      if (filter.listingType != null) {
        final matchesListing = switch (filter.listingType) {
          'rent' => property.isForRent,
          'sale' => property.isForSale,
          'under_construction' => property.isUnderConstruction,
          _ => true,
        };
        if (!matchesListing) return false;
      }

      if (filter.minPrice != null &&
          property.price < filter.minPrice!) {
        return false;
      }

      if (filter.maxPrice != null &&
          property.price > filter.maxPrice!) {
        return false;
      }

      if (filter.minBedrooms != null &&
          property.bedrooms < filter.minBedrooms!) {
        return false;
      }

      if (filter.minBathrooms != null &&
          property.bathrooms < filter.minBathrooms!) {
        return false;
      }

      if (filter.minArea != null &&
          property.areaSqft < filter.minArea!) {
        return false;
      }

      if (filter.maxArea != null &&
          property.areaSqft > filter.maxArea!) {
        return false;
      }

      if (filter.furnished != null) {
        final wanted =
            filter.furnished!.toLowerCase();
        final actual =
            property.isFurnished
                ? 'furnished'
                : 'unfurnished';

        if (wanted != actual) {
          return false;
        }
      }

      if (filter.rentFrequency != null &&
          property.rentFrequency !=
              filter.rentFrequency) {
        return false;
      }

      if (filter.featuredOnly &&
          !property.isFeatured) {
        return false;
      }

      if (_searchQuery.isEmpty) {
        return true;
      }

      final query = _searchQuery.toLowerCase();

      final title = property.displayTitle.toLowerCase();

      final description = property.displayDescription.toLowerCase();

      final location =
          property.location?.addressLine1 ?? '';

      final normalizedLocation =
      location.toLowerCase();

      final slug =
      property.slug.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          normalizedLocation.contains(query) ||
          slug.contains(query);
    }).toList();
  }

  List<PropertyModel> _featuredProperties(
      HomeModel home,
      ) {
    final source = <PropertyModel>[
      ...(_highlightedProperty == null
          ? const <PropertyModel>[]
          : <PropertyModel>[_highlightedProperty!]),
      ...home.featuredProperties,
    ];
    return _filterProperties(_uniqueProperties(source));
  }

  List<PropertyModel> _recommendedProperties(
      HomeModel home,
      ) {
    final source = <PropertyModel>[
      ...(_highlightedProperty == null
          ? const <PropertyModel>[]
          : <PropertyModel>[_highlightedProperty!]),
      ...home.recommendedProperties,
    ];
    return _filterProperties(_uniqueProperties(source));
  }

  List<PropertyModel> _nearbyProperties(
      HomeModel home,
      ) {
    final source = home.properties.isNotEmpty
        ? home.properties
        : home.recommendedProperties;

    return _filterProperties(_uniqueProperties([
      ...(_highlightedProperty == null
          ? const <PropertyModel>[]
          : <PropertyModel>[_highlightedProperty!]),
      ...source,
    ]));
  }

  List<PropertyModel> _rentProperties(HomeModel home) {
    return _filterProperties(
      _uniqueProperties(home.properties.where((p) => p.isForRent).toList()),
      applyTypeFilter: false,
    );
  }

  List<PropertyModel> _saleProperties(HomeModel home) {
    return _filterProperties(
      _uniqueProperties(home.properties.where((p) => p.isForSale).toList()),
      applyTypeFilter: false,
    );
  }

  List<PropertyModel> _underConstructionProperties(HomeModel home) {
    return _filterProperties(
      _uniqueProperties(
        home.properties.where((p) => p.isUnderConstruction).toList(),
      ),
      applyTypeFilter: false,
    );
  }

  List<PropertyModel> _uniqueProperties(List<PropertyModel> properties) {
    final seen = <int>{};
    return properties.where((property) => seen.add(property.id)).toList();
  }

  Future<void> _showNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotificationsPage(),
      ),
    );
  }

  Future<void> _showLocation() async {
    final localization = AppLocalization.of(context);

    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return AnimatedBuilder(
          animation: LocationManager.instance,
          builder: (context, _) {
            final manager = LocationManager.instance;
            final current = manager.displayLocation;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localization.translate('current_location'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      current.isEmpty
                          ? localization.translate('location_unavailable')
                          : current,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: manager.isUpdating
                            ? null
                            : () async {
                                final success =
                                    await manager.updateCurrentLocation();
                                if (context.mounted) {
                                  Navigator.pop(context, success);
                                }
                              },
                        icon: manager.isUpdating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                        label: Text(
                          manager.isUpdating
                              ? localization.translate('updating_location')
                              : localization.translate('use_current_location'),
                        ),
                      ),
                    ),
                    if (current.isEmpty && !manager.isUpdating) ...[
                      const SizedBox(height: 10),
                      Text(
                        localization.translate('location_permission_hint'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: LocationService.instance.openLocationSettings,
                              icon: const Icon(Icons.location_on_outlined),
                              label: Text(
                                localization.translate('open_location_settings'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: LocationService.instance.openAppSettings,
                              icon: const Icon(Icons.settings_outlined),
                              label: Text(
                                localization.translate('open_app_settings'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      await _loadHome(force: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    _home = controller.home ?? _home;
    _highlightedProperty = controller.highlightedProperty ?? _highlightedProperty;
    _errorMessage = controller.errorMessage;
    _aiSearchResponse = controller.aiSearchResponse ?? _aiSearchResponse;
    _aiSearchError = controller.aiSearchError;
    _isAiSearching = controller.isAiSearching;
    _isLoading = controller.isLoading && _home == null;
    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final controller = Get.find<HomeController>();
    if (_home == null && controller.home != null) {
      _home = controller.home;
      _highlightedProperty = controller.highlightedProperty;
      _errorMessage = controller.errorMessage;
    }
    _isLoading = controller.isLoading && _home == null;
    if (_home != null && controller.home != null &&
        identical(_home, controller.home) == false) {
      _home = controller.home;
    }
    _highlightedProperty ??= controller.highlightedProperty;

    if (_isLoading) {
      return const HomeLoadingView();
    }

    if (_errorMessage != null) {
      final networkError = _errorMessage!.toLowerCase().contains('timed out') ||
          _errorMessage!.toLowerCase().contains('internet') ||
          _errorMessage!.toLowerCase().contains('connection') ||
          _errorMessage!.toLowerCase().contains('socket') ||
          _errorMessage!.toLowerCase().contains('failed host lookup');

      return networkError
          ? NoInternetView(onRetry: _loadHome)
          : HomeErrorView(
              message: _errorMessage!,
              onRetry: _loadHome,
            );
    }

    if (_home == null) {
      return HomeErrorView(
        message:
        AppLocalization.of(context).translate(
          'home_load_error',
        ),
        onRetry: _loadHome,
      );
    }

    return _buildHomeContent(
      context,
      _home!,
    );
  }

  Widget _buildHomeContent(
      BuildContext context,
      HomeModel home,
      ) {
    final localization =
    AppLocalization.of(context);

    final featured =
    _featuredProperties(home);

    final recommended =
    _recommendedProperties(home);

    final nearby =
    _nearbyProperties(home);
    final allProperties = _filterProperties(
      _uniqueProperties(home.properties),
      applyTypeFilter: false,
    );
    final rentProperties = _rentProperties(home);
    final saleProperties = _saleProperties(home);
    final underConstructionProperties =
        _underConstructionProperties(home);

    final isSearchMode =
        _searchQuery.isNotEmpty;
    final screenWidth = Responsive.width(context);
    final featuredHeight = screenWidth < 360
        ? 340.0
        : screenWidth < 420
            ? 355.0
            : 365.0;

    return RefreshIndicator(
      onRefresh: _loadHome,
      child: CustomScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              14,
              20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: HomeHeader(
                onLocationTap: _showLocation,
                onNotificationsTap:
                _showNotifications,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: HomeSearchBar(
                controller:
                _searchController,
                onChanged:
                _onSearchChanged,
                onSubmitted: (_) {
                  _performAiSearch();
                },
                onSearch:
                _performAiSearch,
                isLoading:
                _isAiSearching,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
            sliver: SliverToBoxAdapter(
              child: PropertySectionHeader(
                titleKey: 'filter_properties',
                subtitleKey: 'filter_properties_subtitle',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 12),
            sliver: SliverToBoxAdapter(
              child: PropertyCategories(
                onCategorySelected: _onCategorySelected,
                onMoreFilters: _showFilters,
              ),
            ),
          ),
          if (isSearchMode)
            ..._buildSearchResults(
              context,
              localization,
            )
          else ...[
            if (home.popularAreas.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  28,
                  0,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child:
                  PropertySectionHeader(
                    titleKey:
                    'popular_areas',
                    subtitleKey: 'popular_areas_subtitle',
                  ),
                ),
              ),
            if (home.popularAreas.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.only(
                  top: 14,
                  bottom: 2,
                ),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 128,
                    child: ListView.separated(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 20,
                      ),
                      scrollDirection:
                      Axis.horizontal,
                      physics:
                      const BouncingScrollPhysics(),
                      itemCount:
                      home.popularAreas.length,
                      separatorBuilder:
                          (_, _) {
                        return const SizedBox(
                          width: 12,
                        );
                      },
                      itemBuilder:
                          (context, index) {
                        return PopularAreaCard(
                          area:
                          home.popularAreas[
                          index],
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (featured.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child:
                  PropertySectionHeader(
                    titleKey:
                    'featured_properties',
                    subtitleKey: 'featured_subtitle',
                    onSeeAll: () {
                      _showAllProperties(
                        context,
                        featured,
                        titleKey: 'featured_properties',
                        subtitleKey: 'featured_subtitle',
                      );
                    },
                  ),
                ),
              ),
            if (featured.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.only(
                  top: 14,
                  bottom: 2,
                ),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: featuredHeight,
                    child: ListView.separated(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 20,
                      ),
                      scrollDirection:
                      Axis.horizontal,
                      physics:
                      const BouncingScrollPhysics(),
                      itemCount:
                      featured.length,
                      separatorBuilder:
                          (_, _) {
                        return const SizedBox(
                          width: 14,
                        );
                      },
                      itemBuilder:
                          (context, index) {
                        return FeaturedPropertyCard(
                          property: featured[index],
                          onTap: () => _openProperty(featured[index].id),
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (recommended.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child:
                  PropertySectionHeader(
                    titleKey:
                    'recommended_property',
                    subtitleKey: 'recommended_subtitle',
                    onSeeAll: () {
                      _showAllProperties(
                        context,
                        recommended,
                        titleKey: 'recommended_property',
                        subtitleKey: 'recommended_subtitle',
                      );
                    },
                  ),
                ),
              ),
            if (recommended.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children:
                    recommended
                        .map(
                          (property) {
                        return Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            bottom: 12,
                          ),
                          child:
                          RecommendedPropertyCard(
                            property: property,
                            variant: PropertyCardVariant.recommended,
                            onTap: () => _openProperty(property.id),
                          ),
                        );
                      },
                    )
                        .toList(),
                  ),
                ),
              ),
            if (nearby.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child:
                  PropertySectionHeader(
                    titleKey:
                    'nearby_property',
                    subtitleKey: 'nearby_subtitle',
                    onSeeAll: () {
                      _showAllProperties(
                        context,
                        nearby,
                        titleKey: 'nearby_property',
                        subtitleKey: 'nearby_subtitle',
                      );
                    },
                  ),
                ),
              ),
            if (nearby.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  30,
                ),
                sliver:
                SliverList.separated(
                  itemCount:
                  nearby.length > 6
                      ? 6
                      : nearby.length,
                  separatorBuilder:
                      (_, _) {
                    return const SizedBox(
                      height: 12,
                    );
                  },
                  itemBuilder:
                      (context, index) {
                    return RecommendedPropertyCard(
                      property: nearby[index],
                      onTap: () => _openProperty(nearby[index].id),
                    );
                  },
                ),
              ),
            if (allProperties.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey: 'all_properties',
                    subtitleKey: 'all_properties_subtitle',
                    onSeeAll: () => _showAllProperties(
                      context,
                      allProperties,
                      titleKey: 'all_properties',
                      subtitleKey: 'all_properties_subtitle',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverList.separated(
                  itemCount: allProperties.length > 6 ? 6 : allProperties.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => RecommendedPropertyCard(
                    property: allProperties[index],
                    variant: PropertyCardVariant.nearby,
                    onTap: () => _openProperty(allProperties[index].id),
                  ),
                ),
              ),
            ],
            if (rentProperties.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey: 'properties_for_rent',
                    subtitleKey: 'properties_for_rent_subtitle',
                    onSeeAll: () => _showAllProperties(
                      context,
                      rentProperties,
                      titleKey: 'properties_for_rent',
                      subtitleKey: 'properties_for_rent_subtitle',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverList.separated(
                  itemCount: rentProperties.length > 6 ? 6 : rentProperties.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => RecommendedPropertyCard(
                    property: rentProperties[index],
                    variant: PropertyCardVariant.nearby,
                    onTap: () => _openProperty(rentProperties[index].id),
                  ),
                ),
              ),
            ],
            if (saleProperties.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey: 'properties_for_sale',
                    subtitleKey: 'properties_for_sale_subtitle',
                    onSeeAll: () => _showAllProperties(
                      context,
                      saleProperties,
                      titleKey: 'properties_for_sale',
                      subtitleKey: 'properties_for_sale_subtitle',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverList.separated(
                  itemCount: saleProperties.length > 6 ? 6 : saleProperties.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => RecommendedPropertyCard(
                    property: saleProperties[index],
                    variant: PropertyCardVariant.recommended,
                    onTap: () => _openProperty(saleProperties[index].id),
                  ),
                ),
              ),
            ],
            if (underConstructionProperties.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey: 'under_construction_properties',
                    subtitleKey: 'under_construction_properties_subtitle',
                    onSeeAll: () => _showAllProperties(
                      context,
                      underConstructionProperties,
                      titleKey: 'under_construction_properties',
                      subtitleKey: 'under_construction_properties_subtitle',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverList.separated(
                  itemCount: underConstructionProperties.length > 6
                      ? 6
                      : underConstructionProperties.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => RecommendedPropertyCard(
                    property: underConstructionProperties[index],
                    variant: PropertyCardVariant.recommended,
                    onTap: () => _openProperty(
                      underConstructionProperties[index].id,
                    ),
                  ),
                ),
              ),
            ],
            if (home.topAgents.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey: 'top_agents',
                    subtitleKey: 'top_agents_subtitle',
                  ),
                ),
              ),
            if (home.topAgents.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  30,
                ),
                sliver: SliverList.separated(
                  itemCount: home.topAgents.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return TopAgentCard(
                      agent: home.topAgents[index],
                    );
                  },
                ),
              ),
            if (featured.isEmpty &&
                recommended.isEmpty &&
                nearby.isEmpty &&
                allProperties.isEmpty &&
                rentProperties.isEmpty &&
                saleProperties.isEmpty &&
                underConstructionProperties.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(
                      24,
                    ),
                    child: Text(
                      localization.translate(
                        'no_properties',
                      ),
                      textAlign:
                      TextAlign.center,
                      style:
                      Theme.of(context)
                          .textTheme
                          .bodyLarge,
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 96),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSearchResults(
      BuildContext context,
      AppLocalization localization,
      ) {
    if (_isAiSearching) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(height: 16),
                Text(
                  localization.translate(
                    'ai_searching',
                  ),
                  style:
                  Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final response =
        _aiSearchResponse;

    if (response == null) {
      if (_aiSearchError != null) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: NoResultsView(
              title: localization.translate('ai_search_error'),
              message: _aiSearchError,
              onClear: _clearSearch,
            ),
          ),
        ];
      }
      return [
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding:
            const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
              Theme.of(context)
                  .colorScheme
                  .surface,
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color:
                Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color:
                      Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localization.translate(
                          'recommended_property',
                        ),
                        style:
                        Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip:
                      localization.translate(
                        'clear',
                      ),
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${response.totalResults} ${localization.translate('properties_found')}',
                  style:
                  Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
                if (response
                    .understood
                    .propertyType !=
                    null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _buildUnderstandingText(
                      response.understood,
                      localization,
                    ),
                    style:
                    Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      if (response.properties.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: NoResultsView(
            onClear: _clearSearch,
          ),
        )
      else
        SliverPadding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            30,
          ),
          sliver: SliverList.separated(
            itemCount:
            response.properties.length,
            separatorBuilder:
                (_, _) {
              return const SizedBox(
                height: 12,
              );
            },
            itemBuilder:
                (context, index) {
              final result =
              response.properties[index];

              return _buildAiResultCard(
                context,
                result,
              );
            },
          ),
        ),
    ];
  }

  String _buildUnderstandingText(
      AiSearchUnderstandingModel understood,
      AppLocalization localization,
      ) {
    final parts = <String>[];

    if (understood.propertyType != null) {
      parts.add(
        understood.propertyType!,
      );
    }

    if (understood.bedrooms != null) {
      parts.add(
        '${understood.bedrooms} ${localization.translate('bedrooms')}',
      );
    }

    if (understood.bathrooms != null) {
      parts.add(
        '${understood.bathrooms} ${localization.translate('bathrooms')}',
      );
    }

    if (understood.neighborhood != null) {
      parts.add(
        understood.neighborhood!,
      );
    }

    parts.addAll(
      understood.features,
    );

    return parts.join(' • ');
  }

  Widget _buildAiResultCard(
      BuildContext context,
      AiSearchPropertyModel result,
      ) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Container(
      decoration: BoxDecoration(
        color:
        theme.colorScheme.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          theme.colorScheme.outlineVariant,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding:
            const EdgeInsets.all(8),
            child: RecommendedPropertyCard(
              property: result.property,
              onTap: () => _openProperty(result.property.id),
            ),
          ),
          PositionedDirectional(
            top: 16,
            start: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
              BoxDecoration(
                color:
                theme.colorScheme.primary,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Text(
                '${result.matchScore}% ${localization.translate('ai_match')}',
                style: TextStyle(
                  color:
                  theme.colorScheme.onPrimary,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllProperties(
      BuildContext context,
      List<PropertyModel> properties,
      {required String titleKey, String? subtitleKey}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllPropertiesPage(
          properties: properties,
          titleKey: titleKey,
          subtitleKey: subtitleKey,
        ),
      ),
    );
  }
}