import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/features/home/map_view/presentation/bloc/map_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RideSelectionSheet extends StatefulWidget {
  const RideSelectionSheet({super.key, required this.draft});

  final RideRequestDraft draft;

  @override
  State<RideSelectionSheet> createState() => _RideSelectionSheetState();
}

class _RideSelectionSheetState extends State<RideSelectionSheet> {
  final _options = RideOption.defaults();
  RideTier _selected = RideTier.economy;

  RideOption get _selectedOption =>
      _options.firstWhere((o) => o.tier == _selected);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: BlocConsumer<RequestRideBloc, RequestRideState>(
          listener: (context, state) {
            if (state is RequestRideSuccess) {
              Navigator.of(context).pop(state.trip);
            } else if (state is RequestRideError) {
              AppToast.error(context, state.message);
            }
          },
          builder: (context, state) {
            final loading = state is RequestRideLoading;

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSheetHandle(),
                    ..._options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: RideOptionCard(
                          option: option,
                          selected: _selected == option.tier,
                          onTap: () => setState(() => _selected = option.tier),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentChip(
                            label: 'payment_card'.tr(),
                            icon: Icons.credit_card,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _PaymentChip(
                          label: 'promo'.tr(),
                          icon: null,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'confirm_ride_tier'.tr(
                        args: [_selectedOption.nameKey.tr()],
                      ),
                      loading: loading,
                      onPressed: () {
                        context.read<RequestRideBloc>().add(
                              RequestRideSubmitted(
                                pickupAddress: widget.draft.pickupAddress,
                                dropoffAddress: widget.draft.dropoffAddress,
                                pickupLat: widget.draft.pickupLat,
                                pickupLng: widget.draft.pickupLng,
                                dropoffLat: widget.draft.dropoffLat,
                                dropoffLng: widget.draft.dropoffLng,
                              ),
                            );
                      },
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    this.icon,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: compact ? scheme.primary : scheme.onSurface,
        );

    if (compact) {
      return Container(
        height: AppSpacing.buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Center(
          child: Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Container(
      height: AppSpacing.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
