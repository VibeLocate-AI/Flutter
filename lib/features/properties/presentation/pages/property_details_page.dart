import 'package:flutter/material.dart';

import '../../../home/data/models/property_model.dart';
import '../../properties_dependencies.dart';

class PropertyDetailsPage
    extends StatefulWidget {
  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
  });

  final int propertyId;

  @override
  State<PropertyDetailsPage>
  createState() =>
      _PropertyDetailsPageState();
}

class _PropertyDetailsPageState
    extends State<PropertyDetailsPage> {
  PropertyModel? _property;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final property =
      await PropertiesDependencies
          .getPropertyDetails(
        widget.propertyId,
      );

      if (!mounted) return;

      setState(() {
        _property = property;
        _error = null;
        _loading = false;
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
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null ||
        _property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Text(
                  _error ??
                      'Property not found.',
                  textAlign:
                  TextAlign.center,
                ),
                const SizedBox(
                  height: 16,
                ),
                FilledButton(
                  onPressed: _load,
                  child:
                  const Text(
                    'Try again',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final property = _property!;

    final images = property.images.isNotEmpty
        ? property.images
        : property.primaryImage ==
        null
        ? const []
        : [property.primaryImage!];

    final location =
        property.location
            ?.addressLine1 ??
            '';

    final theme =
    Theme.of(context);

    return Scaffold(
      body:
      CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor:
            theme.colorScheme
                .surface,
            foregroundColor:
            theme.colorScheme
                .onSurface,
            flexibleSpace:
            FlexibleSpaceBar(
              background:
              images.isEmpty
                  ? ColoredBox(
                color: theme
                    .colorScheme
                    .surfaceContainerHighest,
                child:
                const Icon(
                  Icons
                      .image_not_supported_outlined,
                  size: 48,
                ),
              )
                  : PageView.builder(
                itemCount:
                images.length,
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  return Image.network(
                    images[index]
                        .imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        _,
                        _,
                        _,
                        ) {
                      return ColoredBox(
                        color: theme
                            .colorScheme
                            .surfaceContainerHighest,
                        child:
                        const Icon(
                          Icons
                              .image_not_supported_outlined,
                          size: 48,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding:
            const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              32,
            ),
            sliver: SliverList(
              delegate:
              SliverChildListDelegate([
                Text(
                  property.title,
                  style: theme
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons
                            .location_on_outlined,
                        size: 18,
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          location,
                          style: theme
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(
                  height: 14,
                ),
                Text(
                  _formatPrice(
                    property,
                  ),
                  style: theme
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .primary,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                _stats(
                  context,
                  property,
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  'Description',
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  property
                      .description
                      .isEmpty
                      ? 'No description available.'
                      : property
                      .description,
                  style: theme
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    height: 1.55,
                  ),
                ),
                if (property
                    .features
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Features',
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: property
                        .features
                        .map(
                          (feature) {
                        return Chip(
                          avatar:
                          const Icon(
                            Icons
                                .check_rounded,
                            size: 16,
                          ),
                          label: Text(
                            feature.name
                                .isEmpty
                                ? feature
                                .category
                                : feature
                                .name,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(
      BuildContext context,
      PropertyModel property,
      ) {
    final values = [
      _StatItem(
        Icons.square_foot_rounded,
        '${property.areaSqft.round()} sqft',
      ),
      _StatItem(
        Icons.bed_rounded,
        '${property.bedrooms} beds',
      ),
      _StatItem(
        Icons.bathtub_outlined,
        '${property.bathrooms} baths',
      ),
      _StatItem(
        Icons.weekend_outlined,
        property.isFurnished,
      ),
    ];

    return GridView.builder(
      itemCount: values.length,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder:
          (context, index) {
        final item =
        values[index];
        final theme =
        Theme.of(context);

        return Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration:
          BoxDecoration(
            color: theme
                .colorScheme
                .surfaceContainerHighest,
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  item.value,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(
      PropertyModel property,
      ) {
    final digits =
    property.price
        .round()
        .toString();

    final buffer =
    StringBuffer();

    for (
    var i = 0;
    i < digits.length;
    i++
    ) {
      if (i > 0 &&
          (digits.length - i) %
              3 ==
              0) {
        buffer.write(',');
      }

      buffer.write(
        digits[i],
      );
    }

    final currency =
    property.currency.trim();

    return currency.isEmpty
        ? buffer.toString()
        : '$currency ${buffer.toString()}';
  }
}

class _StatItem {
  const _StatItem(
      this.icon,
      this.value,
      );

  final IconData icon;
  final String value;
}