import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/utils/date_time_format.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/chat_message_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDriver = message.isFromDriver;
    final time = formatAppClockTime(message.sentAt);

    final bubbleColor = isDriver
        ? scheme.surfaceContainerHigh
        : scheme.primaryContainer;
    final textColor = isDriver ? scheme.onSurface : scheme.onPrimaryContainer;

    return Align(
      alignment: isDriver ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppSpacing.radiusMd),
              topRight: const Radius.circular(AppSpacing.radiusMd),
              bottomLeft: Radius.circular(isDriver ? 4 : AppSpacing.radiusMd),
              bottomRight: Radius.circular(isDriver ? AppSpacing.radiusMd : 4),
            ),
            boxShadow: isDriver
                ? null
                : const [
                    BoxShadow(
                      color: AppColors.elevationShadow,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
