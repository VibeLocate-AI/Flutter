import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}