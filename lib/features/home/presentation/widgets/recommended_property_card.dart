import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/controllers/favorites_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../data/models/property_model.dart';

enum PropertyCardVariant { nearby, recommended }

class RecommendedPropertyCard extends StatelessWidget {
  const RecommendedPropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.variant = PropertyCardVariant.nearby,
  });

  final PropertyModel property;
  final VoidCallback? onTap;
  final PropertyCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final isRecommended = variant == PropertyCardVariant.recommended;
    final width = Responsive.width(context);
    final cardHeight = isRecommended
        ? (width < 370 ? 172.0 : 188.0)
        : (width < 370 ? 150.0 : 162.0);
    final imageWidth = isRecommended
        ? (width < 370 ? 120.0 : 140.0)
        : (width < 370 ? 108.0 : 124.0);

    final imageUrl = property.primaryImage?.imageUrl ??
        (property.images.isNotEmpty ? property.images.first.imageUrl : '');
    final location = _location(context);
    final accent = theme.colorScheme.primary;
    final borderColor = isRecommended
        ? accent.withValues(alpha: .22)
        : theme.colorScheme.outlineVariant;

    return Card(
      margin: EdgeInsets.zero,
      elevation: isRecommended ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: .12),
      color: isRecommended
          ? theme.colorScheme.surfaceContainerLow
          : theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isRecommended ? 24 : 20),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              if (isRecommended)
                Container(
                  width: 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: const Radius.circular(24),
                      bottomStart: const Radius.circular(24),
                    ),
                  ),
                ),
              SizedBox(
                width: imageWidth,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _PropertyImage(imageUrl: imageUrl),
                      ),
                    ),
                    PositionedDirectional(
                      start: 13,
                      top: 13,
                      child: _Tag(
                        text: _typeName(context, property.typeId),
                      ),
                    ),
                    PositionedDirectional(
                      end: 13,
                      bottom: 13,
                      child: _MiniBadge(
                        icon: isRecommended
                            ? Icons.auto_awesome_rounded
                            : Icons.near_me_rounded,
                        text: localization.translate(
                          isRecommended
                              ? 'recommended_badge'
                              : 'nearby_badge',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 12, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              property.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          _FavoriteButton(propertyId: property.id),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.isEmpty
                                  ? localization.translate('location_unavailable')
                                  : location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _details(context),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CurrencyPrice(
                              amount: property.price,
                              sourceCurrency: property.currency,
                              suffix: _formatFrequency(
                                property.rentFrequency,
                                localization,
                              ),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);
    final parts = <String>[];
    if (property.bedrooms > 0) {
      parts.add('${property.bedrooms} ${localization.translate('bedrooms')}');
    }
    if (property.bathrooms > 0) {
      parts.add('${property.bathrooms} ${localization.translate('bathrooms')}');
    }
    if (property.areaSqft > 0) {
      parts.add('${property.areaSqft.round()} ${localization.translate('area_unit')}');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: .045),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              parts[index],
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  String _location(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (isArabic) {
      return (property.location?.neighborhoodAr?.trim().isNotEmpty == true
              ? property.location!.neighborhoodAr!
              : (property.location?.neighborhoodName ??
                  property.location?.addressLine1 ?? ''))
          .trim();
    }
    return (property.location?.neighborhoodEn?.trim().isNotEmpty == true
            ? property.location!.neighborhoodEn!
            : (property.location?.neighborhoodName ??
                property.location?.addressLine1 ?? ''))
        .trim();
  }

  String _typeName(BuildContext context, int typeId) {
    final localization = AppLocalization.of(context);
    const keys = <int, String>{
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
    };
    return localization.translate(keys[typeId] ?? 'property');
  }

  String _formatFrequency(String frequency, AppLocalization localization) {
    switch (frequency.trim().toLowerCase()) {
      case 'month':
      case 'monthly':
        return ' ${localization.translate('per_month')}';
      case 'year':
      case 'yearly':
      case 'annual':
      case 'annually':
        return ' ${localization.translate('per_year')}';
      case 'week':
      case 'weekly':
        return ' ${localization.translate('per_week')}';
      case 'day':
      case 'daily':
        return ' ${localization.translate('per_day')}';
      default:
        return '';
    }
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.propertyId});

  final int propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final dark = theme.brightness == Brightness.dark;
    final controller = Get.find<FavoritesController>();

    return Obx(() {
      final isFavorite = controller.isFavorite(propertyId);
      final loading = controller.isPending(propertyId);

      return Material(
        color: dark
            ? AppColors.navigationDark.withValues(alpha: .96)
            : theme.colorScheme.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: loading
              ? null
              : () async {
                  try {
                    await controller.toggle(propertyId);
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error.toString().replaceFirst('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                },
          child: Tooltip(
            message: isFavorite
                ? localization.translate('remove_favorite')
                : localization.translate('favorite'),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: loading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Icon(
                          key: ValueKey(isFavorite),
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          text,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: .85),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (imageUrl.isEmpty) return _fallback(theme);

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _fallback(theme, loading: true);
      },
      errorBuilder: (_, _, _) => _fallback(theme),
    );
  }

  Widget _fallback(ThemeData theme, {bool loading = false}) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Icon(
                Icons.home_work_outlined,
                size: 30,
                color: theme.colorScheme.primary,
              ),
      ),
    );
  }
}
