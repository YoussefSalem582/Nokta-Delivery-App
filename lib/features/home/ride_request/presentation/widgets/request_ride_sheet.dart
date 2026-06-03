import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestRideSheet extends StatelessWidget {
  const RequestRideSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    this.initialDropoff,
    this.initialDropoffQuery,
    this.hintMessageKey,
    this.initialActiveField,
  });

  final double pickupLat;
  final double pickupLng;
  final PlaceSuggestion? initialDropoff;
  final String? initialDropoffQuery;
  final String? hintMessageKey;
  final LocationSearchField? initialActiveField;

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return BlocProvider(
      create: (_) {
        final cubit = sl<LocationSearchCubit>();
        cubit.reverseGeocodePickup(
          lat: pickupLat,
          lng: pickupLng,
          languageCode: languageCode,
        );
        if (initialDropoffQuery != null && initialDropoffQuery!.trim().isNotEmpty) {
          cubit.searchImmediately(
            query: initialDropoffQuery!,
            biasLat: pickupLat,
            biasLng: pickupLng,
            languageCode: languageCode,
          );
        }
        if (initialActiveField != null) {
          cubit.setActiveField(initialActiveField!);
        }
        return cubit;
      },
      child: _RequestRideSheetBody(
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        initialDropoff: initialDropoff,
        initialDropoffQuery: initialDropoffQuery,
        hintMessageKey: hintMessageKey,
        initialActiveField: initialActiveField,
      ),
    );
  }
}

class _RequestRideSheetBody extends StatefulWidget {
  const _RequestRideSheetBody({
    required this.pickupLat,
    required this.pickupLng,
    this.initialDropoff,
    this.initialDropoffQuery,
    this.hintMessageKey,
    this.initialActiveField,
  });

  final double pickupLat;
  final double pickupLng;
  final PlaceSuggestion? initialDropoff;
  final String? initialDropoffQuery;
  final String? hintMessageKey;
  final LocationSearchField? initialActiveField;

  @override
  State<_RequestRideSheetBody> createState() => _RequestRideSheetBodyState();
}

class _RequestRideSheetBodyState extends State<_RequestRideSheetBody> {
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;
  late final FocusNode _pickupFocus;
  late final FocusNode _dropoffFocus;

