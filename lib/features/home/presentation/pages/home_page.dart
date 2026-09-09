import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../data/models/ai_search_response_model.dart';
import '../../data/models/home_model.dart';
import '../../data/models/property_model.dart';
import '../../home_dependencies.dart';
import '../widgets/featured_property_card.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_header.dart';
import '../widgets/home_loading_view.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/popular_area_card.dart';
import '../widgets/property_categories.dart';
import '../widgets/property_section_header.dart';
import '../widgets/recommended_property_card.dart';
import '../widgets/top_agent_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController =
  TextEditingController();

  HomeModel? _home;

  String? _errorMessage;

  bool _isLoading = true;

  // null = All
  int? _selectedTypeId;

  String _searchQuery = '';

  bool _isAiSearching = false;

  AiSearchResponseModel? _aiSearchResponse;

  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================
  // HOME API
  // ===========================================================

  Future<void> _loadHome() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result =
      await HomeDependencies.getHome();

      if (!mounted) {
        return;
      }

      setState(() {
        _home = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  // ===========================================================
  // CATEGORY
  // ===========================================================

  void _onCategorySelected(int? typeId) {
    setState(() {
      _selectedTypeId = typeId;

      _searchQuery = '';

      _aiSearchResponse = null;

      _searchController.clear();

      _isAiSearching = false;
    });
  }

  // ===========================================================
  // SEARCH INPUT
  // ===========================================================

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();

      if (_searchQuery.isEmpty) {
        _aiSearchResponse = null;
        _isAiSearching = false;
      }
    });
  }

  // ===========================================================
  // AI SEARCH
  // ===========================================================

  Future<void> _performAiSearch() async {
    final query =
    _searchController.text.trim();

    if (query.isEmpty) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _searchQuery = query;
      _isAiSearching = true;
      _aiSearchResponse = null;
    });

    try {
      final response =
      await HomeDependencies.aiContextualSearch(
        query,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _aiSearchResponse = response;
        _isAiSearching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isAiSearching = false;
        _aiSearchResponse = null;
      });

      final localization =
      AppLocalization.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'ai_search_error',
            ),
          ),
        ),
      );
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();

      _searchQuery = '';

      _aiSearchResponse = null;

      _isAiSearching = false;
    });
  }

  // ===========================================================
  // LOCAL HOME FILTER
  // ===========================================================

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

      if (_searchQuery.isEmpty) {
        return true;
      }

      final title =
      property.title.toLowerCase();

      final description =
      property.description.toLowerCase();

      final location =
          property.location?.addressLine1
              .toLowerCase() ??
              '';

      final slug =
      property.slug.toLowerCase();

      final query =
      _searchQuery.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          location.contains(query) ||
          slug.contains(query);
    }).toList();
  }

  List<PropertyModel> _featuredProperties(
      HomeModel home,
      ) {
    return _filterProperties(
      home.featuredProperties,
    );
  }

  List<PropertyModel> _nearbyProperties(
      HomeModel home,
      ) {
    final source = home.properties.isNotEmpty
        ? home.properties
        : home.recommendedProperties;

    return _filterProperties(source);
  }

  // ===========================================================
  // NOTIFICATIONS
  // ===========================================================

  void _showNotifications() {
    final localization =
    AppLocalization.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor:
      Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 42,
                  color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(height: 12),
                Text(
                  localization.translate(
                    'notifications',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  localization.translate(
                    'no_notifications',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // LOCATION
  // ===========================================================

  void _showLocation() {
    final localization =
    AppLocalization.of(context);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor:
      Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 42,
                  color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(height: 12),
                Text(
                  localization.translate(
                    'current_location',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  localization.translate(
                    'home_location',
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // NAVIGATION
  // ===========================================================

  void _handleNavigation(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(context),
      ),
      bottomNavigationBar:
      _buildBottomNavigation(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_currentNavIndex != 0) {
      return _buildNavigationPlaceholder(
        context,
      );
    }

    if (_isLoading) {
      return const HomeLoadingView();
    }

    if (_errorMessage != null) {
      return HomeErrorView(
        message: _errorMessage!,
        onRetry: _loadHome,
      );
    }

    if (_home == null) {
      return HomeErrorView(
        message:
        AppLocalization.of(context)
            .translate(
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

  // ===========================================================
  // HOME CONTENT
  // ===========================================================

  Widget _buildHomeContent(
      BuildContext context,
      HomeModel home,
      ) {
    final localization =
    AppLocalization.of(context);

    final featured =
    _featuredProperties(home);

    final nearby =
    _nearbyProperties(home);

    final isSearchMode =
        _searchQuery.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadHome,
      child: CustomScrollView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ---------------------------------------------------
          // HEADER
          // ---------------------------------------------------

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

          // ---------------------------------------------------
          // AI SEARCH
          // ---------------------------------------------------

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: HomeSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: (_) {
                  _performAiSearch();
                },
                onSearch: _performAiSearch,
                isLoading: _isAiSearching,
              ),
            ),
          ),

          // ---------------------------------------------------
          // CATEGORIES
          // ---------------------------------------------------

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              22,
              0,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: PropertyCategories(
                onCategorySelected:
                _onCategorySelected,
              ),
            ),
          ),

          // ---------------------------------------------------
          // SEARCH RESULTS
          // ---------------------------------------------------

          if (isSearchMode)
            ..._buildSearchResults(
              context,
              localization,
            )
          else ...[
            // -----------------------------------------------
            // POPULAR AREAS
            // -----------------------------------------------

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
                  child: PropertySectionHeader(
                    titleKey: 'popular_areas',
                  ),
                ),
              ),

            if (home.popularAreas.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(
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
                      itemCount:
                      home.popularAreas.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(
                          width: 12,
                        );
                      },
                      itemBuilder:
                          (context, index) {
                        return PopularAreaCard(
                          area: home
                              .popularAreas[index],
                        );
                      },
                    ),
                  ),
                ),
              ),

            // -----------------------------------------------
            // FEATURED / RECOMMENDED
            // -----------------------------------------------

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
                  child: PropertySectionHeader(
                    titleKey:
                    'recommended_property',
                    onSeeAll: () {
                      _showAllProperties(
                        context,
                        featured,
                      );
                    },
                  ),
                ),
              ),

            if (featured.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 14,
                  bottom: 2,
                ),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    height: 365,
                    child: ListView.separated(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 20,
                      ),
                      scrollDirection:
                      Axis.horizontal,
                      itemCount: featured.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(
                          width: 14,
                        );
                      },
                      itemBuilder:
                          (context, index) {
                        return FeaturedPropertyCard(
                          property:
                          featured[index],
                        );
                      },
                    ),
                  ),
                ),
              ),

            // -----------------------------------------------
            // TOP AGENT
            // -----------------------------------------------

            if (home.topAgent != null)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey: 'top_agent',
                  ),
                ),
              ),

            if (home.topAgent != null)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: TopAgentCard(
                    agent: home.topAgent!,
                  ),
                ),
              ),

            // -----------------------------------------------
            // NEARBY
            // -----------------------------------------------

            if (nearby.isNotEmpty)
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: PropertySectionHeader(
                    titleKey:
                    'nearby_property',
                    onSeeAll: () {
                      _showAllProperties(
                        context,
                        nearby,
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
                sliver: SliverList.separated(
                  itemCount: nearby.length > 6
                      ? 6
                      : nearby.length,
                  separatorBuilder: (_, _) {
                    return const SizedBox(
                      height: 12,
                    );
                  },
                  itemBuilder:
                      (context, index) {
                    return RecommendedPropertyCard(
                      property: nearby[index],
                    );
                  },
                ),
              ),

            // -----------------------------------------------
            // EMPTY
            // -----------------------------------------------

            if (featured.isEmpty &&
                nearby.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(24),
                    child: Text(
                      localization.translate(
                        'no_properties',
                      ),
                      textAlign:
                      TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ===========================================================
  // AI SEARCH RESULTS
  // ===========================================================

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
                  style: Theme.of(context)
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
      return [
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 20,
          ),
        ),
      ];
    }

    return [
      // -------------------------------------------------------
      // SEARCH SUMMARY
      // -------------------------------------------------------

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
              color: Theme.of(context)
                  .colorScheme
                  .surface,
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context)
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
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip:
                      localization.translate(
                        'clear',
                      ),
                      onPressed:
                      _clearSearch,
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  '${response.totalResults} properties found',
                  style: Theme.of(context)
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
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      // -------------------------------------------------------
      // RESULTS
      // -------------------------------------------------------

      if (response.properties.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding:
              const EdgeInsets.all(24),
              child: Text(
                localization.translate(
                  'no_search_results',
                ),
                textAlign:
                TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            30,
          ),
          sliver: SliverList.separated(
            itemCount:
            response.properties.length,
            separatorBuilder: (_, _) {
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
      ) {
    final parts = <String>[];

    if (understood.propertyType != null) {
      parts.add(
        understood.propertyType!,
      );
    }

    if (understood.bedrooms != null) {
      parts.add(
        '${understood.bedrooms} bedrooms',
      );
    }

    if (understood.bathrooms != null) {
      parts.add(
        '${understood.bathrooms} bathrooms',
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
    final theme =
    Theme.of(context);

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
              property:
              result.property,
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                theme.colorScheme.primary,
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Text(
                '${result.matchScore}% AI MATCH',
                style: TextStyle(
                  color: theme
                      .colorScheme
                      .onPrimary,
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

  // ===========================================================
  // SEE ALL
  // ===========================================================

  void _showAllProperties(
      BuildContext context,
      List<PropertyModel> properties,
      ) {
    final localization =
    AppLocalization.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor:
      Theme.of(context)
          .colorScheme
          .surface,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
            MediaQuery.sizeOf(context)
                .height *
                0.88,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    20,
                    4,
                    20,
                    12,
                  ),
                  child: Align(
                    alignment:
                    AlignmentDirectional
                        .centerStart,
                    child: Text(
                      localization.translate(
                        'properties',
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      20,
                      0,
                      20,
                      24,
                    ),
                    itemCount:
                    properties.length,
                    separatorBuilder:
                        (_, _) {
                      return const SizedBox(
                        height: 12,
                      );
                    },
                    itemBuilder:
                        (context, index) {
                      return RecommendedPropertyCard(
                        property:
                        properties[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================
  // NAVIGATION PLACEHOLDER
  // ===========================================================

  Widget _buildNavigationPlaceholder(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(context);

    final titles = [
      'nav_home',
      'nav_map',
      'nav_favorites',
      'nav_profile',
    ];

    final icons = [
      Icons.home_rounded,
      Icons.map_outlined,
      Icons.favorite_border_rounded,
      Icons.person_outline_rounded,
    ];

    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icons[_currentNavIndex],
            size: 54,
            color:
            Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(height: 16),
          Text(
            localization.translate(
              titles[_currentNavIndex],
            ),
            style: Theme.of(context)
                .textTheme
                .headlineSmall,
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // BOTTOM NAVIGATION
  // ===========================================================

  Widget _buildBottomNavigation(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(context);

    return NavigationBar(
      selectedIndex:
      _currentNavIndex,
      onDestinationSelected:
      _handleNavigation,
      destinations: [
        NavigationDestination(
          icon: const Icon(
            Icons.home_outlined,
          ),
          selectedIcon: const Icon(
            Icons.home_rounded,
          ),
          label:
          localization.translate(
            'nav_home',
          ),
        ),
        NavigationDestination(
          icon: const Icon(
            Icons.map_outlined,
          ),
          selectedIcon: const Icon(
            Icons.map_rounded,
          ),
          label:
          localization.translate(
            'nav_map',
          ),
        ),
        NavigationDestination(
          icon: const Icon(
            Icons.favorite_border_rounded,
          ),
          selectedIcon: const Icon(
            Icons.favorite_rounded,
          ),
          label:
          localization.translate(
            'nav_favorites',
          ),
        ),
        NavigationDestination(
          icon: const Icon(
            Icons.person_outline_rounded,
          ),
          selectedIcon: const Icon(
            Icons.person_rounded,
          ),
          label:
          localization.translate(
            'nav_profile',
          ),
        ),
      ],
    );
  }
}