import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileLogoutButton
    extends StatelessWidget {
  const ProfileLogoutButton({
    super.key,
    required this.onPressed,
    required this.enabled,
  });

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(
      BuildContext context,
      ) {
    final localization =
    AppLocalization.of(context);

    final isArabic =
        Localizations.localeOf(
          context,
        ).languageCode ==
            'ar';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed:
        enabled
            ? onPressed
            : null,
        icon: const Icon(
          Icons.logout_rounded,
        ),
        label: Text(
          isArabic
              ? 'تسجيل الخروج'
              : _t(
            localization,
            'logout',
            'Log out',
          ),
          style:
          AppTextStyles.button
              .copyWith(
            color: Theme.of(context)
                .colorScheme
                .error,
          ),
        ),
        style:
        OutlinedButton.styleFrom(
          foregroundColor:
          Theme.of(context)
              .colorScheme
              .error,
          side: BorderSide(
            color:
            Theme.of(context)
                .colorScheme
                .error
                .withValues(
              alpha: 0.35,
            ),
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }

  String _t(
      AppLocalization localization,
      String key,
      String fallback,
      ) {
    final value =
    localization.translate(
      key,
    );

    return value == key
        ? fallback
        : value;
  }
}