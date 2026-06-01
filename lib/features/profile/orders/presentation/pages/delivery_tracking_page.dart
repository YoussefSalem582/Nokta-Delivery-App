import 'package:delivery_app/features/profile/orders/presentation/bloc/delivery_tracking_bloc.dart';
import 'package:delivery_app/features/profile/orders/presentation/pages/delivery_live_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeliveryTrackingPage extends StatelessWidget {
  const DeliveryTrackingPage({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return DeliveryLiveTrackingPage(
      deliveryId: deliveryId,
      role: DeliveryTrackingRole.customer,
      onBack: () => context.pop(),
    );
  }
}
