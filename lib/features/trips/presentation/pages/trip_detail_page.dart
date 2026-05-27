import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_detail_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TripDetailPage extends StatelessWidget {
  const TripDetailPage({super.key, @PathParam('tripId') required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TripDetailBloc>()..add(TripDetailLoadRequested(tripId)),
      child: Scaffold(
        appBar: AppBar(title: Text('trip_detail'.tr())),
        body: BlocBuilder<TripDetailBloc, TripDetailState>(
          builder: (context, state) {
            if (state is TripDetailLoading) {
              return LoadingView(message: 'loading');
            }
            if (state is TripDetailError) {
              return ErrorView(message: state.message);
            }
            if (state is TripDetailLoaded) {
              return _TripDetailBody(trip: state.trip);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TripDetailBody extends StatelessWidget {
  const _TripDetailBody({required this.trip});

  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'trip_${trip.id}',
            child: Material(
              color: Colors.transparent,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.pickupAddress,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('→ ${trip.dropoffAddress}'),
                      const SizedBox(height: 12),
                      Chip(label: Text(tripStatusLabel(trip.status))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(trip.driverName ?? 'driver'.tr()),
              subtitle: Text(trip.driverPhone ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          _StatusTimeline(status: trip.status),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                context.router.push(TrackingRoute(tripId: trip.id)),
            icon: const Icon(Icons.navigation),
            label: Text('track_trip'.tr()),
          ),
          if (trip.status != TripStatus.completed) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.read<TripDetailBloc>().add(
                      TripDetailStatusUpdateRequested(
                        trip.id,
                        TripStatus.driverArrived,
                      ),
                    );
              },
              child: Text('Simulate Driver Arrived'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                context.read<TripDetailBloc>().add(
                      TripDetailCompleteRequested(trip.id),
                    );
              },
              child: Text('complete_trip'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = [
      TripStatus.requested,
      TripStatus.accepted,
      TripStatus.driverArrived,
      TripStatus.inProgress,
      TripStatus.completed,
    ];
    final currentIndex = steps.indexOf(status).clamp(0, steps.length - 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('status'.tr(), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...List.generate(steps.length, (index) {
              final active = index <= currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      active ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Text(tripStatusLabel(steps[index])),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
