import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const Color navyPrimary = Color(0xFF0F2F79);
  static const Color navyDark = Color(0xFF0F172A);
  static const Color navyDeep = Color(0xFF0B1329);

  static const Color blueAccent = Color(0xFF2563EB);
  static const Color blueHover = Color(0xFF1D4ED8);
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color cyanAccent = Color(0xFF06B6D4);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Light theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9);

  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightBorderLight = Color(0xFFE2E8F0);
  static const Color lightBorderFocus = Color(0xFF2563EB);

  static const Color lightTextPrimary = Color(0xFF0F2F79);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark theme
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceAlt = Color(0xFF1E293B);

  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderLight = Color(0xFF1E293B);
  static const Color darkBorderFocus = Color(0xFF60A5FA);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Semantic
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);

  static const Color favoriteRed = Color(0xFFEF4444);
  static const Color overlay = Color(0x66000000);

  static const Color lightShadow = Color(0x14000000);
  static const Color darkShadow = Color(0x33000000);

  // Backward-compatible aliases
  static const Color grayBg = lightBackground;
  static const Color graySurface = lightSurface;
  static const Color graySurfaceAlt = lightSurfaceAlt;

  static const Color grayBorder = lightBorder;
  static const Color grayBorderLight = lightBorderLight;
  static const Color grayBorderFocus = lightBorderFocus;

  static const Color grayTextDark = lightTextPrimary;
  static const Color grayTextLabel = lightTextPrimary;
  static const Color grayTextSub = lightTextSecondary;
  static const Color grayTextMuted = lightTextMuted;
}