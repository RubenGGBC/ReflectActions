// ============================================================================
// data/services/analytics_database_extension_v4.dart
// V4 ANALYTICS DATABASE EXTENSION - ADVANCED STATISTICAL METHODS
// ============================================================================

import 'dart:math' as math;
import '../../data/models/daily_entry_model.dart';
import '../../data/models/interactive_moment_model.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/daily_roadmap_model.dart';
import 'optimized_database_service.dart';

// ============================================================================
// V4 ANALYTICS DATA MODELS
// ============================================================================

class AnalyticsTimeframe {
  final DateTime startDate;
  final DateTime endDate;
  final String label;
  
  AnalyticsTimeframe({
    required this.startDate,
    required this.endDate,
    required this.label,
  });
  
  static AnalyticsTimeframe last7Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    return AnalyticsTimeframe(
      startDate: start,
      endDate: end,
      label: 'Last 7 Days',
    );
  }
  
  static AnalyticsTimeframe last30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return AnalyticsTimeframe(
      startDate: start,
      endDate: end,
      label: 'Last 30 Days',
    );
  }
}

class WellbeingTrend {
  final String metric;
  final List<DataPoint> dataPoints;
  final double averageValue;
  final double trendSlope;
  final String trendDirection;
  final double improvementPercentage;
  
  WellbeingTrend({
    required this.metric,
    required this.dataPoints,
    required this.averageValue,
    required this.trendSlope,
    required this.trendDirection,
    required this.improvementPercentage,
  });
}

class DataPoint {
  final DateTime date;
  final double value;
  final String? label;
  
  DataPoint({
    required this.date,
    required this.value,
    this.label,
  });
}

class GoalAnalytics {
  final int totalGoals;
  final int completedGoals;
  final int activeGoals;
  final double completionRate;
  final Map<GoalCategory, int> goalsByCategory;
  final List<GoalStreakInfo> streaks;
  final double averageCompletionTime;
  
  GoalAnalytics({
    required this.totalGoals,
    required this.completedGoals,
    required this.activeGoals,
    required this.completionRate,
    required this.goalsByCategory,
    required this.streaks,
    required this.averageCompletionTime,
  });
}

class GoalStreakInfo {
  final GoalCategory category;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletionDate;
  
  GoalStreakInfo({
    required this.category,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletionDate,
  });
}

class RoadmapAnalytics {
  final int totalRoadmaps;
  final int completedRoadmaps;
  final double averageCompletionRate;
  final Map<String, double> activityCategoryCompletion;
  final int currentStreak;
  final List<DataPoint> completionTrend;
  
  RoadmapAnalytics({
    required this.totalRoadmaps,
    required this.completedRoadmaps,
    required this.averageCompletionRate,
    required this.activityCategoryCompletion,
    required this.currentStreak,
    required this.completionTrend,
  });
}

class QuickMomentsAnalytics {
  final int totalMoments;
  final Map<String, int> momentsByType;
  final Map<String, double> averageIntensityByCategory;
  final List<DataPoint> sentimentTrend;
  final Map<String, int> momentsByTimeOfDay;
  final double positivityRatio;
  
  QuickMomentsAnalytics({
    required this.totalMoments,
    required this.momentsByType,
    required this.averageIntensityByCategory,
    required this.sentimentTrend,
    required this.momentsByTimeOfDay,
    required this.positivityRatio,
  });
}

class UserMotivationInsights {
  final List<String> achievements;
  final List<String> improvements;
  final List<String> recommendations;
  final double motivationScore;
  final String primaryMotivationFactor;
  
  UserMotivationInsights({
    required this.achievements,
    required this.improvements,
    required this.recommendations,
    required this.motivationScore,
    required this.primaryMotivationFactor,
  });
}

// ============================================================================
// V4 ANALYTICS DATABASE EXTENSION
// ============================================================================

extension AnalyticsDatabaseExtensionV4 on OptimizedDatabaseService {
  
  // ============================================================================
  // DAILY ENTRY ANALYTICS METHODS
  // ============================================================================
  
  Future<List<WellbeingTrend>> getWellbeingTrends(
    int userId, 
    AnalyticsTimeframe timeframe
  ) async {
    final db = await database;
    
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
    
    // Calculate trends for key metrics
    final trends = <WellbeingTrend>[];
    
    // Mood Score Trend
    if (entries.isNotEmpty) {
      trends.add(_calculateTrend('Mood Score', entries, (entry) => entry.moodScore?.toDouble()));
      trends.add(_calculateTrend('Energy Level', entries, (entry) => entry.energyLevel?.toDouble()));
      trends.add(_calculateTrend('Sleep Quality', entries, (entry) => entry.sleepQuality?.toDouble()));
      trends.add(_calculateTrend('Stress Level', entries, (entry) => 
        entry.stressLevel != null ? 10.0 - entry.stressLevel!.toDouble() : null)); // Invert stress
      trends.add(_calculateTrend('Motivation Level', entries, (entry) => entry.motivationLevel?.toDouble()));
      trends.add(_calculateTrend('Life Satisfaction', entries, (entry) => entry.lifeSatisfaction?.toDouble()));
    }
    
    return trends.where((trend) => trend.dataPoints.isNotEmpty).toList();
  }
  
