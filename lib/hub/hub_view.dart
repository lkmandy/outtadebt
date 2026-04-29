import 'package:flutter/material.dart';
import 'package:outtadebt/core/ui/app_theme.dart';
import 'package:outtadebt/core/ui/constants/kit_colors.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/hub/hub_view_model.dart';

class HubView extends StatefulWidget {
  const HubView({super.key});

  @override
  State<HubView> createState() => _HubViewState();
}

class _HubViewState extends State<HubView> {
  late final HubViewModel _viewModel = HubViewModel(
    notifyService: locator<NotifyService>(),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hub'),
            ValueListenableBuilder<int>(
              valueListenable: _viewModel.userPoints,
              builder: (context, points, _) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.md,
                    vertical: context.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: KitColors.green600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: context.spacing.xs),
                      Text(
                        '$points pts',
                        style: context.textStyles.sm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Bar
          ValueListenableBuilder<int>(
            valueListenable: _viewModel.selectedTab,
            builder: (context, selectedTab, _) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacing.lg,
                  vertical: context.spacing.md,
                ),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Learn',
                      isSelected: selectedTab == 0,
                      onTap: () => _viewModel.switchTab(0),
                    ),
                    SizedBox(width: context.spacing.lg),
                    _TabButton(
                      label: 'Leaderboard',
                      isSelected: selectedTab == 1,
                      onTap: () => _viewModel.switchTab(1),
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab Content
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _viewModel.selectedTab,
              builder: (context, selectedTab, _) {
                if (selectedTab == 0) {
                  return _buildLearnTab(context);
                } else {
                  return _buildLeaderboardTab(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build Learn tab content
  Widget _buildLearnTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.lg,
        vertical: context.spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Course Card
          ValueListenableBuilder<List<HubCourse>>(
            valueListenable: _viewModel.courses,
            builder: (context, courses, _) {
              if (courses.isEmpty) {
                return const SizedBox.shrink();
              }

              final featured = courses.first;
              return _FeaturedCourseCard(
                course: featured,
                onTap: () => _showCourseDialog(context, featured),
              );
            },
          ),

          SizedBox(height: context.spacing.xl),

          // Courses Section
          Text(
            'Courses',
            style: context.textStyles.lg.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: context.spacing.md),

          ValueListenableBuilder<List<HubCourse>>(
            valueListenable: _viewModel.courses,
            builder: (context, courses, _) {
              if (courses.length <= 1) {
                return const SizedBox.shrink();
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: courses.length - 1,
                itemBuilder: (context, index) {
                  final course = courses[index + 1];
                  return _CourseCard(
                    course: course,
                    onTap: () => _showCourseDialog(context, course),
                  );
                },
              );
            },
          ),

          SizedBox(height: context.spacing.lg),
        ],
      ),
    );
  }

  /// Build Leaderboard tab content
  Widget _buildLeaderboardTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.lg,
        vertical: context.spacing.lg,
      ),
      child: Column(
        children: [
          // Current User's Rank Card
          ValueListenableBuilder<List<LeaderboardEntry>>(
            valueListenable: _viewModel.leaderboard,
            builder: (context, leaderboard, _) {
              final currentUser = leaderboard.firstWhere(
                (entry) => entry.isCurrentUser,
                orElse: () => LeaderboardEntry(
                  userId: '',
                  displayName: 'You',
                  points: 0,
                  rank: 0,
                  isCurrentUser: true,
                ),
              );

              return _UserRankCard(entry: currentUser);
            },
          ),

          SizedBox(height: context.spacing.xl),

          // Top Players List
          Text(
            'Top Players',
            style: context.textStyles.lg.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: context.spacing.md),

          ValueListenableBuilder<List<LeaderboardEntry>>(
            valueListenable: _viewModel.leaderboard,
            builder: (context, leaderboard, _) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = leaderboard[index];
                  return _LeaderboardRow(entry: entry);
                },
              );
            },
          ),

          SizedBox(height: context.spacing.lg),
        ],
      ),
    );
  }

  /// Show course completion dialog
  void _showCourseDialog(BuildContext context, HubCourse course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.description,
              style: context.textStyles.standard,
            ),
            SizedBox(height: context.spacing.md),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: context.kitColors.neutral500,
                ),
                SizedBox(width: context.spacing.xs),
                Text(
                  '${course.durationMinutes} min',
                  style: context.textStyles.sm.copyWith(
                    color: context.kitColors.neutral500,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.lg),
            if (!course.isCompleted)
              Text(
                'Complete this course to earn +${course.pointsReward} points',
                style: context.textStyles.sm.copyWith(
                  color: KitColors.green600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (course.isCompleted)
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  SizedBox(width: context.spacing.xs),
                  Text(
                    'Completed',
                    style: context.textStyles.sm.copyWith(
                      color: KitColors.green600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (!course.isCompleted)
            FilledButton(
              onPressed: () {
                _viewModel.markCourseComplete(course.id);
                Navigator.pop(context);
              },
              child: const Text('Complete Course'),
            ),
        ],
      ),
    );
  }
}

