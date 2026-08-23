import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/legal_agreement_text.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalization.of(context).translate(
            'login_success_demo',
          ),
        ),
      ),
    );

    // API + Login UseCase سيتم ربطهم لاحقًا.
  }

  void _continueWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalization.of(context).translate(
            'google_login_demo',
          ),
        ),
      ),
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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: height < 700 ? 20 : 32,
            ),
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
                    AuthHeader(
                      title: localization.translate(
                        'welcome_back',
                      ),
                      subtitle: localization.translate(
                        'login_subtitle',
                      ),
                    ),

                    const SizedBox(height: 36),

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
                      TextInputAction.next,
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
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller: _passwordController,
                      label: localization.translate(
                        'password',
                      ),
                      hint: localization.translate(
                        'password_hint',
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
                      TextInputAction.done,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
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
                      },
                      onSubmitted: (_) => _login(),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment:
                      AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.forgotPassword,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize:
                          MaterialTapTargetSize
                              .shrinkWrap,
                        ),
                        child: Text(
                          localization.translate(
                            'forgot_password',
                          ),
                          style:
                          AppTextStyles.labelMedium
                              .copyWith(
                            color:
                            AppColors.blueAccent,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: Text(
                          localization.translate(
                            'login',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color:
                            AppColors.grayBorderLight,
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          child: Text(
                            localization.translate('or'),
                            style:
                            AppTextStyles.labelSmall
                                .copyWith(
                              color:
                              AppColors.grayTextMuted,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color:
                            AppColors.grayBorderLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SocialLoginButton(
                      label: localization.translate(
                        'continue_with_google',
                      ),
                      onPressed:
                      _continueWithGoogle,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            localization.translate(
                              'dont_have_account',
                            ),
                            style:
                            AppTextStyles.bodySmall
                                .copyWith(
                              color:
                              AppColors.grayTextSub,
                            ),
                            textAlign:
                            TextAlign.center,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.register,
                            );
                          },
                          child: Text(
                            localization.translate(
                              'sign_up',
                            ),
                            style:
                            AppTextStyles.labelMedium
                                .copyWith(
                              color:
                              AppColors.navyPrimary,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    LegalAgreementText(
                      centered: true,
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