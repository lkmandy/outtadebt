import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:outtadebt/add_debt/add_debt_view.dart';
import 'package:outtadebt/auth/login_view.dart';
import 'package:outtadebt/auth/signup_view.dart';
import 'package:outtadebt/circles/circle_detail_view.dart';
import 'package:outtadebt/circles/circles_view.dart';
import 'package:outtadebt/circles/create_circle_view.dart';
import 'package:outtadebt/home/home_view.dart';
import 'package:outtadebt/hub/hub_view.dart';
import 'package:outtadebt/not_found/not_found_view.dart';
import 'package:outtadebt/onboarding/onboarding_view.dart';
import 'package:outtadebt/progress/progress_view.dart';
import 'package:outtadebt/shell/shell_view.dart';

abstract final class RoutePaths {
  // Auth
  static const login = '/login';
  static const signup = '/signup';

  // Onboarding
  static const onboarding = '/onboarding';

  // Shell branches (bottom nav)
  static const home = '/';
  static const circles = '/circles';
  static const circleDetail = '/circles/:id';
  static const createCircle = '/circles/create';
  static const progress = '/progress';
  static const hub = '/hub';

  // Feature flows
  static const addDebt = '/add-debt';

  // Utility
  static const notFound = '/404';
}

final routes = [
  // ── Auth routes (outside shell) ──────────────────────────────────────────
  GoRoute(
    path: RoutePaths.login,
    pageBuilder: (context, state) => _buildPage(const LoginView(), state),
  ),
  GoRoute(
    path: RoutePaths.signup,
    pageBuilder: (context, state) => _buildPage(const SignupView(), state),
  ),

  // ── Onboarding (outside shell) ───────────────────────────────────────────
  GoRoute(
    path: RoutePaths.onboarding,
    pageBuilder: (context, state) => _buildPage(const OnboardingView(), state),
  ),

  // ── Add Debt (full-screen modal, outside shell) ───────────────────────────
  GoRoute(
    path: RoutePaths.addDebt,
    pageBuilder: (context, state) => _buildPage(const AddDebtView(), state),
  ),

  // ── Shell with persistent bottom navigation ───────────────────────────────
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        ShellView(navigationShell: navigationShell),
    branches: [
      // Branch 0 — Home
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) =>
                _buildPage(const HomeView(), state),
          ),
        ],
      ),
      // Branch 1 — Circles
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.circles,
            pageBuilder: (context, state) =>
                _buildPage(const CirclesView(), state),
            routes: [
              GoRoute(
                path: 'create',
                pageBuilder: (context, state) =>
                    _buildPage(const CreateCircleView(), state),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _buildPage(CircleDetailView(circleId: id), state);
                },
              ),
            ],
          ),
        ],
      ),
      // Branch 2 — Progress
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.progress,
            pageBuilder: (context, state) =>
                _buildPage(const ProgressView(), state),
          ),
        ],
      ),
      // Branch 3 — Hub
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: RoutePaths.hub,
            pageBuilder: (context, state) =>
                _buildPage(const HubView(), state),
          ),
        ],
      ),
    ],
  ),

  // ── 404 ──────────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.notFound,
    pageBuilder: (context, state) => _buildPage(const NotFoundView(), state),
  ),
];

// ── Page transition helper ───────────────────────────────────────────────────
Page<void> _buildPage(Widget child, GoRouterState state) {
  if (kIsWeb) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }
  return MaterialPage<void>(key: state.pageKey, child: child);
}
