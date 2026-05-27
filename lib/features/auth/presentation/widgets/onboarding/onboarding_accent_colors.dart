import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/features/auth/presentation/models/onboarding_slide_data.dart';
import 'package:flutter/material.dart';

class OnboardingAccentColors {
  OnboardingAccentColors._();

  static Color container(OnboardingAccent accent, ColorScheme scheme) {
    return switch (accent) {
      OnboardingAccent.primary => scheme.primary.withValues(alpha: 0.12),
      OnboardingAccent.secondary => NoktaColors.secondary.withValues(alpha: 0.14),
      OnboardingAccent.tertiary => NoktaColors.tertiary.withValues(alpha: 0.12),
      OnboardingAccent.primaryContainer =>
        NoktaColors.primaryContainer.withValues(alpha: 0.14),
    };
  }

  static Color icon(OnboardingAccent accent, ColorScheme scheme) {
    return switch (accent) {
      OnboardingAccent.primary => scheme.primary,
      OnboardingAccent.secondary => NoktaColors.secondary,
      OnboardingAccent.tertiary => NoktaColors.tertiary,
      OnboardingAccent.primaryContainer => NoktaColors.primaryContainer,
    };
  }
}
