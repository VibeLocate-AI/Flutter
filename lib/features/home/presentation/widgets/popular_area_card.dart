import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/popular_area_model.dart';

class PopularAreaCard extends StatelessWidget {
  const PopularAreaCard({
    super.key,
    required this.area,
  });

  final PopularAreaModel area;

  String _imageForArea(String name) {
    final value = name.toLowerCase();

    if (value.contains('marina')) {
      return 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=700&q=80';
    }

    if (value.contains('palm')) {
      return 'https://images.unsplash.com/photo-1518684079-3c830dcef090?auto=format&fit=crop&w=700&q=80';
    }

    if (value.contains('downtown')) {
      return 'https://images.unsplash.com/photo-1518684079-3c830dcef090?auto=format&fit=crop&w=700&q=80';
    }

    if (value.contains('business')) {
      return 'https://images.unsplash.com/photo-1512632578888-169bbbc64f33?auto=format&fit=crop&w=700&q=80';
    }

    return 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?auto=format&fit=crop&w=700&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 185,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(17),
          side: BorderSide(
            color: theme
                .colorScheme
                .outlineVariant,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _imageForArea(area.name),
              fit: BoxFit.cover,
              errorBuilder:
                  (_, _, _) {
                return Container(
                  color: theme.colorScheme
                      .surfaceContainerHighest,
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 34,
                    color: theme
                        .colorScheme
                        .primary,
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black
                        .withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    area.name,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: AppTextStyles
                        .labelLarge
                        .copyWith(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${area.propertiesCount} ${_propertiesLabel(context)}',
                    style: AppTextStyles
                        .bodySmall
                        .copyWith(
                      color: Colors.white
                          .withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _propertiesLabel(
      BuildContext context,
      ) {
    final isArabic =
        Localizations.localeOf(context)
            .languageCode ==
            'ar';

    return isArabic
        ? 'عقار'
        : 'properties';
  }
}