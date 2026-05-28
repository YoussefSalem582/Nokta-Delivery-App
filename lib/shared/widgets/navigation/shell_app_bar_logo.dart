import 'package:delivery_app/shared/widgets/branding/app_brand_icon.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Compact Nokta wordmark for main-shell tab AppBars.
class ShellAppBarLogo extends StatelessWidget {
  const ShellAppBarLogo({
    super.key,
    this.size = leadingHeight,
    this.centered = false,
  });

  /// Centered wordmark on the home map AppBar (full title width).
  const ShellAppBarLogo.centered({super.key})
      : size = centeredSize,
        centered = true;

  /// Height used in [AppBar.leading]; pair with [leadingWidth] and [tabToolbarHeight].
  static const double leadingHeight = 32;

  /// Height when placed in [AppBar.title] (e.g. home).
  static const double centeredSize = 36;

  /// Leading slot must fit wordmark aspect ratio or Flutter scales the logo down.
  static double leadingWidthFor(double height) =>
      height * AppBrandIcon.wordmarkAspectRatio + AppSpacing.md;

  static double get leadingWidth => leadingWidthFor(leadingHeight);

  static const double tabToolbarHeight = kToolbarHeight;

  final double size;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: centered ? 0 : AppSpacing.sm),
      child: Align(
        alignment: centered ? Alignment.center : Alignment.centerLeft,
        child: AppBrandIcon(size: size, filled: false),
      ),
    );
  }
}
