import 'package:flutter/material.dart';

class AppColors {
  static bool isDarkMode = false;

  static const primary = Color(0xFF004AC6);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2563EB);
  static const onPrimaryContainer = Color(0xFFEEEFFF);
  static const primaryFixedDim = Color(0xFFB4C5FF);

  static const secondary = Color(0xFF006A61);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF86F2E4);
  static const onSecondaryContainer = Color(0xFF006F66);

  static Color get background => isDarkMode
      ? const Color(0xFF111820)
      : const Color(0xFFF8F9FF);
  static Color get onBackground => isDarkMode
      ? const Color(0xFFE5EAF2)
      : const Color(0xFF0B1C30);
  static Color get surface => background;
  static Color get onSurface => onBackground;
  static Color get onSurfaceVariant => isDarkMode
      ? const Color(0xFFB8C0D2)
      : const Color(0xFF434655);
  static Color get surfaceContainerLow => isDarkMode
      ? const Color(0xFF1A2430)
      : const Color(0xFFEFF4FF);
  static Color get surfaceContainerHighest => isDarkMode
      ? const Color(0xFF2A3A4F)
      : const Color(0xFFD3E4FE);
  static Color get surfaceContainerLowest => isDarkMode
      ? const Color(0xFF18212B)
      : const Color(0xFFFFFFFF);

  static Color get outline => isDarkMode
      ? const Color(0xFF8994A6)
      : const Color(0xFF737686);
  static Color get outlineVariant => isDarkMode
      ? const Color(0xFF3A4657)
      : const Color(0xFFC3C6D7);

  static Color get error => isDarkMode
      ? const Color(0xFFFFB4AB)
      : const Color(0xFFBA1A1A);
  static Color get errorContainer => isDarkMode
      ? const Color(0xFF93000A)
      : const Color(0xFFFFDAD6);
  static Color get success => isDarkMode
      ? const Color(0xFF57D9BC)
      : const Color(0xFF006A61);
}
