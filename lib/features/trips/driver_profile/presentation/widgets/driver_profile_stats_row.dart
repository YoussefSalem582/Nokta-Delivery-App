import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DriverProfileStatsRow extends StatelessWidget {
  const DriverProfileStatsRow({
    super.key,
    required this.rating,
    required this.totalRides,
  });

  final double? rating;
  final String totalRides;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (rating != null)
          _StatChip(
            icon: Icons.star,
            iconColor: AppColors.tertiaryFixedDim,
            label: 'driver_rating'.tr(args: [rating!.toStringAsFixed(1)]),
          ),
        if (rating != null) const SizedBox(width: AppSpacing.sm),
        _StatChip(
          icon: Icons.directions_car_outlined,
          iconColor: scheme.primary,
          label: 'driver_total_rides'.tr(args: [totalRides]),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
