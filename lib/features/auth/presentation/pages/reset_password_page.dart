import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/localization.dart';
import '../../auth_dependencies.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_indicator.dart';

class ResetPasswordArgs {
  const ResetPasswordArgs({
    required this.email,
    required this.token,
  });

  final String email;
  final String token;
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.args,
  });

  final ResetPasswordArgs args;

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
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(
          r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=;]',
        ).hasMatch(password);
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

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=;]',
    ).hasMatch(value)) {
      return 'Password must contain a special character';
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

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    final localization =
    AppLocalization.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    if (!_isStrongPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please create a strong password before continuing.',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords do not match.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthDependencies.resetPassword(
        email: widget.args.email,
        token: widget.args.token,
        newPassword: password,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        AppRouter.resetSuccess,
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
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

    final width =
        MediaQuery.sizeOf(context).width;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    final colorScheme =
        Theme.of(context).colorScheme;

    final passwordsMatch =
        _confirmPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text ==
                _passwordController.text;

    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 30,
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
                    const SizedBox(height: 18),
                    AuthHeader(
                      title:
                      localization.translate(
                        'reset_password_title',
                      ),
                      subtitle:
                      localization.translate(
                        'reset_password_subtitle',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.args.email,
                      textAlign:
                      TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                        color:
                        colorScheme.primary,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AuthTextField(
                      controller:
                      _passwordController,
                      label:
                      localization.translate(
                        'password',
                      ),
                      hint:
                      localization.translate(
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
                      onChanged: (_) {
                        setState(() {});
                      },
                      textInputAction:
                      TextInputAction.next,
                      validator:
                          (value) =>
                          _passwordValidator(
                            value,
                            localization,
                          ),
                    ),
                    PasswordStrengthIndicator(
                      password:
                      _passwordController.text,
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller:
                      _confirmPasswordController,
                      label:
                      localization.translate(
                        'confirm_password',
                      ),
                      hint:
                      localization.translate(
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
                      onChanged: (_) {
                        setState(() {});
                      },
                      textInputAction:
                      TextInputAction.done,
                      validator:
                          (value) =>
                          _confirmPasswordValidator(
                            value,
                            localization,
                          ),
                      onSubmitted: (_) =>
                          _resetPassword(),
                    ),
                    if (passwordsMatch) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration:
                            const BoxDecoration(
                              color:
                              Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Passwords match',
                            style: TextStyle(
                              color:
                              Color(0xFF16A34A),
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 52,
                      child:
                      ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _resetPassword,
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