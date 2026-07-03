import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Presents a post-trip receipt to the driver after completing a trip.
/// Resolves when the sheet is dismissed.
Future<void> showDriverTripSummary(BuildContext context, TripEntity trip) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => DriverTripSummarySheet(trip: trip),
  );
}

class DriverTripSummarySheet extends StatelessWidget {
  const DriverTripSummarySheet({super.key, required this.trip});

  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: scheme.onPrimaryContainer,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'driver_trip_summary_title'.tr(),
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                Text('driver_summary_fare'.tr(), style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${trip.fare.toStringAsFixed(2)} EGP',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            icon: Icons.route_outlined,
            label: 'driver_summary_distance'.tr(),
            value: trip.distanceKm != null
                ? '${trip.distanceKm!.toStringAsFixed(1)} km'
                : '—',
          ),
          _SummaryRow(
            icon: Icons.schedule_outlined,
            label: 'driver_summary_duration'.tr(),
            value: trip.etaMinutes != null ? '${trip.etaMinutes} min' : '—',
          ),
          _SummaryRow(
            icon: Icons.place_outlined,
            label: 'driver_summary_route'.tr(),
            value: '${trip.pickupAddress} → ${trip.dropoffAddress}',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'driver_summary_done'.tr(),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
