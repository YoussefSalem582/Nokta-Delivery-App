import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/core/utils/demo_destinations.dart';
import 'package:delivery_app/features/home/ride_request/domain/entities/demo_place.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/shared/widgets/buttons/app_button.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class RequestRideSheet extends StatefulWidget {
  const RequestRideSheet({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    this.initialDropoff,
    this.initialDropoffKey,
  });

  final double pickupLat;
  final double pickupLng;
  final String? initialDropoff;
  final String? initialDropoffKey;

  @override
  State<RequestRideSheet> createState() => _RequestRideSheetState();
}

class _RequestRideSheetState extends State<RequestRideSheet> {
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;
  late final FocusNode _dropoffFocus;

  DemoPlace? _selectedPlace;
  List<DemoPlace> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'Current Location');
    _dropoffFocus = FocusNode()..addListener(_onDropoffFocusChanged);
    _dropoffController = TextEditingController(
      text: widget.initialDropoff ?? '',
    );

    if (widget.initialDropoffKey != null) {
      final initialPlace =
          DemoDestinations.placeForDestinationKey(widget.initialDropoffKey!);
      if (initialPlace != null) {
        _selectedPlace = initialPlace;
        _dropoffController.text = initialPlace.nameKey.tr();
      }
    }

    _dropoffController.addListener(_onDropoffTextChanged);
  }

  @override
  void dispose() {
    _dropoffController.removeListener(_onDropoffTextChanged);
    _dropoffFocus.removeListener(_onDropoffFocusChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _dropoffFocus.dispose();
    super.dispose();
  }

  void _onDropoffFocusChanged() {
    if (_dropoffFocus.hasFocus) {
      setState(() {
        _showSuggestions = true;
        _refreshSuggestions();
      });
    }
  }

  void _onDropoffTextChanged() {
    final selected = _selectedPlace;
    if (selected != null && _dropoffController.text != selected.nameKey.tr()) {
      _selectedPlace = null;
    }
    _refreshSuggestions();
  }

  void _refreshSuggestions() {
    setState(() {
      _suggestions = DemoDestinations.searchPlaces(
        _dropoffController.text,
        labelFor: (key) => key.tr(),
      );
      _showSuggestions = _dropoffFocus.hasFocus;
    });
  }

  void _selectPlace(DemoPlace place) {
    setState(() {
      _selectedPlace = place;
      _dropoffController.text = place.nameKey.tr();
      _showSuggestions = false;
    });
    _dropoffFocus.unfocus();
  }

  void _continue() {
    final place = _selectedPlace;
    if (place == null) return;

    final dropoff = DemoDestinations.nearPickup(
      pickupLat: widget.pickupLat,
      pickupLng: widget.pickupLng,
      key: place.destinationKey,
    );

    Navigator.of(context).pop(
      RideRequestDraft(
        pickupAddress: _pickupController.text,
        dropoffAddress: _dropoffController.text,
        pickupLat: widget.pickupLat,
        pickupLng: widget.pickupLng,
        dropoffLat: dropoff.latitude,
        dropoffLng: dropoff.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final hasQuery = _dropoffController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.elevationShadow,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppSheetHandle(),
                Text(
                  'request_ride_title'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                _LocationInputs(
                  pickupController: _pickupController,
                  dropoffController: _dropoffController,
                  dropoffFocus: _dropoffFocus,
                  onDropoffTap: () {
                    setState(() {
                      _showSuggestions = true;
                      _refreshSuggestions();
                    });
                  },
                ),
                if (_selectedPlace == null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'destination_select_hint'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                if (_showSuggestions) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _DestinationSuggestions(
                    suggestions: _suggestions,
                    hasQuery: hasQuery,
                    onSelect: _selectPlace,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'continue'.tr(),
                  usePrimaryContainer: true,
                  onPressed: _selectedPlace != null ? _continue : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DestinationSuggestions extends StatelessWidget {
  const _DestinationSuggestions({
    required this.suggestions,
    required this.hasQuery,
    required this.onSelect,
  });

  final List<DemoPlace> suggestions;
  final bool hasQuery;
  final ValueChanged<DemoPlace> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'destination_no_results'.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
          itemBuilder: (context, index) {
            final place = suggestions[index];
            return ListTile(
              leading: Icon(
                _iconForKey(place.iconKey),
                color: scheme.primary,
              ),
              title: Text(place.nameKey.tr()),
              subtitle: place.subtitleKey != null
                  ? Text(place.subtitleKey!.tr())
                  : null,
              onTap: () => onSelect(place),
            );
          },
        ),
      ),
    );
  }

  IconData _iconForKey(String key) => switch (key) {
        'home' => Icons.home_outlined,
        'work' => Icons.work_outline,
        'airport' => Icons.flight_takeoff,
        'mall' => Icons.storefront_outlined,
        'city' => Icons.location_city_outlined,
        'school' => Icons.school_outlined,
        'hospital' => Icons.local_hospital_outlined,
        _ => Icons.location_on_outlined,
      };
}

class _LocationInputs extends StatelessWidget {
  const _LocationInputs({
    required this.pickupController,
    required this.dropoffController,
    required this.dropoffFocus,
    required this.onDropoffTap,
  });

  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final FocusNode dropoffFocus;
  final VoidCallback onDropoffTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          left: 23,
          top: 40,
          bottom: 40,
          child: Container(
            width: 2,
            color: scheme.outlineVariant,
          ),
        ),
        Column(
          children: [
            _LocationRow(
              icon: Icons.trip_origin,
              iconColor: scheme.primary,
              controller: pickupController,
              hint: 'pickup'.tr(),
              readOnly: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            _LocationRow(
              icon: Icons.location_on,
              iconColor: scheme.error,
              controller: dropoffController,
              hint: 'dropoff'.tr(),
              focusNode: dropoffFocus,
              onTap: onDropoffTap,
              textInputAction: TextInputAction.search,
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
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.textInputAction,
  });

  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;
  final String hint;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Icon(icon, color: iconColor),
        ),
        Expanded(
          child: Container(
            height: AppSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onTap: onTap,
              textInputAction: textInputAction,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
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
