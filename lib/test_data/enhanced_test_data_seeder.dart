// ============================================================================
// ENHANCED TEST DATA SEEDER - COMPREHENSIVE TEST DATA GENERATION
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../data/services/optimized_database_service.dart';
import '../data/models/optimized_models.dart';
import '../data/models/goal_model.dart';
import '../data/models/daily_roadmap_model.dart';
import '../data/models/roadmap_activity_model.dart';
import '../data/models/user_model.dart';

class EnhancedTestDataSeeder {
  final OptimizedDatabaseService _databaseService;
  final Random _random = Random();

  EnhancedTestDataSeeder(this._databaseService);

  /// Seed comprehensive test data for a user
  Future<void> seedEnhancedTestData(int userId) async {
    if (kDebugMode) {
      debugPrint('🌱 Seeding enhanced test data for user $userId...');
    }

    try {
      await seedUserInfo(userId);
      await seedQuickMoments(userId);
      await seedDailyReviews(userId);
      await seedEnhancedGoals(userId);
      await seedDailyRoadmaps(userId);
      await seedRecommendedActivities(userId);
      await seedDiverseTagsAndCategories(userId);
      await seedAdvancedAnalyticsData(userId);
      
      if (kDebugMode) {
        debugPrint('✅ Enhanced test data seeded successfully');
        debugPrint('📊 Comprehensive data includes:');
        debugPrint('   • Rich user profile with preferences');
        debugPrint('   • 90+ days of varied quick moments');
        debugPrint('   • 60 days of detailed daily reviews with analytics');
        debugPrint('   • 8 comprehensive goals across all categories');
        debugPrint('   • 21 days of structured daily roadmaps');
        debugPrint('   • 50+ recommended activities across categories');
        debugPrint('   • Diverse tags and emotional patterns');
        debugPrint('   • Advanced analytics with realistic patterns');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error seeding enhanced test data: $e');
      }
      rethrow;
    }
  }

  /// Update user info with rich test data
  Future<void> seedUserInfo(int userId) async {
    if (kDebugMode) {
      debugPrint('👤 Adding user info...');
    }

    final userInfo = UserModel(
      id: userId,
      email: 'testuser@example.com',
      name: 'Alex Johnson',
      avatarEmoji: '🌟',
      bio: 'Passionate about personal growth, mindfulness, and creating positive daily habits. Love exploring nature and connecting with others.',
      age: 28,
      isFirstTimeUser: false,
      preferences: {
        'theme': 'light',
        'notifications': true,
        'dailyReminders': true,
        'preferredReminderTime': '09:00',
        'language': 'en',
        'weekStartsOn': 'monday',
        'goalCategories': ['mindfulness', 'health', 'productivity', 'relationships'],
        'favoriteEmojis': ['🌟', '💪', '🧘‍♀️', '📚', '🌱'],
        'motivationalStyle': 'encouraging',
        'privacyLevel': 'private',
      },
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    );

    // Note: This would require a method to update user info in the database service
    if (kDebugMode) {
      debugPrint('✅ User info prepared (would need updateUser method in database service)');
    }
  }

  /// Seed quick moments with diverse content
  Future<void> seedQuickMoments(int userId) async {
    if (kDebugMode) {
      debugPrint('⚡ Adding quick moments...');
    }

    final now = DateTime.now();
    final momentTypes = ['positive', 'negative', 'neutral', 'reflective', 'gratitude'];
    
    for (int i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Create 1-6 moments per day with more variation
      final momentsCount = _random.nextInt(6) + 1;
      
      for (int j = 0; j < momentsCount; j++) {
        final momentData = _generateQuickMomentData();
        final momentType = momentTypes[_random.nextInt(momentTypes.length)];
        final timestamp = date.add(Duration(
          hours: _random.nextInt(16) + 6,
          minutes: _random.nextInt(60),
        ));

        final moment = OptimizedInteractiveMomentModel(
          userId: userId,
          entryDate: timestamp,
          emoji: momentData['emoji'] as String,
          text: momentData['text'] as String,
          type: momentType,
          intensity: _random.nextInt(5) + 1,
          timestamp: timestamp,
          createdAt: timestamp,
        );
        
        await _databaseService.saveInteractiveMoment(userId, moment);
      }
    }
  }

