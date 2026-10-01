import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/state/favorites_manager.dart';
import '../../../../core/widgets/currency_price.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/property_model.dart';

class FeaturedPropertyCard extends StatelessWidget {
  const FeaturedPropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  final PropertyModel property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final screenWidth = Responsive.width(context);
    final cardWidth = (screenWidth - 40).clamp(270.0, 310.0).toDouble();

    final imageUrl =
        property.primaryImage?.imageUrl ?? '';

    final location =
        property.location?.addressLine1 ?? '';

    final propertyType = _propertyTypeLabel(context, property.typeId, localization);

    return SizedBox(
      width: cardWidth,
      child: Card(
        elevation: 0,
        color:
        theme.colorScheme.surface,
        clipBehavior:
        Clip.antiAlias,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(22),
          side: BorderSide(
            color: theme
                .colorScheme
                .outlineVariant,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child:
                      imageUrl.isEmpty
                          ? _imageFallback(
                        theme,
                      )
                          : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                            _,
                            _,
                            _,
                            ) {
                          return _imageFallback(
                            theme,
                          );
                        },
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration:
                        BoxDecoration(
                          color:
                          theme
                              .colorScheme
                              .primary,
                          borderRadius:
                          BorderRadius
                              .circular(
                            11,
                          ),
                        ),
                        child: Text(
                          propertyType,
                          style:
                          AppTextStyles
                              .labelSmall
                              .copyWith(
                            color:
                            theme
                                .colorScheme
                                .onPrimary,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: AnimatedBuilder(
                        animation: FavoritesManager.instance,
                        builder: (context, _) {
                          final isFavorite =
                              FavoritesManager.instance.isFavorite(property.id);
                          final loading =
                              FavoritesManager.instance.isLoading(property.id);

                          final favoriteBackground = theme.brightness == Brightness.dark
                              ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: .98)
                              : theme.colorScheme.surface.withValues(alpha: .96);

                          return Tooltip(
                            message: isFavorite
                                ? localization.translate('remove_favorite')
                                : localization.translate('favorite'),
                            child: Material(
                              color: favoriteBackground,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: loading
                                    ? null
                                    : () async {
                                        try {
                                          await FavoritesManager.instance
                                              .toggle(property.id);
                                        } catch (error) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                error.toString().replaceFirst(
                                                  'Exception: ',
                                                  '',
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Center(
                                    child: loading
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: theme.colorScheme.primary,
                                            ),
                                          )
                                        : Icon(
                                            isFavorite
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            color: isFavorite
                                                ? theme.colorScheme.error
                                                : theme.colorScheme.onSurface,
                                            size: 21,
                                          ),
                                  ),
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
              Expanded(
                flex: 4,
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.displayTitle,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        AppTextStyles
                            .labelLarge
                            .copyWith(
                          color: theme
                              .colorScheme
                              .onSurface,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            size: 15,
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              location.isEmpty
                                  ? localization
                                  .translate(
                                'home_location',
                              )
                                  : location,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style:
                              AppTextStyles
                                  .bodySmall
                                  .copyWith(
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      _buildDetailsRow(theme, localization),
                      const Spacer(),
                      CurrencyPrice(
                        amount: property.price,
                        sourceCurrency: property.currency,
                        suffix: _formatFrequency(
                          property.rentFrequency,
                          localization,
                        ),
                        style: AppTextStyles
                            .headingSmall
                            .copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      )
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

  Widget _buildDetailsRow(
    ThemeData theme,
    AppLocalization localization,
  ) {
    final items = <Widget>[];

    if (property.bedrooms > 0) {
      items.add(_detailChip(
        theme,
        Icons.bed_outlined,
        '${property.bedrooms} ${localization.translate('bedrooms')}',
      ));
    }
    if (property.bathrooms > 0) {
      items.add(_detailChip(
        theme,
        Icons.bathtub_outlined,
        '${property.bathrooms} ${localization.translate('bathrooms')}',
      ));
    }
    if (property.areaSqft > 0) {
      items.add(_detailChip(
        theme,
        Icons.square_foot_rounded,
        '${property.areaSqft.round()} ${localization.translate('area_unit')}',
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 24,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: items.map((item) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 6),
          child: item,
        )).toList()),
      ),
    );
  }

  Widget _detailChip(
    ThemeData theme,
    IconData icon,
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback(
      ThemeData theme,
      ) {
    return ColoredBox(
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons
              .image_not_supported_outlined,
          color: theme
              .colorScheme
              .onSurfaceVariant,
        ),
      ),
    );
  }

  String _propertyTypeLabel(
    BuildContext context,
    int typeId,
    AppLocalization localization,
  ) {
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


  String _formatFrequency(
      String frequency,
      AppLocalization localization,
      ) {
    final normalized =
    frequency.trim().toLowerCase();

    if (normalized.isEmpty) {
      return '';
    }

    String key;

    switch (normalized) {
      case 'month':
      case 'monthly':
        key = 'per_month';
        break;
      case 'year':
      case 'yearly':
      case 'annual':
      case 'annually':
        key = 'per_year';
        break;
      case 'week':
      case 'weekly':
        key = 'per_week';
        break;
      case 'day':
      case 'daily':
        key = 'per_day';
        break;
      default:
        return '';
    }

    return ' ${localization.translate(key)}';
  }
}