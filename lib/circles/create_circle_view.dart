import 'package:flutter/material.dart';
import 'package:outtadebt/circles/create_circle_view_model.dart';
import 'package:outtadebt/core/ui/widgets/app_text_field.dart';
import 'package:outtadebt/core/ui/widgets/primary_button.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/core/services/circle_service.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';

class CreateCircleView extends StatefulWidget {
  const CreateCircleView({super.key});

  @override
  State<CreateCircleView> createState() => _CreateCircleViewState();
}

class _CreateCircleViewState extends State<CreateCircleView> {
  late final CreateCircleViewModel _viewModel = CreateCircleViewModel(
    routerService: locator<RouterService>(),
    notifyService: locator<NotifyService>(),
    circleService: locator<CircleService>(),
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
        title: const Text('Create Circle'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Name
              AppTextField(
                label: 'Circle Name',
                hint: 'e.g., Student Debt Support',
                controller: _viewModel.nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Circle name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              AppTextField(
                label: 'Description',
                hint: 'Describe your circle and its goal',
                controller: _viewModel.descriptionController,
                maxLines: 3,
                minLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Goal Amount
              AppTextField(
                label: 'Goal Amount',
                hint: '0.00',
                controller: _viewModel.goalAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Goal amount is required';
                  }
                  try {
                    final parsed = double.parse(value);
                    if (parsed <= 0) {
                      return 'Goal amount must be greater than 0';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 24),

              // Category Selector
              Text(
                'Category',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<CircleCategory>(
                valueListenable: _viewModel.selectedCategory,
                builder: (context, selectedCategory, _) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: CircleCategory.values.map((category) {
                        final isSelected = selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _viewModel.selectCategory(category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? category.color.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: isSelected ? category.color : Theme.of(context).colorScheme.outlineVariant,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? category.color : const Color(0xFF374151),
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
              const SizedBox(height: 32),

              // Create Button
              ValueListenableBuilder<bool>(
                valueListenable: _viewModel.isLoading,
                builder: (context, isLoading, _) {
                  return PrimaryButton(
                    label: 'Create Circle',
                    isLoading: isLoading,
                    onPressed: _viewModel.createCircle,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
