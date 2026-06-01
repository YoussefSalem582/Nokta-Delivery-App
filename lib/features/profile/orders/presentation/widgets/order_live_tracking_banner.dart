import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderLiveTrackingBanner extends StatelessWidget {
  const OrderLiveTrackingBanner({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    if (!order.isTrackableByCustomer || !order.hasRouteCoordinates) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        leading: Icon(Icons.local_shipping_outlined, color: scheme.primary),
        title: Text('order_inTransit'.tr()),
        subtitle: Text(order.title),
        trailing: FilledButton(
          onPressed: () => context.pushNamed(
            RouteNames.deliveryTracking,
            pathParameters: {'deliveryId': order.id},
          ),
          child: Text('track_delivery'.tr()),
        ),
      ),
    );
  }
}
