// ============================================================================
// V4 ANALYTICS TEST DATA SEEDER - WELLBEING DATA FOR ANALYTICS SCREEN
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/services/optimized_database_service.dart';
import '../data/models/daily_entry_model.dart';
import '../data/models/goal_model.dart';
import '../data/models/optimized_models.dart';

class V4AnalyticsTestDataSeeder {
  final OptimizedDatabaseService _databaseService;
  final Random _random = Random(42); // Fixed seed for consistent test data

  V4AnalyticsTestDataSeeder(this._databaseService);

  /// Seed comprehensive wellbeing test data for Analytics V4 screen
  Future<void> seedV4AnalyticsData(int userId) async {
    if (kDebugMode) {
      debugPrint('🌱 Seeding V4 Analytics test data for user $userId...');
    }

    try {
      await seedWellbeingDailyEntries(userId);
      await seedGoalsForAnalytics(userId);
      await seedDiverseMoments(userId);
      
      if (kDebugMode) {
        debugPrint('✅ V4 Analytics test data seeded successfully');
        debugPrint('📊 Generated data includes:');
        debugPrint('   • 60 days of detailed wellbeing entries');
        debugPrint('   • 12 diverse goals across all categories');
        debugPrint('   • 150+ interactive moments with varied emotions');
        debugPrint('   • Realistic trends and patterns for analytics');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seeding V4 analytics data: $e');
      }
      rethrow;
    }
  }

  /// Seed daily entries with comprehensive wellbeing data
  Future<void> seedWellbeingDailyEntries(int userId) async {
    if (kDebugMode) {
      debugPrint('📝 Adding wellbeing daily entries...');
    }

    final now = DateTime.now();
    
    // Generate 60 days of data with realistic trends
    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Create realistic trends over time
      final progressFactor = (60 - i) / 60.0; // Progress over time (0.0 to 1.0)
      final weekdayFactor = _getWeekdayFactor(date.weekday);
      final seasonalFactor = _getSeasonalFactor(date.month);
      
      // Base values with some randomness and trends
      final moodScore = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: progressFactor * 0.3, // Slight improvement over time
        weekdayFactor: weekdayFactor,
        seasonalFactor: seasonalFactor,
        randomVariation: 2.0,
        min: 1,
        max: 10,
      ).round();
      
      final energyLevel = _generateTrendingValue(
        baseValue: 6.5,
        trendFactor: progressFactor * 0.4,
        weekdayFactor: weekdayFactor,
        seasonalFactor: seasonalFactor,
        randomVariation: 2.5,
        min: 1,
        max: 10,
      ).round();
      