/// Featured course card widget
class _FeaturedCourseCard extends StatelessWidget {
  final HubCourse course;
  final VoidCallback onTap;

  const _FeaturedCourseCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: context.borderRadius.lg,
        ),
        padding: EdgeInsets.all(context.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured',
                        style: context.textStyles.xs.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: context.spacing.sm),
                      Text(
                        course.title,
                        style: context.textStyles.lg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.all(context.spacing.md),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: context.spacing.xs),
                    Text(
                      '${course.durationMinutes} min',
                      style: context.textStyles.sm.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.md,
                    vertical: context.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${course.pointsReward} pts',
                    style: context.textStyles.xs.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Course grid card widget
class _CourseCard extends StatelessWidget {
  final HubCourse course;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: context.kitColors.neutral50,
        shape: RoundedRectangleBorder(
          borderRadius: context.borderRadius.md,
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: KitColors.green600.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(context.spacing.sm),
                    child: Icon(
                      course.icon,
                      color: KitColors.green600,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: context.spacing.md),
                  Text(
                    course.title,
                    style: context.textStyles.sm.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: context.kitColors.neutral500,
                          ),
                          SizedBox(width: context.spacing.xs),
                          Text(
                            '${course.durationMinutes}m',
                            style: context.textStyles.xs.copyWith(
                              color: context.kitColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      if (course.isCompleted)
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: KitColors.green600,
                        ),
                    ],
                  ),
                  SizedBox(height: context.spacing.sm),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                      vertical: context.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: KitColors.green600.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+${course.pointsReward} pts',
                      style: context.textStyles.xs.copyWith(
                        color: KitColors.green600,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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

/// User rank card widget
class _UserRankCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _UserRankCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: context.borderRadius.md,
      ),
      child: Column(
        children: [
          Text(
            'Your Rank',
            style: context.textStyles.sm.copyWith(
              color: Colors.white70,
            ),
          ),
          SizedBox(height: context.spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${entry.rank}',
                            style: context.textStyles.lg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.spacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.displayName,
                            style: context.textStyles.standard.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${entry.points} points',
                            style: context.textStyles.sm.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.emoji_events,
                color: Colors.white70,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Leaderboard row widget
class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isCrown = entry.rank == 1;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.md,
      ),
      margin: EdgeInsets.only(bottom: context.spacing.sm),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? KitColors.green600.withValues(alpha: 0.1)
            : context.kitColors.neutral50,
        borderRadius: context.borderRadius.md,
        border: entry.isCurrentUser
            ? Border.all(
                color: KitColors.green600,
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: isCrown
                ? Icon(
                    Icons.emoji_events,
                    color: Colors.amber.shade600,
                    size: 24,
                  )
                : Text(
                    '#${entry.rank}',
                    style: context.textStyles.lg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
          ),

          // Avatar initials
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KitColors.green600.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.displayName.isNotEmpty
                    ? entry.displayName[0].toUpperCase()
                    : '?',
                style: context.textStyles.standard.copyWith(
                  color: KitColors.green600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(width: context.spacing.md),

          // Name and points
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: context.textStyles.standard.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry.points} points',
                  style: context.textStyles.xs.copyWith(
                    color: context.kitColors.neutral500,
                  ),
                ),
              ],
            ),
          ),

          // Badge for current user
          if (entry.isCurrentUser)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.xs,
              ),
              decoration: BoxDecoration(
                color: KitColors.green600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You',
                style: context.textStyles.xs.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tab button widget
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: context.textStyles.standard.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? context.theme.colorScheme.onSurface
                  : context.kitColors.neutral500,
            ),
          ),
        ),
        SizedBox(height: context.spacing.sm),
        Container(
          height: 3,
          width: 40,
          decoration: BoxDecoration(
            color: isSelected ? KitColors.green600 : Colors.transparent,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ],
    );
  }
}
