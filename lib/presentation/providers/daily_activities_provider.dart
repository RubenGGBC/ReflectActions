// lib/presentation/providers/daily_activities_provider.dart
// ============================================================================
// DAILY ACTIVITIES PROVIDER FOR ACTIVITY COMPLETION TRACKING
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../data/models/daily_activity_model.dart';
import '../../data/services/optimized_database_service.dart';

class DailyActivitiesProvider extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;

  DailyActivitiesProvider(this._databaseService) {
    _loadDefaultActivities();
  }

  List<DailyActivity> _activities = [];
  List<DailyActivity> _completedActivities = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DailyActivity> get activities => _activities;
  List<DailyActivity> get completedActivities => _completedActivities;
  List<DailyActivity> get pendingActivities => _activities.where((activity) => !activity.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  int get totalActivities => _activities.length;
  int get completedCount => _completedActivities.length;
  int get pendingCount => pendingActivities.length;
  double get completionPercentage => totalActivities > 0 ? (completedCount / totalActivities) * 100 : 0.0;

  void _loadDefaultActivities() {
    _isLoading = true;
    notifyListeners();

    try {
      _activities = DailyActivity.getDefaultActivities();
      _updateCompletedActivities();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga el estado de completado persistido para el usuario en el día actual.
  Future<void> loadForUser(int userId, {DateTime? date}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final today = date ?? DateTime.now();
      final completions = await _databaseService.getActivityCompletions(
        userId: userId,
        source: 'daily',
        completionDate: today,
      );

      // Reset to defaults, then apply persisted completion state.
      _activities = DailyActivity.getDefaultActivities();
      for (final row in completions) {
        final activityId = row['activity_id'] as String;
        final index = _activities.indexWhere((a) => a.id == activityId);
        if (index != -1) {
          final completedAtStr = row['completed_at'] as String?;
          final ratingValue = row['rating'];
          _activities[index] = _activities[index].copyWith(
            isCompleted: true,
            completedAt: completedAtStr != null
                ? DateTime.tryParse(completedAtStr)
                : today,
            completionNotes: row['notes'] as String?,
            rating: ratingValue != null ? (ratingValue as num).round() : null,
          );
        }
      }
      _updateCompletedActivities();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateCompletedActivities() {
    _completedActivities = _activities.where((activity) => activity.isCompleted).toList();
  }

  Future<void> completeActivity(String activityId, {String? notes, int? rating}) async {
    try {
      final activityIndex = _activities.indexWhere((activity) => activity.id == activityId);
      if (activityIndex != -1) {
        final activity = _activities[activityIndex];
        final completedActivity = activity.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
          completionNotes: notes,
          rating: rating,
        );
        
        _activities[activityIndex] = completedActivity;
        _updateCompletedActivities();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> undoActivityCompletion(String activityId) async {
    try {
      final activityIndex = _activities.indexWhere((activity) => activity.id == activityId);
      if (activityIndex != -1) {
        final activity = _activities[activityIndex];
        final pendingActivity = activity.copyWith(
          isCompleted: false,
          completedAt: null,
          completionNotes: null,
          rating: null,
        );
        
        _activities[activityIndex] = pendingActivity;
        _updateCompletedActivities();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addCustomActivity(DailyActivity activity) async {
    try {
      _activities.add(activity);
      _updateCompletedActivities();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeActivity(String activityId) async {
    try {
      _activities.removeWhere((activity) => activity.id == activityId);
      _updateCompletedActivities();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateActivity(DailyActivity updatedActivity) async {
    try {
      final activityIndex = _activities.indexWhere((activity) => activity.id == updatedActivity.id);
      if (activityIndex != -1) {
        _activities[activityIndex] = updatedActivity;
        _updateCompletedActivities();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  DailyActivity? getActivityById(String activityId) {
    try {
      return _activities.firstWhere((activity) => activity.id == activityId);
    } catch (e) {
      return null;
    }
  }

  List<DailyActivity> getActivitiesByCategory(String category) {
    return _activities.where((activity) => activity.category == category).toList();
  }

  List<String> getCompletedActivityTitles() {
    return _completedActivities.map((activity) => activity.title).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset activities for a new day
  Future<void> resetDailyActivities() async {
    try {
      _activities = DailyActivity.getDefaultActivities();
      _updateCompletedActivities();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}