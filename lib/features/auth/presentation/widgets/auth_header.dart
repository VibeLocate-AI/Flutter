import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final logoSize = width < 360 ? 58.0 : 68.0;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
         decoration: BoxDecoration(
            color: AppColors.navyPrimary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Image.asset(
      'assets/icons/logo_without_background.png',
      fit: BoxFit.contain,
    ),
        ),

        const SizedBox(height: 22),

        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headingLarge.copyWith(
            color: AppColors.navyDark,
          ),
        ),

        const SizedBox(height: 8),

        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 320,
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grayTextSub,
            ),
          ),
        ),
      ],
    );
  }
}