  WellbeingTrend _calculateTrend(
    String metric,
    List<DailyEntryModel> entries,
    double? Function(DailyEntryModel) valueExtractor,
  ) {
    final dataPoints = <DataPoint>[];
    final values = <double>[];
    
    for (final entry in entries) {
      final value = valueExtractor(entry);
      if (value != null) {
        dataPoints.add(DataPoint(date: entry.entryDate, value: value));
        values.add(value);
      }
    }
    
    if (values.isEmpty) {
      return WellbeingTrend(
        metric: metric,
        dataPoints: [],
        averageValue: 0.0,
        trendSlope: 0.0,
        trendDirection: 'stable',
        improvementPercentage: 0.0,
      );
    }
    
    final averageValue = values.reduce((a, b) => a + b) / values.length;
    final trendSlope = _calculateLinearTrendSlope(dataPoints);
    final trendDirection = _getTrendDirection(trendSlope);
    final improvementPercentage = _calculateImprovement(values);
    
    return WellbeingTrend(
      metric: metric,
      dataPoints: dataPoints,
      averageValue: averageValue,
      trendSlope: trendSlope,
      trendDirection: trendDirection,
      improvementPercentage: improvementPercentage,
    );
  }
  
  double _calculateLinearTrendSlope(List<DataPoint> points) {
    if (points.length < 2) return 0.0;
    
    final n = points.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble(); // Use index as X
      final y = points[i].value;
      
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope.isNaN ? 0.0 : slope;
  }
  
  String _getTrendDirection(double slope) {
    if (slope > 0.1) return 'improving';
    if (slope < -0.1) return 'declining';
    return 'stable';
  }
  
  double _calculateImprovement(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final firstQuarter = values.take(values.length ~/ 4).toList();
    final lastQuarter = values.skip((values.length * 3) ~/ 4).toList();
    
    if (firstQuarter.isEmpty || lastQuarter.isEmpty) return 0.0;
    
    final firstAvg = firstQuarter.reduce((a, b) => a + b) / firstQuarter.length;
    final lastAvg = lastQuarter.reduce((a, b) => a + b) / lastQuarter.length;
    
    return ((lastAvg - firstAvg) / firstAvg) * 100;
  }
  
  // ============================================================================
  // GOALS ANALYTICS METHODS  
  // ============================================================================
  
  Future<GoalAnalytics> getGoalAnalytics(int userId, AnalyticsTimeframe timeframe) async {
    final db = await database;
    
    // Get all goals for user
    final results = await db.query(
      'user_goals',
      where: 'user_id = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [
        userId,
        timeframe.startDate.millisecondsSinceEpoch ~/ 1000,
        timeframe.endDate.millisecondsSinceEpoch ~/ 1000,
      ],
    );
    
