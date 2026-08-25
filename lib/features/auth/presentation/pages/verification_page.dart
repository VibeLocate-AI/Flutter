import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_router.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/device_identity.dart';
import '../../auth_dependencies.dart';
import '../widgets/auth_header.dart';
import 'reset_password_page.dart';

enum VerificationPurpose {
  emailVerification,
  passwordReset,
}

class VerificationPageArgs {
  const VerificationPageArgs({
    required this.email,
    required this.purpose,
  });

  final String email;
  final VerificationPurpose purpose;
}

class VerificationPage extends StatefulWidget {
  const VerificationPage({
    super.key,
    required this.args,
  });

  final VerificationPageArgs args;

  @override
  State<VerificationPage> createState() =>
      _VerificationPageState();
}

class _VerificationPageState
    extends State<VerificationPage> {
  static const int _otpLength = 6;

  final List<TextEditingController> _controllers =
  List.generate(
    _otpLength,
        (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
  List.generate(
    _otpLength,
        (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();

    for (final controller in _controllers) {
      controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
          .removeListener(_onControllerChanged);
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String get _code {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  bool get _isCodeComplete =>
      _code.length == _otpLength &&
          RegExp(r'^\d{6}$').hasMatch(_code);

  void _onCodeChanged(
      String value,
      int index,
      ) {
    // Handle pasting multiple digits.
    if (value.length > 1) {
      final digitsOnly =
      value.replaceAll(RegExp(r'\D'), '');

      if (digitsOnly.isEmpty) {
        _controllers[index].clear();
        return;
      }

      final remaining =
      digitsOnly.substring(
        0,
        digitsOnly.length > _otpLength
            ? _otpLength
            : digitsOnly.length,
      );

      for (int i = 0;
      i < remaining.length;
      i++) {
        if (i < _otpLength) {
          _controllers[i].text =
          remaining[i];
        }
      }

      final targetIndex =
      remaining.length >= _otpLength
          ? _otpLength - 1
          : remaining.length;

      if (remaining.length >= _otpLength) {
        FocusScope.of(context).unfocus();
      } else {
        _focusNodes[targetIndex].requestFocus();
      }

      setState(() {});
      return;
    }

    // Move to the next box automatically.
    if (value.isNotEmpty &&
        index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Unfocus after entering the sixth digit.
    if (value.isNotEmpty &&
        index == _otpLength - 1) {
      FocusScope.of(context).unfocus();
    }

    setState(() {});
  }

  KeyEventResult _handleKeyEvent(
      KeyEvent event,
      int index,
      ) {
    if (event is KeyDownEvent &&
        event.logicalKey ==
            LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty &&
          index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();

        setState(() {});

        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  Future<void> _verify() async {
    final localization =
    AppLocalization.of(context);

    if (!_isCodeComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'verification_code_required',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.args.purpose ==
          VerificationPurpose.emailVerification) {
        final deviceUuid =
        await DeviceIdentity.getDeviceUuid();

        final deviceType =
        defaultTargetPlatform ==
            TargetPlatform.iOS
            ? 'ios'
            : 'android';

        await AuthDependencies.verifyEmail(
          email: widget.args.email,
          otp: _code,
          deviceUuid: deviceUuid,
          deviceType: deviceType,
        );

        if (!mounted) {
          return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
              (route) => false,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              localization.translate(
                'email_verified_success',
              ),
            ),
          ),
        );

        return;
      }

      final resetToken =
      await AuthDependencies
          .repository
          .verifyResetOtp(
        email: widget.args.email,
        otp: _code,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRouter.resetPassword,
        arguments: ResetPasswordArgs(
          email: widget.args.email,
          token: resetToken,
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

  Future<void> _resendCode() async {
    if (_isResending) {
      return;
    }

    final localization =
    AppLocalization.of(context);

    setState(() {
      _isResending = true;
    });

    try {
      await AuthDependencies
          .resendVerification(
        email: widget.args.email,
      );

      // Clear old OTP after successful resend.
      for (final controller in _controllers) {
        controller.clear();
      }

      if (mounted) {
        _focusNodes.first.requestFocus();
      }

      if (!mounted) {
        return;
      }

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
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Widget _buildOtpField(
      int index,
      double width,
      ) {
    final fieldWidth =
    width < 360 ? 42.0 : 46.0;

    return SizedBox(
      width: fieldWidth,
      height: 54,
      child: Focus(
        onKeyEvent: (
            node,
            event,
            ) {
          return _handleKeyEvent(
            event,
            index,
          );
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction:
          index == _otpLength - 1
              ? TextInputAction.done
              : TextInputAction.next,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter
                .digitsOnly,
          ],
          onChanged: (value) {
            _onCodeChanged(
              value,
              index,
            );
          },
          onFieldSubmitted: (_) {
            if (index ==
                _otpLength - 1) {
              _verify();
            }
          },
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide:
              const BorderSide(
                color: AppColors.grayBorder,
              ),
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide:
              const BorderSide(
                color: AppColors.grayBorder,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide:
              const BorderSide(
                color: AppColors.blueAccent,
                width: 1.5,
              ),
            ),
          ),
          style: AppTextStyles
              .headingSmall
              .copyWith(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization =
    AppLocalization.of(context);

    final width =
        MediaQuery.sizeOf(context).width;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.grayBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal:
            horizontalPadding,
            vertical: 30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  AuthHeader(
                    title:
                    localization.translate(
                      'verification_title',
                    ),
                    subtitle:
                    localization.translate(
                      'verification_subtitle',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.args.email,
                    textAlign:
                    TextAlign.center,
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color:
                      AppColors.navyPrimary,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children:
                    List.generate(
                      _otpLength,
                          (index) {
                        return Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 3,
                          ),
                          child:
                          _buildOtpField(
                            index,
                            width,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                      _isLoading
                          ? null
                          : _verify,
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
                          'verify',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          localization
                              .translate(
                            'didnt_receive_code',
                          ),
                          style: AppTextStyles
                              .bodySmall
                              .copyWith(
                            color: AppColors
                                .grayTextSub,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed:
                        _isResending
                            ? null
                            : _resendCode,
                        child: _isResending
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          localization
                              .translate(
                            'resend_code',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      localization.translate(
                        'back',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}