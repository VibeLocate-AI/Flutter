import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class PasswordStrengthResult {
  const PasswordStrengthResult({
    required this.score,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  final int score;

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  bool get isStrong => score == 5;
}

PasswordStrengthResult checkPasswordStrength(
    String password,
    ) {
  final hasMinLength = password.length >= 8;
  final hasUppercase =
  RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase =
  RegExp(r'[a-z]').hasMatch(password);
  final hasNumber =
  RegExp(r'[0-9]').hasMatch(password);
  final hasSpecial =
  RegExp(r'[^A-Za-z0-9]').hasMatch(password);

  final checks = [
    hasMinLength,
    hasUppercase,
    hasLowercase,
    hasNumber,
    hasSpecial,
  ];

  final score =
      checks.where((item) => item).length;

  return PasswordStrengthResult(
    score: score,
    hasMinLength: hasMinLength,
    hasUppercase: hasUppercase,
    hasLowercase: hasLowercase,
    hasNumber: hasNumber,
    hasSpecial: hasSpecial,
  );
}

class PasswordStrengthIndicator
    extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme =
        Theme.of(context).colorScheme;

    final result =
    checkPasswordStrength(password);

    final Color strengthColor;

    if (result.score <= 2) {
      strengthColor = colorScheme.error;
    } else if (result.score <= 4) {
      strengthColor = Colors.amber;
    } else {
      strengthColor = Colors.green;
    }

    final String strengthText;

    if (result.score <= 2) {
      strengthText = 'Weak';
    } else if (result.score <= 4) {
      strengthText = 'Medium';
    } else {
      strengthText = 'Strong';
    }

    return AnimatedSize(
      duration:
      const Duration(milliseconds: 200),

      child: Padding(
        padding:
        const EdgeInsets.only(top: 10),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children:
                    List.generate(
                      5,
                          (index) {
                        final active =
                            index < result.score;

                        return Expanded(
                          child:
                          AnimatedContainer(
                            duration:
                            const Duration(
                              milliseconds: 200,
                            ),
                            height: 5,
                            margin:
                            EdgeInsets.only(
                              right:
                              index == 4
                                  ? 0
                                  : 4,
                            ),
                            decoration:
                            BoxDecoration(
                              color: active
                                  ? strengthColor
                                  : colorScheme
                                  .outlineVariant,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                10,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  strengthText,
                  style:
                  AppTextStyles.labelSmall
                      .copyWith(
                    color: strengthColor,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _Requirement(
              text: 'At least 8 characters',
              valid: result.hasMinLength,
            ),

            _Requirement(
              text:
              'At least one uppercase letter',
              valid: result.hasUppercase,
            ),

            _Requirement(
              text:
              'At least one lowercase letter',
              valid: result.hasLowercase,
            ),

            _Requirement(
              text: 'At least one number',
              valid: result.hasNumber,
            ),

            _Requirement(
              text:
              'At least one special character',
              valid: result.hasSpecial,
            ),
          ],
        ),
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.text,
    required this.valid,
  });

  final String text;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding:
      const EdgeInsets.only(bottom: 3),

      child: Row(
        children: [
          Icon(
            valid
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            size: 14,
            color: valid
                ? Colors.green
                : colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              text,
              style:
              AppTextStyles.labelSmall
                  .copyWith(
                color: valid
                    ? colorScheme.onSurface
                    : colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}