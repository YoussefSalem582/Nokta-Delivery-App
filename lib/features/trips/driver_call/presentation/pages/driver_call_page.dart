import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/features/trips/driver_call/presentation/bloc/driver_call_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DriverCallPage extends StatelessWidget {
  const DriverCallPage({super.key, required this.tripId});

  final String tripId;

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriverCallBloc>()..add(DriverCallStarted(tripId)),
      child: BlocConsumer<DriverCallBloc, DriverCallState>(
        listenWhen: (_, current) => current is DriverCallEndedState,
        listener: (context, state) => context.pop(),
        builder: (context, state) {
          final scheme = Theme.of(context).colorScheme;

          if (state is DriverCallLoading || state is DriverCallInitial) {
            return Scaffold(
              backgroundColor: scheme.surfaceContainerLowest,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is DriverCallError) {
            return Scaffold(
              backgroundColor: scheme.surfaceContainerLowest,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                ),
                title: Text('call_title'.tr()),
              ),
              body: ErrorView(
                message: state.message.tr(),
                onRetry: () => context.read<DriverCallBloc>().add(
                      DriverCallStarted(tripId),
                    ),
              ),
            );
          }

          if (state is DriverCallConnecting ||
              state is DriverCallActive) {
            final trip = state is DriverCallConnecting
                ? state.trip
                : (state as DriverCallActive).trip;
            final isMuted = state is DriverCallConnecting
                ? state.isMuted
                : (state as DriverCallActive).isMuted;
            final isSpeakerOn = state is DriverCallConnecting
                ? state.isSpeakerOn
                : (state as DriverCallActive).isSpeakerOn;
            final driverName = trip.driverName ?? 'driver'.tr();
            final statusText = state is DriverCallConnecting
                ? 'call_connecting'.tr()
                : '${'call_active'.tr()} • ${_formatDuration((state as DriverCallActive).elapsedSeconds)}';

            return Scaffold(
              backgroundColor: scheme.surfaceContainerLowest,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.read<DriverCallBloc>().add(
                                const DriverCallEnded(),
                              ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.35),
                            width: 3,
                          ),
                        ),
                        child: AvatarImage(
                          imageUrl: trip.driverAvatarUrl,
                          fallback: driverName,
                          radius: 56,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        driverName,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CallControlButton(
                            icon: isMuted ? Icons.mic_off : Icons.mic,
                            label: 'call_mute'.tr(),
                            isActive: isMuted,
                            onPressed: () => context.read<DriverCallBloc>().add(
                                  const DriverCallMuteToggled(),
                                ),
                          ),
                          _CallControlButton(
                            icon: Icons.call_end,
                            label: 'call_end'.tr(),
                            isDestructive: true,
                            onPressed: () => context.read<DriverCallBloc>().add(
                                  const DriverCallEnded(),
                                ),
                          ),
                          _CallControlButton(
                            icon: isSpeakerOn
                                ? Icons.volume_up
                                : Icons.volume_off,
                            label: 'call_speaker'.tr(),
                            isActive: isSpeakerOn,
                            onPressed: () => context.read<DriverCallBloc>().add(
                                  const DriverCallSpeakerToggled(),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = isDestructive
        ? AppColors.error
        : isActive
            ? scheme.primaryContainer
            : scheme.surfaceContainerHigh;
    final foreground = isDestructive
        ? AppColors.onError
        : isActive
            ? scheme.onPrimaryContainer
            : scheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(icon, color: foreground, size: 28),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
