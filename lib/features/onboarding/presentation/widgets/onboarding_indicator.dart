import 'package:flutter/material.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.itemCount,
  });

  final int currentPage;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        itemCount,
            (index) {
          final isActive = index == currentPage;

          return AnimatedContainer(
            duration: const Duration(
              milliseconds: 250,
            ),
            curve: Curves.easeInOut,
            width: isActive ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}