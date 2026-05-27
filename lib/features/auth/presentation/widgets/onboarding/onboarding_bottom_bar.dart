import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/features/auth/presentation/widgets/onboarding/onboarding_page_dots.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Dots, primary CTA (Next / Get Started), and optional sign-in link.
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.pageCount,
    required this.activeIndex,
    required this.isLastPage,
    required this.onNext,
    required this.onFinish,
    this.onSignIn,
  });

  final int pageCount;
  final int activeIndex;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NoktaSpacing.lg,
        NoktaSpacing.md,
        NoktaSpacing.lg,
        NoktaSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OnboardingPageDots(
            count: pageCount,
            activeIndex: activeIndex,
          ),
          const SizedBox(height: NoktaSpacing.lg),
          NoktaPrimaryButton(
            label: isLastPage ? 'get_started'.tr() : 'onboarding_next'.tr(),
            icon: isLastPage ? Icons.arrow_forward_rounded : null,
            onPressed: isLastPage ? onFinish : onNext,
          ),
          if (isLastPage && onSignIn != null) ...[
            const SizedBox(height: NoktaSpacing.md),
            TextButton(
              onPressed: onSignIn,
              child: Text(
                'onboarding_sign_in'.tr(),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
