import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:outtadebt/config/route_config.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class HomeViewModel {
  HomeViewModel({
    required RouterService routerService,
    required NotifyService notifyService,
    required AuthService authService,
    required DebtService debtService,
  })  : _routerService = routerService,
        _notifyService = notifyService,
        _authService = authService,
        _debtService = debtService;

  final RouterService _routerService;
  final NotifyService _notifyService;
  final AuthService _authService;
  final DebtService _debtService;

  StreamSubscription<List<Debt>>? _debtsSubscription;

  final ValueNotifier<List<Debt>> debts = ValueNotifier<List<Debt>>([]);
  final ValueNotifier<double> totalDebt = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  void initialize() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _debtsSubscription = _debtService.getDebts(userId).listen(
        (debtList) {
          debts.value = debtList;
          _updateTotalDebt(debtList);
          isLoading.value = false;
        },
        onError: (error) {
          isLoading.value = false;
          _notifyService.setToastEvent(
            ToastEventError(message: 'Failed to load debts'),
          );
        },
      );
    } else {
      isLoading.value = false;
    }
  }

  void _updateTotalDebt(List<Debt> debtList) {
    totalDebt.value = debtList.fold<double>(
      0.0,
      (sum, debt) => sum + debt.balance,
    );
  }

  String get userName {
    return _authService.currentUser?.displayName ?? 'Guest';
  }

  Map<DebtType, double> get debtsByType {
    final Map<DebtType, double> grouped = {};
    for (final debt in debts.value) {
      grouped[debt.type] = (grouped[debt.type] ?? 0.0) + debt.balance;
    }
    return grouped;
  }

  void navigateToAddDebt() {
    _routerService.push('/add-debt');
  }

  void navigateToDebtDetail(String debtId) {
    _notifyService.setToastEvent(
      ToastEventInfo(message: 'Debt detail coming soon'),
    );
  }

  void navigateToJoinCircle() {
    _routerService.go(RoutePaths.circles);
  }

  void navigateToMakePayment() {
    _notifyService.setToastEvent(
      ToastEventInfo(message: 'Payments coming soon'),
    );
  }

  void dispose() {
    _debtsSubscription?.cancel();
    debts.dispose();
    totalDebt.dispose();
    isLoading.dispose();
  }
}

