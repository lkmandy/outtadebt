import 'package:flutter/material.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/circle_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class CreateCircleViewModel {
  CreateCircleViewModel({
    required RouterService routerService,
    required NotifyService notifyService,
    required CircleService circleService,
    required AuthService authService,
  })  : _routerService = routerService,
        _notifyService = notifyService,
        _circleService = circleService,
        _authService = authService;

  final RouterService _routerService;
  final NotifyService _notifyService;
  final CircleService _circleService;
  final AuthService _authService;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final goalAmountController = TextEditingController();

  final selectedCategory = ValueNotifier<CircleCategory>(CircleCategory.general);
  final isLoading = ValueNotifier<bool>(false);

  Future<void> createCircle() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final goalAmountText = goalAmountController.text.trim();

    if (name.isEmpty || description.isEmpty || goalAmountText.isEmpty) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please fill in all fields'),
      );
      return;
    }

    final userId = _authService.userId.value;
    if (userId == null) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'User not authenticated'),
      );
      return;
    }

    isLoading.value = true;
    try {
      final goalAmount = double.parse(goalAmountText);

      if (goalAmount <= 0) {
        _notifyService.setToastEvent(
          ToastEventError(message: 'Goal amount must be greater than 0'),
        );
        isLoading.value = false;
        return;
      }

      await _circleService.createCircle(
        name: name,
        description: description,
        goalAmount: goalAmount,
        creatorId: userId,
        category: selectedCategory.value,
      );

      _notifyService.setToastEvent(
        ToastEventSuccess(message: 'Circle created successfully'),
      );

      _routerService.pop();
    } on FormatException {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please enter a valid goal amount'),
      );
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Failed to create circle. Please try again.'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(CircleCategory category) {
    selectedCategory.value = category;
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    goalAmountController.dispose();
    selectedCategory.dispose();
    isLoading.dispose();
  }
}
