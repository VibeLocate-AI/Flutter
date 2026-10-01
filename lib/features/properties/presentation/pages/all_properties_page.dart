import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../home/data/models/property_model.dart';
import '../../../home/presentation/widgets/recommended_property_card.dart';

class AllPropertiesPage extends StatelessWidget {
  const AllPropertiesPage({
    super.key,
    required this.properties,
    required this.titleKey,
    this.subtitleKey,
  });

  final List<PropertyModel> properties;
  final String titleKey;
  final String? subtitleKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate(titleKey)),
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (subtitleKey != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  localization.translate(subtitleKey!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          if (properties.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  localization.translate('no_properties'),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              sliver: SliverList.separated(
                itemCount: properties.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return RecommendedPropertyCard(
                    property: property,
                    variant: PropertyCardVariant.recommended,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.propertyDetails,
                      arguments: property.id,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
