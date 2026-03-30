import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:outtadebt/core/ui/app_theme.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/progress/progress_view_model.dart';
import 'package:intl/intl.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  late final ProgressViewModel _viewModel = ProgressViewModel(
    debtService: locator<DebtService>(),
    authService: locator<AuthService>(),
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _viewModel.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.lg,
              vertical: context.spacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Row
                _buildSummaryCards(context),
                SizedBox(height: context.spacing.xl),

                // Payoff Projection Chart
                _buildPayoffChart(context),
                SizedBox(height: context.spacing.xl),

                // Debt Breakdown Pie Chart
                _buildDebtBreakdown(context),
                SizedBox(height: context.spacing.xl),

                // Payment Simulator
                _buildPaymentSimulator(context),
                SizedBox(height: context.spacing.xl),

                // Milestones
                _buildMilestones(context),
                SizedBox(height: context.spacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build 3-card summary row: Total Debt, Monthly Minimum, Debt-Free Date
  Widget _buildSummaryCards(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _viewModel.totalDebt,
      builder: (context, totalDebt, _) {
        return ValueListenableBuilder<List<Debt>>(
          valueListenable: _viewModel.debts,
          builder: (context, debts, __) {
            final totalMinimum = debts.fold<double>(
              0.0,
              (sum, debt) => sum + debt.minimumPayment,
            );
            final debtFreeDate = _viewModel.debtFreeDate;
            final formattedDate =
                DateFormat('MMM dd, yyyy').format(debtFreeDate);

            return Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Debt',
                    value: '\$${totalDebt.toStringAsFixed(2)}',
                    icon: Icons.trending_down,
                  ),
                ),
                SizedBox(width: context.spacing.md),
                Expanded(
                  child: _SummaryCard(
                    title: 'Monthly Min',
                    value: '\$${totalMinimum.toStringAsFixed(2)}',
                    icon: Icons.calendar_month,
                  ),
                ),
                SizedBox(width: context.spacing.md),
                Expanded(
                  child: _SummaryCard(
                    title: 'Debt-Free',
                    value: formattedDate,
                    icon: Icons.celebration,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Build payoff projection line chart
  Widget _buildPayoffChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payoff Projection',
          style: context.textStyles.lg.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.md),
        ValueListenableBuilder<List<dynamic>>(
          valueListenable: ValueNotifier([
            _viewModel.payoffChartData,
            _viewModel.debtFreeDate,
          ]),
          builder: (context, _, __) {
            final chartData = _viewModel.payoffChartData;
            final debtFreeDate = _viewModel.debtFreeDate;
            final formattedDate =
                DateFormat('MMM yyyy').format(debtFreeDate);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.sm),
                  child: Text(
                    'Pay off by $formattedDate',
                    style: context.textStyles.sm.copyWith(
                      color: context.kitColors.neutral500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval:
                            _getChartInterval(chartData),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: context.kitColors.neutral200,
                            strokeWidth: 0.5,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: context.kitColors.neutral200,
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${(value / 1000).toStringAsFixed(0)}k',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.kitColors.neutral500,
                                ),
                              );
                            },
                            reservedSize: 45,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}m',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.kitColors.neutral500,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981),
                              const Color(0xFF10B981).withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: const Color(0xFF10B981),
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF10B981).withValues(alpha: 0.3),
                                const Color(0xFF10B981).withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '\$${spot.y.toStringAsFixed(0)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build debt breakdown pie chart
  Widget _buildDebtBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debt Breakdown',
          style: context.textStyles.lg.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.md),
        ValueListenableBuilder<List<Debt>>(
          valueListenable: _viewModel.debts,
          builder: (context, debts, __) {
            final chartData = _viewModel.debtBreakdownData;

            if (debts.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(context.spacing.lg),
                  child: Text(
                    'No debts added yet',
                    style: context.textStyles.standard.copyWith(
                      color: context.kitColors.neutral500,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: chartData,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.lg),
                // Legend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: debts.map<Widget>((debt) {
                    final percentage = _viewModel.totalDebt.value > 0
                        ? (debt.balance / _viewModel.totalDebt.value) * 100
                        : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(bottom: context.spacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: debt.type.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: context.spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  debt.name,
                                  style:
                                      context.textStyles.standard.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}% • \$${debt.balance.toStringAsFixed(2)}',
                                  style: context.textStyles.sm.copyWith(
                                    color: context.kitColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build payment simulator card
  Widget _buildPaymentSimulator(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: context.borderRadius.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Simulator',
              style: context.textStyles.lg.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: context.spacing.lg),
            ValueListenableBuilder<double>(
              valueListenable: _viewModel.simulatedMonthlyPayment,
              builder: (context, payment, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Monthly Payment:',
                          style: context.textStyles.standard,
                        ),
                        const Spacer(),
                        Text(
                          '\$${payment.toStringAsFixed(2)}',
                          style: context.textStyles.standard.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.spacing.md),
                    Slider(
                      value: payment,
                      min: 10,
                      max: 5000,
                      divisions: 499,
                      activeColor: const Color(0xFF10B981),
                      inactiveColor: context.kitColors.neutral300,
                      label: '\$${payment.toStringAsFixed(0)}',
                      onChanged: _viewModel.updateSimulatedPayment,
                    ),
                    SizedBox(height: context.spacing.lg),
                    // Results
                    ValueListenableBuilder<int>(
                      valueListenable: ValueNotifier(
                        _viewModel.monthsToPayoff,
                      ),
                      builder: (context, months, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Months to Payoff',
                                  style: context.textStyles.sm.copyWith(
                                    color: context.kitColors.neutral500,
                                  ),
                                ),
                                Text(
                                  months < 999 ? '$months months' : '> 30 years',
                                  style: context.textStyles.lg.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Interest Saved',
                                  style: context.textStyles.sm.copyWith(
                                    color: context.kitColors.neutral500,
                                  ),
                                ),
                                Text(
                                  '\$${_viewModel.interestSaved.toStringAsFixed(2)}',
                                  style: context.textStyles.lg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build milestones section
  Widget _buildMilestones(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: context.textStyles.lg.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: context.spacing.md),
        ValueListenableBuilder<double>(
          valueListenable: _viewModel.totalDebt,
          builder: (context, totalDebt, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _viewModel.totalPaid,
              builder: (context, totalPaid, _) {
                final paidPercentage = totalDebt > 0 ? totalPaid / totalDebt : 0.0;

                return Wrap(
                  spacing: context.spacing.md,
                  runSpacing: context.spacing.md,
                  children: [
                    _MilestoneChip(
                      label: 'First payment',
                      isCompleted: paidPercentage > 0,
                    ),
                    _MilestoneChip(
                      label: '10% paid',
                      isCompleted: paidPercentage >= 0.1,
                    ),
                    _MilestoneChip(
                      label: '25% paid',
                      isCompleted: paidPercentage >= 0.25,
                    ),
                    _MilestoneChip(
                      label: '50% paid',
                      isCompleted: paidPercentage >= 0.5,
                    ),
                    _MilestoneChip(
                      label: 'Debt Free!',
                      isCompleted: totalDebt == 0,
                      isFinal: true,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  double _getChartInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1000;
    final maxY =
        spots.reduce((a, b) => a.y > b.y ? a : b).y;
    if (maxY < 1000) return 100;
    if (maxY < 10000) return 1000;
    return 5000;
  }
}

/// Summary card widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final double fontSize;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.kitColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: context.borderRadius.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF10B981),
              size: 24,
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              title,
              style: context.textStyles.xs.copyWith(
                color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: context.spacing.xs),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Milestone chip widget
class _MilestoneChip extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isFinal;

  const _MilestoneChip({
    required this.label,
    required this.isCompleted,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? isFinal
                ? const Color(0xFF10B981)
                : const Color(0xFF10B981).withValues(alpha: 0.1)
            : context.kitColors.neutral200,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted && isFinal
            ? Border.all(color: const Color(0xFF10B981), width: 2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            Padding(
              padding: EdgeInsets.only(right: context.spacing.xs),
              child: Icon(
                Icons.check_circle,
                size: 16,
                color: isFinal ? Colors.white : const Color(0xFF10B981),
              ),
            ),
          Text(
            label,
            style: context.textStyles.sm.copyWith(
              color: isCompleted
                  ? isFinal
                      ? Colors.white
                      : const Color(0xFF10B981)
                  : context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
