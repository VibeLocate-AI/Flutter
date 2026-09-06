import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/localization.dart';
import '../../auth_dependencies.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import 'verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController
  _emailController =
  TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
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
      final email =
      _emailController.text.trim();

      await AuthDependencies.forgotPassword(
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
          VerificationPurpose.passwordReset,
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

    final width =
        MediaQuery.sizeOf(context).width;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 32,
          ),

          child: Center(
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
                    const SizedBox(height: 20),

                    AuthHeader(
                      title:
                      localization.translate(
                        'forgot_password_title',
                      ),
                      subtitle:
                      localization.translate(
                        'forgot_password_subtitle',
                      ),
                    ),

                    const SizedBox(height: 40),

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
                      TextInputAction.done,
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
                      onSubmitted: (_) =>
                          _sendCode(),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,

                      child: ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _sendCode,

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
                            'send_code',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator
                            .pushReplacementNamed(
                          context,
                          AppRouter.login,
                        );
                      },

                      child: Text(
                        localization.translate(
                          'back_to_login',
                        ),
                        style: TextStyle(
                          color:
                          colorScheme.primary,
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