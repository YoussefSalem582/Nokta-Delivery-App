import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestRideSheet extends StatefulWidget {
  const RequestRideSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
  });

  final double pickupLat;
  final double pickupLng;

  @override
  State<RequestRideSheet> createState() => _RequestRideSheetState();
}

class _RequestRideSheetState extends State<RequestRideSheet> {
  final _pickupController =
      TextEditingController(text: 'Current Location');
  final _dropoffController = TextEditingController(text: 'City Mall');

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: BlocConsumer<RequestRideBloc, RequestRideState>(
        listener: (context, state) {
          if (state is RequestRideSuccess) {
            Navigator.of(context).pop(state.trip);
          } else if (state is RequestRideError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is RequestRideLoading;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'request_ride_title'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pickupController,
                  decoration: InputDecoration(
                    labelText: 'pickup'.tr(),
                    prefixIcon: const Icon(Icons.trip_origin),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dropoffController,
                  decoration: InputDecoration(
                    labelText: 'dropoff'.tr(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: loading
                      ? null
                      : () {
                          context.read<RequestRideBloc>().add(
                                RequestRideSubmitted(
                                  pickupAddress: _pickupController.text,
                                  dropoffAddress: _dropoffController.text,
                                  pickupLat: widget.pickupLat,
                                  pickupLng: widget.pickupLng,
                                  dropoffLat: AppConstants.defaultDropoffLat,
                                  dropoffLng: AppConstants.defaultDropoffLng,
                                ),
                              );
                        },
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('confirm_ride'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
