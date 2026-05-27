import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/home/presentation/widgets/request_ride_sheet.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomeMapPage extends StatelessWidget {
  const HomeMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapStarted()),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('home_title'.tr())),
            body: Stack(
              children: [
                if (state is MapReady)
                  DeliveryMap(
                    center: state.userPosition,
                    zoom: MapConfig.defaultZoom,
                    followCenter: true,
                    markers: [
                      MapMarkerData(
                        point: state.userPosition,
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.my_location,
                      ),
                    ],
                  )
                else
                  const LoadingView(),
                if (state is MapReady && state.usingFallback)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: OfflineBanner(),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: AnimatedSlide(
                    offset: state is MapReady
                        ? Offset.zero
                        : const Offset(0, 1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: FilledButton.icon(
                      onPressed: state is MapReady
                          ? () => _showRequestSheet(context, state)
                          : null,
                      icon: const Icon(Icons.local_taxi),
                      label: Text('request_ride'.tr()),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showRequestSheet(
    BuildContext context,
    MapReady mapState,
  ) async {
    final trip = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider(
        create: (_) => sl<RequestRideBloc>(),
        child: RequestRideSheet(
          pickupLat: mapState.userPosition.latitude,
          pickupLng: mapState.userPosition.longitude,
        ),
      ),
    );

    if (trip != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('trip_requested_success'.tr())));
      context.router.push(TrackingRoute(tripId: trip.id));
    }
  }
}
