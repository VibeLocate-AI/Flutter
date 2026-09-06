import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/utils/device_identity.dart';
import '../../auth_dependencies.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/legal_agreement_text.dart';
import '../widgets/social_login_button.dart';
import 'verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUnverifiedEmail() async {
    final localization =
    AppLocalization.of(context);

    final email =
    _emailController.text.trim();

    try {
      await AuthDependencies.resendVerification(
        email: email,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRouter.verification,
        arguments: VerificationPageArgs(
          email: email,
          purpose:
          VerificationPurpose.emailVerification,
        ),
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'verification_code_resent',
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'generic_api_error',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final localization =
    AppLocalization.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final deviceUuid =
      await DeviceIdentity.getDeviceUuid();

      final deviceType =
      defaultTargetPlatform ==
          TargetPlatform.iOS
          ? 'ios'
          : 'android';

      await AuthDependencies.login(
        email:
        _emailController.text.trim(),
        password:
        _passwordController.text,
        rememberMe: false,
        deviceUuid: deviceUuid,
        deviceType: deviceType,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
            (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      final message =
      e.message.trim().toLowerCase();

      final isEmailNotVerified =
          message ==
              'please verify your email first' ||
              message.contains(
                'verify your email',
              );

      if (isEmailNotVerified) {
        await _handleUnverifiedEmail();
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'generic_api_error',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthDependencies.loginWithGoogle();

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
            (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            AppLocalization.of(context)
                .translate(
              'generic_api_error',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization =
    AppLocalization.of(context);

    final colorScheme =
        Theme.of(context).colorScheme;

    final size = MediaQuery.sizeOf(context);

    final width = size.width;
    final height = size.height;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics:
            const BouncingScrollPhysics(),

            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical:
              height < 700 ? 20 : 32,
            ),

            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 430,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,

                  children: [
                    AuthHeader(
                      title:
                      localization.translate(
                        'welcome_back',
                      ),
                      subtitle:
                      localization.translate(
                        'login_subtitle',
                      ),
                    ),

                    const SizedBox(height: 36),

                    AuthTextField(
                      controller:
                      _emailController,
                      label:
                      localization.translate(
                        'email',
                      ),
                      hint:
                      localization.translate(
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
                          return localization
                              .translate(
                            'email_required',
                          );
                        }

                        final emailRegex =
                        RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex
                            .hasMatch(
                          value.trim(),
                        )) {
                          return localization
                              .translate(
                            'email_invalid',
                          );
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    AuthTextField(
                      controller:
                      _passwordController,
                      label:
                      localization.translate(
                        'password',
                      ),
                      hint:
                      localization.translate(
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
                          return localization
                              .translate(
                            'password_required',
                          );
                        }

                        if (value.length < 6) {
                          return localization
                              .translate(
                            'password_min',
                          );
                        }

                        return null;
                      },
                      onSubmitted: (_) =>
                          _login(),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment:
                      AlignmentDirectional
                          .centerEnd,

                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter
                                .forgotPassword,
                          );
                        },

                        style:
                        TextButton.styleFrom(
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
                          style: TextStyle(
                            color:
                            colorScheme.primary,
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
                        onPressed:
                        _isLoading
                            ? null
                            : _login,

                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          localization
                              .translate(
                            'login',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color:
                            colorScheme
                                .outlineVariant,
                          ),
                        ),

                        Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 14,
                          ),

                          child: Text(
                            localization.translate(
                              'or',
                            ),
                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),

                        Expanded(
                          child: Divider(
                            color:
                            colorScheme
                                .outlineVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SocialLoginButton(
                      label:
                      localization.translate(
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
                            style: TextStyle(
                              color: colorScheme
                                  .onSurfaceVariant,
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
                            style: TextStyle(
                              color:
                              colorScheme.primary,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const LegalAgreementText(
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