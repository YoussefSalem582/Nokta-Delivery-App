import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.categoryFilter,
    required this.unreadOnly,
    required this.unreadCount,
  });

  final NotificationCategoryFilter categoryFilter;
  final bool unreadOnly;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = NotificationTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.filterBarBackground,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: theme.filterBarBorderAlpha,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _CategoryChip(
                label: 'notifications_filter_all'.tr(),
                selected: categoryFilter == NotificationCategoryFilter.all,
                onSelected: () => _setCategory(
                  context,
                  NotificationCategoryFilter.all,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CategoryChip(
                label: 'notifications_filter_trip'.tr(),
                selected: categoryFilter == NotificationCategoryFilter.trips,
                onSelected: () => _setCategory(
                  context,
                  NotificationCategoryFilter.trips,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CategoryChip(
                label: 'notifications_filter_messages'.tr(),
                selected: categoryFilter == NotificationCategoryFilter.messages,
                onSelected: () => _setCategory(
                  context,
                  NotificationCategoryFilter.messages,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _CategoryChip(
                label: 'notifications_filter_calls'.tr(),
                selected: categoryFilter == NotificationCategoryFilter.calls,
                onSelected: () => _setCategory(
                  context,
                  NotificationCategoryFilter.calls,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilterChip(
                label: Text(
                  unreadCount > 0
                      ? '${'notifications_filter_unread_only'.tr()} ($unreadCount)'
                      : 'notifications_filter_unread_only'.tr(),
                ),
                selected: unreadOnly,
                onSelected: (selected) {
                  context.read<NotificationBloc>().add(
                        NotificationUnreadOnlyToggled(selected),
                      );
                },
                showCheckmark: true,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setCategory(BuildContext context, NotificationCategoryFilter category) {
    context.read<NotificationBloc>().add(NotificationCategoryChanged(category));
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: true,
      visualDensity: VisualDensity.compact,
      selectedColor: scheme.primary.withValues(alpha: 0.2),
      checkmarkColor: scheme.primary,
      labelStyle: TextStyle(
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
