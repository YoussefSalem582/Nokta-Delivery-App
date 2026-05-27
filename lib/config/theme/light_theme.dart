import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class LightTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: AppColors.inverseSurface,
    onInverseSurface: Color(0xFFEFF1F4),
    inversePrimary: AppColors.inversePrimary,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
  );
}
