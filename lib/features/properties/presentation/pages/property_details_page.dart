import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/property_details_controller.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/state/favorites_manager.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../../../core/widgets/no_internet_view.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/property_review_model.dart';
import '../../../reviews/reviews_dependencies.dart';
import '../../localization/property_strings.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({
    super.key,
    required this.propertyId,
  });

  final int propertyId;

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  PropertyModel? _property;
  bool _loading = true;
  bool _reviewLoading = false;
  bool _editingReview = false;
  String? _error;
  int _selectedImage = 0;
  double _selectedRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  final PageController _galleryController = PageController();
  PropertyReviewModel? _myReview;

  @override
  void initState() {
    super.initState();
    LocaleManager.instance.addListener(_onLocaleChanged);
    _load();
  }

  void _onLocaleChanged() {
    if (mounted) _load();
  }

  @override
  void dispose() {
    LocaleManager.instance.removeListener(_onLocaleChanged);
    _reviewController.dispose();
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    final details = Get.find<PropertyDetailsController>();
    final cached = details.getCached(widget.propertyId);
    if (cached != null && mounted) {
      setState(() {
        _property = cached;
        _loading = false;
        _error = null;
      });
      if (!force) {
        // Cache-first: render immediately and synchronize in background.
        details.load(widget.propertyId, force: true).then((fresh) {
          if (!mounted) return;
          setState(() => _property = fresh);
        }).catchError((_) {});
        return;
      }
    } else if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final property = await details.load(widget.propertyId, force: force);
      if (!mounted) return;
      setState(() {
        _property = property;
        _loading = false;
        _error = null;
      });
      FavoritesManager.instance.setFromProperty(
        property.id,
        property.isFavorite,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final property = _property;
    if (property == null) return;

    try {
      await FavoritesManager.instance.toggle(property.id);
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _submitReview() async {
    final property = _property;
    if (property == null || _reviewLoading) return;

    final text = _reviewController.text.trim();

    // Read BuildContext-dependent values before the async gap.
    final localization = AppLocalization.of(context);
    final authorName = localization.translate('you');

    setState(() => _reviewLoading = true);

    try {
      // The current Laravel ReviewController uses POST for both create
      // and update. If the user already has a review, store() updates it.
      final result = await ReviewsDependencies.saveReview(
        propertyId: property.id,
        rating: _selectedRating,
        review: text.isEmpty ? null : text,
      );

      final userId = await TokenStorage.getUserId();

      if (!mounted) return;

      _myReview = PropertyReviewModel(
        id: _myReview?.id ?? -DateTime.now().millisecondsSinceEpoch,
        userId: userId,
        rating: _selectedRating,
        comment: text,
        authorName: authorName,
        createdAt: DateTime.now().toIso8601String().split('T').first,
        isMine: true,
        canEdit: true,
        canDelete: true,
      );

      _reviewController.clear();

      setState(() {
        _editingReview = false;
        _selectedRating = 5;
      });

      await _load(force: true);

      if (!mounted) return;

      _message(
        result.message.isEmpty
            ? localization.translate('review_saved')
            : result.message,
      );
    } catch (error) {
      if (mounted) {
        _message(
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _reviewLoading = false);
      }
    }
  }

  Future<void> _deleteMyReview() async {
    final property = _property;
    if (property == null || _reviewLoading) return;

    final localization = AppLocalization.of(context);
    setState(() => _reviewLoading = true);
    try {
      final result = await ReviewsDependencies.deleteReview(property.id);
      if (!mounted) return;
      _myReview = null;
      setState(() {
        _editingReview = false;
        _selectedRating = 5;
        _reviewController.clear();
      });
      await _load(force: true);
      if (!mounted) return;
      _message(result.message.isEmpty ? localization.translate('review_deleted') : result.message);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _reviewLoading = false);
    }
  }

  void _startEditingReview(PropertyReviewModel review) {
    setState(() {
      _editingReview = true;
      _selectedRating = review.rating.clamp(1, 5).toDouble();
      _reviewController.text = review.comment;
    });
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_property == null || _error != null) {
      final errorText = (_error ?? '').toLowerCase();
      final networkError = errorText.contains('internet') ||
          errorText.contains('connection') ||
          errorText.contains('timed out') ||
          errorText.contains('socket') ||
          errorText.contains('failed host lookup');

      return Scaffold(
        appBar: AppBar(),
        body: networkError
            ? NoInternetView(onRetry: _load)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error ?? PropertyStrings.propertyNotFound,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _load,
                        child: Text(PropertyStrings.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    final property = _property!;
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final images = _gallery(property);
    final isFavorite = FavoritesManager.instance.isFavorite(property.id);

    final actionLabel = property.primaryAction?['label']?.toString() ??
        localization.translate('book_now');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopBar(context, property, isFavorite),
            ),
            SliverToBoxAdapter(
              child: _buildGallery(context, images, property),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPropertyHeader(
                    context,
                    property,
                    localization,
                  ),
                  const SizedBox(height: 16),
                  _buildStats(context, property),
                  if (_hasExtraDetails(property)) ...[
                    const SizedBox(height: 26),
                    _sectionTitle(context, localization.translate('property_details_more')),
                    const SizedBox(height: 10),
                    _buildExtraDetails(context, property),
                  ],
                  const SizedBox(height: 28),
                  _sectionTitle(context, PropertyStrings.description),
                  const SizedBox(height: 8),
                  Text(
                    property.displayDescription.isEmpty
                        ? PropertyStrings.noDescription
                        : property.displayDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                  ),
                  if (property.features.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _sectionTitle(context, PropertyStrings.features),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: property.features.map((feature) {
                        return Chip(
                          avatar: const Icon(Icons.check_rounded, size: 15),
                          label: Text(
                            feature.displayName.isEmpty ? feature.category : feature.displayName,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (property.owner != null || property.agency != null) ...[
                    const SizedBox(height: 28),
                    _buildAgent(context, property),
                  ],
                  const SizedBox(height: 30),
                  _buildReviews(context, property),
                  const SizedBox(height: 18),
                  _buildReviewForm(context, property),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: () {
              _message(actionLabel);
            },
            child: Text(actionLabel),
          ),
        ),
      ),
    );
  }

  List<dynamic> _gallery(PropertyModel property) {
    final result = <dynamic>[];
    if (property.primaryImage != null &&
        property.primaryImage!.imageUrl.isNotEmpty) {
      result.add(property.primaryImage!);
    }
    for (final image in property.images) {
      if (image.imageUrl.isEmpty) continue;
      if (result.any((item) => item.imageUrl == image.imageUrl)) continue;
      result.add(image);
    }
    return result;
  }

  Widget _buildTopBar(
    BuildContext context,
    PropertyModel property,
    bool isFavorite,
  ) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              localization.translate('property_details_title'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: FavoritesManager.instance,
            builder: (context, _) {
              final liveFavorite = FavoritesManager.instance.isFavorite(property.id);
              final pending = FavoritesManager.instance.isLoading(property.id);
              return IconButton(
                onPressed: pending ? null : _toggleFavorite,
                icon: pending
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        liveFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: liveFavorite ? theme.colorScheme.error : null,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(
    BuildContext context,
    List<dynamic> images,
    PropertyModel property,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: images.isEmpty
                  ? ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 48),
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() => _selectedImage = index);
                          },
                          controller: _galleryController,
                          itemBuilder: (context, index) {
                            return Image.network(
                              images[index].imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return ColoredBox(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported_outlined),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: .54),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (images.length > 1)
                          PositionedDirectional(
                            top: 12,
                            end: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .48),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_selectedImage + 1}/${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        PositionedDirectional(
                          start: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalization.of(context).translate('property_gallery'),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (images.isNotEmpty)
              SizedBox(
                height: 70,
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final selected = index == _selectedImage;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedImage = index);
                        if (_galleryController.hasClients) {
                          _galleryController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                      child: Container(
                        width: 82,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          images[index].imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyHeader(
    BuildContext context,
    PropertyModel property,
    AppLocalization localization,
  ) {
    final theme = Theme.of(context);
    final location = _locationName(property);
    final typeKey = <int, String>{
      1: 'property_type_apartment',
      2: 'property_type_villa',
      3: 'property_type_penthouse',
      4: 'property_type_townhouse',
      5: 'property_type_house',
      6: 'property_type_office',
      7: 'property_type_warehouse',
      8: 'property_type_land',
      9: 'property_type_restaurant',
      10: 'property_type_hotel',
      11: 'property_type_building',
      12: 'property_type_commercial_shop',
      13: 'property_type_clinic',
      14: 'property_type_school',
      15: 'property_type_showroom',
      16: 'property_type_cafe',
    }[property.typeId];

    final listingLabel = property.isForSale
        ? localization.translate('sale')
        : property.isForRent
            ? localization.translate('rent')
            : null;

    final statusLabel = property.isUnderConstruction
        ? localization.translate('under_construction')
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? .18 : .06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (typeKey != null)
                _InfoPill(
                  icon: Icons.home_work_outlined,
                  text: localization.translate(typeKey),
                  filled: true,
                ),
              if (listingLabel != null)
                _InfoPill(
                  icon: property.isForSale
                      ? Icons.sell_outlined
                      : Icons.key_outlined,
                  text: listingLabel,
                ),
              if (statusLabel != null)
                _InfoPill(
                  icon: Icons.construction_outlined,
                  text: statusLabel,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            property.displayTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CurrencyPrice(
                  amount: property.price,
                  sourceCurrency: property.currency,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (property.rentFrequency.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _formatFrequency(property.rentFrequency, localization),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (property.location?.latitude != null &&
              property.location?.longitude != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRouter.propertyLocation,
                arguments: property.id,
              ),
              icon: const Icon(Icons.map_outlined, size: 17),
              label: Text(localization.translate('view_on_map')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildStats(BuildContext context, PropertyModel property) {
    final localization = AppLocalization.of(context);
    final items = [
      _StatItem(
        Icons.bed_rounded,
        '${property.bedrooms} ${localization.translate('bedrooms')}',
      ),
      _StatItem(
        Icons.bathtub_outlined,
        '${property.bathrooms} ${localization.translate('bathrooms')}',
      ),
      _StatItem(
        Icons.square_foot_rounded,
        '${property.areaSqft.round()} ${localization.translate('area_unit')}',
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 16),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _hasExtraDetails(PropertyModel property) {
    return property.propertyCondition?.trim().isNotEmpty == true ||
        property.actionType?.trim().isNotEmpty == true ||
        property.rentFrequency.trim().isNotEmpty ||
        property.isFurnished ||
        property.floorNumber != null ||
        property.totalFloors != null ||
        property.yearBuilt != null ||
        property.availabilityDate?.trim().isNotEmpty == true ||
        property.listingDate?.trim().isNotEmpty == true ||
        property.location?.addressLine2?.trim().isNotEmpty == true ||
        property.location?.buildingName?.trim().isNotEmpty == true;
  }

  Widget _buildExtraDetails(BuildContext context, PropertyModel property) {
    final localization = AppLocalization.of(context);
    final items = <String, String>{};
    void add(String key, String? value) {
      final text = value?.trim() ?? '';
      if (text.isNotEmpty) items[key] = text;
    }

    add(localization.translate('property_action'), _localizedAction(property.actionType, localization));
    add(localization.translate('property_condition'), _localizedCondition(property.propertyCondition, localization));
    if (property.rentFrequency.trim().isNotEmpty) {
      add(localization.translate('property_frequency'), _formatFrequency(property.rentFrequency, localization));
    }
    add(
      localization.translate('property_furnished'),
      property.isFurnished
          ? localization.translate('furnished')
          : localization.translate('unfurnished'),
    );
    if (property.floorNumber != null) add(localization.translate('property_floor'), '${property.floorNumber}');
    if (property.totalFloors != null) add(localization.translate('property_total_floors'), '${property.totalFloors}');
    if (property.yearBuilt != null) add(localization.translate('property_year_built'), '${property.yearBuilt}');
    add(localization.translate('property_availability'), property.availabilityDate);
    add(localization.translate('property_listing_date'), property.listingDate);
    add(localization.translate('property_address_2'), property.location?.addressLine2);
    add(localization.translate('property_building'), property.location?.buildingName);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.entries.map((entry) {
        return Container(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 3),
              Text(entry.value, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _localizedAction(String? value, AppLocalization localization) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'sale':
      case 'sell':
        return localization.translate('action_sale');
      case 'rent':
      case 'rental':
        return localization.translate('action_rent');
      default:
        return value?.trim() ?? '';
    }
  }

  String _localizedCondition(String? value, AppLocalization localization) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'ready':
      case 'completed':
        return localization.translate('condition_ready');
      case 'off_plan':
      case 'off-plan':
        return localization.translate('condition_off_plan');
      case 'under_construction':
        return localization.translate('condition_under_construction');
      default:
        return value?.trim() ?? '';
    }
  }

  Widget _buildAgent(BuildContext context, PropertyModel property) {
    final theme = Theme.of(context);
    final source = property.agency ?? property.owner ?? const <String, dynamic>{};
    final name = (source['name'] ??
            source['full_name'] ??
            source['agency_name'] ??
            '${source['first_name'] ?? ''} ${source['last_name'] ?? ''}')
        .toString()
        .trim();
    final phone = (source['phone'] ?? source['phone_number'] ?? '').toString();
    final localization = AppLocalization.of(context);
    final displayName = name.isEmpty
        ? localization.translate('real_estate_agent')
        : name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          localization.translate('real_estate_agent'),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                child: Text(
                  displayName.trim().substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (phone.isNotEmpty)
                      Text(
                        phone,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: const Icon(Icons.phone_outlined, size: 19),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviews(BuildContext context, PropertyModel property) {
    final theme = Theme.of(context);
    final reviews = <PropertyReviewModel>[
      ...property.reviewItems,
      ...property.reviews.asMap().entries.map(
        (entry) => PropertyReviewModel(
          id: -entry.key - 1,
          rating: property.rating > 0 ? property.rating : 5,
          comment: entry.value,
          authorName: AppLocalization.of(context).translate('vibelocate_user'),
        ),
      ),
    ];
    final average = property.rating > 0
        ? property.rating
        : reviews.isEmpty
            ? 0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    final counts = List<int>.filled(5, 0);
    for (final review in reviews) {
      final index = review.rating.round().clamp(1, 5) - 1;
      counts[index]++;
    }
    final maxCount = counts.fold<int>(1, (max, value) => value > max ? value : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle(context, PropertyStrings.reviews)),
            Text(
              '${reviews.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(
                    average.toStringAsFixed(1),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < average.round()
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 15,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = counts[star - 1];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(width: 14, child: Text('$star')),
                          const SizedBox(width: 5),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                minHeight: 7,
                                value: count / maxCount,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          SizedBox(width: 24, child: Text('$count')),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (reviews.isEmpty)
          Text(
            PropertyStrings.noReviews,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...reviews.map((review) => _reviewCard(context, review)),
      ],
    );
  }

  Widget _reviewCard(BuildContext context, PropertyReviewModel review) {
    final theme = Theme.of(context);
    final name = review.authorName.trim().isEmpty
        ? AppLocalization.of(context).translate('vibelocate_user')
        : review.authorName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: review.authorAvatarUrl != null &&
                    review.authorAvatarUrl!.trim().isNotEmpty
                ? NetworkImage(review.authorAvatarUrl!)
                : null,
            child: review.authorAvatarUrl == null ||
                    review.authorAvatarUrl!.trim().isEmpty
                ? Text(
                    name.trim().substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                if (review.createdAt != null && review.createdAt!.isNotEmpty)
                  Text(
                    review.createdAt!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (review.comment.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    review.comment,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ],
              ],
            ),
          ),
          if (review.isMine && (review.canEdit || review.canDelete))
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _startEditingReview(review);
                if (value == 'delete') _deleteMyReview();
              },
              itemBuilder: (_) => [
                if (review.canEdit)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(AppLocalization.of(context).translate('edit')),
                  ),
                if (review.canDelete)
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(AppLocalization.of(context).translate('delete')),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReviewForm(BuildContext context, PropertyModel property) {
    final theme = Theme.of(context);
    PropertyReviewModel? myReview;
    for (final review in property.reviewItems) {
      if (review.isMine) {
        myReview = review;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _editingReview || myReview != null
                      ? AppLocalization.of(context).translate('your_review')
                      : PropertyStrings.rateProperty,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (myReview != null && !_editingReview)
                TextButton(
                  onPressed: () => _startEditingReview(myReview!),
                  child: Text(AppLocalization.of(context).translate('edit')),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: _reviewLoading
                    ? null
                    : () => setState(() => _selectedRating = value.toDouble()),
                icon: Icon(
                  value <= _selectedRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: PropertyStrings.writeReview,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _reviewLoading ? null : _submitReview,
                  child: _reviewLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                            _editingReview
                                ? AppLocalization.of(context).translate('update_review')
                                : PropertyStrings.submitReview,
                          ),
                ),
              ),
              if (myReview != null) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: AppLocalization.of(context).translate('delete_review'),
                  onPressed: _reviewLoading ? null : _deleteMyReview,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );
  }

  String _locationName(PropertyModel property) {
    final location = property.location;
    if (location == null) return '';

    final language = Localizations.localeOf(context).languageCode;
    if (language == 'ar' && (location.neighborhoodAr ?? '').trim().isNotEmpty) {
      return location.neighborhoodAr!.trim();
    }
    if ((location.neighborhoodEn ?? '').trim().isNotEmpty) {
      return location.neighborhoodEn!.trim();
    }
    return location.addressLine1.trim();
  }

  String _formatFrequency(String value, AppLocalization localization) {
    switch (value.trim().toLowerCase()) {
      case 'month':
      case 'monthly':
        return localization.translate('per_month');
      case 'year':
      case 'yearly':
      case 'annual':
      case 'annually':
        return localization.translate('per_year');
      case 'week':
      case 'weekly':
        return localization.translate('per_week');
      case 'day':
      case 'daily':
        return localization.translate('per_day');
      default:
        return '';
    }
  }

}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    this.filled = false,
  });

  final IconData icon;
  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = filled
        ? theme.colorScheme.primary.withValues(alpha: .10)
        : theme.colorScheme.onSurface.withValues(alpha: .045);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled
              ? theme.colorScheme.primary.withValues(alpha: .20)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem(this.icon, this.value);

  final IconData icon;
  final String value;
}
