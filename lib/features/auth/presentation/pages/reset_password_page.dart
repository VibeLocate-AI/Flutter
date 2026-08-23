import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _passwordValidator(
      String? value,
      AppLocalization localization,
      ) {
    if (value == null || value.isEmpty) {
      return localization.translate(
        'password_required',
      );
    }

    if (value.length < 6) {
      return localization.translate(
        'password_min',
      );
    }

    return null;
  }

  String? _confirmPasswordValidator(
      String? value,
      AppLocalization localization,
      ) {
    if (value == null || value.isEmpty) {
      return localization.translate(
        'confirm_password_required',
      );
    }

    if (value != _passwordController.text) {
      return localization.translate(
        'passwords_not_match',
      );
    }

    return null;
  }

  void _resetPassword() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      AppRouter.resetSuccess,
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: height < 700 ? 20 : 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      localization.translate(
                        'reset_password_title',
                      ),
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.headingLarge.copyWith(
                        color: AppColors.navyDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      localization.translate(
                        'reset_password_subtitle',
                      ),
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grayTextSub,
                        height: 1.5,
                      ),
                    ),

                    if (widget.email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style:
                        AppTextStyles.labelMedium.copyWith(
                          color: AppColors.navyPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    AuthTextField(
                      controller: _passwordController,
                      label: localization.translate(
                        'password',
                      ),
                      hint: localization.translate(
                        'new_password_hint',
                      ),
                      prefixIcon:
                      Icons.lock_outline,
                      obscureText:
                      _obscurePassword,
                      showPasswordToggle: true,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                      textInputAction:
                      TextInputAction.next,
                      validator: (value) =>
                          _passwordValidator(
                            value,
                            localization,
                          ),
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller:
                      _confirmPasswordController,
                      label: localization.translate(
                        'confirm_password',
                      ),
                      hint: localization.translate(
                        'confirm_password_hint',
                      ),
                      prefixIcon:
                      Icons.lock_outline,
                      obscureText:
                      _obscureConfirmPassword,
                      showPasswordToggle: true,
                      onTogglePassword: () {
                        setState(() {
                          _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                        });
                      },
                      textInputAction:
                      TextInputAction.done,
                      validator: (value) =>
                          _confirmPasswordValidator(
                            value,
                            localization,
                          ),
                      onSubmitted: (_) =>
                          _resetPassword(),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        child: Text(
                          localization.translate(
                            'reset_password_button',
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
      ),
    );
  }
}