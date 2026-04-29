import 'package:flutter/material.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class LoginViewModel {
  LoginViewModel({
    required RouterService routerService,
    required NotifyService notifyService,
    required AuthService authService,
  })  : _routerService = routerService,
        _notifyService = notifyService,
        _authService = authService;

  final RouterService _routerService;
  final NotifyService _notifyService;
  final AuthService _authService;

  final isLoading = ValueNotifier<bool>(false);

  late final emailController = TextEditingController();
  late final passwordController = TextEditingController();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please fill in all fields'),
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _routerService.go('/');
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: e.toString().replaceFirst('Exception: ', '')),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSignup() {
    _routerService.go('/signup');
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isLoading.dispose();
  }
}
