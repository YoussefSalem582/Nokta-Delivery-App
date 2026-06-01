import 'package:delivery_app/features/profile/orders/presentation/bloc/delivery_tracking_bloc.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryNavigationActions extends StatelessWidget {
  const DeliveryNavigationActions({
    super.key,
    required this.active,
    required this.deliveryId,
  });

  final DeliveryTrackingActive active;
  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DeliveryTrackingBloc>();
    final hasAction = active.canMarkPickedUp ||
        active.canStartTransit ||
        active.canMarkDelivered;
    if (!hasAction) return const SizedBox.shrink();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(
            alpha: 0.92,
          ),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            if (active.canMarkPickedUp)
              Expanded(
                child: AppButton(
                  label: 'delivery_mark_picked_up'.tr(),
                  loading: active.isUpdating,
                  onPressed: active.isUpdating
                      ? null
                      : () => bloc.add(
                            DeliveryTrackingStatusRequested(
                              deliveryId: deliveryId,
                              status: OrderStatus.pickedUp,
                            ),
                          ),
                ),
              ),
            if (active.canStartTransit) ...[
              if (active.canMarkPickedUp)
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'delivery_start_transit'.tr(),
                  loading: active.isUpdating,
                  onPressed: active.isUpdating
                      ? null
                      : () => bloc.add(
                            DeliveryTrackingStatusRequested(
                              deliveryId: deliveryId,
                              status: OrderStatus.inTransit,
                            ),
                          ),
                ),
              ),
            ],
            if (active.canMarkDelivered) ...[
              if (active.canMarkPickedUp || active.canStartTransit)
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'delivery_mark_delivered'.tr(),
                  loading: active.isUpdating,
                  onPressed: active.isUpdating
                      ? null
                      : () => bloc.add(
                            DeliveryTrackingStatusRequested(
                              deliveryId: deliveryId,
                              status: OrderStatus.delivered,
                            ),
                          ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
