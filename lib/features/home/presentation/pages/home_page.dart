import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayBg,
      body: SafeArea(
        child: Center(
          child: Text(
            'Home screen',
            style: AppTextStyles.headingLarge.copyWith(
              color: AppColors.navyDark,
            ),
          ),
        ),
      ),
    );
  }
}