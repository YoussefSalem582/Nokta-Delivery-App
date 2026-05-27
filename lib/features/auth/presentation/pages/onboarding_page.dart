import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/features/auth/presentation/models/onboarding_slide_data.dart';
import 'package:delivery_app/features/auth/presentation/widgets/onboarding/onboarding_background.dart';
import 'package:delivery_app/features/auth/presentation/widgets/onboarding/onboarding_bottom_bar.dart';
import 'package:delivery_app/features/auth/presentation/widgets/onboarding/onboarding_slide_content.dart';
import 'package:delivery_app/features/auth/presentation/widgets/onboarding/onboarding_top_bar.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  int get _pageCount => kOnboardingSlides.length;
  bool get _isLastPage => _currentPage >= _pageCount - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _goToAuthChoice() {
    context.router.replace(const AuthChoiceRoute());
  }

  void _goNext() {
    if (_isLastPage) {
      _goToAuthChoice();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(),
          SafeArea(
            child: Column(
              children: [
                OnboardingTopBar(
                  showBrand: _currentPage == 0,
                  onSkip: _goToAuthChoice,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pageCount,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final slide = kOnboardingSlides[index];
                      return OnboardingSlideContent(
                        slide: slide,
                        pageIndex: index,
                        showBrandLogo: index == 0,
                      );
                    },
                  ),
                ),
                OnboardingBottomBar(
                  pageCount: _pageCount,
                  activeIndex: _currentPage,
                  isLastPage: _isLastPage,
                  onNext: _goNext,
                  onFinish: _goToAuthChoice,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
