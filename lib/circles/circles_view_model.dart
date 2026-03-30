import 'dart:async';
import 'package:flutter/material.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/circle_service.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class CirclesViewModel {
  CirclesViewModel({
    required RouterService routerService,
    required CircleService circleService,
    required AuthService authService,
  })  : _routerService = routerService,
        _circleService = circleService,
        _authService = authService;

  final RouterService _routerService;
  final CircleService _circleService;
  final AuthService _authService;

  final circles = ValueNotifier<List<Circle>>([]);
  final myCircles = ValueNotifier<List<Circle>>([]);
  final isLoading = ValueNotifier<bool>(false);
  final selectedTab = ValueNotifier<int>(0);

  late StreamSubscription<List<Circle>> _circlesSubscription;
  late StreamSubscription<List<Circle>> _myCirclesSubscription;

  void initialize() {
    isLoading.value = true;

    // Listen to all public circles
    _circlesSubscription = _circleService.getCircles().listen(
      (loadedCircles) {
        circles.value = loadedCircles;
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
      },
    );

    // Listen to user's circles
    final userId = _authService.userId.value;
    if (userId != null) {
      _myCirclesSubscription = _circleService.getUserCircles(userId).listen(
        (loadedCircles) {
          myCircles.value = loadedCircles;
        },
        onError: (e) {
          // Handle error silently
        },
      );
    }
  }

  void navigateToCreateCircle() {
    _routerService.push('/circles/create');
  }

  void navigateToCircleDetail(String circleId) {
    _routerService.push('/circles/$circleId');
  }

  void switchTab(int tab) {
    selectedTab.value = tab;
  }

  void dispose() {
    _circlesSubscription.cancel();
    _myCirclesSubscription.cancel();
    circles.dispose();
    myCircles.dispose();
    isLoading.dispose();
    selectedTab.dispose();
  }
}

