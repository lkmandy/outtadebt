import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  UserPreferencesService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static const _onboardingCompleteKey = 'has_completed_onboarding';

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }
}