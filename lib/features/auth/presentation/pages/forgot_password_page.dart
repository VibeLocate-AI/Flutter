import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.verification,
      arguments: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    final size = MediaQuery.sizeOf(context);
    final width = size.width;

    final horizontalPadding = width < 360 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.grayBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 32,
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
                    const SizedBox(height: 20),

                    AuthHeader(
                      title: localization.translate(
                        'forgot_password_title',
                      ),
                      subtitle: localization.translate(
                        'forgot_password_subtitle',
                      ),
                    ),

                    const SizedBox(height: 40),

                    AuthTextField(
                      controller: _emailController,
                      label: localization.translate(
                        'email',
                      ),
                      hint: localization.translate(
                        'email_hint',
                      ),
                      prefixIcon:
                      Icons.email_outlined,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.done,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return localization.translate(
                            'email_required',
                          );
                        }

                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(
                          value.trim(),
                        )) {
                          return localization.translate(
                            'email_invalid',
                          );
                        }

                        return null;
                      },
                      onSubmitted: (_) => _sendCode(),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _sendCode,
                        child: Text(
                          localization.translate(
                            'send_code',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.login,
                        );
                      },
                      child: Text(
                        localization.translate(
                          'back_to_login',
                        ),
                        style: AppTextStyles.labelMedium
                            .copyWith(
                          color:
                          AppColors.navyPrimary,
                          fontWeight:
                          FontWeight.w600,
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