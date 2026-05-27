import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class DarkTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryContainer,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primary,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondaryContainer,
    onSecondary: AppColors.onSecondaryContainer,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.secondaryContainer,
    tertiary: AppColors.tertiaryFixedDim,
    onTertiary: Color(0xFF271900),
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: AppColors.errorContainer,
    surface: AppColors.darkSurface,
    onSurface: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF64748B),
    outlineVariant: Color(0xFF334155),
    inverseSurface: Color(0xFFE2E8F0),
    onInverseSurface: AppColors.darkSurface,
    inversePrimary: AppColors.primary,
    surfaceContainerHighest: Color(0xFF1E293B),
    surfaceContainerHigh: Color(0xFF1A2332),
    surfaceContainer: Color(0xFF162032),
    surfaceContainerLow: Color(0xFF131B2A),
    surfaceContainerLowest: Color(0xFF0F172A),
  );
}
