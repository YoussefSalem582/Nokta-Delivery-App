import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'expandable_sheet_body.dart';

class ExpandableRideSheet extends StatefulWidget {
  const ExpandableRideSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.onContinue,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  final double pickupLat;
  final double pickupLng;
  final ValueChanged<RideRequestDraft> onContinue;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  State<ExpandableRideSheet> createState() => _ExpandableRideSheetState();
}

class _ExpandableRideSheetState extends State<ExpandableRideSheet> {
  late final LocationSearchCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<LocationSearchCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ExpandableSheetBody(
        pickupLat: widget.pickupLat,
        pickupLng: widget.pickupLng,
        onContinue: widget.onContinue,
        isExpanded: widget.isExpanded,
        onToggleExpand: widget.onToggleExpand,
      ),
    );
  }
}
