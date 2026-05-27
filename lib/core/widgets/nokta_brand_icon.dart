import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';

class NoktaBrandIcon extends StatelessWidget {
  const NoktaBrandIcon({
    super.key,
    this.size = 64,
    this.filled = true,
  });

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (filled) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: NoktaColors.elevationShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.directions_car,
          size: size * 0.5,
          color: scheme.onPrimaryContainer,
        ),
      );
    }

    return Icon(
      Icons.directions_car,
      size: size,
      color: scheme.primary,
    );
  }
}
