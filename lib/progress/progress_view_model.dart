import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/services/auth_service.dart';

class ProgressViewModel extends ChangeNotifier {
  final DebtService _debtService;
  final AuthService _authService;

  late StreamSubscription<List<Debt>> _debtSubscription;
  late StreamSubscription<double> _totalDebtSubscription;

  // ValueNotifiers for reactive state
  final ValueNotifier<List<Debt>> debts = ValueNotifier<List<Debt>>([]);
  final ValueNotifier<double> totalDebt = ValueNotifier<double>(0.0);
  final ValueNotifier<double> totalPaid = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<double> simulatedMonthlyPayment =
      ValueNotifier<double>(500.0);

  ProgressViewModel({
    required DebtService debtService,
    required AuthService authService,
  })  : _debtService = debtService,
        _authService = authService {
    _initialize();
  }

  void _initialize() {
    final userId = _authService.userId.value;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    // Subscribe to debts stream
    _debtSubscription = _debtService.getDebts(userId).listen(
      (debtList) {
        debts.value = debtList;
        isLoading.value = false;
        notifyListeners();
      },
      onError: (error) {
        isLoading.value = false;
        notifyListeners();
      },
    );

    // Subscribe to total debt stream
    _totalDebtSubscription = _debtService.getTotalDebt(userId).listen(
      (total) {
        totalDebt.value = total;
        notifyListeners();
      },
      onError: (error) {
        notifyListeners();
      },
    );

    // Mock total paid calculation (30% of total debt as demo)
    totalPaid.value = totalDebt.value * 0.3;
  }

  /// Computed getter: months to pay off based on simulated payment
  int get monthsToPayoff {
    if (totalDebt.value <= 0 || simulatedMonthlyPayment.value <= 0) {
      return 0;
    }

    // Simple calculation: months = total debt / monthly payment
    // In a real app, this would factor in interest rates
    double avgInterestRate = debts.value.isEmpty
        ? 0.0
        : debts.value.fold<double>(
              0.0,
              (sum, debt) => sum + debt.interestRate,
            ) /
            debts.value.length;

    // If no interest, simple calculation
    if (avgInterestRate <= 0) {
      return (totalDebt.value / simulatedMonthlyPayment.value).ceil();
    }

    // With interest: rough amortization estimate
    // Formula: n = -log(1 - (r * A / P)) / log(1 + r)
    // where r = monthly interest rate, P = principal, A = monthly payment
    double monthlyRate = avgInterestRate / 100 / 12;
    if (monthlyRate == 0) {
      return (totalDebt.value / simulatedMonthlyPayment.value).ceil();
    }

    double monthlyPayment = simulatedMonthlyPayment.value;
    if (monthlyPayment * 12 < totalDebt.value * monthlyRate) {
      // Payment doesn't cover interest
      return 999; // Effectively infinite
    }

    double numerator = monthlyPayment - (totalDebt.value * monthlyRate);
    double denominator = monthlyPayment;
    double ratio = numerator / denominator;

    if (ratio <= 0) return 999;

    double months = -Math.log(ratio) / Math.log(1 + monthlyRate);
    return months.ceil();
  }

  /// Computed getter: estimated interest saved vs minimum payment
  double get interestSaved {
    if (debts.value.isEmpty) return 0.0;

    double avgInterestRate = debts.value.fold<double>(
          0.0,
          (sum, debt) => sum + debt.interestRate,
        ) /
        debts.value.length;

    double totalMinimum = debts.value.fold<double>(
      0.0,
      (sum, debt) => sum + debt.minimumPayment,
    );

    // Rough estimate: simulate with minimum payment for 60 months
    // vs simulated payment
    double monthlyRate = avgInterestRate / 100 / 12;
    if (monthlyRate == 0) return 0.0;

    double remainingBalance = totalDebt.value;
    double totalInterestMinimum = 0.0;
    int monthCounter = 0;
    const maxMonths = 360;

    // Simulate with minimum payment
    while (remainingBalance > 0 && monthCounter < maxMonths) {
      double interest = remainingBalance * monthlyRate;
      totalInterestMinimum += interest;
      remainingBalance -= (totalMinimum - interest);
      if (remainingBalance < 0) remainingBalance = 0;
      monthCounter++;
    }

    // Simulate with simulated payment
    remainingBalance = totalDebt.value;
    double totalInterestSimulated = 0.0;
    monthCounter = 0;

    while (remainingBalance > 0 && monthCounter < maxMonths) {
      double interest = remainingBalance * monthlyRate;
      totalInterestSimulated += interest;
      remainingBalance -= (simulatedMonthlyPayment.value - interest);
      if (remainingBalance < 0) remainingBalance = 0;
      monthCounter++;
    }

    return (totalInterestMinimum - totalInterestSimulated).clamp(0, double.infinity);
  }

  /// Computed getter: estimated debt-free date
  DateTime get debtFreeDate {
    final now = DateTime.now();
    return now.add(Duration(days: monthsToPayoff * 30));
  }

  /// Computed getter: chart data for payoff projection (12 months)
  List<FlSpot> get payoffChartData {
    if (totalDebt.value <= 0) {
      return [FlSpot(0, 0), FlSpot(12, 0)];
    }

    final spots = <FlSpot>[];
    double remainingBalance = totalDebt.value;

    double avgInterestRate = debts.value.isEmpty
        ? 0.0
        : debts.value.fold<double>(
              0.0,
              (sum, debt) => sum + debt.interestRate,
            ) /
            debts.value.length;

    double monthlyRate = avgInterestRate / 100 / 12;

    for (int month = 0; month <= 12; month++) {
      spots.add(FlSpot(month.toDouble(), remainingBalance.clamp(0, double.infinity)));

      if (month < 12) {
        double interest = remainingBalance * monthlyRate;
        remainingBalance -= (simulatedMonthlyPayment.value - interest);
      }
    }

    return spots;
  }

  /// Computed getter: pie chart data for debt breakdown
  List<PieChartSectionData> get debtBreakdownData {
    if (debts.value.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'No Debts',
          color: Colors.grey.shade300,
          radius: 50,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ];
    }

    final sections = <PieChartSectionData>[];
    for (final debt in debts.value) {
      final percentage = totalDebt.value > 0
          ? (debt.balance / totalDebt.value) * 100
          : 0.0;

      sections.add(
        PieChartSectionData(
          value: debt.balance,
          title: '${percentage.toStringAsFixed(0)}%',
          color: debt.type.color,
          radius: 50,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    return sections;
  }

  /// Update the simulated monthly payment amount
  void updateSimulatedPayment(double amount) {
    simulatedMonthlyPayment.value = amount.clamp(10.0, double.infinity);
    notifyListeners();
  }

  @override
  void dispose() {
    _debtSubscription.cancel();
    _totalDebtSubscription.cancel();
    debts.dispose();
    totalDebt.dispose();
    totalPaid.dispose();
    isLoading.dispose();
    simulatedMonthlyPayment.dispose();
    super.dispose();
  }
}

// Math utility for logarithm calculation
abstract class Math {
  static double log(double value) {
    return _naturalLog(value);
  }

  static double _naturalLog(double x) {
    if (x <= 0) return double.nan;
    if (x == 1.0) return 0.0;
    if (x.isInfinite) return double.infinity;

    // Simple natural log approximation using series expansion
    double y = (x - 1) / (x + 1);
    double y2 = y * y;
    double result = 0.0;
    double term = y;
    int n = 1;

    while (term.abs() > 1e-15 && n < 100) {
      result += term / n;
      term *= y2;
      n += 2;
    }

    return 2.0 * result;
  }
}
