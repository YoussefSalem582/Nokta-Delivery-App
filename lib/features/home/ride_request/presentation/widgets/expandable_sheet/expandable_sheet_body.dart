import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_cubit.dart';
import 'package:delivery_app/features/home/ride_request/presentation/cubit/location_search_state.dart';
import 'package:delivery_app/features/home/shared/domain/entities/place_suggestion.dart';
import 'package:delivery_app/features/home/shared/data/datasources/saved_places_local_datasource.dart';
import 'package:delivery_app/features/home/ride_request/domain/entities/quick_destination_type.dart';
import 'package:delivery_app/features/home/ride_request/presentation/widgets/ride_option_card.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'collapsed_ride_view.dart';
import 'expanded_ride_view.dart';

class ExpandableSheetBody extends StatefulWidget {
  const ExpandableSheetBody({
    super.key,
    required this.pickupLat,
    required this.pickupLng,
    required this.onContinue,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  final double pickupLat;
  final double pickupLng;
  final ValueChanged<RideRequestDraft> onContinue;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  @override
  State<ExpandableSheetBody> createState() => _ExpandableSheetBodyState();
}

class _ExpandableSheetBodyState extends State<ExpandableSheetBody> {
  late final TextEditingController _pickupController;
  late final TextEditingController _dropoffController;
  late final FocusNode _pickupFocus;
  late final FocusNode _dropoffFocus;

  PlaceSuggestion? _selectedPickup;
  PlaceSuggestion? _selectedDropoff;
  bool _showSuggestions = false;
  String? _hintMessageKey;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'current_location'.tr());
    _dropoffController = TextEditingController();
    _pickupFocus = FocusNode()..addListener(_onPickupFocusChanged);
    _dropoffFocus = FocusNode()..addListener(_onDropoffFocusChanged);

    _pickupController.addListener(_onPickupTextChanged);
    _dropoffController.addListener(_onDropoffTextChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LocationSearchCubit>().reverseGeocodePickup(
          lat: widget.pickupLat,
          lng: widget.pickupLng,
          languageCode: context.locale.languageCode,
        );
      }
    });
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
    if (selected != null && _pickupController.text != selected.displayAddress) {
      _selectedPickup = null;
    }
    if (_pickupFocus.hasFocus) {
      _refreshSearch(_pickupController.text);
    }
  }

  void _onDropoffTextChanged() {
    final selected = _selectedDropoff;
    if (selected != null && _dropoffController.text != selected.displayAddress) {
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
        context.read<LocationSearchCubit>().setActiveField(LocationSearchField.dropoff);
        _dropoffFocus.requestFocus();
      } else {
        _selectedDropoff = place;
        _dropoffController.text = place.displayAddress;
        _dropoffFocus.unfocus();
      }
      _showSuggestions = false;
    });
    context.read<LocationSearchCubit>().clearSuggestions();
  }

  PlaceSuggestion? get _effectivePickup {
    if (_selectedPickup != null) return _selectedPickup;
    if (_pickupController.text == 'current_location'.tr() || _pickupController.text.isEmpty) {
      return PlaceSuggestion(
        id: 'current_location',
        title: _pickupController.text.isNotEmpty ? _pickupController.text : 'current_location'.tr(),
        subtitle: '',
        lat: widget.pickupLat,
        lng: widget.pickupLng,
      );
    }
    return null;
  }

  void _continue() {
    final pickup = _effectivePickup;
    final dropoff = _selectedDropoff;
    if (pickup == null || dropoff == null) return;

    widget.onContinue(
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

  void _handleQuickDestination(QuickDestinationType quickDestination) {
    PlaceSuggestion? dropoff;
    String? dropoffQuery;
    String? hint;

    switch (quickDestination) {
      case QuickDestinationType.home:
        final saved = sl<SavedPlacesLocalDataSource>().getHome();
        if (saved != null) {
          dropoff = PlaceSuggestion(
            id: 'saved_home',
            title: saved.address ?? 'quick_home'.tr(),
            subtitle: '',
            lat: saved.lat,
            lng: saved.lng,
          );
        } else {
          hint = 'saved_place_missing_home';
        }
      case QuickDestinationType.work:
        final saved = sl<SavedPlacesLocalDataSource>().getWork();
        if (saved != null) {
          dropoff = PlaceSuggestion(
            id: 'saved_work',
            title: saved.address ?? 'quick_work'.tr(),
            subtitle: '',
            lat: saved.lat,
            lng: saved.lng,
          );
        } else {
          hint = 'saved_place_missing_work';
        }
      case QuickDestinationType.airport:
        dropoffQuery = 'place_airport_search_query'.tr();
    }

    widget.onToggleExpand();
    context.read<LocationSearchCubit>().setActiveField(LocationSearchField.dropoff);
    
    setState(() {
      _hintMessageKey = hint;
      if (dropoff != null) {
        _selectedDropoff = dropoff;
        _dropoffController.text = dropoff.displayAddress;
      } else if (dropoffQuery != null && dropoffQuery.trim().isNotEmpty) {
        _dropoffController.text = dropoffQuery;
        _dropoffFocus.requestFocus();
      } else {
        _dropoffFocus.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocListener<LocationSearchCubit, LocationSearchState>(
      listenWhen: (prev, curr) => prev.reverseGeocodedPickup != curr.reverseGeocodedPickup,
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
            _selectedDropoff == null &&
            _dropoffController.text.isNotEmpty &&
            prev.suggestions != curr.suggestions &&
            curr.suggestions.isNotEmpty &&
            curr.status == LocationSearchStatus.loaded,
        listener: (context, state) {
          if (_selectedDropoff != null) return;
          if (_dropoffFocus.hasFocus && _dropoffController.text == 'place_airport_search_query'.tr()) {
            _selectPlace(state.suggestions.first);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 450),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              reverseDuration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeInQuart,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ...previousChildren.map((child) => Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: child,
                        )),
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: widget.isExpanded 
                  ? ExpandedRideView(
                      key: const ValueKey('expanded_view'),
                      pickupController: _pickupController,
                      dropoffController: _dropoffController,
                      pickupFocus: _pickupFocus,
                      dropoffFocus: _dropoffFocus,
                      onPickupTap: () {
                        context.read<LocationSearchCubit>().setActiveField(LocationSearchField.pickup);
                        setState(() {
                          _showSuggestions = true;
                          _refreshSearch(_pickupController.text);
                        });
                      },
                      onDropoffTap: () {
                        context.read<LocationSearchCubit>().setActiveField(LocationSearchField.dropoff);
                        setState(() {
                          _showSuggestions = true;
                          _refreshSearch(_dropoffController.text);
                        });
                      },
                      onClose: () {
                        _pickupFocus.unfocus();
                        _dropoffFocus.unfocus();
                        widget.onToggleExpand();
                      },
                      onContinue: _continue,
                      onSelectPlace: _selectPlace,
                      canContinue: _effectivePickup != null && _selectedDropoff != null,
                      showSuggestions: _showSuggestions,
                      hintMessageKey: _hintMessageKey,
                    )
                  : CollapsedRideView(
                      key: const ValueKey('collapsed_view'),
                      onSearchTap: () {
                        widget.onToggleExpand();
                        _dropoffFocus.requestFocus();
                      },
                      onQuickDestination: _handleQuickDestination,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
