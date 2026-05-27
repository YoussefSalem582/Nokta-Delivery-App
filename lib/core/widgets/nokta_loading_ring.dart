import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';

class NoktaLoadingRing extends StatelessWidget {
  const NoktaLoadingRing({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        backgroundColor: NoktaColors.primaryContainer.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation(NoktaColors.primaryContainer),
      ),
    );
  }
}
