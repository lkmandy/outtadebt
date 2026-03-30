import 'package:flutter/material.dart';
import 'package:outtadebt/config/route_config.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/core/utils/preferences/user_preferences_service.dart';

/// Data for a single onboarding page.
/// This is a plain data class — no logic, no state, just values.
class OnboardingPageData {
  final String title;
  final String subtitle;
  final String animationPath;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.animationPath,
  });
}

class OnboardingViewModel {
  OnboardingViewModel({
    required RouterService routerService,
    required UserPreferencesService preferencesService,
  }) : _routerService = routerService,
       _preferencesService = preferencesService;

  final RouterService _routerService;
  final UserPreferencesService _preferencesService;

  // PageController drives the PageView widget in the View.
  // We own it here so the ViewModel controls navigation between pages.
  final pageController = PageController();

  // Tracks which page dot to highlight.
  final ValueNotifier<int> currentPage = ValueNotifier(0);

  // Static because the page content never changes at runtime.
  static const pages = [
    OnboardingPageData(
      title: 'Know Exactly\nWhat You Owe',
      subtitle:
          'Add all your debts in one place. Credit cards, loans, everything — tracked and organized.',
      animationPath: 'assets/animations/onboarding_1.json',
    ),
    OnboardingPageData(
      title: 'Build a Plan\nThat Works',
      subtitle:
          'Snowball or Avalanche — choose your strategy and see exactly when you\'ll be debt-free.',
      animationPath: 'assets/animations/onboarding_2.json',
    ),
    OnboardingPageData(
      title: 'Stay Accountable\nTogether',
      subtitle:
          'Join a Circle with friends or family. Shared goals are reached faster.',
      animationPath: 'assets/animations/onboarding_3.json',
    ),
    OnboardingPageData(
      title: 'Your Freedom\nStarts Today',
      subtitle:
          'Thousands of people are getting out of debt with OuttaDebt. You\'re next.',
      animationPath: 'assets/animations/onboarding_4.json',
    ),
  ];

  // Called by PageView when the user swipes keeps our dot indicator in sync.
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void skip() => _completeOnboarding();

  Future<void> _completeOnboarding() async {
    await _preferencesService.completeOnboarding();
    _routerService.go(RoutePaths.home);
  }

  void dispose() {
    currentPage.dispose();
    pageController.dispose();  // PageController is a ChangeNotifier  always dispose it
  }
}
