import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/features/home/ride_request/domain/entities/quick_destination_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'quick_destination_chips.dart';

class CollapsedRideView extends StatelessWidget {
  const CollapsedRideView({
    super.key,
    required this.onSearchTap,
    required this.onQuickDestination,
  });

  final VoidCallback onSearchTap;
  final ValueChanged<QuickDestinationType> onQuickDestination;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
          border: isDark
              ? Border(top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)))
              : null,
          boxShadow: isDark
              ? null
              : [
                  const BoxShadow(
                    color: AppColors.elevationShadow,
                    blurRadius: 24,
                    offset: Offset(0, -4),
                  ),
                ],
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSheetHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Text(
                'request_ride_title'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onSearchTap,
                child: Container(
                  height: AppSpacing.inputHeight + 4,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: scheme.primary, size: 24),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'search_locations'.tr(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  QuickChip(
                    icon: Icons.home_outlined,
                    label: 'quick_home'.tr(),
                    onTap: () => onQuickDestination(QuickDestinationType.home),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  QuickChip(
                    icon: Icons.work_outline,
                    label: 'quick_work'.tr(),
                    onTap: () => onQuickDestination(QuickDestinationType.work),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  QuickChip(
                    icon: Icons.flight_takeoff,
                    label: 'quick_airport'.tr(),
                    onTap: () => onQuickDestination(QuickDestinationType.airport),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
