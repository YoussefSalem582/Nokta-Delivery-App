import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'location_inputs.dart';
import 'place_suggestions_list.dart';

class ExpandedRideView extends StatelessWidget {
  const ExpandedRideView({
    super.key,
    required this.pickupController,
    required this.dropoffController,
    required this.pickupFocus,
    required this.dropoffFocus,
    required this.onPickupTap,
    required this.onDropoffTap,
    required this.onClose,
    required this.onContinue,
    required this.onSelectPlace,
    required this.canContinue,
    required this.showSuggestions,
    this.hintMessageKey,
  });

  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final FocusNode pickupFocus;
  final FocusNode dropoffFocus;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final VoidCallback onClose;
  final VoidCallback onContinue;
  final ValueChanged<PlaceSuggestion> onSelectPlace;
  final bool canContinue;
  final bool showSuggestions;
  final String? hintMessageKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusSheet),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.elevationShadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: Column(
                children: [
                  const AppSheetHandle(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'request_ride_title'.tr(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LocationInputs(
                      pickupController: pickupController,
                      dropoffController: dropoffController,
                      pickupFocus: pickupFocus,
                      dropoffFocus: dropoffFocus,
                      onPickupTap: onPickupTap,
                      onDropoffTap: onDropoffTap,
                    ),
                    if (hintMessageKey != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline, size: 18, color: scheme.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                hintMessageKey!.tr(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!canContinue && !showSuggestions)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'location_select_both_hint'.tr(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (showSuggestions) ...[
                      const SizedBox(height: AppSpacing.md),
                      BlocBuilder<LocationSearchCubit, LocationSearchState>(
                        builder: (context, searchState) {
                          final hasQuery = searchState.activeField == LocationSearchField.pickup
                              ? pickupController.text.trim().isNotEmpty
                              : dropoffController.text.trim().isNotEmpty;
                          return PlaceSuggestionsList(
                            state: searchState,
                            hasQuery: hasQuery,
                            onSelect: onSelectPlace,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            if (!showSuggestions || canContinue)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: AppButton(
                  label: 'continue'.tr(),
                  usePrimaryContainer: true,
                  onPressed: canContinue ? onContinue : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
