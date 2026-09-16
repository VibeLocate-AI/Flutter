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
    final localization = AppLocalization.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final cardHeight = width < 360 ? 104.0 : 112.0;
    final imageWidth = width < 360 ? 104.0 : 112.0;

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
          height: cardHeight,
          child: Row(
            children: [
              SizedBox(
                width: imageWidth,
                height: double.infinity,
                child: _PropertyImage(
                  imageUrl: imageUrl,
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsetsDirectional
                      .fromSTEB(
                    12,
                    10,
                    6,
                    10,
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
                        style: AppTextStyles.labelLarge
                            .copyWith(
                          color: theme
                              .colorScheme
                              .onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
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
                        style:
                        AppTextStyles.labelLarge
                            .copyWith(
                          color: theme
                              .colorScheme
                              .primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsetsDirectional.only(
                  end: 10,
                ),
                child: Icon(
                  Directionality.of(context) ==
                      TextDirection.rtl
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons
                      .arrow_forward_ios_rounded,
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
    final price = property.price.round();

    final currency = property.currency.trim();

    final frequency =
    _formatFrequency(
      property.rentFrequency,
      localization,
    );

    return '$currency ${_formatNumber(price)}$frequency';
  }

  String _formatNumber(int value) {
    final digits = value.toString();
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

        return ColoredBox(
          color:
          theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: SizedBox(
              width: 19,
              height: 19,
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
    return ColoredBox(
      color:
      theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.home_work_outlined,
        size: 28,
        color:
        theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}