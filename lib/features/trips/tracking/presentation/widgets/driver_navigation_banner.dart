import 'package:delivery_app/core/navigation/maneuver_labels.dart';
import 'package:delivery_app/core/navigation/route_maneuver.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DriverNavigationBanner extends StatelessWidget {
  const DriverNavigationBanner({
    super.key,
    required this.current,
    this.next,
  });

  final RouteManeuver? current;
  final RouteManeuver? next;

  @override
  Widget build(BuildContext context) {
    if (current == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final primaryBg = scheme.secondary;
    final onPrimary = scheme.onSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: primaryBg,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppSpacing.radiusMd),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(
                    ManeuverLabels.iconFor(current!.kind),
                    color: onPrimary,
                    size: 40,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      ManeuverLabels.primaryLabel(current!),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.xs,
            ),
            child: Material(
              color: primaryBg.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'nav_then'.tr(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: onPrimary,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      ManeuverLabels.iconFor(next!.kind),
                      color: onPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
