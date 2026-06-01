import 'dart:async';

import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/realtime/delivery_location_update.dart';
import 'package:delivery_app/core/realtime/realtime_location_service.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OrderLiveTrackingBanner extends StatefulWidget {
  const OrderLiveTrackingBanner({super.key, required this.order});

  final OrderEntity order;

  @override
  State<OrderLiveTrackingBanner> createState() =>
      _OrderLiveTrackingBannerState();
}

class _OrderLiveTrackingBannerState extends State<OrderLiveTrackingBanner> {
  StreamSubscription<DeliveryLocationUpdate>? _subscription;
  DeliveryLocationUpdate? _latest;

  @override
  void initState() {
    super.initState();
    if (EnvConfig.usesRealBackend &&
        widget.order.status == OrderStatus.inTransit) {
      _subscription = sl<RealtimeLocationService>()
          .watchDelivery(widget.order.id)
          .listen((update) {
        if (!mounted) return;
        setState(() => _latest = update);
      });
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!EnvConfig.usesRealBackend ||
        widget.order.status != OrderStatus.inTransit) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final subtitle = _latest == null
        ? 'order_inTransit'.tr()
        : '${_latest!.lat.toStringAsFixed(4)}, ${_latest!.lng.toStringAsFixed(4)}';

    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        leading: Icon(Icons.local_shipping_outlined, color: scheme.primary),
        title: Text('order_inTransit'.tr()),
        subtitle: Text(subtitle),
      ),
    );
  }
}
