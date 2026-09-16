import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/property_model.dart';

class FeaturedPropertyCard extends StatefulWidget {
  const FeaturedPropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  final PropertyModel property;
  final VoidCallback? onTap;

  @override
  State<FeaturedPropertyCard> createState() =>
      _FeaturedPropertyCardState();
}

class _FeaturedPropertyCardState
    extends State<FeaturedPropertyCard> {
  bool _isFavorite = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    final cardWidth = math.min(
      screenWidth * 0.82,
      315.0,
    );

    final imageUrl =
        widget.property.primaryImage?.imageUrl ?? '';

    final location =
        widget.property.location?.addressLine1 ?? '';

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant
                  .withValues(alpha: 0.65),
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) {
              setState(() {
                _pressed = true;
              });
            },
            onTapCancel: () {
              setState(() {
                _pressed = false;
              });
            },
            onTapUp: (_) {
              setState(() {
                _pressed = false;
              });
            },
            child: AspectRatio(
              aspectRatio: 0.82,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
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
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin:
                                  Alignment.topCenter,
                                  end:
                                  Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(
                                      alpha: 0.08,
                                    ),
                                    Colors.transparent,
                                    Colors.black.withValues(
                                      alpha: 0.45,
                                    ),
                                  ],
                                  stops: const [
                                    0,
                                    0.48,
                                    1,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningAmber,
                              borderRadius:
                              BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors
                                      .warningAmber
                                      .withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 12,
                                  offset:
                                  const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              localization.translate(
                                _propertyTypeKey(
                                  widget.property.typeId,
                                ),
                              ),
                              style: AppTextStyles
                                  .labelSmall
                                  .copyWith(
                                color: AppColors.white,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Material(
                            color: Colors.white
                                .withValues(alpha: 0.94),
                            shape:
                            const CircleBorder(),
                            child: InkWell(
                              customBorder:
                              const CircleBorder(),
                              onTap: () {
                                setState(() {
                                  _isFavorite =
                                  !_isFavorite;
                                });
                              },
                              child:
                              AnimatedContainer(
                                duration:
                                const Duration(
                                  milliseconds: 180,
                                ),
                                width: 42,
                                height: 42,
                                decoration:
                                BoxDecoration(
                                  shape:
                                  BoxShape.circle,
                                  color: _isFavorite
                                      ? AppColors
                                      .warningAmber
                                      .withValues(
                                    alpha: 0.12,
                                  )
                                      : Colors.transparent,
                                ),
                                child:
                                AnimatedSwitcher(
                                  duration:
                                  const Duration(
                                    milliseconds: 180,
                                  ),
                                  child: Icon(
                                    _isFavorite
                                        ? Icons
                                        .favorite_rounded
                                        : Icons
                                        .favorite_border_rounded,
                                    key: ValueKey(
                                      _isFavorite,
                                    ),
                                    size: 21,
                                    color: _isFavorite
                                        ? AppColors
                                        .warningAmber
                                        : AppColors
                                        .navyDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 14,
                          child: Row(
                            children: [
                              _ImageInfoChip(
                                icon: Icons.star_rounded,
                                label:
                                localization.translate(
                                  'featured',
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding:
                      const EdgeInsets.fromLTRB(
                        16,
                        14,
                        16,
                        14,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.title,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: AppTextStyles
                                .labelLarge
                                .copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurface,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .location_on_rounded,
                                size: 15,
                                color:
                                AppColors.blueAccent,
                              ),
                              const SizedBox(width: 4),
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
                                    widget.property,
                                    localization,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: AppTextStyles
                                      .headingSmall
                                      .copyWith(
                                    color:
                                    AppColors
                                        .blueAccent,
                                    fontWeight:
                                    FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const _DetailsArrow(),
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
        ),
      ),
    );
  }

  Widget _imageFallback(ThemeData theme) {
    return Container(
      color:
      theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 42,
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

    final frequency = _formatFrequency(
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

class _ImageInfoChip extends StatelessWidget {
  const _ImageInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.34,
        ),
        borderRadius:
        BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.warningAmber,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall
                .copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsArrow extends StatelessWidget {
  const _DetailsArrow();

  @override
  Widget build(BuildContext context) {
    final isRtl =
        Directionality.of(context) ==
            TextDirection.rtl;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.blueAccent.withValues(
          alpha: 0.09,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Icon(
        isRtl
            ? Icons.arrow_back_rounded
            : Icons.arrow_forward_rounded,
        size: 17,
        color: AppColors.blueAccent,
      ),
    );
  }
}