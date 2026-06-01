import 'dart:async';

import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/navigation/navigation_guidance.dart';
import 'package:delivery_app/core/navigation/route_maneuver.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/core/realtime/delivery_location_update.dart';
import 'package:delivery_app/core/realtime/realtime_location_service.dart';
import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/profile/shared/domain/repositories/order_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'delivery_tracking_event.dart';
part 'delivery_tracking_state.dart';

enum DeliveryTrackingRole { customer, courier }

enum DeliveryTrackingPhase { approach, onTrip }

class DeliveryTrackingBloc
    extends Bloc<DeliveryTrackingEvent, DeliveryTrackingState> {
  DeliveryTrackingBloc({
    required OrderRepository orderRepository,
    required RouteService routeService,
    required RealtimeLocationService realtimeLocationService,
  })  : _orderRepository = orderRepository,
        _routeService = routeService,
        _realtimeLocationService = realtimeLocationService,
        super(const DeliveryTrackingInitial()) {
    on<DeliveryTrackingLoadRequested>(_onLoad);
    on<DeliveryTrackingTick>(_onTick);
    on<DeliveryTrackingLiveLocationReceived>(_onLiveLocation);
    on<DeliveryTrackingStatusRequested>(_onStatusRequested);
    on<DeliveryTrackingStopped>(_onStopped);
  }

  final OrderRepository _orderRepository;
  final RouteService _routeService;
  final RealtimeLocationService _realtimeLocationService;

  Timer? _timer;
  StreamSubscription<DeliveryLocationUpdate>? _liveSub;
  TripRoutePlan? _routePlan;
  List<LatLng> _route = [];
  double _distanceTraveledMeters = 0;
  double _totalDistanceMeters = 1;
  double _avgSpeedMps = 8.33;
  double _phaseBoundaryProgress = 0.5;
  DateTime? _lastTickAt;
  int _locationTick = 0;
  DeliveryTrackingRole _role = DeliveryTrackingRole.customer;
  String? _deliveryId;

  Future<void> _onLoad(
    DeliveryTrackingLoadRequested event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    _deliveryId = event.deliveryId;
    _role = event.role;
    emit(DeliveryTrackingLoading(deliveryId: event.deliveryId));

    try {
      final order = await _orderRepository.getDeliveryById(event.deliveryId);
      if (!order.hasRouteCoordinates) {
        emit(const DeliveryTrackingError('error_generic'));
        return;
      }
      if (order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled) {
        emit(const DeliveryTrackingError('tracking_already_completed'));
        return;
      }

      final pickup = LatLng(order.pickupLat!, order.pickupLng!);
      final dropoff = LatLng(order.dropoffLat!, order.dropoffLng!);
      final routePlan = await _routeService.getTripRoutePlan(
        pickup: pickup,
        dropoff: dropoff,
        placementSeed: order.id,
      );

      _routePlan = routePlan;
      _route = routePlan.fullRoute;
      _totalDistanceMeters = routePlan.totalDistanceMeters;
      _avgSpeedMps = routePlan.avgSpeedMps;
      _phaseBoundaryProgress = routePlan.phaseBoundaryProgress;

      _distanceTraveledMeters = _initialDistance(order);
      final progress =
          (_distanceTraveledMeters / _totalDistanceMeters).clamp(0.0, 1.0);
      final split = splitRouteAtProgress(_route, progress);
      final remainingMeters = remainingDistanceMeters(_route, progress);

      emit(
        _withNavigation(
          DeliveryTrackingActive(
            order: order,
            route: _route,
            driverPosition: interpolateAlongRoute(_route, progress),
            driverBearing: bearingAtProgress(_route, progress),
            traveledRoute: split.traveled,
            remainingRoute: split.remaining,
            progress: progress,
            etaMinutes: _etaMinutes(remainingMeters),
            phase: _phaseForOrder(order, progress),
            remainingDistanceKm: remainingMeters / 1000,
            role: _role,
          ),
          remainingMeters: remainingMeters,
        ),
      );

      _lastTickAt = DateTime.now();
      if (_role == DeliveryTrackingRole.courier) {
        if (EnvConfig.usesRealBackend) {
          unawaited(_realtimeLocationService.joinDeliveryRoom(order.id));
        }
        _startTimer();
      } else if (order.isTrackableByCustomer && EnvConfig.usesRealBackend) {
        _liveSub = _realtimeLocationService
            .watchDelivery(order.id)
            .listen((u) => add(DeliveryTrackingLiveLocationReceived(u)));
      }
    } catch (_) {
      emit(const DeliveryTrackingError('error_generic'));
    }
  }

  double _initialDistance(OrderEntity order) {
    if (order.status == OrderStatus.pickedUp ||
        order.status == OrderStatus.inTransit) {
      return _phaseBoundaryProgress * _totalDistanceMeters;
    }
    return 0;
  }

  DeliveryTrackingPhase _phaseForOrder(OrderEntity order, double progress) {
    if (order.status == OrderStatus.inTransit) {
      return DeliveryTrackingPhase.onTrip;
    }
    if (order.status == OrderStatus.pickedUp) {
      return DeliveryTrackingPhase.onTrip;
    }
    return progress >= _phaseBoundaryProgress
        ? DeliveryTrackingPhase.onTrip
        : DeliveryTrackingPhase.approach;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      add(DeliveryTrackingTick(DateTime.now()));
    });
  }

  Future<void> _onTick(
    DeliveryTrackingTick event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    if (state is! DeliveryTrackingActive || _route.length < 2) return;
    final current = state as DeliveryTrackingActive;
    if (current.role != DeliveryTrackingRole.courier) return;

    final delta = event.now.difference(_lastTickAt ?? event.now).inMilliseconds /
        1000;
    _lastTickAt = event.now;

    _distanceTraveledMeters = (_distanceTraveledMeters + _avgSpeedMps * delta)
        .clamp(0, _totalDistanceMeters);
    final progress =
        (_distanceTraveledMeters / _totalDistanceMeters).clamp(0.0, 1.0);
    final split = splitRouteAtProgress(_route, progress);
    final remainingMeters = remainingDistanceMeters(_route, progress);
    final driverPosition = interpolateAlongRoute(_route, progress);
    final phase = _phaseForOrder(current.order, progress);

    if (progress >= 1.0) {
      _timer?.cancel();
      emit(
        DeliveryTrackingCompleted(
          order: current.order.copyWith(status: OrderStatus.delivered),
          route: _route,
          driverPosition: driverPosition,
          driverBearing: bearingAtProgress(_route, 1),
          traveledRoute: split.traveled,
          remainingRoute: split.remaining,
          role: _role,
        ),
      );
      return;
    }

    emit(
      _withNavigation(
        current.copyWith(
          driverPosition: driverPosition,
          driverBearing: bearingAtProgress(_route, progress),
          traveledRoute: split.traveled,
          remainingRoute: split.remaining,
          progress: progress,
          etaMinutes: _etaMinutes(remainingMeters),
          phase: phase,
          remainingDistanceKm: remainingMeters / 1000,
        ),
        remainingMeters: remainingMeters,
      ),
    );

    unawaited(_publishLocation(driverPosition, bearingAtProgress(_route, progress)));
  }

  Future<void> _publishLocation(LatLng position, double bearing) async {
    final id = _deliveryId;
    if (id == null) return;

    if (EnvConfig.usesRealBackend) {
      _realtimeLocationService.publishDeliveryLocation(
        deliveryId: id,
        lat: position.latitude,
        lng: position.longitude,
        heading: bearing,
      );
      _locationTick++;
      if (_locationTick % 10 != 0) return;
      try {
        await _orderRepository.updateDeliveryLocation(
          id: id,
          lat: position.latitude,
          lng: position.longitude,
          heading: bearing,
        );
      } catch (_) {}
    }
  }

  void _onLiveLocation(
    DeliveryTrackingLiveLocationReceived event,
    Emitter<DeliveryTrackingState> emit,
  ) {
    if (state is! DeliveryTrackingActive || _route.length < 2) return;
    if (_role != DeliveryTrackingRole.customer) return;

    final current = state as DeliveryTrackingActive;
    final pos = LatLng(event.update.lat, event.update.lng);
    final projection = projectPointOntoRoute(_route, pos);
    _distanceTraveledMeters =
        projection.distanceAlongRoute.clamp(0, _totalDistanceMeters);

    final progress =
        (_distanceTraveledMeters / _totalDistanceMeters).clamp(0.0, 1.0);
    final split = splitRouteAtProgress(_route, progress);
    final remainingMeters = remainingDistanceMeters(_route, progress);

    emit(
      _withNavigation(
        current.copyWith(
          driverPosition: pos,
          driverBearing:
              event.update.heading ?? bearingAtProgress(_route, progress),
          traveledRoute: split.traveled,
          remainingRoute: split.remaining,
          progress: progress,
          etaMinutes: _etaMinutes(remainingMeters),
          phase: _phaseForOrder(current.order, progress),
          remainingDistanceKm: remainingMeters / 1000,
        ),
        remainingMeters: remainingMeters,
      ),
    );
  }

  Future<void> _onStatusRequested(
    DeliveryTrackingStatusRequested event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    if (state is! DeliveryTrackingActive) return;
    final current = state as DeliveryTrackingActive;
    emit(current.copyWith(isUpdating: true));

    try {
      final updated = await _orderRepository.updateDeliveryStatus(
        event.deliveryId,
        event.status,
      );
      if (event.status == OrderStatus.pickedUp) {
        _distanceTraveledMeters =
            _phaseBoundaryProgress * _totalDistanceMeters;
      }
      if (state is DeliveryTrackingActive) {
        final active = state as DeliveryTrackingActive;
        emit(active.copyWith(order: updated, isUpdating: false));
      }
    } catch (_) {
      if (state is DeliveryTrackingActive) {
        emit((state as DeliveryTrackingActive).copyWith(isUpdating: false));
      }
    }
  }

  Future<void> _onStopped(
    DeliveryTrackingStopped event,
    Emitter<DeliveryTrackingState> emit,
  ) async {
    _timer?.cancel();
    await _liveSub?.cancel();
    _liveSub = null;
    await _realtimeLocationService.disconnect();
  }

  int _etaMinutes(double remainingMeters) {
    if (_avgSpeedMps <= 0) return 1;
    return (remainingMeters / _avgSpeedMps / 60).ceil().clamp(1, 99);
  }

  DeliveryTrackingActive _withNavigation(
    DeliveryTrackingActive active, {
    required double remainingMeters,
  }) {
    if (_role != DeliveryTrackingRole.courier || _routePlan == null) {
      return active;
    }

    final navPhase = active.phase == DeliveryTrackingPhase.approach
        ? NavigationLegPhase.approach
        : NavigationLegPhase.onTrip;
    final guidance = NavigationGuidance.resolve(
      routePlan: _routePlan!,
      progress: active.progress,
      phase: navPhase,
      totalDistanceMeters: _totalDistanceMeters,
    );
    final etaSeconds = _avgSpeedMps > 0
        ? (remainingMeters / _avgSpeedMps).round()
        : active.etaMinutes * 60;
    final destinationLabel = active.phase == DeliveryTrackingPhase.approach
        ? active.order.pickupAddress ?? ''
        : active.order.dropoffAddress ?? '';

    return active.copyWith(
      currentManeuver: guidance.current,
      nextManeuver: guidance.next,
      estimatedArrival: DateTime.now().add(Duration(seconds: etaSeconds)),
      destinationLabel: destinationLabel,
    );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _liveSub?.cancel();
    return super.close();
  }
}
