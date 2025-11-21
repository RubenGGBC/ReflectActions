// ============================================================================
// data/services/analytics_database_extension_v4_simple.dart
// V4 ANALYTICS DATABASE EXTENSION - SIMPLIFIED VERSION FOR EXISTING TABLES
// ============================================================================

import 'dart:math' as math;
import '../../data/models/daily_entry_model.dart';
import '../../data/models/interactive_moment_model.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/daily_roadmap_model.dart';
import 'optimized_database_service.dart';

// ============================================================================
// SIMPLIFIED V4 ANALYTICS DATA MODELS
// ============================================================================

class SimpleAnalyticsTimeframe {
  final DateTime startDate;
  final DateTime endDate;
  final String label;
  
  SimpleAnalyticsTimeframe({
    required this.startDate,
    required this.endDate,
    required this.label,
  });
  
  static SimpleAnalyticsTimeframe last7Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    return SimpleAnalyticsTimeframe(
      startDate: start,
      endDate: end,
      label: 'Last 7 Days',
    );
  }
  
  static SimpleAnalyticsTimeframe last30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return SimpleAnalyticsTimeframe(
      startDate: start,
      endDate: end,
      label: 'Last 30 Days',
    );
  }
}

class SimpleWellbeingTrend {
  final String metric;
  final List<SimpleDataPoint> dataPoints;
  final double averageValue;
  final String trendDirection;
  final double improvementPercentage;
  
  SimpleWellbeingTrend({
    required this.metric,
    required this.dataPoints,
    required this.averageValue,
    required this.trendDirection,
    required this.improvementPercentage,
  });
}

class SimpleDataPoint {
  final DateTime date;
  final double value;
  
  SimpleDataPoint({
    required this.date,
    required this.value,
  });
}

class SimpleGoalAnalytics {
  final int totalGoals;
  final int completedGoals;
  final int activeGoals;
  final double completionRate;
  final Map<String, int> goalsByCategory;
  
  SimpleGoalAnalytics({
    required this.totalGoals,
    required this.completedGoals,
    required this.activeGoals,
    required this.completionRate,
    required this.goalsByCategory,
  });
}

class SimpleQuickMomentsAnalytics {
  final int totalMoments;
  final Map<String, int> momentsByType;
  final double positivityRatio;
  final Map<String, int> momentsByTimeOfDay;
  
  SimpleQuickMomentsAnalytics({
    required this.totalMoments,
    required this.momentsByType,
    required this.positivityRatio,
    required this.momentsByTimeOfDay,
  });
}

class SimpleUserMotivationInsights {
  final List<String> achievements;
  final List<String> improvements;
  final List<String> recommendations;
  final double motivationScore;
  final String primaryMotivationFactor;
  
  SimpleUserMotivationInsights({
    required this.achievements,
    required this.improvements,
    required this.recommendations,
    required this.motivationScore,
    required this.primaryMotivationFactor,
  });
}

// ============================================================================
// SIMPLIFIED V4 ANALYTICS DATABASE EXTENSION
// ============================================================================

extension SimpleAnalyticsDatabaseExtensionV4 on OptimizedDatabaseService {
  
  // ============================================================================
  // SIMPLIFIED WELLBEING TRENDS
  // ============================================================================
  
  Future<List<SimpleWellbeingTrend>> getSimpleWellbeingTrends(
    int userId, 
    SimpleAnalyticsTimeframe timeframe
  ) async {
    final db = await database;
    
    try {
      // Get daily entries within timeframe
      final results = await db.query(
        'daily_entries',
        where: 'user_id = ? AND entry_date BETWEEN ? AND ?',
        whereArgs: [
          userId,
          timeframe.startDate.toIso8601String().split('T')[0],
          timeframe.endDate.toIso8601String().split('T')[0],
        ],
        orderBy: 'entry_date ASC',
      );
      
      final entries = results.map((map) => DailyEntryModel.fromDatabase(map)).toList();
      
      if (entries.isEmpty) {
        return [];
      }
      
      final trends = <SimpleWellbeingTrend>[];
      
      // Mood Score Trend
      trends.add(_calculateSimpleTrend('Mood Score', entries, (entry) => entry.moodScore?.toDouble()));
      
      // Add other metrics if they exist
      if (entries.any((e) => e.energyLevel != null)) {
        trends.add(_calculateSimpleTrend('Energy Level', entries, (entry) => entry.energyLevel?.toDouble()));
      }
      
      if (entries.any((e) => e.sleepQuality != null)) {
        trends.add(_calculateSimpleTrend('Sleep Quality', entries, (entry) => entry.sleepQuality?.toDouble()));
      }
      
      if (entries.any((e) => e.stressLevel != null)) {
        trends.add(_calculateSimpleTrend('Stress Level', entries, (entry) => 
          entry.stressLevel != null ? 10.0 - entry.stressLevel!.toDouble() : null));
      }
      
      if (entries.any((e) => e.motivationLevel != null)) {
        trends.add(_calculateSimpleTrend('Motivation Level', entries, (entry) => entry.motivationLevel?.toDouble()));
      }
      
      return trends.where((trend) => trend.dataPoints.isNotEmpty).toList();
    } catch (e) {
      print('Error getting wellbeing trends: $e');
      return [];
    }
  }
  
