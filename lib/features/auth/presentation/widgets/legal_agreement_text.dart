import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LegalAgreementText extends StatefulWidget {
  const LegalAgreementText({
    super.key,
    this.centered = false,
  });

  final bool centered;

  @override
  State<LegalAgreementText> createState() =>
      _LegalAgreementTextState();
}

class _LegalAgreementTextState
    extends State<LegalAgreementText> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = _openTerms;

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = _openPrivacy;
  }

  void _openTerms() {
    Navigator.pushNamed(
      context,
      AppRouter.terms,
    );
  }

  void _openPrivacy() {
    Navigator.pushNamed(
      context,
      AppRouter.privacy,
    );
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return Text.rich(
      TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.grayTextSub,
          fontSize: 11,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: localization.translate(
              'terms_agreement_start',
            ),
          ),
          TextSpan(
            text: localization.translate(
              'terms_of_service',
            ),
            recognizer: _termsRecognizer,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.blueAccent,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blueAccent,
            ),
          ),
          TextSpan(
            text: localization.translate(
              'terms_and',
            ),
          ),
          TextSpan(
            text: localization.translate(
              'privacy_policy',
            ),
            recognizer: _privacyRecognizer,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.blueAccent,
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blueAccent,
            ),
          ),
          const TextSpan(
            text: '.',
          ),
        ],
      ),
      textAlign: widget.centered
          ? TextAlign.center
          : TextAlign.start,
    );
  }
}