import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.onTogglePassword,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool showPasswordToggle;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.navyDark,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.navyDark,
          ),
          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: prefixIcon == null
                ? null
                : Icon(
              prefixIcon,
              size: 20,
              color: AppColors.grayTextMuted,
            ),

            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grayTextMuted,
            ),

            suffixIcon: showPasswordToggle
                ? IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              color: AppColors.grayTextMuted,
            )
                : null,
          ),
        ),
      ],
    );
  }
}