  SimpleWellbeingTrend _calculateSimpleTrend(
    String metric,
    List<DailyEntryModel> entries,
    double? Function(DailyEntryModel) valueExtractor,
  ) {
    final dataPoints = <SimpleDataPoint>[];
    final values = <double>[];
    
    for (final entry in entries) {
      final value = valueExtractor(entry);
      if (value != null && value > 0) {
        dataPoints.add(SimpleDataPoint(date: entry.entryDate, value: value));
        values.add(value);
      }
    }
    
    if (values.isEmpty) {
      return SimpleWellbeingTrend(
        metric: metric,
        dataPoints: [],
        averageValue: 0.0,
        trendDirection: 'stable',
        improvementPercentage: 0.0,
      );
    }
    
    final averageValue = values.reduce((a, b) => a + b) / values.length;
    final trendDirection = _getSimpleTrendDirection(values);
    final improvementPercentage = _calculateSimpleImprovement(values);
    
    return SimpleWellbeingTrend(
      metric: metric,
      dataPoints: dataPoints,
      averageValue: averageValue,
      trendDirection: trendDirection,
      improvementPercentage: improvementPercentage,
    );
  }
  
  String _getSimpleTrendDirection(List<double> values) {
    if (values.length < 3) return 'stable';
    
    final firstHalf = values.take(values.length ~/ 2).toList();
    final secondHalf = values.skip(values.length ~/ 2).toList();
    
    if (firstHalf.isEmpty || secondHalf.isEmpty) return 'stable';
    
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    
    final difference = secondAvg - firstAvg;
    
    if (difference > 0.5) return 'improving';
    if (difference < -0.5) return 'declining';
    return 'stable';
  }
  
  double _calculateSimpleImprovement(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final firstQuarter = values.take(values.length ~/ 4).toList();
    final lastQuarter = values.skip((values.length * 3) ~/ 4).toList();
    
    if (firstQuarter.isEmpty || lastQuarter.isEmpty) return 0.0;
    
    final firstAvg = firstQuarter.reduce((a, b) => a + b) / firstQuarter.length;
    final lastAvg = lastQuarter.reduce((a, b) => a + b) / lastQuarter.length;
    
    if (firstAvg == 0) return 0.0;
    
    return ((lastAvg - firstAvg) / firstAvg) * 100;
  }
  
  // ============================================================================
  // SIMPLIFIED GOALS ANALYTICS
  // ============================================================================
  