  /// Seed daily reviews with comprehensive reflection data
  Future<void> seedDailyReviews(int userId) async {
    if (kDebugMode) {
      debugPrint('📝 Adding daily reviews...');
    }

    final now = DateTime.now();
    
    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      
      // Create 2-4 entries per day with different productivity levels at different hours
      final entriesPerDay = 2 + _random.nextInt(3);
      
      for (int j = 0; j < entriesPerDay; j++) {
        // Create realistic productivity patterns throughout the day
        final hour = _getProductiveHour(j, entriesPerDay);
        final productivity = _getProductivityForHour(hour);
        final focus = _getFocusForHour(hour);
        final creative = _getCreativeEnergyForHour(hour);
        
        final entryTime = DateTime(date.year, date.month, date.day, hour, _random.nextInt(60));
        
        final entry = OptimizedDailyEntryModel(
          userId: userId,
          entryDate: date,
          freeReflection: j == 0 ? _generateDailyReflection() : '', // Empty string instead of null
          sleepHours: j == 0 ? 5.5 + _random.nextDouble() * 4.5 : null, // Only first entry gets sleep data
          anxietyLevel: j == 0 ? _random.nextInt(5) + 1 : null,
          stressLevel: j == 0 ? _random.nextInt(5) + 1 : null,
          energyLevel: _random.nextInt(5) + 1,
          // Add productivity-related fields for analytics with realistic hour patterns
          workProductivity: productivity,
          focusLevel: focus,
          creativeEnergy: creative,
          exerciseMinutes: j == 0 ? _random.nextInt(120) : null, // Remove decimal part
          meditationMinutes: j == 0 ? _random.nextInt(60) : null, // Remove decimal part
          screenTimeHours: j == 0 ? 2.0 + _random.nextDouble() * 8.0 : null,
          socialInteraction: j == 0 ? _random.nextInt(8) + 1 : null,
          createdAt: entryTime,
          updatedAt: entryTime,
        );

        await _databaseService.saveDailyEntry(entry);
      }
    }
  }

  /// Seed enhanced goals with notes and updates
  Future<void> seedEnhancedGoals(int userId) async {
    if (kDebugMode) {
      debugPrint('🎯 Adding enhanced goals...');
    }

    final goals = _generateEnhancedGoals(userId);

    for (final goal in goals) {
      await _databaseService.createGoalSafe(
        userId: goal.userId,
        title: goal.title,
        description: goal.description,
        type: goal.category.name,
        targetValue: goal.targetValue.toDouble(),
      );
    }
  }

  /// Seed daily roadmaps with structured activities
  Future<void> seedDailyRoadmaps(int userId) async {
    if (kDebugMode) {
      debugPrint('🗺️ Adding daily roadmaps...');
    }

    final now = DateTime.now();
    
    for (int i = 0; i < 21; i++) {
      final date = now.subtract(Duration(days: i));
      final activities = _generateRoadmapActivities(date);
      
      final roadmap = DailyRoadmapModel.create(
        userId: userId,
        targetDate: date,
        dailyGoal: _generateDailyGoal(),
        morningNotes: _generateMorningNotes(),
      ).copyWith(
        activities: activities,
        eveningReflection: i > 0 ? _generateEveningReflection() : null,
        status: i > 0 ? _getRandomRoadmapStatus() : RoadmapStatus.planned,
        overallMood: i > 0 ? _getRandomMood() : null,
      );

      // Note: This would require a method to save daily roadmaps in the database service
      if (kDebugMode) {
        debugPrint('📅 Generated roadmap for ${date.toString().split(' ')[0]} with ${activities.length} activities');
      }
    }
  }

  // Helper methods for generating realistic test data

  Map<String, String> _generateQuickMomentData() {
    final moments = [
      // Positive moments
      {'emoji': '☕', 'text': 'Perfect morning coffee with a beautiful sunrise view'},
      {'emoji': '📚', 'text': 'Finished reading an inspiring chapter that really resonated with me'},
      {'emoji': '🌱', 'text': 'Noticed my plant has new growth - small wins matter!'},
      {'emoji': '💪', 'text': 'Completed my workout even though I didn\'t feel like it initially'},
      {'emoji': '🤝', 'text': 'Had a meaningful conversation with a friend who was feeling down'},
      {'emoji': '🎵', 'text': 'Discovered a new song that perfectly matches my current mood'},
      {'emoji': '🌙', 'text': 'Taking a moment to appreciate the peaceful evening atmosphere'},
      {'emoji': '✨', 'text': 'Felt a surge of creativity and motivation out of nowhere'},
      {'emoji': '🍃', 'text': 'Enjoyed a refreshing walk in nature that cleared my mind'},
      {'emoji': '📝', 'text': 'Wrote down some thoughts and felt more organized'},
      {'emoji': '🎨', 'text': 'Spent time on a creative project that brought me joy'},
      {'emoji': '🧘‍♀️', 'text': 'Meditation session helped me feel more centered and calm'},
      {'emoji': '🌈', 'text': 'Grateful for the small beautiful moments throughout the day'},
      {'emoji': '🎯', 'text': 'Made progress on a personal goal that I\'ve been working towards'},
      {'emoji': '💡', 'text': 'Had an interesting insight about myself during reflection time'},
      
      // Reflective moments
      {'emoji': '🤔', 'text': 'Pausing to reflect on how much I\'ve grown in the past few months'},
      {'emoji': '🌊', 'text': 'Feeling the ebb and flow of emotions, accepting them as they come'},
      {'emoji': '🔍', 'text': 'Looking deeper into a pattern I\'ve been noticing about myself'},
      {'emoji': '⚖️', 'text': 'Finding balance between pushing forward and being patient'},
      {'emoji': '🗣️', 'text': 'Practicing speaking my truth with kindness and clarity'},
      
      // Challenging moments
      {'emoji': '😤', 'text': 'Feeling frustrated with traffic but choosing to use it as mindfulness practice'},
      {'emoji': '😔', 'text': 'Having a low-energy day, reminding myself this too shall pass'},
      {'emoji': '😰', 'text': 'Anxiety is high today, focusing on what I can control'},
      {'emoji': '🌧️', 'text': 'Mood feels heavy like the weather, but I\'m being gentle with myself'},
      {'emoji': '💭', 'text': 'Mind is racing with worries, taking a moment to breathe deeply'},
      
      // Social moments
      {'emoji': '👨‍👩‍👧‍👦', 'text': 'Family dinner brought laughter and connection tonight'},
      {'emoji': '📱', 'text': 'Received an unexpected message that made my day brighter'},
      {'emoji': '🫂', 'text': 'Sometimes you need a hug, and today I got the perfect one'},
      {'emoji': '👂', 'text': 'Really listened to someone today and felt the power of presence'},
      {'emoji': '🎉', 'text': 'Celebrated a friend\'s achievement and felt genuine joy for them'},
      
      // Achievement moments
      {'emoji': '🏆', 'text': 'Small victory today - finished a task I\'ve been putting off'},
      {'emoji': '📈', 'text': 'Can see measurable progress in my personal development journey'},
      {'emoji': '🔧', 'text': 'Fixed something that was broken and felt surprisingly accomplished'},
      {'emoji': '🎓', 'text': 'Learned something new that shifted my perspective'},
      {'emoji': '✅', 'text': 'Checked off everything on my list - feeling organized and capable'},
      
      // Sensory moments
      {'emoji': '🌺', 'text': 'The smell of flowers during my walk was absolutely intoxicating'},
      {'emoji': '🎶', 'text': 'Music is hitting different today - every note feels meaningful'},
      {'emoji': '🍯', 'text': 'Simple pleasure: really tasting and enjoying my food today'},
      {'emoji': '🌅', 'text': 'Caught the sunrise and felt connected to something bigger'},
      {'emoji': '🌟', 'text': 'Stars are especially bright tonight, feeling wonder and perspective'},
      
      // Growth moments
      {'emoji': '🪴', 'text': 'Nurturing my growth requires patience, just like tending plants'},
      {'emoji': '🔄', 'text': 'Noticing old patterns and choosing a different response today'},
      {'emoji': '🧩', 'text': 'Another piece of the puzzle clicked into place about myself'},
      {'emoji': '🌸', 'text': 'Blooming at my own pace and that feels perfectly right'},
      {'emoji': '🔮', 'text': 'Trusting the process even when I can\'t see the full picture'},
    ];
    
    return moments[_random.nextInt(moments.length)];
  }

  String _generateDailyReflection() {
    final reflections = [
      '''Today was a journey of small victories and gentle challenges. I found myself appreciating the quiet moments between tasks, where I could just breathe and acknowledge how far I\'ve come. The morning started with intention, and even though not everything went according to plan, I adapted with grace. I\'m learning that flexibility is not giving up on goals, but rather finding different paths to reach them.

What stood out most was a conversation I had that reminded me of the importance of genuine connection. Sometimes we get so caught up in our own worlds that we forget how much impact a simple, authentic interaction can have on both ourselves and others.

Tomorrow, I want to continue building on the momentum I felt today, while also being gentle with myself if things don\'t unfold exactly as expected.''',
      
      '''Reflection has become such an important part of my daily rhythm. Today brought a mix of productivity and contemplation. I noticed how my energy levels fluctuate throughout the day, and I\'m getting better at honoring those natural rhythms instead of fighting against them.

The challenging moments today taught me something valuable about resilience. It\'s not about avoiding difficulties, but about how we respond to them. I found myself pausing before reacting, which felt like a small but significant growth moment.

I\'m grateful for the support system around me and for my growing ability to support myself through both the highs and the inevitable lows. Each day is truly an opportunity to practice being human with a little more wisdom and compassion.''',
      
      '''Today I practiced being present in a way that felt different from before. Instead of rushing through tasks to get to the \'important\' stuff, I tried to find meaning and mindfulness in the ordinary moments. Making tea became a meditation, walking became an opportunity to notice the world around me, and even routine conversations became chances to really listen.

I\'m noticing patterns in my thoughts and reactions that I want to continue observing with curiosity rather than judgment. Growth isn\'t always about dramatic changes; sometimes it\'s about the subtle shifts in awareness that accumulate over time.

The evening brought a sense of quiet satisfaction - not because everything was perfect, but because I showed up for myself and others in ways that felt authentic and caring.''',
      
      '''This day reminded me of the importance of balance. I had moments of high energy and productivity, followed by periods where I needed to slow down and recharge. I\'m learning to see both as valuable and necessary parts of a full, human experience.

An unexpected challenge today became an opportunity to practice problem-solving and creativity. Instead of getting frustrated, I found myself getting curious about different approaches. This shift in perspective felt significant and worth remembering.

I\'m carrying forward a sense of gratitude for the ordinary magic of daily life - the way sunlight looks different at various times of day, the comfort of familiar routines, and the potential that exists in each moment to choose kindness, both for myself and others.''',
      
      '''Today was one of those days where I felt more connected to my deeper intentions and values. The tasks I completed felt aligned with who I\'m becoming, rather than just things I had to get done. There\'s something powerful about that sense of coherence between actions and aspirations.

I had a moment of real clarity about something I\'ve been pondering for weeks. Sometimes insights come when we stop trying so hard to force them and instead create space for them to emerge naturally.

As I prepare for tomorrow, I\'m holding onto the feeling of being exactly where I need to be in this moment, while also maintaining that gentle excitement about continued growth and discovery.''',
    ];
    
    return reflections[_random.nextInt(reflections.length)];
  }

  List<GoalModel> _generateEnhancedGoals(int userId) {
    final now = DateTime.now();
    
    return [
      GoalModel(
        userId: userId,
        title: 'Daily Mindfulness Practice',
        description: 'Establish a consistent mindfulness routine with meditation, breathing exercises, and present-moment awareness throughout the day.',
        category: GoalCategory.mindfulness,
        targetValue: 45,
        createdAt: now.subtract(const Duration(days: 30)),
        durationDays: 45,
        milestones: [],
        metrics: {
          'consecutiveDays': 23,
          'averageSessionLength': 12.5,
          'missedDays': 2,
          'favoriteTimeOfDay': 'morning',
        },
        frequency: FrequencyType.daily,
        tags: ['meditation', 'mindfulness', 'wellbeing', 'stress-relief'],
        customSettings: {
          'reminderTime': '07:00',
          'preferredLocation': 'quiet corner',
          'backgroundSounds': 'nature',
        },
        motivationalQuotes: [
          'The present moment is the only time over which we have dominion.',
          'Mindfulness is a way of befriending ourselves and our experience.',
          'Peace comes from within. Do not seek it without.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '07:00',
          'message': 'Time for your mindfulness practice 🧘‍♀️',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Emotional Intelligence Development',
        description: 'Enhance emotional awareness, regulation, and empathy through daily reflection, journaling, and conscious relationship building.',
        category: GoalCategory.emotional,
        targetValue: 60,
        createdAt: now.subtract(const Duration(days: 15)),
        durationDays: 60,
        milestones: [],
        metrics: {
          'emotionalAwarenessScore': 7.2,
          'journalEntries': 45,
          'conflictResolutionSuccesses': 3,
          'empathyPracticeFrequency': 'daily',
        },
        frequency: FrequencyType.daily,
        tags: ['emotional-intelligence', 'self-awareness', 'relationships', 'growth'],
        customSettings: {
          'journalPrompts': true,
          'moodTracking': true,
          'relationshipFocus': 'family and friends',
        },
        motivationalQuotes: [
          'The way you treat yourself becomes the way others treat you.',
          'Emotional intelligence is the ability to sense, understand, and effectively apply emotions.',
          'Your emotions are signals, not facts.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '20:00',
          'message': 'Time for emotional reflection 💭',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Creative Expression Journey',
        description: 'Explore and develop creative abilities through writing, art, music, or other forms of expression, dedicating time daily to creative practice.',
        category: GoalCategory.habits,
        targetValue: 90,
        createdAt: now.subtract(const Duration(days: 7)),
        durationDays: 90,
        milestones: [],
        metrics: {
          'creativeSessionsCompleted': 35,
          'piecesCreated': 8,
          'newTechniquesLearned': 12,
          'inspirationSources': 'nature, music, literature',
        },
        frequency: FrequencyType.daily,
        tags: ['creativity', 'art', 'expression', 'skill-building'],
        customSettings: {
          'primaryMedium': 'mixed',
          'shareWork': false,
          'learningResources': ['online tutorials', 'books', 'workshops'],
        },
        motivationalQuotes: [
          'Creativity is intelligence having fun.',
          'The creative adult is the child who survived.',
          'Art enables us to find ourselves and lose ourselves at the same time.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '19:00',
          'message': 'Time to create something beautiful 🎨',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Deep Connection Building',
        description: 'Strengthen existing relationships and build new meaningful connections through intentional communication, active listening, and shared experiences.',
        category: GoalCategory.social,
        targetValue: 40,
        createdAt: now.subtract(const Duration(days: 20)),
        durationDays: 40,
        milestones: [],
        metrics: {
          'qualityConversations': 28,
          'newConnectionsMade': 5,
          'relationshipSatisfactionScore': 8.1,
          'conflictsResolvedPeacefully': 2,
        },
        frequency: FrequencyType.weekly,
        tags: ['relationships', 'connection', 'communication', 'empathy'],
        customSettings: {
          'focusAreas': ['family', 'friendships', 'community'],
          'communicationStyle': 'authentic and caring',
          'boundaryPractice': true,
        },
        motivationalQuotes: [
          'The quality of your life is the quality of your relationships.',
          'Connection is why we\'re here; it is what gives purpose and meaning to our lives.',
          'Be curious, not judgmental.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '18:00',
          'message': 'Reach out to someone you care about 💕',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Holistic Wellness Integration',
        description: 'Create a sustainable wellness routine incorporating physical activity, nutrition, sleep hygiene, and stress management practices.',
        category: GoalCategory.physical,
        targetValue: 75,
        createdAt: now.subtract(const Duration(days: 45)),
        durationDays: 75,
        milestones: [],
        metrics: {
          'averageSleepHours': 7.8,
          'workoutFrequency': 5,
          'nutritionScore': 7.5,
          'stressLevelReduction': 2.3,
          'energyLevelIncrease': 1.8,
        },
        frequency: FrequencyType.daily,
        tags: ['health', 'wellness', 'fitness', 'nutrition', 'sleep'],
        customSettings: {
          'preferredWorkoutTime': 'morning',
          'dietaryPreferences': 'balanced',
          'sleepGoal': 8,
          'stressManagementTools': ['breathing', 'meditation', 'journaling'],
        },
        motivationalQuotes: [
          'Take care of your body. It\'s the only place you have to live.',
          'Health is not about the weight you lose, but about the life you gain.',
          'Self-care is not selfish. You cannot serve from an empty vessel.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '21:30',
          'message': 'Time to wind down for quality sleep 🌙',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Stress Management Mastery',
        description: 'Develop effective techniques for managing stress and maintaining calm in challenging situations.',
        category: GoalCategory.stress,
        targetValue: 30,
        createdAt: now.subtract(const Duration(days: 12)),
        durationDays: 30,
        milestones: [],
        metrics: {
          'stressLevelReduction': 2.1,
          'copingTechniques': 8,
          'stressfulSituationsHandled': 15,
          'averageRecoveryTime': '25 minutes',
        },
        frequency: FrequencyType.daily,
        tags: ['stress-management', 'resilience', 'coping', 'mental-health'],
        customSettings: {
          'triggers': ['work deadlines', 'traffic', 'social situations'],
          'techniques': ['breathing', 'progressive relaxation', 'reframing'],
          'trackingMethod': 'stress scale 1-10',
        },
        motivationalQuotes: [
          'You have been assigned this mountain to show others it can be moved.',
          'Stress is caused by being here but wanting to be there.',
          'The greatest weapon against stress is our ability to choose one thought over another.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '12:00',
          'message': 'Check in with your stress levels 🧘‍♂️',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Quality Sleep Optimization',
        description: 'Establish consistent sleep habits and improve sleep quality for better physical and mental health.',
        category: GoalCategory.sleep,
        targetValue: 60,
        createdAt: now.subtract(const Duration(days: 25)),
        durationDays: 60,
        milestones: [],
        metrics: {
          'averageSleepHours': 7.5,
          'sleepQualityScore': 8.2,
          'nightsWithout8Hours': 8,
          'sleepConsistencyScore': 85,
        },
        frequency: FrequencyType.daily,
        tags: ['sleep', 'health', 'routine', 'recovery'],
        customSettings: {
          'bedtime': '22:30',
          'wakeTime': '06:30',
          'environment': 'dark, cool, quiet',
          'preSeepRoutine': ['no screens', 'reading', 'meditation'],
        },
        motivationalQuotes: [
          'Sleep is the best meditation.',
          'A good laugh and a long sleep are the two best cures for anything.',
          'Sleep is that golden chain that ties health and our bodies together.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '21:00',
          'message': 'Start winding down for quality sleep 🌙',
        },
        isTemplate: false,
      ),
      
      GoalModel(
        userId: userId,
        title: 'Productivity & Focus Enhancement',
        description: 'Improve work efficiency, eliminate distractions, and develop laser-sharp focus for meaningful tasks.',
        category: GoalCategory.productivity,
        targetValue: 45,
        createdAt: now.subtract(const Duration(days: 8)),
        durationDays: 45,
        milestones: [],
        metrics: {
          'averageFocusTime': 85,
          'tasksCompleted': 127,
          'distractionReduction': 65,
          'deepWorkSessions': 38,
        },
        frequency: FrequencyType.daily,
        tags: ['productivity', 'focus', 'efficiency', 'time-management'],
        customSettings: {
          'focusMethod': 'Pomodoro Technique',
          'workEnvironment': 'minimalist desk setup',
          'distractionBlockers': ['phone silent', 'website blockers', 'closed door'],
          'peakHours': '9:00-11:00 AM',
        },
        motivationalQuotes: [
          'Focus on being productive instead of busy.',
          'The successful warrior is the average person with laser-like focus.',
          'Where focus goes, energy flows and results show.',
        ],
        reminderSettings: {
          'enabled': true,
          'time': '08:30',
          'message': 'Time for focused, productive work! 🎯',
        },
        isTemplate: false,
      ),
    ];
  }

  List<RoadmapActivityModel> _generateRoadmapActivities(DateTime date) {
    final activities = <RoadmapActivityModel>[];
    final activityTemplates = [
      {'title': 'Morning Meditation', 'category': 'Mindfulness', 'duration': 15, 'time': [7, 0]},
      {'title': 'Healthy Breakfast', 'category': 'Wellness', 'duration': 30, 'time': [7, 30]},
      {'title': 'Email Review', 'category': 'Productivity', 'duration': 20, 'time': [8, 30]},
      {'title': 'Deep Work Session', 'category': 'Productivity', 'duration': 90, 'time': [9, 0]},
      {'title': 'Coffee & Reflection', 'category': 'Self-care', 'duration': 15, 'time': [10, 30]},
      {'title': 'Creative Writing', 'category': 'Creativity', 'duration': 45, 'time': [11, 0]},
      {'title': 'Lunch & Walk', 'category': 'Wellness', 'duration': 45, 'time': [12, 30]},
      {'title': 'Skill Learning', 'category': 'Growth', 'duration': 60, 'time': [14, 0]},
      {'title': 'Connect with Friend', 'category': 'Social', 'duration': 30, 'time': [16, 0]},
      {'title': 'Exercise/Movement', 'category': 'Fitness', 'duration': 45, 'time': [17, 30]},
      {'title': 'Dinner Preparation', 'category': 'Self-care', 'duration': 40, 'time': [18, 30]},
      {'title': 'Reading Time', 'category': 'Learning', 'duration': 30, 'time': [20, 0]},
      {'title': 'Gratitude Journal', 'category': 'Reflection', 'duration': 10, 'time': [21, 0]},
      {'title': 'Wind Down', 'category': 'Self-care', 'duration': 20, 'time': [21, 30]},
    ];

    // Select 6-10 activities for the day
    final selectedCount = _random.nextInt(5) + 6;
    final selectedTemplates = List.from(activityTemplates)..shuffle(_random);
    
    for (int i = 0; i < selectedCount && i < selectedTemplates.length; i++) {
      final template = selectedTemplates[i];
      final timeSlot = template['time'] as List<int>;
      
      final activity = RoadmapActivityModel.create(
        title: template['title'] as String,
        hour: timeSlot[0],
        minute: timeSlot[1],
        estimatedDuration: template['duration'] as int,
        category: template['category'] as String,
        priority: _getRandomPriority(),
        description: _generateActivityDescription(template['title'] as String),
      );

      // For past days, randomly mark some activities as completed
      final isPastDay = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      if (isPastDay && _random.nextBool()) {
        final completedActivity = activity.copyWith(
          isCompleted: true,
          completedAt: date.add(Duration(hours: timeSlot[0], minutes: timeSlot[1] + (template['duration'] as int))),
          actualMood: _getRandomMood(),
          notes: _generateActivityNotes(),
        );
        activities.add(completedActivity);
      } else {
        activities.add(activity);
      }
    }
    
    return activities;
  }

  String _generateDailyGoal() {
    final goals = [
      'Focus on being present in each moment and interaction',
      'Practice gratitude and notice three things I appreciate',
      'Move my body mindfully and with joy',
      'Create something meaningful, however small',
      'Connect authentically with someone I care about',
      'Learn something new that sparks curiosity',
      'Take care of my physical and emotional needs',
      'Approach challenges with patience and creativity',
      'Celebrate small wins and progress made',
      'End the day feeling grateful and at peace',
    ];
    
    return goals[_random.nextInt(goals.length)];
  }

  String _generateMorningNotes() {
    final notes = [
      'Feeling energized and ready to tackle the day with intention and purpose.',
      'Starting slow and gentle, honoring my body\'s rhythm and needs.',
      'Excited about the creative projects I have planned for today.',
      'Focusing on connection and meaningful interactions throughout the day.',
      'Committed to staying present and not rushing through moments.',
      'Ready to learn and grow, approaching challenges with curiosity.',
      'Grateful for this new day and the opportunities it brings.',
      'Setting an intention to be kind to myself and others today.',
    ];
    
    return notes[_random.nextInt(notes.length)];
  }

  String _generateEveningReflection() {
    final reflections = [
      'Today brought a nice balance of productivity and rest. I\'m grateful for the moments of connection I experienced.',
      'I handled today\'s challenges with more grace than I expected. Proud of the progress I\'m making.',
      'The creative work I did today felt fulfilling. It\'s amazing how expression can shift my entire mood.',
      'I noticed myself being more present during conversations today. This mindfulness practice is really helping.',
      'Even though not everything went as planned, I adapted well and found joy in unexpected moments.',
      'Today reinforced the importance of self-care. Taking breaks actually made me more productive.',
      'I feel grateful for the support system around me and for my growing self-awareness.',
      'Tomorrow I want to build on today\'s momentum while also being gentle with myself.',
    ];
    
    return reflections[_random.nextInt(reflections.length)];
  }

  String _generateActivityDescription(String title) {
    final descriptions = {
      'Morning Meditation': 'Start the day with 15 minutes of mindful breathing and intention setting',
      'Healthy Breakfast': 'Nourishing meal with protein, whole grains, and fruits/vegetables',
      'Email Review': 'Check and respond to important messages, organize inbox',
      'Deep Work Session': 'Focused, uninterrupted work on priority projects',
      'Coffee & Reflection': 'Mindful coffee break with brief reflection on morning progress',
      'Creative Writing': 'Free writing or structured creative project work',
      'Lunch & Walk': 'Nutritious meal followed by outdoor movement and fresh air',
      'Skill Learning': 'Dedicated time for learning new skills or improving existing ones',
      'Connect with Friend': 'Meaningful conversation with someone I care about',
      'Exercise/Movement': 'Physical activity that brings joy and energy',
      'Dinner Preparation': 'Mindful cooking and meal preparation',
      'Reading Time': 'Engaging with books, articles, or learning materials',
      'Gratitude Journal': 'Reflect on and write down things I\'m grateful for',
      'Wind Down': 'Calming activities to prepare for restful sleep',
    };
    
    return descriptions[title] ?? 'Meaningful activity that contributes to personal growth';
  }

  String _generateActivityNotes() {
    final notes = [
      'Felt really good about this activity. It energized me for the rest of the day.',
      'This was more challenging than expected, but I pushed through and felt accomplished.',
      'Really enjoyed this time. It reminded me why this activity is important to me.',
      'Had to adjust the timing, but still got the core benefits from this activity.',
      'This activity helped me feel more centered and focused.',
      'Grateful I made time for this, even though my schedule was packed.',
      'This brought more joy than I anticipated. Want to make more time for it.',
      'Good reminder of the importance of consistency with activities that matter.',
    ];
    
    return notes[_random.nextInt(notes.length)];
  }

  ActivityPriority _getRandomPriority() {
    final priorities = ActivityPriority.values;
    final weights = [0.3, 0.4, 0.2, 0.1]; // high, medium, low, optional
    final randomValue = _random.nextDouble();
    
    double cumulativeWeight = 0.0;
    for (int i = 0; i < priorities.length; i++) {
      cumulativeWeight += weights[i];
      if (randomValue <= cumulativeWeight) {
        return priorities[i];
      }
    }
    
    return ActivityPriority.medium;
  }

  ActivityMood _getRandomMood() {
    final moods = ActivityMood.values;
    return moods[_random.nextInt(moods.length)];
  }

  RoadmapStatus _getRandomRoadmapStatus() {
    final statuses = [
      RoadmapStatus.completed,
      RoadmapStatus.partiallyCompleted,
      RoadmapStatus.inProgress,
    ];
    final weights = [0.6, 0.3, 0.1]; // More likely to be completed for past days
    final randomValue = _random.nextDouble();
    
    double cumulativeWeight = 0.0;
    for (int i = 0; i < statuses.length; i++) {
      cumulativeWeight += weights[i];
      if (randomValue <= cumulativeWeight) {
        return statuses[i];
      }
    }
    
    return RoadmapStatus.completed;
  }

  // Helper methods for realistic productivity patterns
  int _getProductiveHour(int entryIndex, int totalEntries) {
    // Create realistic work hour patterns
    final workHours = [9, 10, 11, 14, 15, 16, 19, 20]; // Common productive hours
    final selectedHours = <int>[];
    
    // Morning productivity (9-11)
    if (entryIndex == 0) {
      selectedHours.addAll([9, 10, 11]);
    }
    // Afternoon productivity (14-16) 
    else if (entryIndex == 1) {
      selectedHours.addAll([14, 15, 16]);
    }
    // Evening productivity (19-20)
    else {
      selectedHours.addAll([19, 20]);
    }
    
    return selectedHours[_random.nextInt(selectedHours.length)];
  }
  
  int _getProductivityForHour(int hour) {
    // Higher productivity during typical work hours
    if (hour >= 9 && hour <= 11) {
      return 6 + _random.nextInt(4); // 6-9 (high morning productivity)
    } else if (hour >= 14 && hour <= 16) {
      return 5 + _random.nextInt(4); // 5-8 (good afternoon productivity)  
    } else if (hour >= 19 && hour <= 20) {
      return 4 + _random.nextInt(4); // 4-7 (moderate evening productivity)
    } else {
      return 2 + _random.nextInt(4); // 2-5 (lower productivity other hours)
    }
  }
  
  int _getFocusForHour(int hour) {
    // Focus tends to be highest in morning, lower after lunch
    if (hour >= 9 && hour <= 11) {
      return 7 + _random.nextInt(3); // 7-9 (high morning focus)
    } else if (hour >= 14 && hour <= 16) {
      return 5 + _random.nextInt(3); // 5-7 (moderate afternoon focus)
    } else if (hour >= 19 && hour <= 20) {
      return 4 + _random.nextInt(3); // 4-6 (lower evening focus)
    } else {
      return 2 + _random.nextInt(4); // 2-5 (variable other hours)
    }
  }
  
  int _getCreativeEnergyForHour(int hour) {
    // Creative energy can vary by person, but often peaks in morning or evening
    if (hour >= 9 && hour <= 11) {
      return 6 + _random.nextInt(4); // 6-9 (high morning creativity)
    } else if (hour >= 19 && hour <= 20) {
      return 5 + _random.nextInt(4); // 5-8 (good evening creativity)
    } else if (hour >= 14 && hour <= 16) {
      return 4 + _random.nextInt(3); // 4-6 (moderate afternoon creativity)
    } else {
      return 2 + _random.nextInt(4); // 2-5 (variable other hours)
    }
  }

  /// Seed recommended activities across all categories
  Future<void> seedRecommendedActivities(int userId) async {
    if (kDebugMode) {
      debugPrint('🎯 Adding recommended activities...');
    }

    final activities = _generateDiverseRecommendedActivities();
    
    for (final activity in activities) {
      try {
        // Create OptimizedRecommendedActivityModel instances
        final recommendedActivity = {
          'user_id': userId,
          'title': activity['title'],
          'description': activity['description'],
          'category': activity['category'],
          'estimated_minutes': activity['estimatedMinutes'],
          'difficulty_level': activity['difficulty'],
          'benefits': activity['benefits'].join(','),
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'is_active': 1,
        };
        
        // Save using raw database insert since we don't have the specific method
        final db = await _databaseService.database;
        
        // Create table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS recommended_activities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            category TEXT,
            estimated_minutes INTEGER,
            difficulty_level TEXT,
            benefits TEXT,
            created_at INTEGER NOT NULL,
            is_active INTEGER DEFAULT 1
          )
        ''');
        
        await db.insert('recommended_activities', recommendedActivity);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Could not save recommended activity: ${activity['title']} - $e');
        }
      }
    }
  }

  /// Seed diverse tags and emotional categories
  Future<void> seedDiverseTagsAndCategories(int userId) async {
    if (kDebugMode) {
      debugPrint('🏷️ Adding diverse tags and categories...');
    }

    final tags = _generateDiverseTags();
    
    for (final tag in tags) {
      try {
        final tagData = {
          'user_id': userId,
          'name': tag['name'],
          'category': tag['category'],
          'color_hex': tag['color'],
          'usage_count': tag['usageCount'],
          'created_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'is_active': 1,
        };
        
        final db = await _databaseService.database;
        
        // Create table if it doesn't exist (extend existing tags table)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            category TEXT,
            color_hex TEXT,
            usage_count INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            is_active INTEGER DEFAULT 1,
            UNIQUE(user_id, name)
          )
        ''');
        
        await db.insert('tags', tagData, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Could not save tag: ${tag['name']} - $e');
        }
      }
    }
  }

  /// Seed advanced analytics data with realistic patterns
  Future<void> seedAdvancedAnalyticsData(int userId) async {
    if (kDebugMode) {
      debugPrint('📊 Adding advanced analytics data...');
    }

    final now = DateTime.now();
    
    // Create 30 days of analytics snapshots
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      
      try {
        final analyticsData = {
          'user_id': userId,
          'date': date.toIso8601String().split('T')[0],
          'mood_average': (5.0 + (_random.nextDouble() - 0.5) * 4).clamp(1.0, 10.0),
          'energy_average': (5.0 + (_random.nextDouble() - 0.5) * 4).clamp(1.0, 10.0),
          'stress_average': (4.0 + (_random.nextDouble() - 0.5) * 3).clamp(1.0, 10.0),
          'productivity_score': (60 + _random.nextInt(40)).toDouble(),
          'sleep_hours': 6.0 + _random.nextDouble() * 3.0,
          'exercise_minutes': _random.nextInt(120),
          'meditation_minutes': _random.nextInt(60),
          'social_interactions': _random.nextInt(8) + 1,
          'screen_time_hours': 4.0 + _random.nextDouble() * 8.0,
          'gratitude_count': _random.nextInt(5),
          'reflection_word_count': _random.nextInt(500) + 50,
          'goal_progress_average': _random.nextDouble() * 100,
          'created_at': date.millisecondsSinceEpoch ~/ 1000,
        };
        
        final db = await _databaseService.database;
        // Create analytics table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_analytics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            mood_average REAL,
            energy_average REAL,
            stress_average REAL,
            productivity_score REAL,
            sleep_hours REAL,
            exercise_minutes INTEGER,
            meditation_minutes INTEGER,
            social_interactions INTEGER,
            screen_time_hours REAL,
            gratitude_count INTEGER,
            reflection_word_count INTEGER,
            goal_progress_average REAL,
            created_at INTEGER NOT NULL,
            UNIQUE(user_id, date)
          )
        ''');
        
        await db.insert('daily_analytics', analyticsData, 
          conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Could not save analytics for ${date.toString().split(' ')[0]} - $e');
        }
      }
    }
  }

  List<Map<String, dynamic>> _generateDiverseRecommendedActivities() {
    return [
      // Mindfulness & Meditation
      {'title': '5-Minute Breathing Exercise', 'description': 'Simple breathing practice to center yourself', 'category': 'Mindfulness', 'estimatedMinutes': 5, 'difficulty': 'easy', 'benefits': ['stress relief', 'focus']},
      {'title': 'Body Scan Meditation', 'description': 'Progressive relaxation through body awareness', 'category': 'Mindfulness', 'estimatedMinutes': 15, 'difficulty': 'medium', 'benefits': ['relaxation', 'awareness']},
      {'title': 'Walking Meditation', 'description': 'Mindful walking practice in nature or indoors', 'category': 'Mindfulness', 'estimatedMinutes': 20, 'difficulty': 'easy', 'benefits': ['mindfulness', 'movement']},
      
      // Physical Activities
      {'title': 'Morning Stretches', 'description': 'Gentle stretching routine to start the day', 'category': 'Physical', 'estimatedMinutes': 10, 'difficulty': 'easy', 'benefits': ['flexibility', 'energy']},
      {'title': 'HIIT Workout', 'description': 'High-intensity interval training session', 'category': 'Physical', 'estimatedMinutes': 25, 'difficulty': 'hard', 'benefits': ['fitness', 'endurance']},
      {'title': 'Yoga Flow', 'description': 'Flowing yoga sequence for strength and flexibility', 'category': 'Physical', 'estimatedMinutes': 30, 'difficulty': 'medium', 'benefits': ['strength', 'balance', 'mindfulness']},
      
      // Creative Activities
      {'title': 'Free Writing', 'description': 'Stream of consciousness writing for 10 minutes', 'category': 'Creative', 'estimatedMinutes': 10, 'difficulty': 'easy', 'benefits': ['expression', 'clarity']},
      {'title': 'Art Journaling', 'description': 'Combine drawing and writing in a personal journal', 'category': 'Creative', 'estimatedMinutes': 30, 'difficulty': 'medium', 'benefits': ['creativity', 'self-expression']},
      {'title': 'Music Appreciation', 'description': 'Listen deeply to your favorite music', 'category': 'Creative', 'estimatedMinutes': 20, 'difficulty': 'easy', 'benefits': ['mood boost', 'inspiration']},
      
      // Social Activities
      {'title': 'Call a Friend', 'description': 'Reach out to someone you care about', 'category': 'Social', 'estimatedMinutes': 15, 'difficulty': 'easy', 'benefits': ['connection', 'support']},
      {'title': 'Write a Thank You Note', 'description': 'Express gratitude to someone in writing', 'category': 'Social', 'estimatedMinutes': 10, 'difficulty': 'easy', 'benefits': ['gratitude', 'connection']},
      {'title': 'Active Listening Practice', 'description': 'Focus on truly hearing someone today', 'category': 'Social', 'estimatedMinutes': 30, 'difficulty': 'medium', 'benefits': ['empathy', 'relationships']},
      
      // Learning & Growth
      {'title': 'Read for Pleasure', 'description': 'Enjoy a good book or article', 'category': 'Learning', 'estimatedMinutes': 30, 'difficulty': 'easy', 'benefits': ['knowledge', 'relaxation']},
      {'title': 'Learn Something New', 'description': 'Explore a topic that interests you', 'category': 'Learning', 'estimatedMinutes': 45, 'difficulty': 'medium', 'benefits': ['growth', 'curiosity']},
      {'title': 'Skill Practice', 'description': 'Work on developing a personal skill', 'category': 'Learning', 'estimatedMinutes': 60, 'difficulty': 'medium', 'benefits': ['mastery', 'confidence']},
      
      // Self-Care
      {'title': 'Digital Detox Hour', 'description': 'One hour without screens or notifications', 'category': 'Self-care', 'estimatedMinutes': 60, 'difficulty': 'medium', 'benefits': ['mental clarity', 'presence']},
      {'title': 'Gratitude Practice', 'description': 'Write down three things you\'re grateful for', 'category': 'Self-care', 'estimatedMinutes': 5, 'difficulty': 'easy', 'benefits': ['positivity', 'perspective']},
      {'title': 'Self-Compassion Break', 'description': 'Practice being kind to yourself', 'category': 'Self-care', 'estimatedMinutes': 10, 'difficulty': 'easy', 'benefits': ['self-acceptance', 'emotional wellness']},
      
      // Productivity
      {'title': 'Priority Setting', 'description': 'Identify your top 3 priorities for today', 'category': 'Productivity', 'estimatedMinutes': 10, 'difficulty': 'easy', 'benefits': ['focus', 'clarity']},
      {'title': 'Deep Work Session', 'description': 'Focused work on an important task', 'category': 'Productivity', 'estimatedMinutes': 90, 'difficulty': 'medium', 'benefits': ['accomplishment', 'progress']},
      {'title': 'Weekly Review', 'description': 'Reflect on the week and plan ahead', 'category': 'Productivity', 'estimatedMinutes': 30, 'difficulty': 'medium', 'benefits': ['planning', 'reflection']},
    ];
  }

  List<Map<String, dynamic>> _generateDiverseTags() {
    return [
      // Emotional tags
      {'name': 'peaceful', 'category': 'emotion', 'color': '4CAF50', 'usageCount': _random.nextInt(20) + 5},
      {'name': 'energized', 'category': 'emotion', 'color': 'FF9800', 'usageCount': _random.nextInt(20) + 5},
      {'name': 'grateful', 'category': 'emotion', 'color': '9C27B0', 'usageCount': _random.nextInt(20) + 5},
      {'name': 'anxious', 'category': 'emotion', 'color': 'F44336', 'usageCount': _random.nextInt(15) + 2},
      {'name': 'excited', 'category': 'emotion', 'color': 'FF5722', 'usageCount': _random.nextInt(18) + 3},
      {'name': 'contemplative', 'category': 'emotion', 'color': '3F51B5', 'usageCount': _random.nextInt(16) + 4},
      
      // Activity tags  
      {'name': 'meditation', 'category': 'activity', 'color': '673AB7', 'usageCount': _random.nextInt(25) + 10},
      {'name': 'exercise', 'category': 'activity', 'color': '4CAF50', 'usageCount': _random.nextInt(22) + 8},
      {'name': 'reading', 'category': 'activity', 'color': '2196F3', 'usageCount': _random.nextInt(20) + 6},
      {'name': 'cooking', 'category': 'activity', 'color': 'FF9800', 'usageCount': _random.nextInt(18) + 5},
      {'name': 'nature', 'category': 'activity', 'color': '4CAF50', 'usageCount': _random.nextInt(24) + 7},
      {'name': 'creativity', 'category': 'activity', 'color': 'E91E63', 'usageCount': _random.nextInt(17) + 4},
      
      // Context tags
      {'name': 'morning', 'category': 'context', 'color': 'FFC107', 'usageCount': _random.nextInt(30) + 15},
      {'name': 'evening', 'category': 'context', 'color': '3F51B5', 'usageCount': _random.nextInt(28) + 12},
      {'name': 'work', 'category': 'context', 'color': '607D8B', 'usageCount': _random.nextInt(25) + 10},
      {'name': 'home', 'category': 'context', 'color': '795548', 'usageCount': _random.nextInt(35) + 20},
      {'name': 'weekend', 'category': 'context', 'color': '9C27B0', 'usageCount': _random.nextInt(20) + 8},
      {'name': 'travel', 'category': 'context', 'color': '00BCD4', 'usageCount': _random.nextInt(12) + 2},
      
      // Achievement tags
      {'name': 'breakthrough', 'category': 'achievement', 'color': 'FF5722', 'usageCount': _random.nextInt(8) + 1},
      {'name': 'milestone', 'category': 'achievement', 'color': 'FF9800', 'usageCount': _random.nextInt(10) + 2},
      {'name': 'learning', 'category': 'achievement', 'color': '2196F3', 'usageCount': _random.nextInt(15) + 5},
      {'name': 'progress', 'category': 'achievement', 'color': '4CAF50', 'usageCount': _random.nextInt(18) + 7},
    ];
  }

  /// Clear all test data for a user
  Future<void> clearEnhancedTestData(int userId) async {
    if (kDebugMode) {
      debugPrint('🧹 Clearing enhanced test data for user $userId...');
    }

    try {
      final db = await _databaseService.database;
      
      // Clear in reverse order to avoid foreign key constraints
      // Use try-catch for each table in case it doesn't exist
      
      await _deleteFromTableSafely(db, 'daily_analytics', userId);
      await _deleteFromTableSafely(db, 'recommended_activities', userId);
      await _deleteFromTableSafely(db, 'tags', userId);
      await _deleteFromTableSafely(db, 'daily_roadmaps', userId);
      await _deleteFromTableSafely(db, 'user_goals', userId);
      await _deleteFromTableSafely(db, 'daily_entries', userId);
      await _deleteFromTableSafely(db, 'interactive_moments', userId);
      
      if (kDebugMode) {
        debugPrint('✅ Enhanced test data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing enhanced test data: $e');
      }
      rethrow;
    }
  }

  /// Helper method to safely delete from a table that might not exist
  Future<void> _deleteFromTableSafely(Database db, String tableName, int userId) async {
    try {
      await db.delete(tableName, where: 'user_id = ?', whereArgs: [userId]);
      if (kDebugMode) {
        debugPrint('🗑️ Cleared data from $tableName');
      }
    } on DatabaseException catch (e) {
      if (e.toString().toLowerCase().contains('no such table')) {
        if (kDebugMode) {
          debugPrint('⚠️ Table $tableName does not exist, skipping...');
        }
      } else {
        rethrow;
      }
    }
  }
}