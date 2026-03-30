import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/services/circle_service.dart';
import 'package:outtadebt/core/services/debt_service.dart';
import 'package:outtadebt/core/utils/http/http_abstraction.dart';
import 'package:outtadebt/core/utils/http/http_interceptor.dart';
import 'package:outtadebt/config/route_config.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/preferences/user_preferences_service.dart';

/// Called by [StartupViewModel] after resolving the initial location at runtime.
List<Module> appModulesWithLocation({
  required SharedPreferences prefs,
  required String initialLocation,
}) {
  return [
    Module<UserPreferencesService>(
      builder: () => UserPreferencesService(prefs: prefs),
      lazy: false,
    ),
    Module<RouterService>(
      builder: () =>
          RouterService(routes: routes, initialLocation: initialLocation),
      lazy: false,
    ),
    Module<NotifyService>(builder: () => NotifyService(), lazy: false),
    Module<HttpAbstraction>(
      builder: () => HttpAbstraction(
        interceptors: [LoggingInterceptor(logBody: !kReleaseMode)],
      ),
      lazy: true,
    ),

    // ── Firebase / Feature Services ───────────────────────────────────────
    Module<AuthService>(
      builder: () => AuthService(),
      lazy: false,
    ),
    Module<DebtService>(
      builder: () => DebtService(),
      lazy: true,
    ),
    Module<CircleService>(
      builder: () => CircleService(),
      lazy: true,
    ),
  ];
}

/// Legacy alias kept so any existing call sites still compile.
List<Module> appModules({required SharedPreferences prefs}) {
  final hasOnboarded = prefs.getBool('has_completed_onboarding') ?? false;
  final initialLocation =
      hasOnboarded ? RoutePaths.home : RoutePaths.onboarding;
  return appModulesWithLocation(prefs: prefs, initialLocation: initialLocation);
}
