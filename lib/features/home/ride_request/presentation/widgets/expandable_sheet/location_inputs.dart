import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocationInputs extends StatelessWidget {
  const LocationInputs({
    super.key,
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
            LocationRow(
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
            LocationRow(
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

class LocationRow extends StatelessWidget {
  const LocationRow({
    super.key,
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
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
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
