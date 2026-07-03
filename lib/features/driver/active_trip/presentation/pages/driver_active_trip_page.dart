import 'package:delivery_app/features/driver/active_trip/presentation/widgets/driver_trip_summary_sheet.dart';
import 'package:delivery_app/features/trips/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:delivery_app/features/trips/tracking/presentation/pages/live_tracking_page.dart';
import 'package:flutter/material.dart';

class DriverActiveTripPage extends StatelessWidget {
  const DriverActiveTripPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return LiveTrackingPage(
      tripId: tripId,
      titleKey: 'driver_active_trip',
      role: TrackingRole.driver,
      onBack: () => Navigator.of(context).pop(),
      onDriverTripCompleted: (trip) async {
        // Show the receipt before returning to the driver home shell.
        await showDriverTripSummary(context, trip);
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }
}
