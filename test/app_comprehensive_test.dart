// ============================================================================
// COMPREHENSIVE TEST SUITE FOR REFLECTACTIONS APP
// ============================================================================
// This file contains tests for all models, providers, services, and utilities
// Run with: flutter test test/app_comprehensive_test.dart
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:untitled3/data/models/user_model.dart';
import 'package:untitled3/data/models/daily_entry_model.dart';
import 'package:untitled3/data/models/goal_model.dart';
import 'package:untitled3/data/models/tag_model.dart';
import 'package:untitled3/data/models/chat_message_model.dart';
import 'package:untitled3/data/models/daily_activity_model.dart';
import 'package:untitled3/data/models/daily_roadmap_model.dart';
import 'package:untitled3/data/models/roadmap_activity_model.dart';
import 'package:untitled3/data/models/recommended_activity_model.dart';
import 'package:untitled3/data/models/interactive_moment_model.dart';
import 'package:untitled3/data/models/analytics_config_model.dart';

void main() {
  // ============================================================================
  // USER MODEL TESTS
  // ============================================================================
  group('UserModel', () {
    test('fromJson creates UserModel from valid JSON', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'profileImagePath': '/path/to/image.jpg',
        'settings': {'theme': 'dark'},
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.profileImagePath, '/path/to/image.jpg');
    });

    test('toJson serializes UserModel correctly', () {
      final user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        profileImagePath: '/path/to/image.jpg',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['profileImagePath'], '/path/to/image.jpg');
    });

    test('fromDatabase creates UserModel from database map', () {
      final map = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'created_at': '2024-01-01T00:00:00.000Z',
        'profile_image_path': '/path/to/image.jpg',
      };

      final user = UserModel.fromDatabase(map);

      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('toDatabase converts UserModel to database format', () {
      final user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      final dbMap = user.toDatabase();

      expect(dbMap['name'], 'Test User');
      expect(dbMap['email'], 'test@example.com');
      expect(dbMap.containsKey('created_at'), true);
    });

    test('copyWith creates modified copy', () {
      final user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      final modifiedUser = user.copyWith(name: 'Modified User');

      expect(modifiedUser.name, 'Modified User');
      expect(modifiedUser.email, 'test@example.com');
      expect(modifiedUser.id, 1);
    });

    test('copyWith preserves all fields when not specified', () {
      final user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        profileImagePath: '/path/to/image.jpg',
      );

      final copy = user.copyWith();

      expect(copy.id, user.id);
      expect(copy.name, user.name);
      expect(copy.email, user.email);
      expect(copy.profileImagePath, user.profileImagePath);
    });
  });

  // ============================================================================
  // DAILY ENTRY MODEL TESTS
  // ============================================================================
  group('DailyEntryModel', () {
    test('create factory creates valid entry', () {
      final entry = DailyEntryModel.create(
        userId: 1,
        freeReflection: 'Test reflection',
        moodScore: 7,
        energyLevel: 8,
        stressLevel: 3,
        worthIt: true,
      );

      expect(entry.userId, 1);
      expect(entry.freeReflection, 'Test reflection');
      expect(entry.moodScore, 7);
      expect(entry.energyLevel, 8);
      expect(entry.stressLevel, 3);
      expect(entry.worthIt, true);
    });

    test('toJson serializes all fields correctly', () {
      final entry = DailyEntryModel.create(
        userId: 1,
        freeReflection: 'Test reflection',
        moodScore: 7,
        energyLevel: 8,
        stressLevel: 3,
        worthIt: true,
        sleepQuality: 8,
        waterIntake: 8,
        exerciseMinutes: 30,
      );

      final json = entry.toJson();

      expect(json['user_id'], 1);
      expect(json['free_reflection'], 'Test reflection');
      expect(json['mood_score'], 7);
      expect(json['energy_level'], 8);
      expect(json['stress_level'], 3);
      expect(json['worth_it'], 1); // Boolean to int
      expect(json['sleep_quality'], 8);
      expect(json['water_intake'], 8);
      expect(json['exercise_minutes'], 30);
    });

    test('fromJson deserializes all fields correctly', () {
      final json = {
        'id': 1,
        'user_id': 1,
        'date': '2024-01-01',
        'free_reflection': 'Test reflection',
        'mood_score': 7,
        'energy_level': 8,
        'stress_level': 3,
        'worth_it': 1,
        'positive_tags': '["happy","productive"]',
        'negative_tags': '["tired"]',
        'sleep_quality': 8,
        'anxiety_level': 3,
        'motivation_level': 7,
        'sleep_hours': 7.5,
        'water_intake': 8,
        'meditation_minutes': 15,
        'exercise_minutes': 30,
        'screen_time_hours': 4.0,
      };

      final entry = DailyEntryModel.fromJson(json);

      expect(entry.id, 1);
      expect(entry.userId, 1);
      expect(entry.freeReflection, 'Test reflection');
      expect(entry.moodScore, 7);
      expect(entry.worthIt, true);
      expect(entry.positiveTags, ['happy', 'productive']);
      expect(entry.negativeTags, ['tired']);
    });

    test('fromDatabase handles null values gracefully', () {
      final map = {
        'id': 1,
        'user_id': 1,
        'date': '2024-01-01',
        'free_reflection': 'Test',
        'positive_tags': null,
        'negative_tags': null,
        'mood_score': null,
        'worth_it': null,
      };

      final entry = DailyEntryModel.fromDatabase(map);

      expect(entry.id, 1);
      expect(entry.positiveTags, isEmpty);
      expect(entry.negativeTags, isEmpty);
      expect(entry.moodScore, isNull);
      expect(entry.worthIt, isNull);
    });

    test('copyWith creates modified copy with all fields', () {
      final entry = DailyEntryModel.create(
        userId: 1,
        freeReflection: 'Original',
        moodScore: 5,
        energyLevel: 5,
        stressLevel: 5,
      );

      final modified = entry.copyWith(
        freeReflection: 'Modified',
        moodScore: 8,
        energyLevel: 9,
      );

      expect(modified.freeReflection, 'Modified');
      expect(modified.moodScore, 8);
      expect(modified.energyLevel, 9);
      expect(modified.stressLevel, 5); // Unchanged
      expect(modified.userId, 1); // Unchanged
    });

    test('toDatabase creates valid database map', () {
      final entry = DailyEntryModel.create(
        userId: 1,
        freeReflection: 'Test',
        moodScore: 7,
        positiveTags: ['happy', 'productive'],
        negativeTags: ['tired'],
      );

      final dbMap = entry.toDatabase();

      expect(dbMap['user_id'], 1);
      expect(dbMap['free_reflection'], 'Test');
      expect(dbMap['mood_score'], 7);
      // Tags should be JSON encoded
      expect(dbMap['positive_tags'], contains('happy'));
    });
  });

  // ============================================================================
  // GOAL MODEL TESTS
  // ============================================================================
  group('GoalModel', () {
    late GoalModel testGoal;

    setUp(() {
      testGoal = GoalModel(
        id: 1,
        userId: 1,
        title: 'Test Goal',
        description: 'Test Description',
        category: GoalCategory.mindfulness,
        targetValue: 100,
        currentValue: 50,
        startDate: DateTime(2024, 1, 1),
        estimatedDuration: GoalDuration.oneMonth,
        status: GoalStatus.active,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    test('progress getter calculates correctly', () {
      expect(testGoal.progress, 50.0);

      final completedGoal = testGoal.copyWith(currentValue: 100);
      expect(completedGoal.progress, 100.0);

      final zeroGoal = testGoal.copyWith(currentValue: 0);
      expect(zeroGoal.progress, 0.0);
    });

    test('progressPercentage getter returns correct percentage', () {
      expect(testGoal.progressPercentage, 0.5);

      final completedGoal = testGoal.copyWith(currentValue: 100);
      expect(completedGoal.progressPercentage, 1.0);
    });

    test('isCompleted getter returns correct status', () {
      expect(testGoal.isCompleted, false);

      final completedGoal = testGoal.copyWith(status: GoalStatus.completed);
      expect(completedGoal.isCompleted, true);
    });

    test('isActive getter returns correct status', () {
      expect(testGoal.isActive, true);

      final completedGoal = testGoal.copyWith(status: GoalStatus.completed);
      expect(completedGoal.isActive, false);
    });

    test('isArchived getter returns correct status', () {
      expect(testGoal.isArchived, false);

      final archivedGoal = testGoal.copyWith(status: GoalStatus.archived);
      expect(archivedGoal.isArchived, true);
    });

    test('daysSinceCreated calculates correctly', () {
      final recentGoal = testGoal.copyWith(createdAt: DateTime.now());
      expect(recentGoal.daysSinceCreated, 0);

      final oldGoal = testGoal.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(oldGoal.daysSinceCreated, 30);
    });

    test('remainingValue calculates correctly', () {
      expect(testGoal.remainingValue, 50);

      final completedGoal = testGoal.copyWith(currentValue: 100);
      expect(completedGoal.remainingValue, 0);

      final overGoal = testGoal.copyWith(currentValue: 150);
      expect(overGoal.remainingValue, 0);
    });

    test('isNearCompletion returns true when progress >= 80%', () {
      expect(testGoal.isNearCompletion, false);

      final nearGoal = testGoal.copyWith(currentValue: 80);
      expect(nearGoal.isNearCompletion, true);

      final completedGoal = testGoal.copyWith(currentValue: 100);
      expect(completedGoal.isNearCompletion, true);
    });

    test('updateProgress creates updated goal', () {
      final updatedGoal = testGoal.updateProgress(75, notes: 'Good progress');

      expect(updatedGoal.currentValue, 75);
      expect(updatedGoal.progressNotes, contains('Good progress'));
    });

    test('markAsCompleted sets status and completion date', () {
      final completedGoal = testGoal.markAsCompleted(
        completionNote: 'Finished!',
      );

      expect(completedGoal.status, GoalStatus.completed);
      expect(completedGoal.completedAt, isNotNull);
      expect(completedGoal.currentValue, testGoal.targetValue);
    });

    test('reactivate sets status back to active', () {
      final archivedGoal = testGoal.copyWith(status: GoalStatus.archived);
      final reactivatedGoal = archivedGoal.reactivate();

      expect(reactivatedGoal.status, GoalStatus.active);
    });

    test('archive sets status to archived', () {
      final archivedGoal = testGoal.archive();

      expect(archivedGoal.status, GoalStatus.archived);
    });

    test('toDatabase creates valid database map', () {
      final dbMap = testGoal.toDatabase();

      expect(dbMap['user_id'], 1);
      expect(dbMap['title'], 'Test Goal');
      expect(dbMap['description'], 'Test Description');
      expect(dbMap['target_value'], 100);
      expect(dbMap['current_value'], 50);
      expect(dbMap['status'], 'active');
    });

    test('fromDatabase creates valid GoalModel', () {
      final map = {
        'id': 1,
        'user_id': 1,
        'title': 'Test Goal',
        'description': 'Test Description',
        'category': 'mindfulness',
        'target_value': 100,
        'current_value': 50,
        'start_date': '2024-01-01',
        'estimated_duration': 'oneMonth',
        'status': 'active',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-15T00:00:00.000Z',
      };

      final goal = GoalModel.fromDatabase(map);

      expect(goal.id, 1);
      expect(goal.title, 'Test Goal');
      expect(goal.category, GoalCategory.mindfulness);
      expect(goal.targetValue, 100);
      expect(goal.currentValue, 50);
    });

    test('toJson serializes correctly', () {
      final json = testGoal.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Goal');
      expect(json['target_value'], 100);
      expect(json['current_value'], 50);
    });

    test('copyWith preserves all fields when not specified', () {
      final copy = testGoal.copyWith();

      expect(copy.id, testGoal.id);
      expect(copy.title, testGoal.title);
      expect(copy.description, testGoal.description);
      expect(copy.category, testGoal.category);
      expect(copy.targetValue, testGoal.targetValue);
      expect(copy.currentValue, testGoal.currentValue);
    });

    test('categoryDisplayName returns correct name', () {
      expect(testGoal.categoryDisplayName, isNotEmpty);

      final sleepGoal = testGoal.copyWith(category: GoalCategory.sleep);
      expect(sleepGoal.categoryDisplayName, isNotEmpty);
    });

    test('categoryColorHex returns valid hex color', () {
      final colorHex = testGoal.categoryColorHex;
      expect(colorHex, isNotEmpty);
      expect(colorHex.length, greaterThanOrEqualTo(6));
    });

    test('generateDefaultMilestones creates milestone list', () {
      final milestones = testGoal.generateDefaultMilestones();

      expect(milestones, isNotEmpty);
      expect(milestones.length, greaterThan(0));
    });

    test('compareByProgress sorts goals correctly', () {
      final goal1 = testGoal.copyWith(currentValue: 30);
      final goal2 = testGoal.copyWith(currentValue: 70);

      final result = GoalModel.compareByProgress(goal1, goal2);
      expect(result, lessThan(0)); // goal1 has less progress
    });

    test('compareByCreatedAt sorts goals correctly', () {
      final goal1 = testGoal.copyWith(createdAt: DateTime(2024, 1, 1));
      final goal2 = testGoal.copyWith(createdAt: DateTime(2024, 2, 1));

      final result = GoalModel.compareByCreatedAt(goal1, goal2);
      expect(result, lessThan(0)); // goal1 was created earlier
    });

    test('addProgressNote adds timestamped note', () {
      final goalWithNote = testGoal.addProgressNote('New progress note');

      expect(goalWithNote.progressNotes, contains('New progress note'));
    });

    test('updateMetrics updates metrics map', () {
      final goalWithMetrics = testGoal.updateMetrics({
        'streak': 5,
        'bestDay': 'Monday',
      });

      expect(goalWithMetrics.metrics, isNotNull);
      expect(goalWithMetrics.metrics!['streak'], 5);
      expect(goalWithMetrics.metrics!['bestDay'], 'Monday');
    });
  });

  // ============================================================================
  // TAG MODEL TESTS
  // ============================================================================
  group('TagModel', () {
    test('fromJson creates valid TagModel', () {
      final json = {
        'id': 1,
        'name': 'happy',
        'isPositive': true,
        'count': 5,
        'color': '#4CAF50',
      };

      final tag = TagModel.fromJson(json);

      expect(tag.id, 1);
      expect(tag.name, 'happy');
      expect(tag.isPositive, true);
      expect(tag.count, 5);
    });

    test('toJson serializes correctly', () {
      final tag = TagModel(
        id: 1,
        name: 'productive',
        isPositive: true,
        count: 10,
        color: '#2196F3',
      );

      final json = tag.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'productive');
      expect(json['isPositive'], true);
      expect(json['count'], 10);
    });

    test('copyWith creates modified copy', () {
      final tag = TagModel(
        id: 1,
        name: 'tired',
        isPositive: false,
        count: 3,
      );

      final modified = tag.copyWith(count: 5);

      expect(modified.count, 5);
      expect(modified.name, 'tired');
      expect(modified.isPositive, false);
    });
  });

  // ============================================================================
  // CHAT MESSAGE MODEL TESTS
  // ============================================================================
  group('ChatMessage', () {
    test('user factory creates user message', () {
      final message = ChatMessage.user(content: 'Hello');

      expect(message.role, MessageRole.user);
      expect(message.content, 'Hello');
      expect(message.id, isNotEmpty);
      expect(message.timestamp, isNotNull);
    });

    test('assistant factory creates assistant message', () {
      final message = ChatMessage.assistant(content: 'Hi there!');

      expect(message.role, MessageRole.assistant);
      expect(message.content, 'Hi there!');
    });

    test('system factory creates system message', () {
      final message = ChatMessage.system(content: 'System info');

      expect(message.role, MessageRole.system);
      expect(message.content, 'System info');
    });

    test('error factory creates error message', () {
      final message = ChatMessage.error(content: 'Error occurred');

      expect(message.type, MessageType.error);
      expect(message.content, 'Error occurred');
    });

    test('thinking factory creates thinking message', () {
      final message = ChatMessage.thinking();

      expect(message.type, MessageType.thinking);
    });

    test('toMap serializes correctly', () {
      final message = ChatMessage.user(content: 'Test message');

      final map = message.toMap();

      expect(map['content'], 'Test message');
      expect(map['role'], 'user');
      expect(map['id'], isNotEmpty);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'test-id',
        'content': 'Test content',
        'role': 'user',
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'user',
        'status': 'sent',
      };

      final message = ChatMessage.fromMap(map);

      expect(message.id, 'test-id');
      expect(message.content, 'Test content');
      expect(message.role, MessageRole.user);
    });

    test('copyWith creates modified copy', () {
      final message = ChatMessage.user(content: 'Original');

      final modified = message.copyWith(content: 'Modified');

      expect(modified.content, 'Modified');
      expect(modified.role, MessageRole.user);
    });

    test('displayTime returns formatted time', () {
      final message = ChatMessage.user(content: 'Test');

      final displayTime = message.displayTime;

      expect(displayTime, isNotEmpty);
    });
  });

  // ============================================================================
  // CHAT CONVERSATION MODEL TESTS
  // ============================================================================
  group('ChatConversation', () {
    test('create factory creates valid conversation', () {
      final conversation = ChatConversation.create(
        userId: 1,
        title: 'Test Conversation',
      );

      expect(conversation.userId, 1);
      expect(conversation.title, 'Test Conversation');
      expect(conversation.messages, isEmpty);
      expect(conversation.id, isNotEmpty);
    });

    test('addMessage adds message to conversation', () {
      final conversation = ChatConversation.create(
        userId: 1,
        title: 'Test',
      );

      final message = ChatMessage.user(content: 'Hello');
      final updated = conversation.addMessage(message);

      expect(updated.messages.length, 1);
      expect(updated.messages.first.content, 'Hello');
    });

    test('removeMessage removes message by id', () {
      final message = ChatMessage.user(content: 'Test');
      final conversation = ChatConversation.create(
        userId: 1,
        title: 'Test',
      ).addMessage(message);

      final updated = conversation.removeMessage(message.id);

      expect(updated.messages, isEmpty);
    });

    test('updateMessage updates existing message', () {
      final message = ChatMessage.user(content: 'Original');
      final conversation = ChatConversation.create(
        userId: 1,
        title: 'Test',
      ).addMessage(message);

      final updatedMessage = message.copyWith(content: 'Updated');
      final updated = conversation.updateMessage(message.id, updatedMessage);

      expect(updated.messages.first.content, 'Updated');
    });

    test('lastMessage returns most recent message', () {
      final conversation = ChatConversation.create(userId: 1, title: 'Test')
          .addMessage(ChatMessage.user(content: 'First'))
          .addMessage(ChatMessage.assistant(content: 'Second'));

      expect(conversation.lastMessage?.content, 'Second');
    });

    test('messageCount returns correct count', () {
      final conversation = ChatConversation.create(userId: 1, title: 'Test')
          .addMessage(ChatMessage.user(content: 'First'))
          .addMessage(ChatMessage.assistant(content: 'Second'));

      expect(conversation.messageCount, 2);
    });

    test('hasMessages returns correct boolean', () {
      final emptyConversation = ChatConversation.create(
        userId: 1,
        title: 'Test',
      );
      expect(emptyConversation.hasMessages, false);

      final withMessages = emptyConversation.addMessage(
        ChatMessage.user(content: 'Hello'),
      );
      expect(withMessages.hasMessages, true);
    });

    test('userMessages returns only user messages', () {
      final conversation = ChatConversation.create(userId: 1, title: 'Test')
          .addMessage(ChatMessage.user(content: 'User msg'))
          .addMessage(ChatMessage.assistant(content: 'Assistant msg'))
          .addMessage(ChatMessage.user(content: 'Another user msg'));

      expect(conversation.userMessages.length, 2);
    });

    test('assistantMessages returns only assistant messages', () {
      final conversation = ChatConversation.create(userId: 1, title: 'Test')
          .addMessage(ChatMessage.user(content: 'User msg'))
          .addMessage(ChatMessage.assistant(content: 'Assistant msg'));

      expect(conversation.assistantMessages.length, 1);
    });

    test('toMap serializes correctly', () {
      final conversation = ChatConversation.create(userId: 1, title: 'Test')
          .addMessage(ChatMessage.user(content: 'Hello'));

      final map = conversation.toMap();

      expect(map['userId'], 1);
      expect(map['title'], 'Test');
      expect(map['messages'], isList);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'conv-id',
        'userId': 1,
        'title': 'Test Conversation',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'messages': [],
      };

      final conversation = ChatConversation.fromMap(map);

      expect(conversation.id, 'conv-id');
      expect(conversation.userId, 1);
      expect(conversation.title, 'Test Conversation');
    });
  });

  // ============================================================================
  // DAILY ACTIVITY MODEL TESTS
  // ============================================================================
  group('DailyActivity', () {
    test('fromJson creates valid DailyActivity', () {
      final json = {
        'id': '1',
        'title': 'Morning Meditation',
        'emoji': '🧘',
        'category': 'mindfulness',
        'duration': 15,
        'isCompleted': false,
        'completedAt': null,
      };

      final activity = DailyActivity.fromJson(json);

      expect(activity.id, '1');
      expect(activity.title, 'Morning Meditation');
      expect(activity.emoji, '🧘');
      expect(activity.category, 'mindfulness');
      expect(activity.duration, 15);
      expect(activity.isCompleted, false);
    });

    test('toJson serializes correctly', () {
      final activity = DailyActivity(
        id: '1',
        title: 'Exercise',
        emoji: '🏃',
        category: 'physical',
        duration: 30,
        isCompleted: true,
        completedAt: DateTime(2024, 1, 1, 10, 0),
      );

      final json = activity.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Exercise');
      expect(json['emoji'], '🏃');
      expect(json['duration'], 30);
      expect(json['isCompleted'], true);
    });

    test('durationText returns formatted duration', () {
      final shortActivity = DailyActivity(
        id: '1',
        title: 'Quick Break',
        emoji: '☕',
        category: 'selfCare',
        duration: 5,
        isCompleted: false,
      );
      expect(shortActivity.durationText, contains('5'));

      final longActivity = DailyActivity(
        id: '2',
        title: 'Long Session',
        emoji: '📚',
        category: 'learning',
        duration: 90,
        isCompleted: false,
      );
      expect(longActivity.durationText, isNotEmpty);
    });

    test('copyWith creates modified copy', () {
      final activity = DailyActivity(
        id: '1',
        title: 'Test',
        emoji: '📝',
        category: 'productivity',
        duration: 20,
        isCompleted: false,
      );

      final completed = activity.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
      expect(completed.title, 'Test');
    });

    test('getDefaultActivities returns non-empty list', () {
      final defaults = DailyActivity.getDefaultActivities();

      expect(defaults, isNotEmpty);
      expect(defaults.length, greaterThan(5));
    });

    test('fromDatabase creates valid activity', () {
      final map = {
        'id': '1',
        'title': 'Test Activity',
        'emoji': '✅',
        'category': 'productivity',
        'duration': 25,
        'is_completed': 1,
        'completed_at': '2024-01-01T10:00:00.000Z',
      };

      final activity = DailyActivity.fromDatabase(map);

      expect(activity.id, '1');
      expect(activity.isCompleted, true);
    });

    test('toDatabase converts to database format', () {
      final activity = DailyActivity(
        id: '1',
        title: 'Test',
        emoji: '📝',
        category: 'productivity',
        duration: 20,
        isCompleted: true,
        completedAt: DateTime(2024, 1, 1),
      );

      final dbMap = activity.toDatabase();

      expect(dbMap['id'], '1');
      expect(dbMap['is_completed'], 1);
    });
  });

  // ============================================================================
  // DAILY ROADMAP MODEL TESTS
  // ============================================================================
  group('DailyRoadmapModel', () {
    test('create factory creates valid roadmap', () {
      final roadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime(2024, 1, 1),
        activities: [],
      );

      expect(roadmap.userId, 1);
      expect(roadmap.activities, isEmpty);
      expect(roadmap.id, isNotEmpty);
    });

    test('isToday returns correct value', () {
      final todayRoadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now(),
        activities: [],
      );
      expect(todayRoadmap.isToday, true);

      final yesterdayRoadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now().subtract(const Duration(days: 1)),
        activities: [],
      );
      expect(yesterdayRoadmap.isToday, false);
    });

    test('isFuture returns correct value', () {
      final futureRoadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now().add(const Duration(days: 1)),
        activities: [],
      );
      expect(futureRoadmap.isFuture, true);

      final todayRoadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now(),
        activities: [],
      );
      expect(todayRoadmap.isFuture, false);
    });

    test('isPast returns correct value', () {
      final pastRoadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now().subtract(const Duration(days: 1)),
        activities: [],
      );
      expect(pastRoadmap.isPast, true);
    });

    test('addActivity adds activity to roadmap', () {
      final roadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now(),
        activities: [],
      );

      final activity = RoadmapActivityModel.create(
        title: 'Test Activity',
        startTime: DateTime.now(),
        duration: 30,
      );

      final updated = roadmap.addActivity(activity);

      expect(updated.activities.length, 1);
      expect(updated.activities.first.title, 'Test Activity');
    });

    test('removeActivity removes activity by id', () {
      final activity = RoadmapActivityModel.create(
        title: 'Test',
        startTime: DateTime.now(),
        duration: 30,
      );

      final roadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now(),
        activities: [activity],
      );

      final updated = roadmap.removeActivity(activity.id);

      expect(updated.activities, isEmpty);
    });

    test('toJson serializes correctly', () {
      final roadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime(2024, 1, 1),
        activities: [],
      );

      final json = roadmap.toJson();

      expect(json['user_id'], 1);
      expect(json['activities'], isList);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'roadmap-id',
        'user_id': 1,
        'date': '2024-01-01',
        'activities': [],
        'completion_percentage': 0.0,
        'total_activities': 0,
        'completed_activities': 0,
        'notes': null,
        'mood_trend': null,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final roadmap = DailyRoadmapModel.fromJson(json);

      expect(roadmap.id, 'roadmap-id');
      expect(roadmap.userId, 1);
    });

    test('copyWith creates modified copy', () {
      final roadmap = DailyRoadmapModel.create(
        userId: 1,
        date: DateTime.now(),
        activities: [],
      );

      final modified = roadmap.copyWith(notes: 'Test notes');

      expect(modified.notes, 'Test notes');
      expect(modified.userId, 1);
    });
  });

  // ============================================================================
  // ROADMAP ACTIVITY MODEL TESTS
  // ============================================================================
  group('RoadmapActivityModel', () {
    test('create factory creates valid activity', () {
      final activity = RoadmapActivityModel.create(
        title: 'Morning Routine',
        startTime: DateTime(2024, 1, 1, 8, 0),
        duration: 30,
        category: ActivityCategory.selfCare,
        priority: ActivityPriority.high,
      );

      expect(activity.title, 'Morning Routine');
      expect(activity.duration, 30);
      expect(activity.category, ActivityCategory.selfCare);
      expect(activity.priority, ActivityPriority.high);
      expect(activity.id, isNotEmpty);
    });

    test('timeString returns formatted time', () {
      final activity = RoadmapActivityModel.create(
        title: 'Test',
        startTime: DateTime(2024, 1, 1, 14, 30),
        duration: 60,
      );

      final timeString = activity.timeString;
      expect(timeString, isNotEmpty);
    });

    test('toJson serializes correctly', () {
      final activity = RoadmapActivityModel.create(
        title: 'Test Activity',
        startTime: DateTime(2024, 1, 1, 9, 0),
        duration: 45,
      );

      final json = activity.toJson();

      expect(json['title'], 'Test Activity');
      expect(json['duration'], 45);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'activity-id',
        'title': 'Test Activity',
        'description': 'Test description',
        'start_time': '2024-01-01T09:00:00.000Z',
        'duration': 45,
        'category': 'productivity',
        'priority': 'medium',
        'status': 'planned',
        'is_completed': false,
      };

      final activity = RoadmapActivityModel.fromJson(json);

      expect(activity.id, 'activity-id');
      expect(activity.title, 'Test Activity');
      expect(activity.duration, 45);
    });

    test('copyWith creates modified copy', () {
      final activity = RoadmapActivityModel.create(
        title: 'Original',
        startTime: DateTime.now(),
        duration: 30,
      );

      final modified = activity.copyWith(
        title: 'Modified',
        duration: 60,
      );

      expect(modified.title, 'Modified');
      expect(modified.duration, 60);
    });
  });

  // ============================================================================
  // RECOMMENDED ACTIVITY MODEL TESTS
  // ============================================================================
  group('RecommendedActivity', () {
    test('fromJson creates valid activity', () {
      final json = {
        'id': '1',
        'title': 'Morning Yoga',
        'description': 'Start your day with yoga',
        'category': 'physical',
        'durationMinutes': 20,
        'difficulty': 'moderate',
        'benefits': ['flexibility', 'relaxation'],
        'bestTimeOfDay': 'morning',
        'targetMood': ['calm', 'energized'],
        'requiredEnergy': 3,
      };

      final activity = RecommendedActivity.fromJson(json);

      expect(activity.id, '1');
      expect(activity.title, 'Morning Yoga');
      expect(activity.durationMinutes, 20);
      expect(activity.difficulty, 'moderate');
      expect(activity.benefits, contains('flexibility'));
    });

    test('toJson serializes correctly', () {
      final activity = RecommendedActivity(
        id: '1',
        title: 'Reading',
        description: 'Read a book',
        category: 'learning',
        durationMinutes: 30,
        difficulty: 'easy',
        benefits: ['knowledge', 'relaxation'],
        bestTimeOfDay: 'evening',
        targetMood: ['calm'],
        requiredEnergy: 2,
      );

      final json = activity.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Reading');
      expect(json['durationMinutes'], 30);
    });

    test('formattedDuration returns formatted string', () {
      final shortActivity = RecommendedActivity(
        id: '1',
        title: 'Quick Break',
        description: 'Take a break',
        category: 'selfCare',
        durationMinutes: 5,
        difficulty: 'easy',
        benefits: ['rest'],
        bestTimeOfDay: 'any',
        targetMood: ['relaxed'],
        requiredEnergy: 1,
      );

      expect(shortActivity.formattedDuration, contains('5'));
    });

    test('difficultyText returns localized text', () {
      final activity = RecommendedActivity(
        id: '1',
        title: 'Test',
        description: 'Test',
        category: 'test',
        durationMinutes: 10,
        difficulty: 'hard',
        benefits: [],
        bestTimeOfDay: 'any',
        targetMood: [],
        requiredEnergy: 5,
      );

      expect(activity.difficultyText, isNotEmpty);
    });

    test('copyWith creates modified copy', () {
      final activity = RecommendedActivity(
        id: '1',
        title: 'Original',
        description: 'Test',
        category: 'test',
        durationMinutes: 10,
        difficulty: 'easy',
        benefits: [],
        bestTimeOfDay: 'any',
        targetMood: [],
        requiredEnergy: 1,
      );

      final modified = activity.copyWith(title: 'Modified');

      expect(modified.title, 'Modified');
      expect(modified.id, '1');
    });
  });

  // ============================================================================
  // INTERACTIVE MOMENT MODEL TESTS
  // ============================================================================
  group('InteractiveMomentModel', () {
    test('create factory creates valid moment', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'thought',
        content: 'Test thought',
        intensity: 7,
      );

      expect(moment.userId, 1);
      expect(moment.type, 'thought');
      expect(moment.content, 'Test thought');
      expect(moment.intensity, 7);
      expect(moment.id, isNotEmpty);
    });

    test('toJson serializes correctly', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Feeling happy',
        intensity: 8,
      );

      final json = moment.toJson();

      expect(json['user_id'], 1);
      expect(json['type'], 'emotion');
      expect(json['content'], 'Feeling happy');
      expect(json['intensity'], 8);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'moment-id',
        'user_id': 1,
        'type': 'thought',
        'content': 'Test content',
        'intensity': 6,
        'timestamp': '2024-01-01T10:00:00.000Z',
        'tags': ['happy', 'peaceful'],
        'color_hex': '#4CAF50',
        'image_paths': [],
      };

      final moment = InteractiveMomentModel.fromJson(json);

      expect(moment.id, 'moment-id');
      expect(moment.type, 'thought');
      expect(moment.intensity, 6);
      expect(moment.tags, contains('happy'));
    });

    test('getTimeInfo returns formatted time with emoji', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'thought',
        content: 'Test',
        intensity: 5,
      );

      final timeInfo = moment.getTimeInfo();
      expect(timeInfo, isNotEmpty);
    });

    test('getIntensityDescription returns description', () {
      final lowMoment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test',
        intensity: 2,
      );
      expect(lowMoment.getIntensityDescription(), isNotEmpty);

      final highMoment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test',
        intensity: 9,
      );
      expect(highMoment.getIntensityDescription(), isNotEmpty);
    });

    test('getColorHex returns valid hex color', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test',
        intensity: 7,
      );

      final colorHex = moment.getColorHex();
      expect(colorHex, isNotEmpty);
    });

    test('toTag converts moment to TagModel', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Feeling grateful',
        intensity: 8,
      );

      final tag = moment.toTag();
      expect(tag, isNotNull);
      expect(tag.name, isNotEmpty);
    });

    test('isSameDay checks date correctly', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'thought',
        content: 'Test',
        intensity: 5,
      );

      expect(moment.isSameDay(DateTime.now()), true);
      expect(
        moment.isSameDay(DateTime.now().subtract(const Duration(days: 1))),
        false,
      );
    });

    test('groupByHour groups moments correctly', () {
      final moment1 = InteractiveMomentModel.create(
        userId: 1,
        type: 'thought',
        content: 'Morning thought',
        intensity: 5,
      );

      final moments = [moment1];
      final grouped = InteractiveMomentModel.groupByHour(moments);

      expect(grouped, isNotEmpty);
    });

    test('calculateAverageIntensity calculates correctly', () {
      final moment1 = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test 1',
        intensity: 6,
      );

      final moment2 = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test 2',
        intensity: 8,
      );

      final average = InteractiveMomentModel.calculateAverageIntensity(
        [moment1, moment2],
      );

      expect(average, 7.0);
    });

    test('getMostIntense returns moment with highest intensity', () {
      final moment1 = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Low',
        intensity: 3,
      );

      final moment2 = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'High',
        intensity: 9,
      );

      final mostIntense = InteractiveMomentModel.getMostIntense(
        [moment1, moment2],
      );

      expect(mostIntense?.intensity, 9);
    });

    test('copyWith creates modified copy', () {
      final moment = InteractiveMomentModel.create(
        userId: 1,
        type: 'thought',
        content: 'Original',
        intensity: 5,
      );

      final modified = moment.copyWith(content: 'Modified', intensity: 8);

      expect(modified.content, 'Modified');
      expect(modified.intensity, 8);
      expect(modified.type, 'thought');
    });

    test('compareTo sorts by timestamp', () {
      final earlier = InteractiveMomentModel.create(
        userId: 1,
        type: 'thought',
        content: 'Earlier',
        intensity: 5,
      );

      // Create a moment with slightly later timestamp
      final later = InteractiveMomentModel(
        id: 'later-id',
        userId: 1,
        type: 'thought',
        content: 'Later',
        intensity: 5,
        timestamp: earlier.timestamp.add(const Duration(hours: 1)),
        tags: [],
      );

      final result = earlier.compareTo(later);
      expect(result, lessThan(0));
    });
  });

  // ============================================================================
  // ANALYTICS CONFIG MODEL TESTS
  // ============================================================================
  group('AnalyticsConfig', () {
    test('getDefault returns valid configuration', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      expect(config.userId, 1);
      expect(config.wellnessScore, isNotNull);
      expect(config.correlation, isNotNull);
      expect(config.temporal, isNotNull);
      expect(config.habits, isNotEmpty);
    });

    test('toJson serializes correctly', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      final json = config.toJson();

      expect(json['user_id'], 1);
      expect(json['wellness_score'], isNotNull);
      expect(json['correlation'], isNotNull);
    });

    test('fromJson deserializes correctly', () {
      final config = AnalyticsConfig.getDefault(userId: 1);
      final json = config.toJson();

      final restored = AnalyticsConfig.fromJson(json);

      expect(restored.userId, 1);
    });

    test('getHabitConfig returns config for habit', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      final habitConfig = config.getHabitConfig('water');

      expect(habitConfig, isNotNull);
    });

    test('getHabitTarget returns target value', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      final target = config.getHabitTarget('sleep', level: 'recommended');

      expect(target, isNotNull);
      expect(target, greaterThan(0));
    });

    test('getWellnessLevel returns level string', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      expect(config.getWellnessLevel(90), isNotEmpty);
      expect(config.getWellnessLevel(70), isNotEmpty);
      expect(config.getWellnessLevel(50), isNotEmpty);
      expect(config.getWellnessLevel(30), isNotEmpty);
    });

    test('getCorrelationStrength returns strength string', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      expect(config.getCorrelationStrength(0.9), isNotEmpty);
      expect(config.getCorrelationStrength(0.5), isNotEmpty);
      expect(config.getCorrelationStrength(0.1), isNotEmpty);
    });

    test('copyWith creates modified copy', () {
      final config = AnalyticsConfig.getDefault(userId: 1);

      final modified = config.copyWith(userId: 2);

      expect(modified.userId, 2);
    });
  });

  // ============================================================================
  // WELLNESS SCORE CONFIG TESTS
  // ============================================================================
  group('WellnessScoreConfig', () {
    test('getDefault returns valid config', () {
      final config = WellnessScoreConfig.getDefault();

      expect(config.moodWeight, greaterThan(0));
      expect(config.sleepWeight, greaterThan(0));
      expect(config.exerciseWeight, greaterThan(0));
    });

    test('toJson serializes correctly', () {
      final config = WellnessScoreConfig.getDefault();
      final json = config.toJson();

      expect(json['moodWeight'], isNotNull);
      expect(json['sleepWeight'], isNotNull);
    });

    test('fromJson deserializes correctly', () {
      final config = WellnessScoreConfig.getDefault();
      final json = config.toJson();

      final restored = WellnessScoreConfig.fromJson(json);

      expect(restored.moodWeight, config.moodWeight);
    });
  });

  // ============================================================================
  // CORRELATION CONFIG TESTS
  // ============================================================================
  group('CorrelationConfig', () {
    test('getDefault returns valid config', () {
      final config = CorrelationConfig.getDefault();

      expect(config.strongThreshold, greaterThan(0));
      expect(config.moderateThreshold, greaterThan(0));
      expect(config.minimumDataPoints, greaterThan(0));
    });

    test('toJson and fromJson work correctly', () {
      final config = CorrelationConfig.getDefault();
      final json = config.toJson();
      final restored = CorrelationConfig.fromJson(json);

      expect(restored.strongThreshold, config.strongThreshold);
      expect(restored.moderateThreshold, config.moderateThreshold);
    });
  });

  // ============================================================================
  // TEMPORAL CONFIG TESTS
  // ============================================================================
  group('TemporalConfig', () {
    test('getDefault returns valid config', () {
      final config = TemporalConfig.getDefault();

      expect(config.morningStart, isNotNull);
      expect(config.eveningStart, isNotNull);
      expect(config.weekendDays, isNotEmpty);
    });

    test('toJson and fromJson work correctly', () {
      final config = TemporalConfig.getDefault();
      final json = config.toJson();
      final restored = TemporalConfig.fromJson(json);

      expect(restored.morningStart, config.morningStart);
    });
  });

  // ============================================================================
  // HABIT CONFIG TESTS
  // ============================================================================
  group('HabitConfig', () {
    test('getHabitTarget returns correct target', () {
      final config = HabitConfig(
        name: 'water',
        unit: 'glasses',
        minTarget: 4.0,
        recommendedTarget: 8.0,
        maxTarget: 12.0,
      );

      expect(config.getHabitTarget('min'), 4.0);
      expect(config.getHabitTarget('recommended'), 8.0);
      expect(config.getHabitTarget('max'), 12.0);
    });

    test('toJson and fromJson work correctly', () {
      final config = HabitConfig(
        name: 'sleep',
        unit: 'hours',
        minTarget: 6.0,
        recommendedTarget: 8.0,
        maxTarget: 10.0,
      );

      final json = config.toJson();
      final restored = HabitConfig.fromJson(json);

      expect(restored.name, config.name);
      expect(restored.recommendedTarget, config.recommendedTarget);
    });
  });

  // ============================================================================
  // ANALYTICS CONFIG PRESET TESTS
  // ============================================================================
  group('AnalyticsConfigPreset', () {
    test('getDefaultPresets returns non-empty list', () {
      final presets = AnalyticsConfigPreset.getDefaultPresets();

      expect(presets, isNotEmpty);
    });

    test('toJson and fromJson work correctly', () {
      final presets = AnalyticsConfigPreset.getDefaultPresets();
      final preset = presets.first;

      final json = preset.toJson();
      final restored = AnalyticsConfigPreset.fromJson(json);

      expect(restored.id, preset.id);
      expect(restored.name, preset.name);
    });
  });

  // ============================================================================
  // ENUM TESTS
  // ============================================================================
  group('GoalStatus enum', () {
    test('has correct values', () {
      expect(GoalStatus.values, contains(GoalStatus.active));
      expect(GoalStatus.values, contains(GoalStatus.completed));
      expect(GoalStatus.values, contains(GoalStatus.archived));
    });
  });

  group('GoalCategory enum', () {
    test('has all expected categories', () {
      expect(GoalCategory.values, contains(GoalCategory.mindfulness));
      expect(GoalCategory.values, contains(GoalCategory.stress));
      expect(GoalCategory.values, contains(GoalCategory.sleep));
      expect(GoalCategory.values, contains(GoalCategory.social));
      expect(GoalCategory.values, contains(GoalCategory.physical));
      expect(GoalCategory.values, contains(GoalCategory.emotional));
      expect(GoalCategory.values, contains(GoalCategory.productivity));
      expect(GoalCategory.values, contains(GoalCategory.habits));
    });
  });

  group('MessageRole enum', () {
    test('has correct values', () {
      expect(MessageRole.values, contains(MessageRole.user));
      expect(MessageRole.values, contains(MessageRole.assistant));
      expect(MessageRole.values, contains(MessageRole.system));
    });
  });

  group('MessageType enum', () {
    test('has correct values', () {
      expect(MessageType.values, contains(MessageType.user));
      expect(MessageType.values, contains(MessageType.assistant));
      expect(MessageType.values, contains(MessageType.system));
      expect(MessageType.values, contains(MessageType.error));
      expect(MessageType.values, contains(MessageType.thinking));
    });
  });

  group('ActivityPriority enum', () {
    test('has correct values', () {
      expect(ActivityPriority.values, contains(ActivityPriority.low));
      expect(ActivityPriority.values, contains(ActivityPriority.medium));
      expect(ActivityPriority.values, contains(ActivityPriority.high));
      expect(ActivityPriority.values, contains(ActivityPriority.urgent));
    });
  });

  // ============================================================================
  // EDGE CASE TESTS
  // ============================================================================
  group('Edge Cases', () {
    test('UserModel handles empty strings', () {
      final user = UserModel(
        id: 1,
        name: '',
        email: '',
        createdAt: DateTime.now(),
      );

      expect(user.name, '');
      expect(user.email, '');
    });

    test('GoalModel handles zero target value', () {
      final goal = GoalModel(
        id: 1,
        userId: 1,
        title: 'Test',
        description: 'Test',
        category: GoalCategory.mindfulness,
        targetValue: 0,
        currentValue: 0,
        startDate: DateTime.now(),
        estimatedDuration: GoalDuration.oneWeek,
        status: GoalStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Should not throw when calculating progress
      expect(() => goal.progress, returnsNormally);
    });

    test('DailyEntryModel handles empty tags lists', () {
      final entry = DailyEntryModel.create(
        userId: 1,
        freeReflection: 'Test',
        positiveTags: [],
        negativeTags: [],
      );

      expect(entry.positiveTags, isEmpty);
      expect(entry.negativeTags, isEmpty);
    });

    test('ChatConversation handles empty messages', () {
      final conversation = ChatConversation.create(
        userId: 1,
        title: 'Empty',
      );

      expect(conversation.lastMessage, isNull);
      expect(conversation.messageCount, 0);
    });

    test('InteractiveMomentModel handles extreme intensity values', () {
      final lowMoment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test',
        intensity: 0,
      );
      expect(lowMoment.intensity, 0);

      final highMoment = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test',
        intensity: 10,
      );
      expect(highMoment.intensity, 10);
    });

    test('DailyActivity handles null completedAt', () {
      final activity = DailyActivity(
        id: '1',
        title: 'Test',
        emoji: '📝',
        category: 'test',
        duration: 10,
        isCompleted: false,
        completedAt: null,
      );

      expect(activity.completedAt, isNull);
    });

    test('GoalModel handles null optional fields', () {
      final goal = GoalModel(
        id: 1,
        userId: 1,
        title: 'Test',
        description: 'Test',
        category: GoalCategory.mindfulness,
        targetValue: 100,
        currentValue: 0,
        startDate: DateTime.now(),
        estimatedDuration: GoalDuration.oneMonth,
        status: GoalStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: null,
        progressNotes: null,
        metrics: null,
        milestones: null,
      );

      expect(goal.completedAt, isNull);
      expect(goal.progressNotes, isNull);
      expect(goal.metrics, isNull);
      expect(goal.hasNotes, false);
    });
  });

  // ============================================================================
  // SERIALIZATION ROUNDTRIP TESTS
  // ============================================================================
  group('Serialization Roundtrips', () {
    test('UserModel survives JSON roundtrip', () {
      final original = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
        profileImagePath: '/path/to/image.jpg',
      );

      final json = original.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
    });

    test('DailyEntryModel survives JSON roundtrip', () {
      final original = DailyEntryModel.create(
        userId: 1,
        freeReflection: 'Test reflection',
        moodScore: 7,
        energyLevel: 8,
        stressLevel: 3,
        worthIt: true,
        positiveTags: ['happy', 'productive'],
        negativeTags: ['tired'],
      );

      final json = original.toJson();
      final restored = DailyEntryModel.fromJson(json);

      expect(restored.userId, original.userId);
      expect(restored.freeReflection, original.freeReflection);
      expect(restored.moodScore, original.moodScore);
      expect(restored.positiveTags, original.positiveTags);
    });

    test('GoalModel survives database roundtrip', () {
      final original = GoalModel(
        id: 1,
        userId: 1,
        title: 'Test Goal',
        description: 'Test Description',
        category: GoalCategory.mindfulness,
        targetValue: 100,
        currentValue: 50,
        startDate: DateTime(2024, 1, 1),
        estimatedDuration: GoalDuration.oneMonth,
        status: GoalStatus.active,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );

      final dbMap = original.toDatabase();
      dbMap['id'] = original.id; // Add id for fromDatabase
      final restored = GoalModel.fromDatabase(dbMap);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.targetValue, original.targetValue);
      expect(restored.currentValue, original.currentValue);
    });

    test('ChatMessage survives map roundtrip', () {
      final original = ChatMessage.user(content: 'Test message');

      final map = original.toMap();
      final restored = ChatMessage.fromMap(map);

      expect(restored.content, original.content);
      expect(restored.role, original.role);
    });

    test('InteractiveMomentModel survives JSON roundtrip', () {
      final original = InteractiveMomentModel.create(
        userId: 1,
        type: 'emotion',
        content: 'Test content',
        intensity: 7,
      );

      final json = original.toJson();
      final restored = InteractiveMomentModel.fromJson(json);

      expect(restored.userId, original.userId);
      expect(restored.type, original.type);
      expect(restored.content, original.content);
      expect(restored.intensity, original.intensity);
    });
  });
}