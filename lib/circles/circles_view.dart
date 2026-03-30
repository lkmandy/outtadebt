import 'package:flutter/material.dart';
import 'package:outtadebt/circles/circles_view_model.dart';
import 'package:outtadebt/core/ui/widgets/primary_button.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/core/services/circle_service.dart';
import 'package:outtadebt/core/services/auth_service.dart';

class CirclesView extends StatefulWidget {
  const CirclesView({super.key});

  @override
  State<CirclesView> createState() => _CirclesViewState();
}

class _CirclesViewState extends State<CirclesView> {
  late final CirclesViewModel _viewModel = CirclesViewModel(
    routerService: locator<RouterService>(),
    circleService: locator<CircleService>(),
    authService: locator<AuthService>(),
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
      appBar: AppBar(
        title: const Text('Circles'),
        centerTitle: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _viewModel.navigateToCreateCircle,
                  borderRadius: BorderRadius.circular(24),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _viewModel.selectedTab,
        builder: (context, selectedTab, _) {
          return Column(
            children: [
              // Custom Tab Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _viewModel.switchTab(0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Discover',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selectedTab == 0 ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (selectedTab == 0)
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _viewModel.switchTab(1),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'My Circles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selectedTab == 1 ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (selectedTab == 1)
                              Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Tab Content
              Expanded(
                child: selectedTab == 0 ? _buildDiscoverTab(context) : _buildMyCirclesTab(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscoverTab(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _viewModel.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ValueListenableBuilder<List<Circle>>(
          valueListenable: _viewModel.circles,
          builder: (context, circles, _) {
            if (circles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No circles available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: circles.length,
              itemBuilder: (context, index) {
                return _CircleCard(
                  circle: circles[index],
                  onTap: () => _viewModel.navigateToCircleDetail(circles[index].id),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMyCirclesTab(BuildContext context) {
    return ValueListenableBuilder<List<Circle>>(
      valueListenable: _viewModel.myCircles,
      builder: (context, circles, _) {
        if (circles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No circles joined yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: PrimaryButton(
                    label: 'Discover Circles',
                    onPressed: () => _viewModel.switchTab(0),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: circles.length,
          itemBuilder: (context, index) {
            return _CircleCard(
              circle: circles[index],
              onTap: () => _viewModel.navigateToCircleDetail(circles[index].id),
            );
          },
        );
      },
    );
  }
}

class _CircleCard extends StatelessWidget {
  final Circle circle;
  final VoidCallback onTap;

  const _CircleCard({
    required this.circle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Category Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    circle.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: circle.category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        circle.category.icon,
                        size: 14,
                        color: circle.category.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        circle.category.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: circle.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              circle.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Progress Bar and Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${circle.currentAmount.toStringAsFixed(2)} of \$${circle.goalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${circle.progressPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: circle.progressPercent / 100,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      circle.category.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Members
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${circle.memberCount} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
