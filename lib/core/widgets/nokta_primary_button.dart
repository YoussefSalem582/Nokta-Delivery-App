import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';

class NoktaPrimaryButton extends StatelessWidget {
  const NoktaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.usePrimaryContainer = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool usePrimaryContainer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = usePrimaryContainer ? scheme.primaryContainer : scheme.primary;
    final fg = usePrimaryContainer ? scheme.onPrimary : scheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      height: NoktaSpacing.buttonHeight,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.6),
          disabledForegroundColor: fg.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          ),
          elevation: 0,
          shadowColor: NoktaColors.elevationShadow,
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: fg,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: fg,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
