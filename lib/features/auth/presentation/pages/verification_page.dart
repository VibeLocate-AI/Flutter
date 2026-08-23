import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<VerificationPage> createState() =>
      _VerificationPageState();
}

class _VerificationPageState
    extends State<VerificationPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final List<TextEditingController> _controllers =
  List.generate(
    4,
        (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes =
  List.generate(
    4,
        (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _onCodeChanged(
      String value,
      int index,
      ) {
    if (value.length > 1) {
      _controllers[index].text =
          value.substring(value.length - 1);
    }

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (index == 3 && value.isNotEmpty) {
      FocusScope.of(context).unfocus();
    }

    setState(() {});
  }


  String get _code {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  bool get _isCodeComplete {
    return _code.length == 4;
  }

  void _verify() {
    final localization = AppLocalization.of(context);

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

    Navigator.pushNamed(
      context,
      AppRouter.resetPassword,
      arguments: widget.email,
    );
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalization.of(context).translate(
            'verification_code_resent',
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

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

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
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      localization.translate(
                        'verification_title',
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
                        'verification_subtitle',
                      ),
                      textAlign: TextAlign.center,
                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color:
                        AppColors.grayTextSub,
                      ),
                    ),

                    if (widget.email.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelMedium
                            .copyWith(
                          color:
                          AppColors.navyPrimary,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: List.generate(
                        4,
                            (index) {
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            child: SizedBox(
                              width: 58,
                              height: 54,
                              child: TextFormField(
                                controller:
                                _controllers[index],
                                focusNode:
                                _focusNodes[index],
                                textAlign:
                                TextAlign.center,
                                keyboardType:
                                TextInputType.number,
                                textInputAction:
                                index == 3
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                maxLength: 1,
                                onChanged: (value) {
                                  _onCodeChanged(
                                    value,
                                    index,
                                  );
                                },
                                onFieldSubmitted: (_) {
                                  if (index == 3) {
                                    _verify();
                                  }
                                },
                                decoration:
                                InputDecoration(
                                  counterText: '',
                                  contentPadding:
                                  EdgeInsets.zero,
                                  filled: true,
                                  fillColor:
                                  AppColors.white,
                                  border:
                                  OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                    borderSide:
                                    const BorderSide(
                                      color: AppColors
                                          .grayBorder,
                                    ),
                                  ),
                                  enabledBorder:
                                  OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                    borderSide:
                                    const BorderSide(
                                      color: AppColors
                                          .grayBorder,
                                    ),
                                  ),
                                  focusedBorder:
                                  OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                    borderSide:
                                    const BorderSide(
                                      color: AppColors
                                          .blueAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                style: AppTextStyles
                                    .headingSmall
                                    .copyWith(
                                  color: AppColors
                                      .navyDark,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
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
                        onPressed: _verify,
                        child: Text(
                          localization.translate(
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
                        Text(
                          localization.translate(
                            'didnt_receive_code',
                          ),
                          style: AppTextStyles.bodySmall
                              .copyWith(
                            color:
                            AppColors.grayTextSub,
                          ),
                        ),
                        TextButton(
                          onPressed: _resendCode,
                          child: Text(
                            localization.translate(
                              'resend_code',
                            ),
                            style:
                            AppTextStyles.labelMedium
                                .copyWith(
                              color:
                              AppColors.blueAccent,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        localization.translate(
                          'back',
                        ),
                        style:
                        AppTextStyles.labelMedium
                            .copyWith(
                          color:
                          AppColors.navyPrimary,
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