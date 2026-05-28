import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Compact user identity card (driver profile tab and similar surfaces).
class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    required this.user,
    this.showPhone = true,
  });

  final UserEntity user;
  final bool showPhone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          AvatarImage(
            imageUrl: user.avatarUrl,
            fallback: user.name,
            radius: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                if (showPhone && user.phone.isNotEmpty)
                  Text(
                    user.phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
