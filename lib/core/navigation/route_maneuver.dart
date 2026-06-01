import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Turn-by-turn maneuver kind derived from OSRM step data.
enum ManeuverKind {
  depart,
  arrive,
  straight,
  turnLeft,
  turnRight,
  slightLeft,
  slightRight,
  uturn,
  roundabout,
  merge,
  other,
}

/// A single navigation instruction along a route leg.
class RouteManeuver extends Equatable {
  const RouteManeuver({
    required this.kind,
    required this.streetName,
    required this.instructionKey,
    required this.distanceToManeuverMeters,
    required this.positionAlongLeg,
    this.location,
  });

  final ManeuverKind kind;
  final String streetName;
  final String instructionKey;
  final double distanceToManeuverMeters;
  final double positionAlongLeg;
  final LatLng? location;

  @override
  List<Object?> get props => [
        kind,
        streetName,
        instructionKey,
        distanceToManeuverMeters,
        positionAlongLeg,
        location,
      ];
}

/// Resolved guidance snapshot for the driver UI.
class NavigationGuidanceSnapshot extends Equatable {
  const NavigationGuidanceSnapshot({
    this.current,
    this.next,
    this.distanceToCurrentMeters = 0,
  });

  final RouteManeuver? current;
  final RouteManeuver? next;
  final double distanceToCurrentMeters;

  @override
  List<Object?> get props => [current, next, distanceToCurrentMeters];
}
