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
      builder: () => RouterService(
        routes: routes,
        initialLocation: initialLocation,
        isLoggedIn: () => prefs.getString('auth_user_id') != null,
      ),
      lazy: false,
    ),
    Module<NotifyService>(builder: () => NotifyService(), lazy: false),
    Module<HttpAbstraction>(
      builder: () => HttpAbstraction(
        interceptors: [LoggingInterceptor(logBody: !kReleaseMode)],
      ),
      lazy: true,
    ),
    Module<AuthService>(
      builder: () => AuthService(prefs: prefs),
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

List<Module> appModules({required SharedPreferences prefs}) {
  final hasOnboarded = prefs.getBool('has_completed_onboarding') ?? false;
  final isLoggedIn = prefs.getString('auth_user_id') != null;
  final initialLocation = !hasOnboarded
      ? RoutePaths.onboarding
      : !isLoggedIn
          ? RoutePaths.login
          : RoutePaths.home;
  return appModulesWithLocation(prefs: prefs, initialLocation: initialLocation);
}
