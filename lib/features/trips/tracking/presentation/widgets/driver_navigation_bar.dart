import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/core/utils/date_time_format.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DriverNavigationBar extends StatelessWidget {
  const DriverNavigationBar({
    super.key,
    required this.etaMinutes,
    required this.remainingDistanceKm,
    this.estimatedArrival,
    required this.onExit,
  });

  final int etaMinutes;
  final double remainingDistanceKm;
  final DateTime? estimatedArrival;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final arrivalText = estimatedArrival != null
        ? formatAppClockTime(estimatedArrival!)
        : '';

    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$etaMinutes ${'minutes'.tr()}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: scheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      arrivalText.isEmpty
                          ? '${remainingDistanceKm.toStringAsFixed(1)} km'
                          : 'nav_eta_summary'.tr(
                              namedArgs: {
                                'km': remainingDistanceKm.toStringAsFixed(1),
                                'time': arrivalText,
                              },
                            ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: onExit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.onError,
                  minimumSize: const Size(88, AppSpacing.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text('nav_exit'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
