import 'package:flutter/material.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class AddDebtViewModel {
  AddDebtViewModel({
    required RouterService routerService,
    required NotifyService notifyService,
    required DebtService debtService,
    required AuthService authService,
  })  : _routerService = routerService,
        _notifyService = notifyService,
        _debtService = debtService,
        _authService = authService;

  final RouterService _routerService;
  final NotifyService _notifyService;
  final DebtService _debtService;
  final AuthService _authService;

  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final interestRateController = TextEditingController();
  final minimumPaymentController = TextEditingController();

  final selectedType = ValueNotifier<DebtType>(DebtType.creditCard);
  final selectedDueDay = ValueNotifier<int>(1);
  final isLoading = ValueNotifier<bool>(false);

  final formKey = GlobalKey<FormState>();

  Future<void> saveDebt() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final balanceText = balanceController.text.trim();
    final interestRateText = interestRateController.text.trim();
    final minimumPaymentText = minimumPaymentController.text.trim();

    if (name.isEmpty || balanceText.isEmpty || interestRateText.isEmpty || minimumPaymentText.isEmpty) {
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
      final balance = double.parse(balanceText);
      final interestRate = double.parse(interestRateText);
      final minimumPayment = double.parse(minimumPaymentText);

      if (balance <= 0) {
        _notifyService.setToastEvent(
          ToastEventError(message: 'Balance must be greater than 0'),
        );
        isLoading.value = false;
        return;
      }

      if (interestRate < 0) {
        _notifyService.setToastEvent(
          ToastEventError(message: 'Interest rate cannot be negative'),
        );
        isLoading.value = false;
        return;
      }

      if (minimumPayment <= 0) {
        _notifyService.setToastEvent(
          ToastEventError(message: 'Minimum payment must be greater than 0'),
        );
        isLoading.value = false;
        return;
      }

      await _debtService.addDebt(
        userId: userId,
        name: name,
        type: selectedType.value,
        balance: balance,
        interestRate: interestRate,
        minimumPayment: minimumPayment,
        dueDay: selectedDueDay.value,
      );

      _notifyService.setToastEvent(
        ToastEventSuccess(message: 'Debt added successfully'),
      );

      _routerService.pop();
    } on FormatException {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Please enter valid numbers'),
      );
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Failed to add debt. Please try again.'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectType(DebtType type) {
    selectedType.value = type;
  }

  void selectDueDay(int day) {
    selectedDueDay.value = day;
  }

  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    interestRateController.dispose();
    minimumPaymentController.dispose();
    selectedType.dispose();
    selectedDueDay.dispose();
    isLoading.dispose();
  }
}
