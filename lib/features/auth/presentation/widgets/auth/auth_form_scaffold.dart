import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';

class AuthFormDotBackground extends StatelessWidget {
  const AuthFormDotBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _AuthDotPatternPainter(
            color: scheme.primary.withValues(alpha: 0.03),
          ),
        ),
      ),
    );
  }
}

class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.appBar,
    required this.form,
  });

  final PreferredSizeWidget appBar;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: appBar,
      body: Stack(
        children: [
          const AuthFormDotBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NoktaSpacing.md),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: form,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthDotPatternPainter extends CustomPainter {
  _AuthDotPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 16.0;
    const radius = 1.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
