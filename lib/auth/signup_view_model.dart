import 'package:flutter/material.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class SignupViewModel {
  SignupViewModel({
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

  late final nameController = TextEditingController();
  late final emailController = TextEditingController();
  late final passwordController = TextEditingController();
  late final confirmPasswordController = TextEditingController();

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please fill in all fields'),
      );
      return;
    }

    if (password.length < 8) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Password must be at least 8 characters'),
      );
      return;
    }

    if (password != confirmPassword) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Passwords do not match'),
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
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

  void navigateToLogin() {
    _routerService.go('/login');
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    isLoading.dispose();
  }
}
