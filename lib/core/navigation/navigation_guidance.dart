import 'package:delivery_app/core/navigation/route_maneuver.dart';
import 'package:delivery_app/core/network/route_service.dart';

enum NavigationLegPhase { approach, onTrip }

/// Resolves current/next maneuvers from route progress on a two-leg trip plan.
abstract final class NavigationGuidance {
  static NavigationGuidanceSnapshot resolve({
    required TripRoutePlan routePlan,
    required double progress,
    required NavigationLegPhase phase,
    required double totalDistanceMeters,
  }) {
    final legProgress = _legProgress(
      progress: progress,
      phaseBoundary: routePlan.phaseBoundaryProgress,
      phase: phase,
    );
    final legDistanceMeters = phase == NavigationLegPhase.approach
        ? routePlan.approachLeg.distanceMeters
        : routePlan.tripLeg.distanceMeters;
    final maneuvers = phase == NavigationLegPhase.approach
        ? routePlan.approachLeg.maneuvers
        : routePlan.tripLeg.maneuvers;

    if (maneuvers.isEmpty) {
      return NavigationGuidanceSnapshot(
        current: _syntheticManeuver(phase, legProgress),
      );
    }

    final traveledMeters = legDistanceMeters * legProgress;
    RouteManeuver? current;
    RouteManeuver? next;
    var distanceToCurrent = 0.0;

    for (var i = 0; i < maneuvers.length; i++) {
      final maneuver = maneuvers[i];
      final maneuverStartMeters =
          maneuver.positionAlongLeg * legDistanceMeters;
      final nextManeuver = i + 1 < maneuvers.length ? maneuvers[i + 1] : null;
      final maneuverEndMeters = nextManeuver != null
          ? nextManeuver.positionAlongLeg * legDistanceMeters
          : legDistanceMeters;

      if (traveledMeters >= maneuverStartMeters &&
          traveledMeters < maneuverEndMeters) {
        current = maneuver;
        next = nextManeuver;
        distanceToCurrent = maneuverEndMeters - traveledMeters;
        break;
      }
    }

    current ??= maneuvers.last;
    next ??= maneuvers.length > 1 ? maneuvers.last : null;
    if (distanceToCurrent <= 0 && legDistanceMeters > 0) {
      distanceToCurrent =
          (legDistanceMeters - traveledMeters).clamp(0, legDistanceMeters);
    }

    return NavigationGuidanceSnapshot(
      current: current,
      next: next != current ? next : null,
      distanceToCurrentMeters: distanceToCurrent,
    );
  }

  static double _legProgress({
    required double progress,
    required double phaseBoundary,
    required NavigationLegPhase phase,
  }) {
    if (phaseBoundary <= 0 || phaseBoundary >= 1) {
      return progress.clamp(0, 1);
    }
    if (phase == NavigationLegPhase.approach) {
      return (progress / phaseBoundary).clamp(0, 1);
    }
    return ((progress - phaseBoundary) / (1 - phaseBoundary)).clamp(0, 1);
  }

  static RouteManeuver _syntheticManeuver(
    NavigationLegPhase phase,
    double legProgress,
  ) {
    final key = phase == NavigationLegPhase.approach
        ? 'nav_head_to_pickup'
        : 'nav_head_to_dropoff';
    return RouteManeuver(
      kind: ManeuverKind.straight,
      streetName: '',
      instructionKey: key,
      distanceToManeuverMeters: 0,
      positionAlongLeg: legProgress,
    );
  }
}