  Future<SimpleGoalAnalytics> getSimpleGoalAnalytics(int userId, SimpleAnalyticsTimeframe timeframe) async {
    final db = await database;
    
    try {
      // Get all goals for user
      final results = await db.query(
        'user_goals',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      final goals = results.map((map) => GoalModel.fromDatabase(map)).toList();
      
      final totalGoals = goals.length;
      final completedGoals = goals.where((g) => g.status == GoalStatus.completed).length;
      final activeGoals = goals.where((g) => g.status == GoalStatus.active).length;
      final completionRate = totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0;
      
      // Group by category
      final goalsByCategory = <String, int>{};
      for (final goal in goals) {
        final categoryName = goal.category.toString().split('.').last;
        goalsByCategory[categoryName] = (goalsByCategory[categoryName] ?? 0) + 1;
      }
      
      return SimpleGoalAnalytics(
        totalGoals: totalGoals,
        completedGoals: completedGoals,
        activeGoals: activeGoals,
        completionRate: completionRate,
        goalsByCategory: goalsByCategory,
      );
    } catch (e) {
      print('Error getting goal analytics: $e');
      return SimpleGoalAnalytics(
        totalGoals: 0,
        completedGoals: 0,
        activeGoals: 0,
        completionRate: 0.0,
        goalsByCategory: {},
      );
    }
  }
  
  // ============================================================================
  // SIMPLIFIED QUICK MOMENTS ANALYTICS
  // ============================================================================
  
  Future<SimpleQuickMomentsAnalytics> getSimpleQuickMomentsAnalytics(int userId, SimpleAnalyticsTimeframe timeframe) async {
    final db = await database;
    
    try {
      // Get interactive moments within timeframe
      final results = await db.query(
        'interactive_moments',
        where: 'user_id = ? AND entry_date BETWEEN ? AND ?',
        whereArgs: [
          userId,
          timeframe.startDate.toIso8601String().split('T')[0],
          timeframe.endDate.toIso8601String().split('T')[0],
        ],
        orderBy: 'created_at ASC',
      );
      
      final moments = results.map((map) => InteractiveMomentModel.fromDatabase(map)).toList();
      
      final totalMoments = moments.length;
      
      // Group by type
      final momentsByType = <String, int>{};
      for (final moment in moments) {
        momentsByType[moment.type] = (momentsByType[moment.type] ?? 0) + 1;
      }
      
      // Moments by time of day
      final momentsByTimeOfDay = <String, int>{};
      for (final moment in moments) {
        final hour = moment.timestamp.hour;
        String timeOfDay;
        if (hour >= 5 && hour < 12) {
          timeOfDay = 'Mañana';
        } else if (hour >= 12 && hour < 17) {
          timeOfDay = 'Tarde';
        } else if (hour >= 17 && hour < 21) {
          timeOfDay = 'Atardecer';
        } else {
          timeOfDay = 'Noche';
        }
        momentsByTimeOfDay[timeOfDay] = (momentsByTimeOfDay[timeOfDay] ?? 0) + 1;
      }
      
      // Positivity ratio
      final positiveMoments = momentsByType['positive'] ?? 0;
      final positivityRatio = totalMoments > 0 
          ? (positiveMoments / totalMoments) * 100 
          : 0.0;
      
      return SimpleQuickMomentsAnalytics(
        totalMoments: totalMoments,
        momentsByType: momentsByType,
        positivityRatio: positivityRatio,
        momentsByTimeOfDay: momentsByTimeOfDay,
      );
    } catch (e) {
      print('Error getting moments analytics: $e');
      return SimpleQuickMomentsAnalytics(
        totalMoments: 0,
        momentsByType: {},
        positivityRatio: 0.0,
        momentsByTimeOfDay: {},
      );
    }
  }
  
  // ============================================================================
  // SIMPLIFIED MOTIVATION INSIGHTS
  // ============================================================================
  
  Future<SimpleUserMotivationInsights> generateSimpleMotivationInsights(
    int userId,
    SimpleAnalyticsTimeframe timeframe,
  ) async {
    try {
      final wellbeingTrends = await getSimpleWellbeingTrends(userId, timeframe);
      final goalAnalytics = await getSimpleGoalAnalytics(userId, timeframe);
      final momentsAnalytics = await getSimpleQuickMomentsAnalytics(userId, timeframe);
      
      final achievements = <String>[];
      final improvements = <String>[];
      final recommendations = <String>[];
      
      // Generate achievements
      if (goalAnalytics.completionRate > 50) {
        achievements.add('🏆 Goal Achievement: ${goalAnalytics.completionRate.toStringAsFixed(0)}% completion rate!');
      }
      
      if (momentsAnalytics.positivityRatio > 60) {
        achievements.add('😊 Positive Mindset: ${momentsAnalytics.positivityRatio.toStringAsFixed(0)}% positive moments!');
      }
      
      if (momentsAnalytics.totalMoments > 20) {
        achievements.add('📝 Active Tracking: ${momentsAnalytics.totalMoments} moments recorded!');
      }
      
      // Generate improvements
      for (final trend in wellbeingTrends) {
        if (trend.trendDirection == 'improving' && trend.improvementPercentage > 5) {
          improvements.add('📈 ${trend.metric}: +${trend.improvementPercentage.toStringAsFixed(0)}% improvement');
        }
      }
      
      // Generate recommendations
      if (goalAnalytics.completionRate < 30) {
        recommendations.add('🎯 Consider setting smaller, more achievable goals');
      }
      
      if (momentsAnalytics.positivityRatio < 40) {
        recommendations.add('🌟 Try focusing on positive moments throughout the day');
      }
      
      if (wellbeingTrends.isEmpty) {
        recommendations.add('📊 Start tracking your daily reflections to see progress');
      }
      
      // Calculate motivation score
      double motivationScore = 5.0; // Base score
      
      if (goalAnalytics.completionRate > 0) {
        motivationScore += (goalAnalytics.completionRate / 100) * 2;
      }
      
      if (momentsAnalytics.positivityRatio > 0) {
        motivationScore += (momentsAnalytics.positivityRatio / 100) * 2;
      }
      
      if (improvements.isNotEmpty) {
        motivationScore += 1.0;
      }
      
      motivationScore = math.min(motivationScore, 10.0);
      
      // Determine primary motivation factor
      String primaryFactor = 'Getting Started';
      if (goalAnalytics.completionRate > 50) {
        primaryFactor = 'Goal Achievement';
      } else if (momentsAnalytics.positivityRatio > 60) {
        primaryFactor = 'Positive Mindset';
      } else if (improvements.isNotEmpty) {
        primaryFactor = 'Personal Growth';
      }
      
      return SimpleUserMotivationInsights(
        achievements: achievements,
        improvements: improvements,
        recommendations: recommendations,
        motivationScore: motivationScore,
        primaryMotivationFactor: primaryFactor,
      );
    } catch (e) {
      print('Error generating motivation insights: $e');
      return SimpleUserMotivationInsights(
        achievements: [],
        improvements: [],
        recommendations: ['📊 Start using the app regularly to see insights!'],
        motivationScore: 5.0,
        primaryMotivationFactor: 'Getting Started',
      );
    }
  }
}