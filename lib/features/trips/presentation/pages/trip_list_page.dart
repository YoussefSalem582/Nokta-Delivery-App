import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/core/utils/responsive.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_list_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TripListBloc>()..add(const TripListLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('trips_title'.tr()),
          actions: [
            IconButton(
              tooltip: 'simulate_offline'.tr(),
              onPressed: () => sl<SyncService>().syncAll(),
              icon: const Icon(Icons.sync),
            ),
          ],
        ),
        body: BlocBuilder<TripListBloc, TripListState>(
          builder: (context, state) {
            if (state is TripListLoading) {
              return LoadingView(message: 'loading');
            }
            if (state is TripListError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<TripListBloc>()
                    .add(const TripListLoadRequested()),
              );
            }
            if (state is TripListLoaded) {
              if (state.trips.isEmpty) {
                return Center(child: Text('no_trips'.tr()));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<TripListBloc>()
                      .add(const TripListRefreshRequested());
                },
                child: CustomScrollView(
                  slivers: [
                    if (state.isOffline)
                      SliverToBoxAdapter(child: OfflineBanner()),
                    SliverPadding(
                      padding: Responsive.pagePadding(context),
                      sliver: SliverList.separated(
                        itemCount: state.trips.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final trip = state.trips[index];
                          return _TripCard(trip: trip);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final TripEntity trip;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'trip_${trip.id}',
      child: Material(
        color: Colors.transparent,
        child: Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.router.push(TripDetailRoute(tripId: trip.id)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.pickupAddress,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        label: Text(tripStatusLabel(trip.status)),
                        backgroundColor: tripStatusColor(trip.status, context)
                            .withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('→ ${trip.dropoffAddress}'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${'fare'.tr()}: ${trip.fare.toStringAsFixed(2)}'),
                      if (trip.isPendingSync)
                        Text(
                          'offline_mode'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
