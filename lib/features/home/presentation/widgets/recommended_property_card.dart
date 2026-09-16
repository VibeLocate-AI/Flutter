import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/property_model.dart';

class RecommendedPropertyCard extends StatelessWidget {
  const RecommendedPropertyCard({
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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 108,
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: double.infinity,
                child: _PropertyImage(
                  imageUrl: imageUrl,
                ),
              ),

              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 11,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: AppTextStyles
                            .labelLarge
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
                            size: 14,
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

                      Text(
                        _formatPrice(
                          property,
                          localization,
                        ),
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: AppTextStyles
                            .labelLarge
                            .copyWith(
                          color: theme
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.only(
                  right: 10,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
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
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl.isEmpty) {
      return _fallback(theme);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return _fallback(theme);
      },
      loadingBuilder:
          (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: theme
              .colorScheme
              .surfaceContainerHighest,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color:
                theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fallback(ThemeData theme) {
    return Container(
      color:
      theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.home_work_outlined,
        size: 30,
        color:
        theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}