// ============================================================================
// PROVIDER TESTS FOR REFLECTACTIONS APP
// ============================================================================
// This file contains tests for all providers
// Run with: flutter test test/providers_test.dart
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:untitled3/presentation/providers/theme_provider.dart';
import 'package:untitled3/presentation/providers/enhanced_goals_provider.dart';
import 'package:untitled3/presentation/providers/analytics_provider_v4.dart';
import 'package:untitled3/presentation/providers/daily_activities_provider.dart';
import 'package:untitled3/presentation/providers/challenges_provider.dart';
import 'package:untitled3/data/models/goal_model.dart';

void main() {
  // ============================================================================
  // THEME PROVIDER TESTS
  // ============================================================================
  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('initial state is dark mode', () {
      expect(themeProvider.isDarkMode, true);
    });

    test('isDarkTheme returns same as isDarkMode', () {
      expect(themeProvider.isDarkTheme, themeProvider.isDarkMode);
    });

    test('isDark returns same as isDarkMode', () {
      expect(themeProvider.isDark, themeProvider.isDarkMode);
    });

    test('toggleTheme switches theme', () async {
      final initialMode = themeProvider.isDarkMode;
      await themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, !initialMode);
    });

    test('setTheme sets specific theme', () async {
      await themeProvider.setTheme(true);
      expect(themeProvider.isDarkMode, true);

      await themeProvider.setTheme(false);
      expect(themeProvider.isDarkMode, false);
    });

    test('getMoodColor returns color for mood score', () {
      final lowMoodColor = themeProvider.getMoodColor(2.0);
      expect(lowMoodColor, isNotNull);
      expect(lowMoodColor, isA<Color>());

      final highMoodColor = themeProvider.getMoodColor(9.0);
      expect(highMoodColor, isNotNull);
      expect(highMoodColor, isA<Color>());
    });

    test('getMoodLabel returns label for mood score', () {
      final lowMoodLabel = themeProvider.getMoodLabel(2.0);
      expect(lowMoodLabel, isNotEmpty);

      final mediumMoodLabel = themeProvider.getMoodLabel(5.0);
      expect(mediumMoodLabel, isNotEmpty);

      final highMoodLabel = themeProvider.getMoodLabel(9.0);
      expect(highMoodLabel, isNotEmpty);
    });

    test('color getters return valid colors', () {
      expect(themeProvider.primaryBg, isA<Color>());
      expect(themeProvider.surface, isA<Color>());
      expect(themeProvider.surfaceVariant, isA<Color>());
      expect(themeProvider.accentPrimary, isA<Color>());
      expect(themeProvider.accentSecondary, isA<Color>());
      expect(themeProvider.textPrimary, isA<Color>());
      expect(themeProvider.textSecondary, isA<Color>());
      expect(themeProvider.textHint, isA<Color>());
      expect(themeProvider.positiveMain, isA<Color>());
      expect(themeProvider.negativeMain, isA<Color>());
      expect(themeProvider.borderColor, isA<Color>());
      expect(themeProvider.shadowColor, isA<Color>());
    });

    test('gradient getters return valid gradients', () {
      expect(themeProvider.gradientHeader, isA<List<Color>>());
      expect(themeProvider.gradientHeader.length, greaterThanOrEqualTo(2));

      expect(themeProvider.gradientButton, isA<List<Color>>());
      expect(themeProvider.gradientButton.length, greaterThanOrEqualTo(2));
    });

    test('currentColors returns AppColors', () {
      final colors = themeProvider.currentColors;
      expect(colors, isNotNull);
    });

    test('currentThemeData returns ThemeData', () {
      final themeData = themeProvider.currentThemeData;
      expect(themeData, isA<ThemeData>());
    });

    test('secondaryBg returns color', () {
      expect(themeProvider.secondaryBg, isA<Color>());
    });

    test('positiveLight returns color', () {
      expect(themeProvider.positiveLight, isA<Color>());
    });

    test('negativeLight returns color', () {
      expect(themeProvider.negativeLight, isA<Color>());
    });

    test('mood colors differ by score range', () {
      final veryLow = themeProvider.getMoodColor(1.0);
      final low = themeProvider.getMoodColor(3.0);
      final medium = themeProvider.getMoodColor(5.0);
      final high = themeProvider.getMoodColor(7.0);
      final veryHigh = themeProvider.getMoodColor(10.0);

      // Colors should vary by mood
      expect(veryLow != veryHigh, true);
    });

    test('mood labels differ by score range', () {
      final veryLowLabel = themeProvider.getMoodLabel(1.0);
      final veryHighLabel = themeProvider.getMoodLabel(10.0);

      // Labels should be different
      expect(veryLowLabel != veryHighLabel, true);
    });
  });

  // ============================================================================
  // ENHANCED GOALS PROVIDER TESTS
  // ============================================================================
  group('EnhancedGoalsProvider', () {
    late EnhancedGoalsProvider goalsProvider;

    setUp(() {
      goalsProvider = EnhancedGoalsProvider();
    });

    test('initial state has empty goals', () {
      expect(goalsProvider.goals, isEmpty);
    });

    test('initial state is not loading', () {
      expect(goalsProvider.isLoading, false);
    });

    test('initial state has no error', () {
      expect(goalsProvider.error, isNull);
    });

    test('selectedCategory is initially null', () {
      expect(goalsProvider.selectedCategory, isNull);
    });

    test('searchQuery is initially empty', () {
      expect(goalsProvider.searchQuery, isEmpty);
    });

    test('sortOption has default value', () {
      expect(goalsProvider.sortOption, isNotEmpty);
    });

    test('filterByCategory sets category filter', () {
      goalsProvider.filterByCategory(GoalCategory.mindfulness);
      expect(goalsProvider.selectedCategory, GoalCategory.mindfulness);
    });

    test('filterByCategory with null clears filter', () {
      goalsProvider.filterByCategory(GoalCategory.mindfulness);
      goalsProvider.filterByCategory(null);
      expect(goalsProvider.selectedCategory, isNull);
    });

    test('setSearchQuery updates search query', () {
      goalsProvider.setSearchQuery('meditation');
      expect(goalsProvider.searchQuery, 'meditation');
    });

    test('setSortOption updates sort option', () {
      goalsProvider.setSortOption('progress');
      expect(goalsProvider.sortOption, 'progress');
    });

    test('clearFilters resets all filters', () {
      goalsProvider.filterByCategory(GoalCategory.mindfulness);
      goalsProvider.setSearchQuery('test');

      goalsProvider.clearFilters();

      expect(goalsProvider.selectedCategory, isNull);
      expect(goalsProvider.searchQuery, isEmpty);
    });

    test('setCategory is alias for filterByCategory', () {
      goalsProvider.setCategory(GoalCategory.sleep);
      expect(goalsProvider.selectedCategory, GoalCategory.sleep);
    });

    test('filteredGoals returns empty when no goals', () {
      expect(goalsProvider.filteredGoals, isEmpty);
    });

    test('activeGoals returns empty when no goals', () {
      expect(goalsProvider.activeGoals, isEmpty);
    });

    test('completedGoals returns empty when no goals', () {
      expect(goalsProvider.completedGoals, isEmpty);
    });

    test('goalStatistics returns statistics map', () {
      final stats = goalsProvider.goalStatistics;
      expect(stats, isNotNull);
      expect(stats, isA<Map>());
    });

    test('getStreakDataForGoal returns default for unknown goal', () {
      final streakData = goalsProvider.getStreakDataForGoal(999);
      expect(streakData, isNotNull);
    });
  });

  // ============================================================================
  // ANALYTICS PROVIDER V4 TESTS
  // ============================================================================
  group('AnalyticsProviderV4', () {
    late AnalyticsProviderV4 analyticsProvider;

    setUp(() {
      analyticsProvider = AnalyticsProviderV4();
    });

    test('initial state is not loading', () {
      expect(analyticsProvider.isLoading, false);
    });

    test('initial loading states are all false', () {
      expect(analyticsProvider.isLoadingTrends, false);
      expect(analyticsProvider.isLoadingGoals, false);
      expect(analyticsProvider.isLoadingRoadmaps, false);
      expect(analyticsProvider.isLoadingMoments, false);
    });

    test('initial state has no error', () {
      expect(analyticsProvider.error, isNull);
    });

    test('currentTimeframe has default value', () {
      expect(analyticsProvider.currentTimeframe, isNotNull);
    });

    test('wellbeingTrends is initially null or empty', () {
      // May be null or empty depending on implementation
      final trends = analyticsProvider.wellbeingTrends;
      expect(trends == null || trends.isEmpty, true);
    });

    test('goalAnalytics is initially null or empty', () {
      final analytics = analyticsProvider.goalAnalytics;
      expect(analytics == null || analytics.isEmpty, true);
    });

    test('roadsnapAnalytics is initially null or empty', () {
      final analytics = analyticsProvider.roadsnapAnalytics;
      expect(analytics == null || analytics.isEmpty, true);
    });

    test('momentsAnalytics is initially null or empty', () {
      final analytics = analyticsProvider.momentsAnalytics;
      expect(analytics == null || analytics.isEmpty, true);
    });

    test('motivationInsights is initially null or empty', () {
      final insights = analyticsProvider.motivationInsights;
      expect(insights == null || insights.isEmpty, true);
    });
  });

  // ============================================================================
  // DAILY ACTIVITIES PROVIDER TESTS
  // ============================================================================
  group('DailyActivitiesProvider', () {
    late DailyActivitiesProvider activitiesProvider;

    setUp(() {
      activitiesProvider = DailyActivitiesProvider();
    });

    test('initial state is not loading', () {
      expect(activitiesProvider.isLoading, false);
    });

    test('initial state has no error', () {
      expect(activitiesProvider.error, isNull);
    });

    test('activities list is initially empty or populated with defaults', () {
      final activities = activitiesProvider.activities;
      expect(activities, isA<List>());
    });

    test('completionPercentage is calculated', () {
      final percentage = activitiesProvider.completionPercentage;
      expect(percentage, isA<double>());
      expect(percentage, greaterThanOrEqualTo(0));
      expect(percentage, lessThanOrEqualTo(100));
    });

    test('completedCount returns count', () {
      final count = activitiesProvider.completedCount;
      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('totalActivities returns count', () {
      final total = activitiesProvider.totalActivities;
      expect(total, isA<int>());
      expect(total, greaterThanOrEqualTo(0));
    });
  });

  // ============================================================================
  // CHALLENGES PROVIDER TESTS
  // ============================================================================
  group('ChallengesProvider', () {
    late ChallengesProvider challengesProvider;

    setUp(() {
      challengesProvider = ChallengesProvider();
    });

    test('initial state is not loading', () {
      expect(challengesProvider.isLoading, false);
    });

    test('initial state has no error', () {
      expect(challengesProvider.error, isNull);
    });

    test('challenges list is initially empty', () {
      expect(challengesProvider.challenges, isEmpty);
    });

    test('activeChallenges returns empty when no challenges', () {
      expect(challengesProvider.activeChallenges, isEmpty);
    });

    test('completedChallenges returns empty when no challenges', () {
      expect(challengesProvider.completedChallenges, isEmpty);
    });
  });

  // ============================================================================
  // PROVIDER STATE TESTS
  // ============================================================================
  group('Provider State Management', () {
    test('ThemeProvider notifies listeners on theme change', () async {
      final provider = ThemeProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      await provider.toggleTheme();

      expect(notified, true);
    });

    test('EnhancedGoalsProvider notifies on filter change', () {
      final provider = EnhancedGoalsProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      provider.filterByCategory(GoalCategory.mindfulness);

      expect(notified, true);
    });

    test('EnhancedGoalsProvider notifies on search change', () {
      final provider = EnhancedGoalsProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      provider.setSearchQuery('test');

      expect(notified, true);
    });

    test('EnhancedGoalsProvider notifies on sort change', () {
      final provider = EnhancedGoalsProvider();
      var notified = false;

      provider.addListener(() {
        notified = true;
      });

      provider.setSortOption('date');

      expect(notified, true);
    });

    test('EnhancedGoalsProvider notifies on clear filters', () {
      final provider = EnhancedGoalsProvider();
      provider.filterByCategory(GoalCategory.mindfulness);
      provider.setSearchQuery('test');

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.clearFilters();

      expect(notified, true);
    });
  });

  // ============================================================================
  // PROVIDER EDGE CASES
  // ============================================================================
  group('Provider Edge Cases', () {
    test('ThemeProvider handles multiple rapid toggles', () async {
      final provider = ThemeProvider();
      final initial = provider.isDarkMode;

      await provider.toggleTheme();
      await provider.toggleTheme();
      await provider.toggleTheme();
      await provider.toggleTheme();

      // After even number of toggles, should be back to initial
      expect(provider.isDarkMode, initial);
    });

    test('EnhancedGoalsProvider handles empty search query', () {
      final provider = EnhancedGoalsProvider();
      provider.setSearchQuery('');
      expect(provider.searchQuery, isEmpty);
    });

    test('EnhancedGoalsProvider handles whitespace search query', () {
      final provider = EnhancedGoalsProvider();
      provider.setSearchQuery('   ');
      expect(provider.searchQuery, '   ');
    });

    test('ThemeProvider getMoodColor handles boundary values', () {
      final provider = ThemeProvider();

      // Test boundary values
      expect(provider.getMoodColor(0.0), isNotNull);
      expect(provider.getMoodColor(1.0), isNotNull);
      expect(provider.getMoodColor(10.0), isNotNull);
      expect(provider.getMoodColor(11.0), isNotNull);
    });

    test('ThemeProvider getMoodLabel handles boundary values', () {
      final provider = ThemeProvider();

      // Test boundary values
      expect(provider.getMoodLabel(0.0), isNotEmpty);
      expect(provider.getMoodLabel(1.0), isNotEmpty);
      expect(provider.getMoodLabel(10.0), isNotEmpty);
      expect(provider.getMoodLabel(11.0), isNotEmpty);
    });
  });

  // ============================================================================
  // PROVIDER INTEGRATION TESTS
  // ============================================================================
  group('Provider Integration', () {
    test('Multiple providers can coexist', () {
      final themeProvider = ThemeProvider();
      final goalsProvider = EnhancedGoalsProvider();
      final analyticsProvider = AnalyticsProviderV4();
      final activitiesProvider = DailyActivitiesProvider();

      expect(themeProvider, isNotNull);
      expect(goalsProvider, isNotNull);
      expect(analyticsProvider, isNotNull);
      expect(activitiesProvider, isNotNull);
    });

    test('Providers maintain independent state', () async {
      final theme1 = ThemeProvider();
      final theme2 = ThemeProvider();

      await theme1.setTheme(true);
      await theme2.setTheme(false);

      expect(theme1.isDarkMode, true);
      expect(theme2.isDarkMode, false);
    });

    test('Goals provider filters work independently', () {
      final provider1 = EnhancedGoalsProvider();
      final provider2 = EnhancedGoalsProvider();

      provider1.filterByCategory(GoalCategory.mindfulness);
      provider2.filterByCategory(GoalCategory.sleep);

      expect(provider1.selectedCategory, GoalCategory.mindfulness);
      expect(provider2.selectedCategory, GoalCategory.sleep);
    });
  });
}
