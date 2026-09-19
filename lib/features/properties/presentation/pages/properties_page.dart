import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/presentation/widgets/recommended_property_card.dart';
import '../../properties_dependencies.dart';

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});

  @override
  State<PropertiesPage> createState() =>
      _PropertiesPageState();
}

class _PropertiesPageState
    extends State<PropertiesPage> {
  final TextEditingController
  _searchController =
  TextEditingController();

  List<PropertyModel> _properties =
  const [];

  bool _loading = true;
  String? _error;
  int? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final properties =
      await PropertiesDependencies
          .getProperties();

      if (!mounted) return;

      setState(() {
        _properties = properties;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (!mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<PropertyModel> get _filtered {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    return _properties.where((property) {
      if (_selectedTypeId != null &&
          property.typeId !=
              _selectedTypeId) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final location = property.location
          ?.addressLine1
          .toLowerCase() ??
          '';

      return property.title
          .toLowerCase()
          .contains(query) ||
          property.description
              .toLowerCase()
              .contains(query) ||
          location.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final properties = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Properties',
        ),
        actions: [
          IconButton(
            onPressed:
            _loading ? null : _load,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(
          context,
          theme,
          properties,
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      ThemeData theme,
      List<PropertyModel> properties,
      ) {
    if (_loading) {
      return ListView(
        physics:
        AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 500,
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.sizeOf(context)
                .height *
                0.45,
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .error_outline_rounded,
                      size: 42,
                      color: theme
                          .colorScheme.error,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      _error!,
                      textAlign:
                      TextAlign.center,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    FilledButton(
                      onPressed: _load,
                      child: const Text(
                        'Try again',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            10,
          ),
          sliver:
          SliverToBoxAdapter(
            child: TextField(
              controller:
              _searchController,
              onChanged: (_) =>
                  setState(() {}),
              decoration:
              InputDecoration(
                hintText:
                'Search properties',
                prefixIcon:
                const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon:
                _searchController
                    .text
                    .isEmpty
                    ? null
                    : IconButton(
                  onPressed: () {
                    _searchController
                        .clear();
                    setState(
                          () {},
                    );
                  },
                  icon:
                  const Icon(
                    Icons
                        .close_rounded,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding:
          const EdgeInsets.only(
            left: 20,
            bottom: 14,
          ),
          sliver:
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView(
                scrollDirection:
                Axis.horizontal,
                children: [
                  _TypeChip(
                    label: 'All',
                    selected:
                    _selectedTypeId ==
                        null,
                    onTap: () {
                      setState(() {
                        _selectedTypeId =
                        null;
                      });
                    },
                  ),
                  ...List.generate(
                    16,
                        (index) {
                      final typeId =
                          index + 1;

                      return _TypeChip(
                        label:
                        _typeLabel(
                          typeId,
                        ),
                        selected:
                        _selectedTypeId ==
                            typeId,
                        onTap: () {
                          setState(() {
                            _selectedTypeId =
                                typeId;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            30,
          ),
          sliver: properties.isEmpty
              ? SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No properties found.',
                style:
                theme.textTheme
                    .bodyLarge,
              ),
            ),
          )
              : SliverList.separated(
            itemCount:
            properties.length,
            separatorBuilder:
                (_, _) =>
            const SizedBox(
              height: 12,
            ),
            itemBuilder:
                (context, index) {
              final property =
              properties[index];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/property-details',
                    arguments:
                    property.id,
                  );
                },
                child:
                RecommendedPropertyCard(
                  property: property,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _typeLabel(int id) {
    const labels = [
      'Apartment',
      'Villa',
      'Penthouse',
      'Townhouse',
      'House',
      'Office',
      'Warehouse',
      'Land',
      'Restaurant',
      'Hotel',
      'Building',
      'Commercial Shop',
      'Clinic',
      'School',
      'Showroom',
      'Cafe',
    ];

    if (id < 1 ||
        id > labels.length) {
      return 'Property';
    }

    return labels[id - 1];
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Padding(
      padding:
      const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) =>
            onTap(),
        labelStyle:
        AppTextStyles.labelMedium
            .copyWith(
          color: selected
              ? theme.colorScheme
              .onPrimary
              : theme.colorScheme
              .onSurface,
        ),
        selectedColor:
        theme.colorScheme.primary,
      ),
    );
  }
}