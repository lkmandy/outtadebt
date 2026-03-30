import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outtadebt/config/locator_config.dart';
import 'package:outtadebt/config/route_config.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/abstractions/logging_abstraction.dart';
import 'package:logging/logging.dart';

sealed class AppState { const AppState(); }
class InitializingApp extends AppState { const InitializingApp(); }
class AppInitialized extends AppState { const AppInitialized(); }
class AppInitializationError extends AppState {
  final Object error;
  final StackTrace stackTrace;
  const AppInitializationError(this.error, this.stackTrace);
}

class StartupViewModel {
  StartupViewModel({
    required SharedPreferences prefs,
    LoggingAbstraction? loggingAbstraction,
  }) : _prefs = prefs,
       _loggingAbstraction = loggingAbstraction ?? LoggingAbstraction();

  final SharedPreferences _prefs;
  final LoggingAbstraction _loggingAbstraction;
  final appStateNotifier = ValueNotifier<AppState>(const InitializingApp());
  late StreamSubscription<LogRecord> loggingSubscription;

  Future<void> initializeApp() async {
    appStateNotifier.value = const InitializingApp();
    try {
      // Determine initial route based on onboarding and auth state
      final hasOnboarded = _prefs.getBool('has_completed_onboarding') ?? false;
      final currentUser = FirebaseAuth.instance.currentUser;

      final String initialLocation;
      if (!hasOnboarded) {
        initialLocation = RoutePaths.onboarding;
      } else if (currentUser == null) {
        initialLocation = RoutePaths.login;
      } else {
        initialLocation = RoutePaths.home;
      }

      // Override the locator with the computed initial location
      locator.registerMany(appModulesWithLocation(
        prefs: _prefs,
        initialLocation: initialLocation,
      ));

      loggingSubscription = _loggingAbstraction.initializeLogging();
      appStateNotifier.value = const AppInitialized();
    } catch (e, st) {
      appStateNotifier.value = AppInitializationError(e, st);
    }
  }

  Future<void> retryInitialization() async {
    locator.reset();
    await initializeApp();
  }

  void dispose() {
    appStateNotifier.dispose();
    loggingSubscription.cancel();
  }
}
