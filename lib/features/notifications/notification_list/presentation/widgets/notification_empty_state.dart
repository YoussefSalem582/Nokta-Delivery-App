import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({
    super.key,
    required this.categoryFilter,
    this.unreadOnly = false,
  });

  final NotificationCategoryFilter categoryFilter;
  final bool unreadOnly;

  String get _titleKey {
    if (unreadOnly) return 'notifications_empty_unread';
    return switch (categoryFilter) {
      NotificationCategoryFilter.trips => 'notifications_empty_trips',
      NotificationCategoryFilter.messages => 'notifications_empty_messages',
      NotificationCategoryFilter.calls => 'notifications_empty_calls',
      NotificationCategoryFilter.all => 'no_notifications',
    };
  }

  String? get _subtitleKey {
    if (unreadOnly || categoryFilter != NotificationCategoryFilter.all) {
      return null;
    }
    return 'notifications_empty_subtitle';
  }

  IconData get _icon {
    if (unreadOnly) return Icons.mark_email_read_outlined;
    return switch (categoryFilter) {
      NotificationCategoryFilter.trips => Icons.directions_car_outlined,
      NotificationCategoryFilter.messages => Icons.chat_bubble_outline,
      NotificationCategoryFilter.calls => Icons.phone_in_talk_outlined,
      NotificationCategoryFilter.all => Icons.notifications_none_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = NotificationTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.emptyIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon,
                size: 64,
                color: theme.emptyIconTint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _titleKey.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: theme.titleColor(isRead: false),
                  ),
              textAlign: TextAlign.center,
            ),
            if (_subtitleKey != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _subtitleKey!.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
