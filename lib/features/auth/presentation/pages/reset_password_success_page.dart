import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ResetPasswordSuccessPage
    extends StatelessWidget {
  const ResetPasswordSuccessPage({
    super.key,
  });

  void _goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.grayBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: height < 700 ? 20 : 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.navyPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 46,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    localization.translate(
                      'reset_password_success_title',
                    ),
                    textAlign: TextAlign.center,
                    style:
                    AppTextStyles.headingLarge.copyWith(
                      color: AppColors.navyDark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 340,
                    ),
                    child: Text(
                      localization.translate(
                        'reset_password_success_subtitle',
                      ),
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grayTextSub,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          _goToLogin(context),
                      child: Text(
                        localization.translate(
                          'go_to_login',
                        ),
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
}