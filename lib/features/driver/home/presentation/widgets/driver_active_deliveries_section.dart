import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/active_delivery/presentation/pages/driver_active_delivery_page.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/profile/shared/domain/repositories/order_repository.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/feedback/section_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class DriverActiveDeliveriesSection extends StatefulWidget {
  const DriverActiveDeliveriesSection({super.key});

  @override
  State<DriverActiveDeliveriesSection> createState() =>
      _DriverActiveDeliveriesSectionState();
}

class _DriverActiveDeliveriesSectionState
    extends State<DriverActiveDeliveriesSection> {
  List<OrderEntity> _deliveries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      setState(() => _loading = false);
      return;
    }

    try {
      final list =
          await sl<OrderRepository>().getDeliveriesForCourier(auth.user.id);
      if (!mounted) return;
      setState(() {
        _deliveries = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDelivery(String deliveryId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => DriverActiveDeliveryPage(deliveryId: deliveryId),
          ),
        )
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_deliveries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'driver_active_delivery'.tr()),
        ..._deliveries.map(
          (order) => Card(
            child: ListTile(
              title: Text(order.title),
              subtitle: Text(order.status.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDelivery(order.id),
            ),
          ),
        ),
      ],
    );
  }
}
