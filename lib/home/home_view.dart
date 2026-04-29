import 'package:flutter/material.dart';
import 'package:outtadebt/core/ui/app_theme.dart';
import 'package:outtadebt/core/ui/constants/kit_colors.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/home/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel = HomeViewModel(
    routerService: locator<RouterService>(),
    notifyService: locator<NotifyService>(),
    authService: locator<AuthService>(),
    debtService: locator<DebtService>(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _viewModel.isLoading,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.spacing.lg),
                  // Greeting header
                  _buildGreeting(context),
                  SizedBox(height: context.spacing.xl),
                  // Total debt card
                  _buildTotalDebtCard(context),
                  SizedBox(height: context.spacing.xl),
                  // Debt type breakdown
                  _buildDebtTypeBreakdown(context),
                  SizedBox(height: context.spacing.xl),
                  // Quick actions
                  _buildQuickActions(context),
                  SizedBox(height: context.spacing.xl),
                  // Your debts section
                  _buildDebtsSection(context),
                  SizedBox(height: context.spacing.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, ${_viewModel.userName}! 👋',
                style: context.textStyles.xl.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFF10B981),
          child: Text(
            _viewModel.userName.isNotEmpty
                ? _viewModel.userName[0].toUpperCase()
                : '?',
            style: context.textStyles.lg.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalDebtCard(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _viewModel.totalDebt,
      builder: (context, total, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0F172A),
                Color(0xFF047857),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: context.borderRadius.lg,
          ),
          padding: EdgeInsets.all(context.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Debt',
                style: context.textStyles.standard.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: context.spacing.md),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: context.textStyles.xxxl.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.spacing.md),
              Text(
                'Across ${_viewModel.debtsByType.length} accounts',
                style: context.textStyles.sm.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: context.spacing.lg),
              // Progress bar
              ClipRRect(
                borderRadius: context.borderRadius.sm,
                child: LinearProgressIndicator(
                  value: 0.064,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                '6.4% paid off',
                style: context.textStyles.xs.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebtTypeBreakdown(BuildContext context) {
    return ValueListenableBuilder<List<Debt>>(
      valueListenable: _viewModel.debts,
      builder: (context, debtList, _) {
        if (debtList.isEmpty) {
          return const SizedBox.shrink();
        }

        final debtsByType = _viewModel.debtsByType;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debt Breakdown',
              style: context.textStyles.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.spacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: debtsByType.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(right: context.spacing.md),
                    child: _buildDebtTypeCard(context, entry.key, entry.value),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDebtTypeCard(
    BuildContext context,
    DebtType type,
    double amount,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: context.borderRadius.md,
        border: Border.all(
          color: context.theme.brightness == Brightness.dark ? context.kitColors.neutral700 : context.kitColors.neutral200,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(context.spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            type.icon,
            color: type.color,
            size: 24,
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            type.displayName,
            style: context.textStyles.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: context.textStyles.lg.copyWith(
              fontWeight: FontWeight.bold,
              color: type.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'label': 'Add Debt',
        'icon': Icons.add_circle_outline,
        'color': const Color(0xFF10B981),
        'onTap': _viewModel.navigateToAddDebt,
      },
      {
        'label': 'Join Circle',
        'icon': Icons.people_outline,
        'color': const Color(0xFF8B5CF6),
        'onTap': _viewModel.navigateToJoinCircle,
      },
      {
        'label': 'Payment',
        'icon': Icons.payment,
        'color': const Color(0xFF3B82F6),
        'onTap': _viewModel.navigateToMakePayment,
      },
      {
        'label': 'Simulator',
        'icon': Icons.show_chart,
        'color': const Color(0xFFF59E0B),
        'onTap': () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.textStyles.lg.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: context.spacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: context.spacing.md,
          mainAxisSpacing: context.spacing.md,
          children: actions.map((action) {
            return _buildActionCard(
              context,
              action['label'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              action['onTap'] as VoidCallback,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.borderRadius.md,
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: context.borderRadius.md,
            border: Border.all(
              color: context.theme.brightness == Brightness.dark ? context.kitColors.neutral700 : context.kitColors.neutral200,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              SizedBox(height: context.spacing.sm),
              Text(
                label,
                style: context.textStyles.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebtsSection(BuildContext context) {
    return ValueListenableBuilder<List<Debt>>(
      valueListenable: _viewModel.debts,
      builder: (context, debtList, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Debts',
              style: context.textStyles.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.spacing.md),
            if (debtList.isEmpty)
              _buildEmptyState(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: debtList.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: context.spacing.md),
                itemBuilder: (context, index) {
                  final debt = debtList[index];
                  return _buildDebtListItem(context, debt);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: context.borderRadius.md,
        border: Border.all(
          color: context.theme.brightness == Brightness.dark ? context.kitColors.neutral700 : context.kitColors.neutral200,
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(context.spacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: context.kitColors.neutral400,
          ),
          SizedBox(height: context.spacing.md),
          Text(
            'No debts added yet',
            style: context.textStyles.lg.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            'Add your first debt to get started on your financial journey',
            textAlign: TextAlign.center,
            style: context.textStyles.standard.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: context.spacing.lg),
          ElevatedButton.icon(
            onPressed: _viewModel.navigateToAddDebt,
            icon: const Icon(Icons.add),
            label: const Text('Add Debt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: KitColors.navy950,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtListItem(BuildContext context, Debt debt) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _viewModel.navigateToDebtDetail(debt.id),
        borderRadius: context.borderRadius.md,
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: context.borderRadius.md,
            border: Border.all(
              color: context.theme.brightness == Brightness.dark ? context.kitColors.neutral700 : context.kitColors.neutral200,
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(context.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.name,
                          style: context.textStyles.lg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: context.spacing.xs),
                        Container(
                          decoration: BoxDecoration(
                            color: debt.type.color.withValues(alpha: 0.1),
                            borderRadius: context.borderRadius.sm,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.spacing.sm,
                            vertical: context.spacing.xs,
                          ),
                          child: Text(
                            debt.type.displayName,
                            style: context.textStyles.xs.copyWith(
                              color: debt.type.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${debt.balance.toStringAsFixed(2)}',
                        style: context.textStyles.lg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: debt.type.color,
                        ),
                      ),
                      SizedBox(height: context.spacing.xs),
                      Text(
                        '${debt.interestRate.toStringAsFixed(2)}%',
                        style: context.textStyles.sm.copyWith(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: context.spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Min. Payment',
                    style: context.textStyles.sm.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    '\$${debt.minimumPayment.toStringAsFixed(2)}',
                    style: context.textStyles.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due Day',
                    style: context.textStyles.sm.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    'Day ${debt.dueDay}',
                    style: context.textStyles.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
