import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onSearch,
    this.isLoading = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSearch;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalization.of(context);
    final width = MediaQuery.sizeOf(context).width;

    final height = width < 360 ? 54.0 : 58.0;
    final buttonSize = width < 360 ? 42.0 : 44.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: localization.translate(
            'search_hint',
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.auto_awesome_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(7),
            child: Material(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: isLoading ? null : onSearch,
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                      width: 19,
                      height: 19,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme
                            .colorScheme
                            .onPrimary,
                      ),
                    )
                        : Icon(
                      Icons.search_rounded,
                      size: 21,
                      color: theme
                          .colorScheme
                          .onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}