import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:outtadebt/core/ui/app_theme.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/core/utils/preferences/user_preferences_service.dart';
import 'package:outtadebt/onboarding/onboarding_view_model.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final OnboardingViewModel _viewModel = OnboardingViewModel(
    routerService: locator<RouterService>(),
    preferencesService: locator<UserPreferencesService>(),
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: _viewModel.currentPage,
          builder: (context, page, _) {
            final isLastPage = page == OnboardingViewModel.pages.length - 1;

            return Column(
              children: [
                // Skip button is hidden on last page
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLastPage ? 0 : 1,
                    child: TextButton(
                      onPressed: isLastPage ? null : _viewModel.skip,
                      child: const Text('Skip'),
                    ),
                  ),
                ),

                // Swipeable page content
                Expanded(
                  child: PageView.builder(
                    controller: _viewModel.pageController,
                    onPageChanged: _viewModel.onPageChanged,
                    itemCount: OnboardingViewModel.pages.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: OnboardingViewModel.pages[index],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Animated page dots
                _PageDotsIndicator(
                  count: OnboardingViewModel.pages.length,
                  currentIndex: page,
                ),

                const SizedBox(height: 32),

                // CTA button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.xl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _viewModel.next,
                      child: Text(isLastPage ? 'Get Started' : 'Next'),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A single onboarding page: illustration + title + subtitle.
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder replace with Lottie animations later
        Lottie.asset(data.animationPath, width: 260),
          const SizedBox(height: 48),
          Text(
            data.title,
            style: context.textStyles.xxxl.copyWith(height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            style: context.textStyles.standard.copyWith(
              color: context.kitColors.neutral500,
              height: 1.65,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Animated pill dots that indicate current page position.
class _PageDotsIndicator extends StatelessWidget {
  const _PageDotsIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          // Active dot stretches to a pill; inactive is a small circle
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? context.theme.colorScheme.primary
                : context.kitColors.neutral300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
