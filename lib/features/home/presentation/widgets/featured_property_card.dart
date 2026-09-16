import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
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
    final localization =
    AppLocalization.of(context);

    final imageUrl =
        property.primaryImage?.imageUrl ?? '';

    final location =
        property.location?.addressLine1 ?? '';

    return SizedBox(
      width: 310,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
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
                      child: imageUrl.isEmpty
                          ? _imageFallback(theme)
                          : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, _, _) {
                          return _imageFallback(
                            theme,
                          );
                        },
                      ),
                    ),

                    Positioned(
                      top: 12,
                      left: 12,
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
                          localization.translate(
                            _propertyTypeKey(
                              property.typeId,
                            ),
                          ),
                          style:
                          AppTextStyles.labelSmall
                              .copyWith(
                            color: theme.colorScheme
                                .onPrimary,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.white
                            .withValues(alpha: 0.92),
                        shape:
                        const CircleBorder(),
                        child: InkWell(
                          customBorder:
                          const CircleBorder(),
                          onTap: () {
                            // Favorite functionality
                            // will be connected later.
                          },
                          child: const SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(
                              Icons
                                  .favorite_border_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding:
                  const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        AppTextStyles.labelLarge
                            .copyWith(
                          color: theme
                              .colorScheme
                              .onSurface,
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
                          const SizedBox(width: 3),
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
                              TextOverflow.ellipsis,
                              style: AppTextStyles
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

                      const Spacer(),

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              _formatPrice(
                                property,
                                localization,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: AppTextStyles
                                  .headingSmall
                                  .copyWith(
                                color: theme
                                    .colorScheme
                                    .primary,
                              ),
                            ),
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

  Widget _imageFallback(ThemeData theme) {
    return ColoredBox(
      color:
      theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color:
          theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatPrice(
      PropertyModel property,
      AppLocalization localization,
      ) {
    final formattedPrice =
    _formatNumber(property.price);

    final currency =
    property.currency.trim().isEmpty
        ? ''
        : '${property.currency.trim()} ';

    final frequency =
    _formatFrequency(
      property.rentFrequency,
      localization,
    );

    return '$currency$formattedPrice$frequency';
  }

  String _formatNumber(double value) {
    final rounded = value.round();
    final digits = rounded.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 &&
          (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return buffer.toString();
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

  String _propertyTypeKey(int typeId) {
    switch (typeId) {
      case 1:
        return 'property_apartment';

      case 2:
        return 'property_villa';

      case 3:
        return 'property_penthouse';

      case 4:
        return 'property_house';

      case 5:
        return 'property_bungalow';

      default:
        return 'property_house';
    }
  }
}