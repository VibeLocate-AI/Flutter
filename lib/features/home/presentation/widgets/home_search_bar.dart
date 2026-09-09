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
    final localization =
    AppLocalization.of(context);

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color:
          theme.colorScheme.outlineVariant,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction:
        TextInputAction.search,
        style: AppTextStyles.bodyMedium.copyWith(
          color:
          theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText:
          localization.translate(
            'search_hint',
          ),
          hintStyle:
          AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme
                .onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.auto_awesome_rounded,
            color:
            theme.colorScheme.primary,
          ),
          suffixIcon: Padding(
            padding:
            const EdgeInsets.all(7),
            child: Material(
              color: theme.colorScheme.primary,
              borderRadius:
              BorderRadius.circular(13),
              child: InkWell(
                borderRadius:
                BorderRadius.circular(13),
                onTap:
                isLoading ? null : onSearch,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
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
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}