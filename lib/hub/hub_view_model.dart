import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/utils/internal_notification/toast/toast_event.dart';

/// Model for a course in the Hub
class HubCourse {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationMinutes;
  final bool isCompleted;
  final int pointsReward;
  final IconData icon;

  HubCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    required this.isCompleted,
    required this.pointsReward,
    required this.icon,
  });
}

/// Model for a leaderboard entry
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int points;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.points,
    required this.rank,
    required this.isCurrentUser,
  });
}

class HubViewModel extends ChangeNotifier {
  final NotifyService _notifyService;
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  // ValueNotifiers for reactive state
  final ValueNotifier<int> userPoints = ValueNotifier<int>(0);
  final ValueNotifier<int> userStars = ValueNotifier<int>(0);
  final ValueNotifier<List<HubCourse>> courses = ValueNotifier<List<HubCourse>>([]);
  final ValueNotifier<List<LeaderboardEntry>> leaderboard =
      ValueNotifier<List<LeaderboardEntry>>([]);
  final ValueNotifier<int> selectedTab = ValueNotifier<int>(0);

  HubViewModel({
    required NotifyService notifyService,
    required AuthService authService,
    FirebaseFirestore? firestore,
  })  : _notifyService = notifyService,
        _authService = authService,
        _firestore = firestore ?? FirebaseFirestore.instance {
    initializeHub();
  }

  /// Initialize the Hub with mock data and load from Firestore
  Future<void> initializeHub() async {
    try {
      await _loadUserPoints();
      _loadMockCourses();
      _loadMockLeaderboard();
    } catch (e) {
      _loadMockCourses();
      _loadMockLeaderboard();
    }
    notifyListeners();
  }

  /// Load user points from Firestore
  Future<void> _loadUserPoints() async {
    final userId = _authService.userId.value;
    if (userId == null) {
      userPoints.value = 0;
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        userPoints.value = doc['points'] as int? ?? 0;
        userStars.value = doc['stars'] as int? ?? 0;
      } else {
        userPoints.value = 0;
        userStars.value = 0;
      }
    } catch (e) {
      userPoints.value = 0;
      userStars.value = 0;
    }
  }

  /// Load mock courses
  void _loadMockCourses() {
    courses.value = [
      HubCourse(
        id: '1',
        title: 'The Debt Avalanche',
        description:
            'Learn the debt avalanche method to prioritize high-interest debt first.',
        category: 'Strategies',
        durationMinutes: 12,
        isCompleted: false,
        pointsReward: 50,
        icon: Icons.trending_down,
      ),
      HubCourse(
        id: '2',
        title: 'Budgeting Basics',
        description: 'Master the fundamentals of creating and maintaining a budget.',
        category: 'Budgeting',
        durationMinutes: 15,
        isCompleted: false,
        pointsReward: 75,
        icon: Icons.pie_chart,
      ),
      HubCourse(
        id: '3',
        title: 'Building an Emergency Fund',
        description: 'Discover how to save 3-6 months of expenses safely.',
        category: 'Saving',
        durationMinutes: 10,
        isCompleted: false,
        pointsReward: 60,
        icon: Icons.savings,
      ),
      HubCourse(
        id: '4',
        title: 'Credit Score Mastery',
        description:
            'Understand credit scores and how to improve yours dramatically.',
        category: 'Credit',
        durationMinutes: 18,
        isCompleted: false,
        pointsReward: 85,
        icon: Icons.grade,
      ),
      HubCourse(
        id: '5',
        title: 'Investment 101',
        description: 'Start your investment journey with this beginner-friendly guide.',
        category: 'Investing',
        durationMinutes: 20,
        isCompleted: false,
        pointsReward: 100,
        icon: Icons.trending_up,
      ),
    ];
  }

  /// Load mock leaderboard
  void _loadMockLeaderboard() {
    final currentUserId = _authService.userId.value ?? 'user123';
    leaderboard.value = [
      LeaderboardEntry(
        userId: 'user001',
        displayName: 'Sarah M.',
        points: 2450,
        rank: 1,
        isCurrentUser: currentUserId == 'user001',
      ),
      LeaderboardEntry(
        userId: 'user002',
        displayName: 'James H.',
        points: 2180,
        rank: 2,
        isCurrentUser: currentUserId == 'user002',
      ),
      LeaderboardEntry(
        userId: 'user003',
        displayName: 'Emma L.',
        points: 1950,
        rank: 3,
        isCurrentUser: currentUserId == 'user003',
      ),
      LeaderboardEntry(
        userId: currentUserId,
        displayName: 'You',
        points: userPoints.value,
        rank: 5,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        userId: 'user004',
        displayName: 'Michael C.',
        points: 1650,
        rank: 4,
        isCurrentUser: currentUserId == 'user004',
      ),
    ];

    // Sort by points descending and update ranks
    leaderboard.value.sort((a, b) => b.points.compareTo(a.points));
    for (int i = 0; i < leaderboard.value.length; i++) {
      leaderboard.value[i] = LeaderboardEntry(
        userId: leaderboard.value[i].userId,
        displayName: leaderboard.value[i].displayName,
        points: leaderboard.value[i].points,
        rank: i + 1,
        isCurrentUser: leaderboard.value[i].isCurrentUser,
      );
    }
  }

  /// Mark a course as complete and add points
  Future<void> markCourseComplete(String courseId) async {
    try {
      final course = courses.value.firstWhere((c) => c.id == courseId);
      if (course.isCompleted) {
        _notifyService.setToastEvent(
          ToastEventInfo(message: 'Already completed!'),
        );
        return;
      }

      // Update course completion
      final updatedCourses = courses.value.map((c) {
        if (c.id == courseId) {
          return HubCourse(
            id: c.id,
            title: c.title,
            description: c.description,
            category: c.category,
            durationMinutes: c.durationMinutes,
            isCompleted: true,
            pointsReward: c.pointsReward,
            icon: c.icon,
          );
        }
        return c;
      }).toList();

      courses.value = updatedCourses;

      // Add points
      userPoints.value += course.pointsReward;
      userStars.value += 1;

      // Update Firestore
      final userId = _authService.userId.value;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'points': userPoints.value,
          'stars': userStars.value,
        });
      }

      _notifyService.setToastEvent(
        ToastEventSuccess(message: '+${course.pointsReward} points earned!'),
      );

      notifyListeners();
    } catch (e) {
      _notifyService.setToastEvent(
        ToastEventError(message: 'Error completing course'),
      );
    }
  }

  /// Switch between Learn and Leaderboard tabs
  void switchTab(int tabIndex) {
    selectedTab.value = tabIndex;
    notifyListeners();
  }

  @override
  void dispose() {
    userPoints.dispose();
    userStars.dispose();
    courses.dispose();
    leaderboard.dispose();
    selectedTab.dispose();
    super.dispose();
  }
}
