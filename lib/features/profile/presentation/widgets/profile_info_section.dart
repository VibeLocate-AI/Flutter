import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileInfoSection extends StatelessWidget {
  const ProfileInfoSection({
    super.key,
    required this.editing,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.cityController,
    required this.countryController,
    required this.bioController,
  });

  final bool editing;

  final TextEditingController
  nameController;

  final TextEditingController
  emailController;

  final TextEditingController
  phoneController;

  final TextEditingController
  cityController;

  final TextEditingController
  countryController;

  final TextEditingController
  bioController;

  @override
  Widget build(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(context);

    return _SectionCard(
      title: _t(
        localization,
        'profile_personal_information',
        'Personal Information',
        'المعلومات الشخصية',
        context,
      ),
      children: [
        _ProfileField(
          controller:
          nameController,
          label: _t(
            localization,
            'full_name',
            'Full name',
            'الاسم الكامل',
            context,
          ),
          icon:
          Icons.person_outline_rounded,
          enabled: editing,
        ),
        _ProfileField(
          controller:
          emailController,
          label: _t(
            localization,
            'email',
            'Email',
            'البريد الإلكتروني',
            context,
          ),
          icon:
          Icons.email_outlined,
          keyboardType:
          TextInputType.emailAddress,
          enabled: editing,
        ),
        _ProfileField(
          controller:
          phoneController,
          label: _t(
            localization,
            'phone_number',
            'Phone',
            'رقم الهاتف',
            context,
          ),
          icon:
          Icons.phone_outlined,
          keyboardType:
          TextInputType.phone,
          enabled: editing,
        ),
        _ProfileField(
          controller:
          cityController,
          label: _t(
            localization,
            'city',
            'City',
            'المدينة',
            context,
          ),
          icon:
          Icons.location_city_outlined,
          enabled: editing,
        ),
        _ProfileField(
          controller:
          countryController,
          label: _t(
            localization,
            'country',
            'Country',
            'الدولة',
            context,
          ),
          icon:
          Icons.public_outlined,
          enabled: editing,
        ),
        _ProfileField(
          controller:
          bioController,
          label: _t(
            localization,
            'bio',
            'Bio',
            'نبذة',
            context,
          ),
          icon:
          Icons.notes_rounded,
          maxLines: 4,
          enabled: editing,
          bottomPadding: 0,
        ),
      ],
    );
  }

  String _t(
      AppLocalization localization,
      String key,
      String en,
      String ar,
      BuildContext context,
      ) {
    final translated =
    localization.translate(key);

    if (translated != key) {
      return translated;
    }

    return Localizations.localeOf(
      context,
    ).languageCode ==
        'ar'
        ? ar
        : en;
  }
}

class _SectionCard
    extends StatelessWidget {
  const _SectionCard({
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
        const SizedBox(height: 12),
        Container(
          padding:
          const EdgeInsets.all(16),
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

class _ProfileField
    extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.maxLines = 1,
    this.bottomPadding = 12,
  });

  final TextEditingController
  controller;

  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final int maxLines;
  final double bottomPadding;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      EdgeInsets.only(
        bottom: bottomPadding,
      ),
      child: TextField(
        controller:
        controller,
        enabled:
        enabled,
        keyboardType:
        keyboardType,
        maxLines:
        maxLines,
        style:
        AppTextStyles.bodyMedium
            .copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurface,
        ),
        decoration:
        InputDecoration(
          labelText:
          label,
          prefixIcon:
          Icon(icon),
          filled:
          true,
          fillColor:
          enabled
              ? Theme.of(context)
              .colorScheme
              .surface
              : Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(
            alpha: 0.35,
          ),
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            borderSide:
            BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}