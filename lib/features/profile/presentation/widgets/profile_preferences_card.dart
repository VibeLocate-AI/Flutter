import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfilePreferencesCard
    extends StatelessWidget {
  const ProfilePreferencesCard({
    super.key,
    required this.language,
    required this.currency,
    required this.onLanguageTap,
    required this.onCurrencyTap,
  });

  final String language;
  final String currency;

  final VoidCallback
  onLanguageTap;

  final VoidCallback
  onCurrencyTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(context);

    final isArabic =
        Localizations.localeOf(
          context,
        ).languageCode ==
            'ar';

    return _PreferenceContainer(
      title: isArabic
          ? 'التفضيلات'
          : _t(
        localization,
        'preferences',
        'Preferences',
      ),
      children: [
        _PreferenceTile(
          icon:
          Icons.language_rounded,
          title: isArabic
              ? 'اللغة'
              : _t(
            localization,
            'language',
            'Language',
          ),
          value: language == 'ar'
              ? 'العربية'
              : 'English',
          onTap:
          onLanguageTap,
        ),
        const Divider(
          height: 1,
        ),
        _PreferenceTile(
          icon:
          Icons.payments_outlined,
          title: isArabic
              ? 'العملة'
              : _t(
            localization,
            'currency',
            'Currency',
          ),
          value: currency.isEmpty
              ? 'AED'
              : currency,
          onTap:
          onCurrencyTap,
        ),
      ],
    );
  }

  String _t(
      AppLocalization localization,
      String key,
      String fallback,
      ) {
    final value =
    localization.translate(
      key,
    );

    return value == key
        ? fallback
        : value;
  }
}

class _PreferenceContainer
    extends StatelessWidget {
  const _PreferenceContainer({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          AppTextStyles.headingSmall
              .copyWith(
            color: theme
                .colorScheme
                .onSurface,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration:
          BoxDecoration(
            color: theme
                .colorScheme
                .surface,
            borderRadius:
            BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: theme
                  .colorScheme
                  .outlineVariant,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _PreferenceTile
    extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return ListTile(
      contentPadding:
      EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration:
        BoxDecoration(
          color: theme
              .colorScheme
              .primary
              .withValues(
            alpha: 0.10,
          ),
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
        child: Icon(
          icon,
          color: theme
              .colorScheme
              .primary,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style:
        AppTextStyles.labelLarge
            .copyWith(
          color: theme
              .colorScheme
              .onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style:
        AppTextStyles.bodySmall
            .copyWith(
          color: theme
              .colorScheme
              .onSurfaceVariant,
        ),
      ),
      trailing:
      const Icon(
        Icons
            .arrow_forward_ios_rounded,
        size: 15,
      ),
      onTap: onTap,
    );
  }
}