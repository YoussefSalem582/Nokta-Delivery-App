import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverNavigationActions extends StatelessWidget {
  const DriverNavigationActions({
    super.key,
    required this.active,
    required this.tripId,
  });

  final TrackingActive active;
  final String tripId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TrackingBloc>();
    final hasAction = active.canDriverMarkArrived ||
        active.canDriverStartTrip ||
        active.canDriverCompleteTrip;
    if (!hasAction) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(
            alpha: 0.92,
          ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            if (active.canDriverMarkArrived)
              Expanded(
                child: AppButton(
                  label: 'driver_mark_arrived'.tr(),
                  loading: active.isUpdating,
                  onPressed: active.isUpdating
                      ? null
                      : () => bloc.add(
                            TrackingDriverStatusRequested(
                              tripId: tripId,
                              status: TripStatus.driverArrived,
                            ),
                          ),
                ),
              ),
            if (active.canDriverStartTrip) ...[
              if (active.canDriverMarkArrived)
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'driver_start_trip'.tr(),
                  loading: active.isUpdating,
                  onPressed: active.isUpdating
                      ? null
                      : () => bloc.add(
                            TrackingDriverStatusRequested(
                              tripId: tripId,
                              status: TripStatus.inProgress,
                            ),
                          ),
                ),
              ),
            ],
            if (active.canDriverCompleteTrip) ...[
              if (active.canDriverMarkArrived || active.canDriverStartTrip)
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'driver_complete_trip'.tr(),
                  loading: active.isUpdating,
                  onPressed: active.isUpdating
                      ? null
                      : () => bloc.add(
                            TrackingDriverStatusRequested(
                              tripId: tripId,
                              status: TripStatus.completed,
                            ),
                          ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
