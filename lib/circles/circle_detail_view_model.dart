import 'package:flutter/material.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/circle_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';

class CircleDetailViewModel {
  CircleDetailViewModel({
    required NotifyService notifyService,
    required CircleService circleService,
    required AuthService authService,
    required String circleId,
  })  : _notifyService = notifyService,
        _circleService = circleService,
        _authService = authService,
        _circleId = circleId;

  final NotifyService _notifyService;
  final CircleService _circleService;
  final AuthService _authService;
  final String _circleId;

  final circle = ValueNotifier<Circle?>(null);
  final isLoading = ValueNotifier<bool>(false);
  final isMember = ValueNotifier<bool>(false);
  final contributionController = TextEditingController();

  void loadCircle() async {
    isLoading.value = true;
    try {
      final loadedCircle = await _circleService.getCircleById(_circleId);
      circle.value = loadedCircle;

      final userId = _authService.userId.value;
      if (loadedCircle != null && userId != null) {
        isMember.value = loadedCircle.memberIds.contains(userId);
      }
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Failed to load circle'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinCircle() async {
    final userId = _authService.userId.value;
    if (userId == null) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'User not authenticated'),
      );
      return;
    }

    isLoading.value = true;
    try {
      final user = _authService.currentUser;
      final displayName = user?.displayName ?? user?.email ?? 'Member';

      await _circleService.joinCircle(
        circleId: _circleId,
        userId: userId,
        displayName: displayName,
      );

      isMember.value = true;

      _notifyService.setToastEvent(
        ToastEventSuccess(message: 'Joined circle successfully'),
      );

      loadCircle();
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Failed to join circle'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveCircle() async {
    final userId = _authService.userId.value;
    if (userId == null) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'User not authenticated'),
      );
      return;
    }

    isLoading.value = true;
    try {
      await _circleService.leaveCircle(
        circleId: _circleId,
        userId: userId,
      );

      isMember.value = false;

      _notifyService.setToastEvent(
        ToastEventSuccess(message: 'Left circle successfully'),
      );

      loadCircle();
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Failed to leave circle'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> contributeAmount() async {
    final userId = _authService.userId.value;
    if (userId == null) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'User not authenticated'),
      );
      return;
    }

    final amountText = contributionController.text.trim();
    if (amountText.isEmpty) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please enter an amount'),
      );
      return;
    }

    isLoading.value = true;
    try {
      final amount = double.parse(amountText);

      if (amount <= 0) {
        _notifyService.setToastEvent(
          ToastEventError(message: 'Amount must be greater than 0'),
        );
        isLoading.value = false;
        return;
      }

      await _circleService.addContribution(
        circleId: _circleId,
        userId: userId,
        amount: amount,
      );

      _notifyService.setToastEvent(
        ToastEventSuccess(message: 'Contribution added successfully'),
      );

      contributionController.clear();
      loadCircle();
    } on FormatException {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please enter a valid amount'),
      );
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Failed to add contribution'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    circle.dispose();
    isLoading.dispose();
    isMember.dispose();
    contributionController.dispose();
  }
}
