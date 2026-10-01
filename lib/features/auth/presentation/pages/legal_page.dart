import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'legal_content.dart';

enum LegalPageType {
  terms,
  privacy,
  safetySecurity,
  helpCenter,
}

class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.type,
  });

  final LegalPageType type;

  @override
  Widget build(BuildContext context) {
    final localization =
    AppLocalization.of(context);

    final colorScheme =
        Theme.of(context).colorScheme;

    final title = switch (type) {
      LegalPageType.terms =>
        localization.translate('terms_title'),
      LegalPageType.privacy =>
        localization.translate('privacy_title'),
      LegalPageType.safetySecurity =>
        localization.translate('safety_security'),
      LegalPageType.helpCenter =>
        localization.translate('help_center'),
    };

    final isArabic = localization.locale.languageCode == 'ar';
    final content = switch (type) {
      LegalPageType.terms => isArabic
          ? LegalContent.termsAr
          : LegalContent.terms,
      LegalPageType.privacy => isArabic
          ? LegalContent.privacyAr
          : LegalContent.privacy,
      LegalPageType.safetySecurity => isArabic
          ? LegalContent.safetySecurityAr
          : LegalContent.safetySecurity,
      LegalPageType.helpCenter => isArabic
          ? LegalContent.helpCenterAr
          : LegalContent.helpCenter,
    };

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
              colorScheme.onSurfaceVariant,
              height: 1.65,
            ),
          ),
        ),
      ),
    );
  }
}