      final sleepQuality = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: progressFactor * 0.25,
        weekdayFactor: weekdayFactor * 0.5, // Less weekday impact on sleep
        seasonalFactor: seasonalFactor * 0.3,
        randomVariation: 2.0,
        min: 1,
        max: 10,
      ).round();
      
      final stressLevel = _generateTrendingValue(
        baseValue: 5.0,
        trendFactor: -progressFactor * 0.35, // Stress decreases over time
        weekdayFactor: -weekdayFactor, // Higher stress on weekdays
        seasonalFactor: -seasonalFactor * 0.2,
        randomVariation: 2.5,
        min: 1,
        max: 10,
      ).round();
      
      final motivationLevel = _generateTrendingValue(
        baseValue: 6.5,
        trendFactor: progressFactor * 0.5,
        weekdayFactor: weekdayFactor,
        seasonalFactor: seasonalFactor,
        randomVariation: 2.0,
        min: 1,
        max: 10,
      ).round();
      
      final anxietyLevel = _generateTrendingValue(
        baseValue: 4.5,
        trendFactor: -progressFactor * 0.3, // Anxiety decreases over time
        weekdayFactor: -weekdayFactor * 0.5,
        seasonalFactor: -seasonalFactor * 0.2,
        randomVariation: 2.0,
        min: 1,
        max: 10,
      ).round();
      
      final socialInteraction = _generateTrendingValue(
        baseValue: 5.5,
        trendFactor: progressFactor * 0.2,
        weekdayFactor: weekdayFactor * 0.3,
        seasonalFactor: seasonalFactor,
        randomVariation: 2.5,
        min: 1,
        max: 10,
      ).round();
      
      final physicalActivity = _generateTrendingValue(
        baseValue: 5.0,
        trendFactor: progressFactor * 0.4,
        weekdayFactor: weekdayFactor * 0.7,
        seasonalFactor: seasonalFactor * 0.5,
        randomVariation: 3.0,
        min: 1,
        max: 10,
      ).round();
      
      final workProductivity = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: progressFactor * 0.3,
        weekdayFactor: weekdayFactor * 1.2, // Much higher on weekdays
        seasonalFactor: seasonalFactor * 0.3,
        randomVariation: 2.0,
        min: 1,
        max: 10,
      ).round();
      
      final emotionalStability = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: progressFactor * 0.35,
        weekdayFactor: weekdayFactor * 0.4,
        seasonalFactor: seasonalFactor,
        randomVariation: 2.0,
        min: 1,
        max: 10,
      ).round();
      
      final focusLevel = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: progressFactor * 0.4,
        weekdayFactor: weekdayFactor * 0.8,
        seasonalFactor: seasonalFactor * 0.3,
        randomVariation: 2.5,
        min: 1,
        max: 10,
      ).round();
      
      final lifeSatisfaction = _generateTrendingValue(
        baseValue: 6.5,
        trendFactor: progressFactor * 0.45,
        weekdayFactor: weekdayFactor * 0.2,
        seasonalFactor: seasonalFactor,
        randomVariation: 1.5,
        min: 1,
        max: 10,
      ).round();
      
      // Additional wellness metrics
      final sleepHours = _generateTrendingValue(
        baseValue: 7.0,
        trendFactor: progressFactor * 0.5,
        weekdayFactor: -weekdayFactor * 0.3, // Less sleep on weekdays
        seasonalFactor: seasonalFactor * 0.2,
        randomVariation: 1.5,
        min: 4.0,
        max: 10.0,
      );
      
      final waterIntake = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: progressFactor * 0.3,
        weekdayFactor: weekdayFactor * 0.2,
        seasonalFactor: seasonalFactor * 0.5,
        randomVariation: 2.0,
        min: 2,
        max: 12,
      ).round();
      
      final meditationMinutes = i % 3 == 0 ? _generateTrendingValue(
        baseValue: 15.0,
        trendFactor: progressFactor * 10.0,
        weekdayFactor: weekdayFactor * 5.0,
        seasonalFactor: seasonalFactor * 3.0,
        randomVariation: 10.0,
        min: 0,
        max: 60,
      ).round() : null;
      
      final exerciseMinutes = i % 2 == 0 ? _generateTrendingValue(
        baseValue: 30.0,
        trendFactor: progressFactor * 15.0,
        weekdayFactor: weekdayFactor * 10.0,
        seasonalFactor: seasonalFactor * 8.0,
        randomVariation: 20.0,
        min: 0,
        max: 120,
      ).round() : null;
      
      final screenTimeHours = _generateTrendingValue(
        baseValue: 6.0,
        trendFactor: -progressFactor * 1.0, // Screen time decreases over time
        weekdayFactor: weekdayFactor * 1.5,
        seasonalFactor: seasonalFactor * 0.5,
        randomVariation: 2.0,
        min: 2.0,
        max: 12.0,
      );

      // Generate reflection text based on mood
      final reflection = _generateReflection(moodScore, energyLevel, stressLevel);
      final positiveTags = _generatePositiveTags(moodScore, energyLevel);
      final negativeTags = _generateNegativeTags(stressLevel, anxietyLevel);
      
      final entry = DailyEntryModel.create(
        userId: userId,
        freeReflection: reflection,
        positiveTags: positiveTags,
        negativeTags: negativeTags,
        energyLevel: energyLevel,
        stressLevel: stressLevel,
        sleepQuality: sleepQuality,
        anxietyLevel: anxietyLevel,
        motivationLevel: motivationLevel,
        socialInteraction: socialInteraction,
        physicalActivity: physicalActivity,
        workProductivity: workProductivity,
        sleepHours: sleepHours,
        waterIntake: waterIntake,
        meditationMinutes: meditationMinutes,
        exerciseMinutes: exerciseMinutes,
        screenTimeHours: screenTimeHours,
        emotionalStability: emotionalStability,
        focusLevel: focusLevel,
        lifeSatisfaction: lifeSatisfaction,
        entryDate: date,
      );

      try {
        // Convert to OptimizedDailyEntryModel using the factory constructor
        final optimizedEntry = OptimizedDailyEntryModel.create(
          userId: entry.userId,
          entryDate: entry.entryDate,
          freeReflection: entry.freeReflection,
          innerReflection: entry.innerReflection,
          positiveTags: entry.positiveTags,
          negativeTags: entry.negativeTags,
          completedActivitiesToday: entry.completedActivitiesToday,
          goalsSummary: entry.goalsSummary,
          worthIt: entry.worthIt,
          moodScore: entry.moodScore,
          energyLevel: entry.energyLevel,
          stressLevel: entry.stressLevel,
          sleepQuality: entry.sleepQuality,
          anxietyLevel: entry.anxietyLevel,
          motivationLevel: entry.motivationLevel,
          socialInteraction: entry.socialInteraction,
          physicalActivity: entry.physicalActivity,
          workProductivity: entry.workProductivity,
          sleepHours: entry.sleepHours,
          waterIntake: entry.waterIntake,
          meditationMinutes: entry.meditationMinutes,
          exerciseMinutes: entry.exerciseMinutes,
          screenTimeHours: entry.screenTimeHours,
          gratitudeItems: entry.gratitudeItems,
          emotionalStability: entry.emotionalStability,
          focusLevel: entry.focusLevel,
          lifeSatisfaction: entry.lifeSatisfaction,
          voiceRecordingPath: entry.voiceRecordingPath,
        );
        
        await _databaseService.saveDailyEntry(optimizedEntry);
      } catch (e) {
        debugPrint('⚠️ Error saving daily entry for ${date.toString().split(' ')[0]}: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('✅ Generated 60 days of wellbeing data with realistic trends');
    }
  }
  
  /// Seed diverse goals for analytics
  Future<void> seedGoalsForAnalytics(int userId) async {
    if (kDebugMode) {
      debugPrint('🎯 Adding goals for analytics...');
    }
    
    final goals = [
      // Completed goals (for success analytics)
      _createGoal(userId, 'Daily Meditation Practice', 'Meditate for 10 minutes every day', GoalCategory.mindfulness, true, 30),
      _createGoal(userId, 'Morning Walks', 'Take a 20-minute walk each morning', GoalCategory.physical, true, 21),
      _createGoal(userId, 'Gratitude Journal', 'Write 3 things I\'m grateful for daily', GoalCategory.emotional, true, 14),
      _createGoal(userId, 'Digital Detox Evening', 'No screens after 9 PM', GoalCategory.habits, true, 10),
      
      // Active goals (in progress)
      _createGoal(userId, 'Weekly Friend Calls', 'Call a friend or family member weekly', GoalCategory.social, false, 4),
      _createGoal(userId, 'Healthy Sleep Schedule', 'Go to bed by 10:30 PM and wake up at 6:30 AM', GoalCategory.sleep, false, 18),
      _createGoal(userId, 'Stress Management', 'Practice deep breathing when feeling overwhelmed', GoalCategory.stress, false, 12),
      _createGoal(userId, 'Reading Habit', 'Read for 30 minutes before bed', GoalCategory.productivity, false, 8),
      
      // Recently started goals
      _createGoal(userId, 'Hydration Goal', 'Drink 8 glasses of water daily', GoalCategory.physical, false, 3),
      _createGoal(userId, 'Mindful Eating', 'Eat without distractions and savor meals', GoalCategory.mindfulness, false, 2),
      _createGoal(userId, 'Weekly Nature Connection', 'Spend time in nature at least once a week', GoalCategory.emotional, false, 1),
      _createGoal(userId, 'Productive Morning Routine', 'Complete morning routine by 8 AM', GoalCategory.productivity, false, 5),
    ];
    
    for (final goal in goals) {
      try {
        final db = await _databaseService.database;
        await db.insert('user_goals', {
          'user_id': goal.userId,
          'title': goal.title,
          'description': goal.description,
          'type': goal.category.name, // Convert enum to string
          'status': goal.status.name, // Convert enum to string
          'target_value': goal.targetValue,
          'current_value': goal.currentValue,
          'created_at': goal.createdAt.millisecondsSinceEpoch ~/ 1000, // Unix timestamp in seconds
          'completed_at': goal.completedAt != null
              ? goal.completedAt!.millisecondsSinceEpoch ~/ 1000
              : null,
        });
        debugPrint('✅ Created goal: ${goal.title}');
      } catch (e) {
        debugPrint('⚠️ Error creating goal "${goal.title}": $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('✅ Generated 12 diverse goals (4 completed, 8 active)');
    }
  }
  
  /// Seed diverse interactive moments
  Future<void> seedDiverseMoments(int userId) async {
    if (kDebugMode) {
      debugPrint('⚡ Adding diverse interactive moments...');
    }
    
    final now = DateTime.now();
    final moments = <Map<String, dynamic>>[];
    
    // Generate moments for the last 30 days
    for (int day = 0; day < 30; day++) {
      final date = now.subtract(Duration(days: day));
      final momentsPerDay = 2 + _random.nextInt(6); // 2-7 moments per day
      
      for (int i = 0; i < momentsPerDay; i++) {
        final hour = 6 + _random.nextInt(16); // Between 6 AM and 10 PM
        final minute = _random.nextInt(60);
        final timestamp = DateTime(date.year, date.month, date.day, hour, minute);
        
        final momentData = _generateMomentData(hour, day);
        
        moments.add({
          'user_id': userId,
          'entry_date': date.toIso8601String().split('T')[0],
          'emoji': momentData['emoji'],
          'text': momentData['text'],
          'type': momentData['type'],
          'intensity': momentData['intensity'],
          'category': momentData['category'],
          'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000, // Unix timestamp in seconds
        });
      }
    }
    
    // Insert moments into database
    for (final momentData in moments) {
      try {
        final db = await _databaseService.database;
        await db.insert('interactive_moments', momentData);
      } catch (e) {
        debugPrint('⚠️ Error inserting moment: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('✅ Generated ${moments.length} diverse interactive moments');
    }
  }
  
  // Helper methods
  
  double _getWeekdayFactor(int weekday) {
    // Monday = 1, Sunday = 7
    if (weekday >= 1 && weekday <= 5) return 0.3; // Weekdays
    return -0.2; // Weekends
  }
  
  double _getSeasonalFactor(int month) {
    // Spring/Summer: higher mood, Fall/Winter: slightly lower
    if (month >= 3 && month <= 8) return 0.2;
    return -0.1;
  }
  
  double _generateTrendingValue({
    required double baseValue,
    required double trendFactor,
    required double weekdayFactor,
    required double seasonalFactor,
    required double randomVariation,
    required double min,
    required double max,
  }) {
    final randomComponent = (_random.nextDouble() - 0.5) * randomVariation;
    final value = baseValue + trendFactor + weekdayFactor + seasonalFactor + randomComponent;
    return value.clamp(min, max);
  }
  
  String _generateReflection(int mood, int energy, int stress) {
    final reflections = {
      'high_mood_high_energy': [
        'Today was fantastic! I felt energized and accomplished so much. Really grateful for this positive momentum.',
        'Woke up feeling great and the good vibes continued throughout the day. Love these kinds of days!',
        'Had amazing energy today and tackled my to-do list with enthusiasm. Feeling really optimistic.',
        'Everything seemed to flow effortlessly today. High energy and positive mood made everything better.',
      ],
      'high_mood_low_energy': [
        'Feeling peaceful and content, even though my energy is low. Sometimes rest is exactly what we need.',
        'In a good headspace today, just taking things slow and being kind to myself.',
        'Mood is great but body needs rest. Learning to appreciate the quieter, more reflective moments.',
      ],
      'low_mood_high_energy': [
        'Felt restless and anxious today despite having energy. Need to find better ways to channel this.',
        'High energy but struggling with my mood. Going to focus on activities that bring me joy.',
        'Productive day but emotionally challenging. Grateful for the energy to keep moving forward.',
      ],
      'low_mood_low_energy': [
        'Tough day overall. Low energy and feeling down, but trying to be patient with myself.',
        'Not my best day. Feeling drained both physically and emotionally. Tomorrow is a new day.',
        'Struggling today but acknowledging that difficult days are part of the journey.',
      ],
      'balanced': [
        'A pretty balanced day overall. Nothing too extreme in either direction, which feels stable.',
        'Steady energy and mood today. Sometimes these consistent days are exactly what I need.',
        'Had a normal, balanced day. Grateful for the stability even if it wasn\'t super exciting.',
      ],
    };
    
    String category;
    if (mood >= 7 && energy >= 7) category = 'high_mood_high_energy';
    else if (mood >= 7 && energy <= 4) category = 'high_mood_low_energy';
    else if (mood <= 4 && energy >= 7) category = 'low_mood_high_energy';
    else if (mood <= 4 && energy <= 4) category = 'low_mood_low_energy';
    else category = 'balanced';
    
    final options = reflections[category] ?? reflections['balanced']!;
    return options[_random.nextInt(options.length)];
  }
  
  List<String> _generatePositiveTags(int mood, int energy) {
    final allPositiveTags = [
      'grateful', 'accomplished', 'energized', 'peaceful', 'motivated',
      'confident', 'optimistic', 'focused', 'creative', 'connected',
      'inspired', 'balanced', 'content', 'joyful', 'strong'
    ];
    
    final count = mood >= 7 ? 2 + _random.nextInt(3) : _random.nextInt(2);
    allPositiveTags.shuffle(_random);
    return allPositiveTags.take(count).toList();
  }
  
  List<String> _generateNegativeTags(int stress, int anxiety) {
    final allNegativeTags = [
      'stressed', 'anxious', 'tired', 'overwhelmed', 'frustrated',
      'restless', 'worried', 'distracted', 'unmotivated', 'tense'
    ];
    
    final count = (stress >= 7 || anxiety >= 7) ? 1 + _random.nextInt(2) : _random.nextInt(2);
    allNegativeTags.shuffle(_random);
    return allNegativeTags.take(count).toList();
  }
  
  GoalModel _createGoal(int userId, String title, String description, GoalCategory category, bool isCompleted, int daysAgo) {
    final now = DateTime.now();
    return GoalModel(
      id: null,
      userId: userId,
      title: title,
      description: description,
      targetValue: 30,
      currentValue: isCompleted ? 30 : (daysAgo < 30 ? daysAgo : _random.nextInt(25)),
      status: isCompleted ? GoalStatus.completed : GoalStatus.active,
      category: category,
      createdAt: now.subtract(Duration(days: daysAgo + 10)),
      completedAt: isCompleted ? now.subtract(Duration(days: daysAgo)) : null,
    );
  }
  
  Map<String, dynamic> _generateMomentData(int hour, int dayIndex) {
    // Generate moments based on time of day and patterns
    final isEvening = hour >= 18;
    final isMorning = hour <= 10;
    final isAfternoon = hour > 10 && hour < 18;
    
    // Create realistic patterns - more positive moments in the morning and evening
    final positivityBias = isMorning ? 0.7 : (isEvening ? 0.6 : 0.5);
    final isPositive = _random.nextDouble() < positivityBias;
    
    final morningMoments = [
      {'emoji': '☕', 'text': 'Perfect morning coffee ritual', 'category': 'routine'},
      {'emoji': '🌅', 'text': 'Beautiful sunrise start to the day', 'category': 'nature'},
      {'emoji': '💪', 'text': 'Great workout to energize the morning', 'category': 'exercise'},
      {'emoji': '📚', 'text': 'Productive morning reading session', 'category': 'learning'},
      {'emoji': '🧘‍♀️', 'text': 'Centering morning meditation', 'category': 'mindfulness'},
    ];
    
    final afternoonMoments = [
      {'emoji': '🎯', 'text': 'Focused work session with good progress', 'category': 'work'},
      {'emoji': '🥗', 'text': 'Nourishing lunch that hit the spot', 'category': 'nutrition'},
      {'emoji': '🚶‍♀️', 'text': 'Refreshing walk to clear my head', 'category': 'movement'},
      {'emoji': '📞', 'text': 'Meaningful conversation with a friend', 'category': 'social'},
      {'emoji': '✅', 'text': 'Accomplished an important task', 'category': 'productivity'},
      // Negative afternoon moments
      {'emoji': '😤', 'text': 'Feeling overwhelmed with afternoon tasks', 'category': 'stress'},
      {'emoji': '😴', 'text': 'Afternoon energy dip hitting hard', 'category': 'energy'},
      {'emoji': '📱', 'text': 'Spent too much time scrolling mindlessly', 'category': 'habits'},
    ];
    
    final eveningMoments = [
      {'emoji': '🌙', 'text': 'Peaceful evening reflection time', 'category': 'reflection'},
      {'emoji': '👨‍👩‍👧‍👦', 'text': 'Quality time with loved ones', 'category': 'family'},
      {'emoji': '📖', 'text': 'Relaxing with a good book', 'category': 'leisure'},
      {'emoji': '🍽️', 'text': 'Enjoyed a home-cooked dinner', 'category': 'nutrition'},
      {'emoji': '🎵', 'text': 'Music perfectly matching my mood', 'category': 'entertainment'},
      {'emoji': '🛁', 'text': 'Relaxing bath to unwind', 'category': 'self-care'},
    ];
    
    final negativeMoments = [
      {'emoji': '😟', 'text': 'Feeling anxious about upcoming challenges', 'category': 'anxiety'},
      {'emoji': '😓', 'text': 'Stressed about work deadlines', 'category': 'work'},
      {'emoji': '😔', 'text': 'Feeling disconnected and lonely', 'category': 'social'},
      {'emoji': '🤯', 'text': 'Overwhelmed by too many decisions', 'category': 'stress'},
      {'emoji': '😴', 'text': 'Exhausted and running on empty', 'category': 'energy'},
    ];
    
    List<Map<String, String>> momentPool;
    if (isPositive) {
      if (isMorning) momentPool = morningMoments;
      else if (isAfternoon) momentPool = afternoonMoments.where((m) => !negativeMoments.contains(m)).toList();
      else momentPool = eveningMoments;
    } else {
      momentPool = negativeMoments + afternoonMoments.where((m) => negativeMoments.any((neg) => neg['text'] == m['text'])).toList();
    }
    
    final moment = momentPool[_random.nextInt(momentPool.length)];
    
    return {
      'emoji': moment['emoji']!,
      'text': moment['text']!,
      'type': isPositive ? 'positive' : 'negative',
      'intensity': 3 + _random.nextInt(6), // 3-8 intensity
      'category': moment['category'] ?? 'general',
    };
  }
}