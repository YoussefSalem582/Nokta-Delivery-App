import 'package:delivery_app/core/navigation/navigation_guidance.dart';
import 'package:delivery_app/core/navigation/osrm_maneuver_parser.dart';
import 'package:delivery_app/core/navigation/route_maneuver.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('OsrmManeuverParser', () {
    test('parseLegSteps maps turn steps', () {
      final steps = [
        {
          'distance': 100,
          'name': 'Street 7',
          'maneuver': {
            'type': 'depart',
            'location': [31.0, 30.0],
          },
        },
        {
          'distance': 200,
          'name': 'Street 4',
          'maneuver': {
            'type': 'turn',
            'modifier': 'right',
            'location': [31.1, 30.1],
          },
        },
      ];

      final maneuvers =
          OsrmManeuverParser.parseLegSteps(steps, 300);

      expect(maneuvers, hasLength(2));
      expect(maneuvers.first.kind, ManeuverKind.depart);
      expect(maneuvers.first.streetName, 'Street 7');
      expect(maneuvers[1].kind, ManeuverKind.turnRight);
    });

    test('syntheticFallback provides depart and arrive', () {
      final maneuvers = OsrmManeuverParser.syntheticFallback(
        isApproachLeg: true,
        legDistanceMeters: 1000,
      );
      expect(maneuvers, hasLength(2));
      expect(maneuvers.first.instructionKey, 'nav_head_to_pickup');
      expect(maneuvers.last.instructionKey, 'nav_arrive_at_pickup');
    });
  });

  group('NavigationGuidance', () {
    late TripRoutePlan plan;

    setUp(() {
      const approach = RouteResult(
        points: [LatLng(30, 31), LatLng(30.01, 31.01)],
        distanceMeters: 500,
        durationSeconds: 60,
        maneuvers: [
          RouteManeuver(
            kind: ManeuverKind.depart,
            streetName: 'A',
            instructionKey: 'nav_depart',
            distanceToManeuverMeters: 250,
            positionAlongLeg: 0,
          ),
          RouteManeuver(
            kind: ManeuverKind.arrive,
            streetName: 'Pickup',
            instructionKey: 'nav_arrive_at_pickup',
            distanceToManeuverMeters: 250,
            positionAlongLeg: 0.5,
          ),
        ],
      );
      const trip = RouteResult(
        points: [LatLng(30.01, 31.01), LatLng(30.02, 31.02)],
        distanceMeters: 500,
        durationSeconds: 60,
        maneuvers: [
          RouteManeuver(
            kind: ManeuverKind.depart,
            streetName: 'B',
            instructionKey: 'nav_depart',
            distanceToManeuverMeters: 500,
            positionAlongLeg: 0,
          ),
        ],
      );
      plan = TripRoutePlan(
        driverStart: const LatLng(30, 31),
        approachLeg: approach,
        tripLeg: trip,
        fullRoute: approach.points + trip.points,
        phaseBoundaryProgress: 0.5,
        totalDistanceMeters: 1000,
        totalDurationSeconds: 120,
      );
    });

    test('resolve returns current maneuver in approach phase', () {
      final snapshot = NavigationGuidance.resolve(
        routePlan: plan,
        progress: 0.1,
        phase: NavigationLegPhase.approach,
        totalDistanceMeters: 1000,
      );

      expect(snapshot.current, isNotNull);
      expect(snapshot.current!.streetName, 'A');
    });

    test('resolve switches leg after phase boundary', () {
      final snapshot = NavigationGuidance.resolve(
        routePlan: plan,
        progress: 0.75,
        phase: NavigationLegPhase.onTrip,
        totalDistanceMeters: 1000,
      );

      expect(snapshot.current?.streetName, 'B');
    });
  });
}
