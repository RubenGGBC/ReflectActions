import 'package:flutter/material.dart';
import '../../data/services/onboarding_service.dart';

/// Provider to manage onboarding state across the app
class OnboardingProvider extends ChangeNotifier {
  final OnboardingService _onboardingService;

  bool _isInitialized = false;
  String? _currentOnboardingScreen;
  bool _isShowingOnboarding = false;

  OnboardingProvider(this._onboardingService);

  bool get isInitialized => _isInitialized;
  String? get currentOnboardingScreen => _currentOnboardingScreen;
  bool get isShowingOnboarding => _isShowingOnboarding;

  /// Initialize the provider
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  /// Check if a screen needs onboarding
  bool shouldShowOnboarding(String screenKey) {
    return !_onboardingService.hasVisitedScreen(screenKey);
  }

  /// Start showing onboarding for a screen
  void startOnboarding(String screenKey) {
    _currentOnboardingScreen = screenKey;
    _isShowingOnboarding = true;
    notifyListeners();
  }

  /// Complete onboarding for the current screen
  Future<void> completeCurrentScreenOnboarding() async {
    if (_currentOnboardingScreen != null) {
      await _onboardingService.markScreenAsVisited(_currentOnboardingScreen!);
      _currentOnboardingScreen = null;
      _isShowingOnboarding = false;

      // Check if all screens have been visited
      if (_hasVisitedAllScreens()) {
        await _onboardingService.completeOnboarding();
      }

      notifyListeners();
    }
  }

  /// Skip onboarding for the current screen (same as complete)
  Future<void> skipCurrentScreenOnboarding() async {
    await completeCurrentScreenOnboarding();
  }

  /// Check if all main screens have been visited
  bool _hasVisitedAllScreens() {
    return OnboardingScreens.allScreens.every(
      (screen) => _onboardingService.hasVisitedScreen(screen),
    );
  }

  /// Get completion progress (0.0 to 1.0)
  double getProgress() {
    final visited = OnboardingScreens.allScreens
        .where((screen) => _onboardingService.hasVisitedScreen(screen))
        .length;
    return visited / OnboardingScreens.allScreens.length;
  }

  /// Check if onboarding is fully completed
  bool isOnboardingCompleted() {
    return _onboardingService.hasCompletedOnboarding();
  }

  /// Reset all onboarding (for testing/debugging)
  Future<void> resetOnboarding() async {
    await _onboardingService.resetOnboarding();
    _currentOnboardingScreen = null;
    _isShowingOnboarding = false;
    notifyListeners();
  }

  /// Get list of visited screens
  List<String> getVisitedScreens() {
    return _onboardingService.getVisitedScreens();
  }
}
