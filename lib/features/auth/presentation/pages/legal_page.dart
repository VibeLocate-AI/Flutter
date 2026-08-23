import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

enum LegalPageType {
  terms,
  privacy,
}

class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.type,
  });

  final LegalPageType type;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    final isTerms = type == LegalPageType.terms;

    final title = isTerms
        ? localization.translate('terms_title')
        : localization.translate('privacy_title');

    final content = isTerms
        ? localization.translate('terms_content')
        : localization.translate('privacy_content');

    return Scaffold(
      backgroundColor: AppColors.grayBg,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            color: AppColors.navyDark,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navyDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grayTextSub,
              height: 1.65,
            ),
          ),
        ),
      ),
    );
  }
}