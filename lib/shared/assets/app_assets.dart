import 'package:flutter/material.dart';

/// Centralized asset path constants.
abstract final class AppAssets {
  /// Wordmark for light theme backgrounds.
  static const logoLightTheme = 'assets/logo.png';

  /// Wordmark for dark theme backgrounds.
  static const logoDarkTheme = 'assets/logo_light.png';

  static const loadingLottie = 'assets/lottie/loading.json';
  static const translations = 'assets/translations';

  /// Theme-appropriate horizontal wordmark.
  static String logoFor(Brightness brightness) =>
      brightness == Brightness.dark ? logoDarkTheme : logoLightTheme;
}
