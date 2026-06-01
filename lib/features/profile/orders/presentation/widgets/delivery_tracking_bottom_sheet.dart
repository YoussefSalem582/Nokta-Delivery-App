import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/features/profile/orders/presentation/bloc/delivery_tracking_bloc.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeliveryTrackingBottomSheet extends StatelessWidget {
  const DeliveryTrackingBottomSheet({super.key, required this.active});

  final DeliveryTrackingActive active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: AppColors.elevationShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'delivery_tracking_title'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${active.etaMinutes} ${'minutes'.tr()}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            '${active.remainingDistanceKm.toStringAsFixed(1)} km',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          if (active.order.dropoffAddress != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              active.order.dropoffAddress!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
