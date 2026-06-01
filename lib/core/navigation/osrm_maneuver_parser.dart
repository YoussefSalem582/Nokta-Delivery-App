import 'package:delivery_app/core/navigation/route_maneuver.dart';
import 'package:latlong2/latlong.dart';

/// Parses OSRM route leg steps into [RouteManeuver] list.
abstract final class OsrmManeuverParser {
  static List<RouteManeuver> parseLegSteps(
    List<dynamic> steps,
    double legDistanceMeters,
  ) {
    if (steps.isEmpty || legDistanceMeters <= 0) {
      return [];
    }

    var accumulatedMeters = 0.0;
    final maneuvers = <RouteManeuver>[];

    for (final stepRaw in steps) {
      final step = stepRaw as Map<String, dynamic>;
      final distance = (step['distance'] as num?)?.toDouble() ?? 0;
      final name = (step['name'] as String?)?.trim() ?? '';
      final maneuverRaw = step['maneuver'] as Map<String, dynamic>?;
      final kind = _parseKind(maneuverRaw);
      final instructionKey = _instructionKey(kind, maneuverRaw);
      final location = _parseLocation(maneuverRaw);

      final positionAlongLeg =
          (accumulatedMeters / legDistanceMeters).clamp(0.0, 1.0);

      maneuvers.add(
        RouteManeuver(
          kind: kind,
          streetName: name,
          instructionKey: instructionKey,
          distanceToManeuverMeters: distance,
          positionAlongLeg: positionAlongLeg,
          location: location,
        ),
      );

      accumulatedMeters += distance;
    }

    return maneuvers;
  }

  static List<RouteManeuver> syntheticFallback({
    required bool isApproachLeg,
    required double legDistanceMeters,
  }) {
    final key =
        isApproachLeg ? 'nav_head_to_pickup' : 'nav_head_to_dropoff';
    return [
      RouteManeuver(
        kind: ManeuverKind.depart,
        streetName: '',
        instructionKey: key,
        distanceToManeuverMeters: legDistanceMeters,
        positionAlongLeg: 0,
      ),
      RouteManeuver(
        kind: ManeuverKind.arrive,
        streetName: '',
        instructionKey: isApproachLeg ? 'nav_arrive_at_pickup' : 'nav_arrive_at_dropoff',
        distanceToManeuverMeters: 0,
        positionAlongLeg: 1,
      ),
    ];
  }

  static ManeuverKind _parseKind(Map<String, dynamic>? maneuver) {
    if (maneuver == null) return ManeuverKind.other;
    final type = maneuver['type'] as String? ?? '';
    final modifier = maneuver['modifier'] as String? ?? '';

    if (type == 'depart') return ManeuverKind.depart;
    if (type == 'arrive') return ManeuverKind.arrive;
    if (type == 'roundabout' || type == 'rotary') {
      return ManeuverKind.roundabout;
    }
    if (type == 'merge') return ManeuverKind.merge;
    if (type == 'turn') {
      return switch (modifier) {
        'left' => ManeuverKind.turnLeft,
        'right' => ManeuverKind.turnRight,
        'slight left' => ManeuverKind.slightLeft,
        'slight right' => ManeuverKind.slightRight,
        'sharp left' => ManeuverKind.turnLeft,
        'sharp right' => ManeuverKind.turnRight,
        'uturn' => ManeuverKind.uturn,
        _ => ManeuverKind.other,
      };
    }
    if (type == 'continue' || type == 'new name' || type == 'on ramp') {
      return ManeuverKind.straight;
    }
    return ManeuverKind.other;
  }

  static String _instructionKey(
    ManeuverKind kind,
    Map<String, dynamic>? maneuver,
  ) {
    final modifier = maneuver?['modifier'] as String? ?? '';
    return switch (kind) {
      ManeuverKind.depart => 'nav_depart',
      ManeuverKind.arrive => 'nav_arrive',
      ManeuverKind.turnLeft => 'nav_turn_left',
      ManeuverKind.turnRight => 'nav_turn_right',
      ManeuverKind.slightLeft => 'nav_slight_left',
      ManeuverKind.slightRight => 'nav_slight_right',
      ManeuverKind.uturn => 'nav_uturn',
      ManeuverKind.roundabout => 'nav_roundabout',
      ManeuverKind.merge => 'nav_merge',
      ManeuverKind.straight => modifier.isNotEmpty
          ? 'nav_continue'
          : 'nav_continue_on',
      ManeuverKind.other => 'nav_continue_on',
    };
  }

  static LatLng? _parseLocation(Map<String, dynamic>? maneuver) {
    if (maneuver == null) return null;
    final location = maneuver['location'] as List<dynamic>?;
    if (location == null || location.length < 2) return null;
    return LatLng(
      (location[1] as num).toDouble(),
      (location[0] as num).toDouble(),
    );
  }
}
