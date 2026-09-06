import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {

  // LIGHT THEME

  static ThemeData light() {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppColors.navyPrimary,
      onPrimary: AppColors.white,
      secondary: AppColors.blueAccent,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.navyDark,
      error: AppColors.errorRed,
      onError: AppColors.white,
      outline: AppColors.grayBorder,
      outlineVariant: AppColors.grayBorderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      fontFamily: AppTextStyles.fontFamily,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.grayBg,

      canvasColor: AppColors.grayBg,

      textTheme: _lightTextTheme(),

       // APP BAR
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navyDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

       // CARD
      cardTheme: CardThemeData(
        color: AppColors.graySurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: AppColors.grayBorderLight,
          ),
        ),
      ),

       // DIVIDER
      dividerTheme: const DividerThemeData(
        color: AppColors.grayBorderLight,
        thickness: 1,
        space: 1,
      ),

       // INPUT
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        hintStyle: const TextStyle(
          color: AppColors.grayTextMuted,
        ),

        labelStyle: const TextStyle(
          color: AppColors.grayTextSub,
        ),

        floatingLabelStyle: const TextStyle(
          color: AppColors.blueAccent,
          fontWeight: FontWeight.w600,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.grayBorder,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.grayBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.grayBorderFocus,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
      ),

       // ELEVATED BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyPrimary,
          foregroundColor: AppColors.white,

          disabledBackgroundColor:
          AppColors.grayBorderLight,

          disabledForegroundColor:
          AppColors.grayTextMuted,

          elevation: 0,

          minimumSize: const Size(
            double.infinity,
            52,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          textStyle: AppTextStyles.button,
        ),
      ),

       // OUTLINED BUTTON
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyPrimary,

          minimumSize: const Size(
            double.infinity,
            52,
          ),

          side: const BorderSide(
            color: AppColors.grayBorder,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          textStyle: AppTextStyles.button,
        ),
      ),

       // TEXT BUTTON
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueAccent,

          textStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

       // FLOATING ACTION BUTTON
      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.navyPrimary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),

       // BOTTOM SHEET
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        showDragHandle: true,
      ),

       // DIALOG
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

       // SNACKBAR
       snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.navyDark,

        contentTextStyle:
        AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

       // NAVIGATION BAR
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,

        indicatorColor:
        AppColors.blueAccent.withValues(
          alpha: 0.12,
        ),

        iconTheme:
        WidgetStateProperty.resolveWith<
            IconThemeData?>(
              (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const IconThemeData(
                color: AppColors.navyPrimary,
              );
            }

            return const IconThemeData(
              color: AppColors.grayTextMuted,
            );
          },
        ),

        labelTextStyle:
        WidgetStateProperty.resolveWith<
            TextStyle?>(
              (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppTextStyles.labelSmall.copyWith(
                color: AppColors.navyPrimary,
                fontWeight: FontWeight.w700,
              );
            }

            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.grayTextMuted,
            );
          },
        ),
      ),

       // PROGRESS INDICATOR
      progressIndicatorTheme:
      const ProgressIndicatorThemeData(
        color: AppColors.navyPrimary,
      ),
    );
  }


  // DARK THEME
  static ThemeData dark() {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppColors.blueAccent,
      onPrimary: AppColors.white,
      secondary: AppColors.indigoAccent,
      onSecondary: AppColors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.errorRed,
      onError: AppColors.white,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      fontFamily: AppTextStyles.fontFamily,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.darkBg,

      canvasColor: AppColors.darkBg,

      textTheme: _darkTextTheme(),

       // APP BAR
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

       // CARD
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: AppColors.darkBorderLight,
          ),
        ),
      ),

       // DIVIDER
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderLight,
        thickness: 1,
        space: 1,
      ),

       // INPUT
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        hintStyle: const TextStyle(
          color: AppColors.darkTextMuted,
        ),

        labelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
        ),

        floatingLabelStyle: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkBorderFocus,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
      ),

       // ELEVATED BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueAccent,
          foregroundColor: AppColors.white,

          disabledBackgroundColor:
          AppColors.darkSurfaceAlt,

          disabledForegroundColor:
          AppColors.darkTextMuted,

          elevation: 0,

          minimumSize: const Size(
            double.infinity,
            52,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          textStyle: AppTextStyles.button,
        ),
      ),

       // OUTLINED BUTTON
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
          AppColors.darkTextPrimary,

          minimumSize: const Size(
            double.infinity,
            52,
          ),

          side: const BorderSide(
            color: AppColors.darkBorder,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          textStyle: AppTextStyles.button,
        ),
      ),

       // TEXT BUTTON
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blueAccent,

          textStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

       // FLOATING ACTION BUTTON
      floatingActionButtonTheme:
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blueAccent,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),

      // BOTTOM SHEET
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        showDragHandle: true,
      ),

      // DIALOG
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // SNACKBAR
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor:
        AppColors.darkSurfaceAlt,

        contentTextStyle:
        AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),


      // NAVIGATION BAR
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,

        indicatorColor:
        AppColors.blueAccent.withValues(
          alpha: 0.18,
        ),

        iconTheme:
        WidgetStateProperty.resolveWith<
            IconThemeData?>(
              (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return const IconThemeData(
                color: AppColors.white,
              );
            }

            return const IconThemeData(
              color: AppColors.darkTextMuted,
            );
          },
        ),

        labelTextStyle:
        WidgetStateProperty.resolveWith<
            TextStyle?>(
              (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppTextStyles.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              );
            }

            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.darkTextMuted,
            );
          },
        ),
      ),

      // PROGRESS INDICATOR
      progressIndicatorTheme:
      const ProgressIndicatorThemeData(
        color: AppColors.blueAccent,
      ),
    );
  }

  // LIGHT TEXT THEME
  static TextTheme _lightTextTheme() {
    return const TextTheme(
      displayLarge:
      AppTextStyles.displayLarge,

      displayMedium:
      AppTextStyles.displayMedium,

      headlineLarge:
      AppTextStyles.headingLarge,

      headlineMedium:
      AppTextStyles.headingMedium,

      headlineSmall:
      AppTextStyles.headingSmall,

      bodyLarge:
      AppTextStyles.bodyLarge,

      bodyMedium:
      AppTextStyles.bodyMedium,

      bodySmall:
      AppTextStyles.bodySmall,

      labelLarge:
      AppTextStyles.labelLarge,

      labelMedium:
      AppTextStyles.labelMedium,

      labelSmall:
      AppTextStyles.labelSmall,
    );
  }

  // DARK TEXT THEME
  static TextTheme _darkTextTheme() {
    return TextTheme(
      displayLarge:
      AppTextStyles.displayLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      displayMedium:
      AppTextStyles.displayMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      headlineLarge:
      AppTextStyles.headingLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      headlineMedium:
      AppTextStyles.headingMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      headlineSmall:
      AppTextStyles.headingSmall.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      bodyLarge:
      AppTextStyles.bodyLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      bodyMedium:
      AppTextStyles.bodyMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),

      bodySmall:
      AppTextStyles.bodySmall.copyWith(
        color: AppColors.darkTextSecondary,
      ),

      labelLarge:
      AppTextStyles.labelLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),

      labelMedium:
      AppTextStyles.labelMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),

      labelSmall:
      AppTextStyles.labelSmall.copyWith(
        color: AppColors.darkTextMuted,
      ),
    );
  }
}