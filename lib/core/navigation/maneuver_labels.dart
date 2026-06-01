import 'package:delivery_app/core/navigation/route_maneuver.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Localized primary label for a [RouteManeuver].
abstract final class ManeuverLabels {
  static String primaryLabel(RouteManeuver maneuver) {
    final key = maneuver.instructionKey;
    if (maneuver.streetName.isNotEmpty &&
        (key == 'nav_continue_on' || key == 'nav_depart')) {
      return 'nav_continue_on'.tr(
        namedArgs: {'street': maneuver.streetName},
      );
    }
    if (maneuver.streetName.isNotEmpty && key == 'nav_arrive') {
      return maneuver.streetName;
    }
    return key.tr();
  }

  static IconData iconFor(ManeuverKind kind) {
    return switch (kind) {
      ManeuverKind.turnLeft => Icons.turn_left,
      ManeuverKind.turnRight => Icons.turn_right,
      ManeuverKind.slightLeft => Icons.turn_slight_left,
      ManeuverKind.slightRight => Icons.turn_slight_right,
      ManeuverKind.uturn => Icons.u_turn_left,
      ManeuverKind.roundabout => Icons.roundabout_right,
      ManeuverKind.arrive => Icons.flag,
      ManeuverKind.depart => Icons.straight,
      _ => Icons.arrow_upward,
    };
  }
}