  PlaceSuggestion? _selectedPickup;
  PlaceSuggestion? _selectedDropoff;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'current_location'.tr());
    _dropoffController = TextEditingController();
    _pickupFocus = FocusNode()..addListener(_onPickupFocusChanged);
    _dropoffFocus = FocusNode()..addListener(_onDropoffFocusChanged);

    if (widget.initialDropoff != null) {
      _selectedDropoff = widget.initialDropoff;
      _dropoffController.text = widget.initialDropoff!.displayAddress;
    } else if (widget.initialDropoffQuery != null) {
      _dropoffController.text = widget.initialDropoffQuery!;
    }

    _pickupController.addListener(_onPickupTextChanged);
    _dropoffController.addListener(_onDropoffTextChanged);
  }

  @override
  void dispose() {
    _pickupController.removeListener(_onPickupTextChanged);
    _dropoffController.removeListener(_onDropoffTextChanged);
    _pickupFocus.removeListener(_onPickupFocusChanged);
    _dropoffFocus.removeListener(_onDropoffFocusChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocus.dispose();
    _dropoffFocus.dispose();
    super.dispose();
  }

  String get _languageCode => context.locale.languageCode;

  double get _biasLat => _selectedPickup?.lat ?? widget.pickupLat;

  double get _biasLng => _selectedPickup?.lng ?? widget.pickupLng;

  void _onPickupFocusChanged() {
    if (_pickupFocus.hasFocus) {
      context.read<LocationSearchCubit>().setActiveField(LocationSearchField.pickup);
      setState(() => _showSuggestions = true);
      _refreshSearch(_pickupController.text);
    }
  }

  void _onDropoffFocusChanged() {
    if (_dropoffFocus.hasFocus) {
      context.read<LocationSearchCubit>().setActiveField(LocationSearchField.dropoff);
      setState(() => _showSuggestions = true);
      _refreshSearch(_dropoffController.text);
    }
  }

  void _onPickupTextChanged() {
    final selected = _selectedPickup;
    if (selected != null &&
        _pickupController.text != selected.displayAddress) {
      _selectedPickup = null;
    }
    if (_pickupFocus.hasFocus) {
      _refreshSearch(_pickupController.text);
    }
  }

  void _onDropoffTextChanged() {
    final selected = _selectedDropoff;
    if (selected != null &&
        _dropoffController.text != selected.displayAddress) {
      _selectedDropoff = null;
    }
    if (_dropoffFocus.hasFocus) {
      _refreshSearch(_dropoffController.text);
    }
  }

  void _refreshSearch(String query) {
    context.read<LocationSearchCubit>().search(
          query: query,
          biasLat: _biasLat,
          biasLng: _biasLng,
          languageCode: _languageCode,
        );
  }

  void _selectPlace(PlaceSuggestion place) {
    final activeField = context.read<LocationSearchCubit>().state.activeField;
    setState(() {
      if (activeField == LocationSearchField.pickup) {
        _selectedPickup = place;
        _pickupController.text = place.displayAddress;
        _pickupFocus.unfocus();
      } else {
        _selectedDropoff = place;
        _dropoffController.text = place.displayAddress;
        _dropoffFocus.unfocus();
      }
      _showSuggestions = false;
    });
    context.read<LocationSearchCubit>().clearSuggestions();
  }

  void _continue() {
    final pickup = _selectedPickup;
    final dropoff = _selectedDropoff;
    if (pickup == null || dropoff == null) return;

    Navigator.of(context).pop(
      RideRequestDraft(
        pickupAddress: pickup.displayAddress,
        dropoffAddress: dropoff.displayAddress,
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        dropoffLat: dropoff.lat,
        dropoffLng: dropoff.lng,
      ),
    );
  }

  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canContinue = _selectedPickup != null && _selectedDropoff != null;

    return BlocListener<LocationSearchCubit, LocationSearchState>(
      listenWhen: (prev, curr) =>
          prev.reverseGeocodedPickup != curr.reverseGeocodedPickup,
      listener: (context, state) {
        final pickup = state.reverseGeocodedPickup;
        if (pickup == null || _selectedPickup != null) return;
        setState(() {
          _selectedPickup = pickup;
          _pickupController.text = pickup.displayAddress;
        });
      },
      child: BlocListener<LocationSearchCubit, LocationSearchState>(
        listenWhen: (prev, curr) =>
            widget.initialDropoff == null &&
            widget.initialDropoffQuery != null &&
            prev.suggestions != curr.suggestions &&
            curr.suggestions.isNotEmpty &&
            curr.status == LocationSearchStatus.loaded,
        listener: (context, state) {
          if (_selectedDropoff != null) return;
          _selectPlace(state.suggestions.first);
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
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
                  const AppSheetHandle(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                    child: Text(
                      'request_ride_title'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _LocationInputs(
                            pickupController: _pickupController,
                            dropoffController: _dropoffController,
                            pickupFocus: _pickupFocus,
                            dropoffFocus: _dropoffFocus,
                            onPickupTap: () {
                              context
                                  .read<LocationSearchCubit>()
                                  .setActiveField(LocationSearchField.pickup);
                              setState(() {
                                _showSuggestions = true;
                                _refreshSearch(_pickupController.text);
                              });
                            },
                            onDropoffTap: () {
                              context
                                  .read<LocationSearchCubit>()
                                  .setActiveField(LocationSearchField.dropoff);
                              setState(() {
                                _showSuggestions = true;
                                _refreshSearch(_dropoffController.text);
                              });
                            },
                          ),
                          if (widget.hintMessageKey != null)
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.md),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, size: 18, color: scheme.primary),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      widget.hintMessageKey!.tr(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!canContinue && !_showSuggestions)
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
                          if (_showSuggestions) ...[
                            const SizedBox(height: AppSpacing.md),
                            BlocBuilder<LocationSearchCubit, LocationSearchState>(
                              builder: (context, searchState) {
                                final hasQuery = searchState.activeField ==
                                        LocationSearchField.pickup
                                    ? _pickupController.text.trim().isNotEmpty
                                    : _dropoffController.text.trim().isNotEmpty;
                                return _PlaceSuggestions(
                                  state: searchState,
                                  hasQuery: hasQuery,
                                  onSelect: _selectPlace,
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  if (!_showSuggestions || canContinue)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                      child: AppButton(
                        label: 'continue'.tr(),
                        usePrimaryContainer: true,
                        onPressed: canContinue ? _continue : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceSuggestions extends StatelessWidget {
  const _PlaceSuggestions({
    required this.state,
    required this.hasQuery,
    required this.onSelect,
  });

  final LocationSearchState state;
  final bool hasQuery;
  final ValueChanged<PlaceSuggestion> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (state.status == LocationSearchStatus.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          ),
        ),
      );
    }

    if (state.status == LocationSearchStatus.offline) {
      return _MessageText(
        icon: Icons.wifi_off,
        text: 'location_search_offline'.tr(),
        color: scheme.error,
      );
    }

    if (state.status == LocationSearchStatus.error) {
      return _MessageText(
        icon: Icons.error_outline,
        text: 'location_search_error'.tr(),
        color: scheme.error,
      );
    }

    if (!hasQuery) {
      return _MessageText(
        icon: Icons.search,
        text: 'location_search_type_hint'.tr(),
        color: scheme.onSurfaceVariant,
      );
    }

    if (state.status == LocationSearchStatus.empty || state.suggestions.isEmpty) {
      return _MessageText(
        icon: Icons.location_off_outlined,
        text: 'destination_no_results'.tr(),
        color: scheme.onSurfaceVariant,
      );
    }

    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: scheme.shadow.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: state.suggestions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 56,
                  color: scheme.outlineVariant.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, index) {
                  final place = state.suggestions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    leading: CircleAvatar(
                      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: scheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      place.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: place.subtitle.isNotEmpty
                        ? Text(
                            place.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          )
                        : null,
                    onTap: () => onSelect(place),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: scheme.surfaceContainerLowest,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                'location_osm_attribution'.tr(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  const _MessageText({required this.text, required this.color, required this.icon});

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LocationInputs extends StatelessWidget {
  const _LocationInputs({
    required this.pickupController,
    required this.dropoffController,
    required this.pickupFocus,
    required this.dropoffFocus,
    required this.onPickupTap,
    required this.onDropoffTap,
  });

  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final FocusNode pickupFocus;
  final FocusNode dropoffFocus;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          left: 23,
          top: AppSpacing.inputHeight / 2 + 8,
          bottom: AppSpacing.inputHeight / 2 + 8,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Column(
          children: [
            _LocationRow(
              icon: Icons.radio_button_checked,
              iconColor: scheme.primary,
              controller: pickupController,
              hint: 'pickup_search_hint'.tr(),
              focusNode: pickupFocus,
              onTap: onPickupTap,
              textInputAction: TextInputAction.next,
              isFocused: pickupFocus.hasFocus,
            ),
            const SizedBox(height: AppSpacing.md),
            _LocationRow(
              icon: Icons.location_on,
              iconColor: scheme.error,
              controller: dropoffController,
              hint: 'dropoff_search_hint'.tr(),
              focusNode: dropoffFocus,
              onTap: onDropoffTap,
              textInputAction: TextInputAction.search,
              isFocused: dropoffFocus.hasFocus,
            ),
          ],
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.controller,
    required this.hint,
    required this.focusNode,
    required this.onTap,
    required this.textInputAction,
    required this.isFocused,
  });

  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final TextInputAction textInputAction;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Icon(icon, color: isFocused ? iconColor : scheme.onSurfaceVariant, size: 20),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: AppSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isFocused ? scheme.surface : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isFocused ? scheme.primary : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: onTap,
              textInputAction: textInputAction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isFocused ? FontWeight.w500 : FontWeight.normal,
                  ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
