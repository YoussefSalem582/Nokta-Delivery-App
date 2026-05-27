import 'package:delivery_app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoadingRing extends StatelessWidget {
  const AppLoadingRing({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation(AppColors.primaryContainer),
      ),
    );
  }
}
