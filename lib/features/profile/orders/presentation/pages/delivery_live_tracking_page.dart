import 'package:delivery_app/core/utils/map_config.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/delivery_map.dart';
import 'package:delivery_app/core/widgets/map_trip_scaffold.dart';
import 'package:delivery_app/features/profile/orders/presentation/bloc/delivery_tracking_bloc.dart';
import 'package:delivery_app/features/profile/orders/presentation/widgets/delivery_navigation_actions.dart';
import 'package:delivery_app/features/profile/orders/presentation/widgets/delivery_tracking_bottom_sheet.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/driver_navigation_banner.dart';
import 'package:delivery_app/features/trips/tracking/presentation/widgets/driver_navigation_bar.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class DeliveryLiveTrackingPage extends StatefulWidget {
  const DeliveryLiveTrackingPage({
    super.key,
    required this.deliveryId,
    required this.role,
    required this.onBack,
    this.onCourierCompleted,
  });

  final String deliveryId;
  final DeliveryTrackingRole role;
  final VoidCallback onBack;
  final VoidCallback? onCourierCompleted;

  @override
  State<DeliveryLiveTrackingPage> createState() =>
      _DeliveryLiveTrackingPageState();
}

class _DeliveryLiveTrackingPageState extends State<DeliveryLiveTrackingPage> {
  final _mapKey = GlobalKey<DeliveryMapState>();
  late final DeliveryTrackingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<DeliveryTrackingBloc>()
      ..add(
        DeliveryTrackingLoadRequested(
          deliveryId: widget.deliveryId,
          role: widget.role,
        ),
      );
  }

  @override
  void dispose() {
    _bloc.add(const DeliveryTrackingStopped());
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<DeliveryTrackingBloc, DeliveryTrackingState>(
        listenWhen: (previous, current) =>
            current is DeliveryTrackingError ||
            (widget.role == DeliveryTrackingRole.courier &&
                current is DeliveryTrackingCompleted),
        listener: (context, state) {
          if (state is DeliveryTrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message.tr())),
            );
          }
          if (state is DeliveryTrackingCompleted &&
              widget.role == DeliveryTrackingRole.courier) {
            widget.onCourierCompleted?.call();
          }
        },
        child: BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(
          builder: (context, state) {
            if (state is DeliveryTrackingError) {
              return MapTripScaffold(
                title: 'delivery_tracking_title'.tr(),
                onBack: widget.onBack,
                body: ErrorView(
                  message: state.message,
                  onRetry: () => _bloc.add(
                    DeliveryTrackingLoadRequested(
                      deliveryId: widget.deliveryId,
                      role: widget.role,
                    ),
                  ),
                ),
              );
            }

            if (state is! DeliveryTrackingActive &&
                state is! DeliveryTrackingCompleted) {
              return MapTripScaffold(
                title: 'delivery_tracking_title'.tr(),
                onBack: widget.onBack,
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final active =
                state is DeliveryTrackingActive ? state : null;
            final completed =
                state is DeliveryTrackingCompleted ? state : null;
            if (active == null && completed == null) {
              return const SizedBox.shrink();
            }

            final route = active?.route ?? completed!.route;
            final driverPosition =
                active?.driverPosition ?? completed!.driverPosition;
            final driverBearing =
                active?.driverBearing ?? completed!.driverBearing;
            final traveled =
                active?.traveledRoute ?? completed!.traveledRoute;
            final remaining =
                active?.remainingRoute ?? completed!.remainingRoute;
            final scheme = Theme.of(context).colorScheme;
            final isCourierNav = widget.role == DeliveryTrackingRole.courier &&
                active != null;

            if (isCourierNav) {
              return Scaffold(
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: DeliveryMap(
                        key: _mapKey,
                        center: driverPosition,
                        zoom: MapConfig.defaultZoom,
                        followCenter: true,
                        fitRouteBounds: true,
                        traveledRoute: traveled,
                        remainingRoute: remaining,
                        markers: [
                          MapMarkerData(
                            point: route.first,
                            color: scheme.secondary,
                            icon: Icons.store,
                          ),
                          MapMarkerData(
                            point: driverPosition,
                            color: scheme.primary,
                            icon: Icons.delivery_dining,
                            size: 36,
                            animate: true,
                            rotation: driverBearing,
                          ),
                          MapMarkerData(
                            point: route.last,
                            color: scheme.error,
                            icon: Icons.location_on,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: DriverNavigationBanner(
                        current: active.currentManeuver,
                        next: active.nextManeuver,
                      ),
                    ),
                    Positioned(
                      right: AppSpacing.md,
                      bottom: 200,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () =>
                            _mapKey.currentState?.recenter(driverPosition),
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: 120,
                      child: DeliveryNavigationActions(
                        active: active,
                        deliveryId: widget.deliveryId,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DriverNavigationBar(
                        etaMinutes: active.etaMinutes,
                        remainingDistanceKm: active.remainingDistanceKm,
                        estimatedArrival: active.estimatedArrival,
                        onExit: () {
                          _bloc.add(const DeliveryTrackingStopped());
                          widget.onBack();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return MapTripScaffold(
              title: 'delivery_tracking_title'.tr(),
              onBack: widget.onBack,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: DeliveryMap(
                      key: _mapKey,
                      center: driverPosition,
                      zoom: MapConfig.defaultZoom,
                      followCenter: active != null,
                      fitRouteBounds: true,
                      traveledRoute: traveled,
                      remainingRoute: remaining,
                      markers: [
                        MapMarkerData(
                          point: route.first,
                          color: scheme.secondary,
                          icon: Icons.store,
                        ),
                        MapMarkerData(
                          point: driverPosition,
                          color: scheme.primary,
                          icon: Icons.delivery_dining,
                          size: 36,
                          animate: active != null,
                          rotation: driverBearing,
                        ),
                        MapMarkerData(
                          point: route.last,
                          color: scheme.error,
                          icon: Icons.location_on,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.md,
                    bottom: 180,
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: () =>
                          _mapKey.currentState?.recenter(driverPosition),
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                  if (active != null)
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: SafeArea(
                        top: false,
                        child: DeliveryTrackingBottomSheet(active: active),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
