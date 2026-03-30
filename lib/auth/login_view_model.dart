import 'package:firebase_auth/firebase_auth.dart';
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
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      _notifyService.setToastEvent(
        ToastEventError(message: errorMessage),
      );
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'An error occurred. Please try again.'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      await _authService.signInWithGoogle();
      _routerService.go('/');
    } on FirebaseAuthException catch (e) {
      if (e.code != 'ERROR_ABORTED_BY_USER') {
        _notifyService.setToastEvent(
          ToastEventError(message: 'Google sign-in failed'),
        );
      }
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'An error occurred. Please try again.'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please enter your email address'),
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authService.sendPasswordResetEmail(email: email);
      _notifyService.setToastEvent(
        ToastEventSuccess(message: 'Reset link sent — check your inbox'),
      );
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'user-not-found'
          ? 'No account found with this email'
          : 'Failed to send reset email';
      _notifyService.setToastEvent(ToastEventError(message: message));
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'An error occurred. Please try again.'),
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