    final goals = results.map((map) => GoalModel.fromDatabase(map)).toList();
    
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.status == GoalStatus.completed).length;
    final activeGoals = goals.where((g) => g.status == GoalStatus.active).length;
    final completionRate = totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0;
    
    // Group by category
    final goalsByCategory = <GoalCategory, int>{};
    for (final goal in goals) {
      goalsByCategory[goal.category] = (goalsByCategory[goal.category] ?? 0) + 1;
    }
    
    // Calculate streaks
    final streaks = await _calculateGoalStreaks(userId, goals);
    
    // Calculate average completion time for completed goals
    final completedGoalsList = goals.where((g) => g.status == GoalStatus.completed).toList();
    double averageCompletionTime = 0.0;
    
    if (completedGoalsList.isNotEmpty) {
      final completionTimes = completedGoalsList
          .where((g) => g.completedAt != null)
          .map((g) => g.completedAt!.difference(g.createdAt).inDays.toDouble())
          .where((days) => days > 0);
      
      if (completionTimes.isNotEmpty) {
        averageCompletionTime = completionTimes.reduce((a, b) => a + b) / completionTimes.length;
      }
    }
    
    return GoalAnalytics(
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      activeGoals: activeGoals,
      completionRate: completionRate,
      goalsByCategory: goalsByCategory,
      streaks: streaks,
      averageCompletionTime: averageCompletionTime,
    );
  }
  
  Future<List<GoalStreakInfo>> _calculateGoalStreaks(int userId, List<GoalModel> goals) async {
    final streakMap = <GoalCategory, GoalStreakInfo>{};
    
    for (final category in GoalCategory.values) {
      final categoryGoals = goals.where((g) => g.category == category).toList();
      
      if (categoryGoals.isEmpty) continue;
      
      // Calculate current and longest streaks
      int currentStreak = 0;
      int longestStreak = 0;
      DateTime? lastCompletion;
      
      // Sort by completion date
      final completedGoals = categoryGoals
          .where((g) => g.status == GoalStatus.completed && g.completedAt != null)
          .toList()
        ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));
      
      if (completedGoals.isNotEmpty) {
        lastCompletion = completedGoals.last.completedAt;
        
        // Simple streak calculation - count consecutive completed goals
        int tempStreak = 0;
        DateTime? lastDate;
        
        for (final goal in completedGoals.reversed) {
          if (lastDate == null || lastDate.difference(goal.completedAt!).inDays <= 7) {
            tempStreak++;
            lastDate = goal.completedAt;
          } else {
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            if (currentStreak == 0) {
              currentStreak = tempStreak;
            }
            tempStreak = 1;
            lastDate = goal.completedAt;
          }
        }
        
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        if (currentStreak == 0) {
          currentStreak = tempStreak;
        }
      }
      
      streakMap[category] = GoalStreakInfo(
        category: category,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastCompletionDate: lastCompletion,
      );
    }
    
    return streakMap.values.toList();
  }
  
  // ============================================================================
  // ROADMAP ANALYTICS METHODS
  // ============================================================================
  
  Future<RoadmapAnalytics> getRoadmapAnalytics(int userId, AnalyticsTimeframe timeframe) async {
    final db = await database;
    
    // Get roadmaps within timeframe
    final results = await db.query(
      'daily_roadmaps',
      where: 'user_id = ? AND target_date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        timeframe.startDate.toIso8601String().split('T')[0],
        timeframe.endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'target_date ASC',
    );
    
    final roadmaps = results.map((map) => DailyRoadmapModel.fromDatabase(map)).toList();
    
    final totalRoadmaps = roadmaps.length;
    final completedRoadmaps = roadmaps.where((r) => r.status == RoadmapStatus.completed).length;
    
    // Calculate average completion rate
    double averageCompletionRate = 0.0;
    if (roadmaps.isNotEmpty) {
      final completionRates = roadmaps
          .where((r) => r.completionPercentage != null)
          .map((r) => r.completionPercentage!)
          .toList();
      
      if (completionRates.isNotEmpty) {
        averageCompletionRate = completionRates.reduce((a, b) => a + b) / completionRates.length;
      }
    }
    
    // Activity category analysis (simplified - would need activity data)
    final activityCategoryCompletion = <String, double>{
      'Health & Wellness': 75.0,
      'Work & Productivity': 80.0,
      'Personal Development': 65.0,
      'Social & Relationships': 70.0,
    };
    
    // Calculate current streak
    final currentStreak = _calculateRoadmapStreak(roadmaps);
    
    // Completion trend
    final completionTrend = roadmaps.map((r) => DataPoint(
      date: r.targetDate,
      value: r.completionPercentage ?? 0.0,
    )).toList();
    
    return RoadmapAnalytics(
      totalRoadmaps: totalRoadmaps,
      completedRoadmaps: completedRoadmaps,
      averageCompletionRate: averageCompletionRate,
      activityCategoryCompletion: activityCategoryCompletion,
      currentStreak: currentStreak,
      completionTrend: completionTrend,
    );
  }
  
  int _calculateRoadmapStreak(List<DailyRoadmapModel> roadmaps) {
    if (roadmaps.isEmpty) return 0;
    
    // Sort by date descending
    roadmaps.sort((a, b) => b.targetDate.compareTo(a.targetDate));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final roadmap in roadmaps) {
      final isComplete = roadmap.status == RoadmapStatus.completed || 
                        (roadmap.completionPercentage ?? 0) >= 80;
      
      if (isComplete) {
        if (lastDate == null || lastDate.difference(roadmap.targetDate).inDays <= 2) {
          streak++;
          lastDate = roadmap.targetDate;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  // ============================================================================
  // QUICK MOMENTS ANALYTICS METHODS
  // ============================================================================
  
  Future<QuickMomentsAnalytics> getQuickMomentsAnalytics(int userId, AnalyticsTimeframe timeframe) async {
    final db = await database;
    
    // Get interactive moments within timeframe
    final results = await db.query(
      'interactive_moments',
      where: 'user_id = ? AND entry_date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        timeframe.startDate.toIso8601String().split('T')[0],
        timeframe.endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'timestamp ASC',
    );
    
    final moments = results.map((map) => InteractiveMomentModel.fromDatabase(map)).toList();
    
    final totalMoments = moments.length;
    
    // Group by type
    final momentsByType = <String, int>{};
    for (final moment in moments) {
      momentsByType[moment.type] = (momentsByType[moment.type] ?? 0) + 1;
    }
    
    // Average intensity by category
    final intensityByCategory = <String, List<int>>{};
    for (final moment in moments) {
      intensityByCategory.putIfAbsent(moment.category, () => []).add(moment.intensity);
    }
    
    final averageIntensityByCategory = intensityByCategory.map(
      (category, intensities) => MapEntry(
        category,
        intensities.reduce((a, b) => a + b) / intensities.length,
      ),
    );
    
    // Sentiment trend (based on type and intensity)
    final sentimentTrend = moments.map((moment) {
      double sentimentValue = moment.intensity.toDouble();
      if (moment.type == 'negative') {
        sentimentValue = -sentimentValue;
      } else if (moment.type == 'neutral') {
        sentimentValue = 0;
      }
      return DataPoint(date: moment.timestamp, value: sentimentValue);
    }).toList();
    
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
    final negativeMoments = momentsByType['negative'] ?? 0;
    final positivityRatio = totalMoments > 0 
        ? (positiveMoments / totalMoments) * 100 
        : 0.0;
    
    return QuickMomentsAnalytics(
      totalMoments: totalMoments,
      momentsByType: momentsByType,
      averageIntensityByCategory: averageIntensityByCategory,
      sentimentTrend: sentimentTrend,
      momentsByTimeOfDay: momentsByTimeOfDay,
      positivityRatio: positivityRatio,
    );
  }
  
  // ============================================================================
  // USER MOTIVATION INSIGHTS
  // ============================================================================
  
  Future<UserMotivationInsights> generateMotivationInsights(
    int userId,
    AnalyticsTimeframe timeframe,
  ) async {
    final wellbeingTrends = await getWellbeingTrends(userId, timeframe);
    final goalAnalytics = await getGoalAnalytics(userId, timeframe);
    final roadmapAnalytics = await getRoadmapAnalytics(userId, timeframe);
    final momentsAnalytics = await getQuickMomentsAnalytics(userId, timeframe);
    
    final achievements = <String>[];
    final improvements = <String>[];
    final recommendations = <String>[];
    
    // Generate achievements
    if (goalAnalytics.completionRate > 80) {
      achievements.add('🏆 Goal Master: ${goalAnalytics.completionRate.toStringAsFixed(0)}% completion rate!');
    }
    
    if (roadmapAnalytics.currentStreak > 7) {
      achievements.add('🔥 Daily Consistency: ${roadmapAnalytics.currentStreak} day streak!');
    }
    
    if (momentsAnalytics.positivityRatio > 70) {
      achievements.add('😊 Positive Mindset: ${momentsAnalytics.positivityRatio.toStringAsFixed(0)}% positive moments!');
    }
    
    // Generate improvements
    for (final trend in wellbeingTrends) {
      if (trend.trendDirection == 'improving' && trend.improvementPercentage > 10) {
        improvements.add('📈 ${trend.metric}: +${trend.improvementPercentage.toStringAsFixed(0)}% improvement');
      }
    }
    
    // Generate recommendations
    if (goalAnalytics.completionRate < 50) {
      recommendations.add('🎯 Consider setting smaller, more achievable goals');
    }
    
    final stressTrend = wellbeingTrends.firstWhere(
      (t) => t.metric == 'Stress Level',
      orElse: () => WellbeingTrend(
        metric: 'Stress Level',
        dataPoints: [],
        averageValue: 5.0,
        trendSlope: 0.0,
        trendDirection: 'stable',
        improvementPercentage: 0.0,
      ),
    );
    
    if (stressTrend.averageValue < 6.0) {
      recommendations.add('🧘 Consider adding stress-reduction activities to your routine');
    }
    
    // Calculate motivation score
    double motivationScore = 5.0; // Base score
    
    if (goalAnalytics.completionRate > 0) {
      motivationScore += (goalAnalytics.completionRate / 100) * 2;
    }
    
    if (roadmapAnalytics.averageCompletionRate > 0) {
      motivationScore += (roadmapAnalytics.averageCompletionRate / 100) * 2;
    }
    
    if (momentsAnalytics.positivityRatio > 0) {
      motivationScore += (momentsAnalytics.positivityRatio / 100) * 2;
    }
    
    motivationScore = math.min(motivationScore, 10.0);
    
    // Determine primary motivation factor
    String primaryFactor = 'Consistency';
    if (goalAnalytics.completionRate > roadmapAnalytics.averageCompletionRate) {
      primaryFactor = 'Goal Achievement';
    } else if (momentsAnalytics.positivityRatio > 75) {
      primaryFactor = 'Positive Mindset';
    }
    
    return UserMotivationInsights(
      achievements: achievements,
      improvements: improvements,
      recommendations: recommendations,
      motivationScore: motivationScore,
      primaryMotivationFactor: primaryFactor,
    );
  }
}