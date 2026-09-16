import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  bool get hasMinLength => password.length >= 8;

  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(password);

  bool get hasLowercase => RegExp(r'[a-z]').hasMatch(password);

  bool get hasNumber => RegExp(r'[0-9]').hasMatch(password);

  bool get hasSpecialCharacter =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=;]').hasMatch(password);

  bool get isStrong =>
      hasMinLength &&
          hasUppercase &&
          hasLowercase &&
          hasNumber &&
          hasSpecialCharacter;

  int get strength {
    int score = 0;

    if (hasMinLength) {
      score++;
    }

    if (hasUppercase && hasLowercase) {
      score++;
    }

    if (hasNumber) {
      score++;
    }

    if (hasSpecialCharacter) {
      score++;
    }

    return score;
  }

  String get strengthLabel {
    if (strength <= 1) {
      return 'Weak';
    }

    if (strength <= 3) {
      return 'Medium';
    }

    return 'Strong';
  }

  Color get strengthColor {
    if (strength <= 1) {
      return const Color(0xFFEF4444);
    }

    if (strength <= 3) {
      return const Color(0xFFF97316);
    }

    return const Color(0xFF16A34A);
  }

  Color get cardBackgroundColor {
    if (strength <= 1) {
      return const Color(0xFFFFF1F2);
    }

    if (strength <= 3) {
      return const Color(0xFFFFF7ED);
    }

    return const Color(0xFFF0FDF4);
  }

  Color get cardBorderColor {
    if (strength <= 1) {
      return const Color(0xFFFECACA);
    }

    if (strength <= 3) {
      return const Color(0xFFFED7AA);
    }

    return const Color(0xFFBBF7D0);
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildStrengthHeader(context),
          const SizedBox(height: 8),
          _buildStrengthBars(),
          const SizedBox(height: 12),
          _buildRequirementsCard(context),
        ],
      ),
    );
  }

  Widget _buildStrengthHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Password strength',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            strengthLabel,
            key: ValueKey(strengthLabel),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: strengthColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthBars() {
    return Row(
      children: List.generate(
        4,
            (index) {
          final active = index < strength;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: 7,
              margin: EdgeInsets.only(
                right: index == 3 ? 0 : 5,
              ),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                  colors: _barGradient(index),
                )
                    : null,
                color: active
                    ? null
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Color> _barGradient(int index) {
    if (strength <= 1) {
      return const [
        Color(0xFFEF4444),
        Color(0xFFF87171),
      ];
    }

    if (strength <= 3) {
      if (index == 0) {
        return const [
          Color(0xFFF97316),
          Color(0xFFFB923C),
        ];
      }

      if (index == 1) {
        return const [
          Color(0xFFF59E0B),
          Color(0xFFFBBF24),
        ];
      }

      return const [
        Color(0xFFFBBF24),
        Color(0xFFA3E635),
      ];
    }

    return const [
      Color(0xFF16A34A),
      Color(0xFF4ADE80),
    ];
  }

  Widget _buildRequirementsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: strengthColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isStrong
                      ? Icons.verified_rounded
                      : Icons.shield_outlined,
                  color: strengthColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStrong
                          ? 'Strong password!'
                          : 'Your password needs more work',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: strengthColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isStrong
                          ? 'Your password meets all requirements.'
                          : 'Please meet the requirements below:',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRequirement(
            text: 'At least 8 characters',
            isValid: hasMinLength,
          ),
          _buildRequirement(
            text: 'One uppercase letter (A-Z)',
            isValid: hasUppercase,
          ),
          _buildRequirement(
            text: 'One lowercase letter (a-z)',
            isValid: hasLowercase,
          ),
          _buildRequirement(
            text: 'One number (0-9)',
            isValid: hasNumber,
          ),
          _buildRequirement(
            text: 'One special character (!@#\$...)',
            isValid: hasSpecialCharacter,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement({
    required String text,
    required bool isValid,
    bool isLast = false,
  }) {
    final color = isValid
        ? const Color(0xFF16A34A)
        : const Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 10,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                isValid ? FontWeight.w500 : FontWeight.w400,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}