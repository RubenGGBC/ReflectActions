import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state and screen visit tracking
class OnboardingService {
  static const String _prefix = 'screen_visited_';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences _prefs;

  OnboardingService(this._prefs);

  /// Factory constructor to create instance with SharedPreferences
  static Future<OnboardingService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingService(prefs);
  }

  /// Check if a specific screen has been visited
  bool hasVisitedScreen(String screenKey) {
    return _prefs.getBool('$_prefix$screenKey') ?? false;
  }

  /// Mark a screen as visited
  Future<void> markScreenAsVisited(String screenKey) async {
    await _prefs.setBool('$_prefix$screenKey', true);
  }

  /// Check if all main screens have been visited
  bool hasCompletedOnboarding() {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark the entire onboarding as completed
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingCompletedKey, true);
  }

  /// Reset onboarding state (useful for testing)
  Future<void> resetOnboarding() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix) || key == _onboardingCompletedKey) {
        await _prefs.remove(key);
      }
    }
  }

  /// Get all visited screens
  List<String> getVisitedScreens() {
    final keys = _prefs.getKeys();
    return keys
        .where((key) => key.startsWith(_prefix) && (_prefs.getBool(key) ?? false))
        .map((key) => key.replaceFirst(_prefix, ''))
        .toList();
  }
}

/// Screen keys for the main navigation screens
class OnboardingScreens {
  static const String analytics = 'analytics';
  static const String plan = 'plan';
  static const String momentos = 'momentos';
  static const String home = 'home';
  static const String reflexion = 'reflexion';
  static const String metas = 'metas';
  static const String perfil = 'perfil';

  static const List<String> allScreens = [
    analytics,
    plan,
    momentos,
    home,
    reflexion,
    metas,
    perfil,
  ];
}
