import 'package:flutter/material.dart';
import 'package:outtadebt/add_debt/add_debt_view_model.dart';
import 'package:outtadebt/core/ui/constants/kit_colors.dart';
import 'package:outtadebt/core/ui/widgets/app_text_field.dart';
import 'package:outtadebt/core/ui/widgets/primary_button.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';

class AddDebtView extends StatefulWidget {
  const AddDebtView({super.key});

  @override
  State<AddDebtView> createState() => _AddDebtViewState();
}

class _AddDebtViewState extends State<AddDebtView> {
  late final AddDebtViewModel _viewModel = AddDebtViewModel(
    routerService: locator<RouterService>(),
    notifyService: locator<NotifyService>(),
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
        title: const Text('Add Debt'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debt Name
                AppTextField(
                  label: 'Debt Name',
                  hint: 'e.g., Chase Credit Card',
                  controller: _viewModel.nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Debt name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Debt Type Selector
                Text(
                  'Debt Type',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<DebtType>(
                  valueListenable: _viewModel.selectedType,
                  builder: (context, selectedType, _) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: DebtType.values.map((type) {
                          final isSelected = selectedType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => _viewModel.selectType(type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? KitColors.green600.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                                  border: Border.all(
                                    color: isSelected ? KitColors.green600 : Theme.of(context).colorScheme.outlineVariant,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type.icon,
                                      color: type.color,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      type.displayName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? KitColors.green600 : Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Balance
                AppTextField(
                  label: 'Balance',
                  hint: '0.00',
                  controller: _viewModel.balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Balance is required';
                    }
                    try {
                      final parsed = double.parse(value);
                      if (parsed <= 0) {
                        return 'Balance must be greater than 0';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  prefixIcon: Icons.attach_money,
                ),
                const SizedBox(height: 24),

                // Interest Rate
                AppTextField(
                  label: 'Interest Rate (%)',
                  hint: '0.00',
                  controller: _viewModel.interestRateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Interest rate is required';
                    }
                    try {
                      final parsed = double.parse(value);
                      if (parsed < 0) {
                        return 'Interest rate cannot be negative';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Minimum Payment
                AppTextField(
                  label: 'Minimum Payment',
                  hint: '0.00',
                  controller: _viewModel.minimumPaymentController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Minimum payment is required';
                    }
                    try {
                      final parsed = double.parse(value);
                      if (parsed <= 0) {
                        return 'Minimum payment must be greater than 0';
                      }
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  prefixIcon: Icons.attach_money,
                ),
                const SizedBox(height: 24),

                // Due Day
                Text(
                  'Due Day',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: _viewModel.selectedDueDay,
                  builder: (context, selectedDay, _) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<int>(
                        value: selectedDay,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        onChanged: (value) {
                          if (value != null) {
                            _viewModel.selectDueDay(value);
                          }
                        },
                        items: List.generate(28, (index) {
                          final day = index + 1;
                          return DropdownMenuItem<int>(
                            value: day,
                            child: Text('Day $day'),
                          );
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Save Button
                ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoading,
                  builder: (context, isLoading, _) {
                    return PrimaryButton(
                      label: 'Save Debt',
                      isLoading: isLoading,
                      onPressed: _viewModel.saveDebt,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
