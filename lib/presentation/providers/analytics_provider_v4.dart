// ============================================================================
// presentation/providers/analytics_provider_v4.dart
// V4 ANALYTICS PROVIDER - ADVANCED MOTIVATIONAL ANALYTICS
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../data/services/optimized_database_service.dart';
import '../../data/services/analytics_database_extension_v4_simple.dart';

class AnalyticsProviderV4 extends ChangeNotifier {
  final OptimizedDatabaseService _databaseService;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingTrends = false;
  bool _isLoadingGoals = false;
  bool _isLoadingRoadmaps = false;
  bool _isLoadingMoments = false;
  
  String? _error;
  
  // Analytics data
  List<SimpleWellbeingTrend> _wellbeingTrends = [];
  SimpleGoalAnalytics? _goalAnalytics;
  SimpleQuickMomentsAnalytics? _momentsAnalytics;
  SimpleUserMotivationInsights? _motivationInsights;
  
  // Selected timeframe
  SimpleAnalyticsTimeframe _selectedTimeframe = SimpleAnalyticsTimeframe.last30Days();
  
  AnalyticsProviderV4(this._databaseService);
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingTrends => _isLoadingTrends;
  bool get isLoadingGoals => _isLoadingGoals;
  bool get isLoadingRoadmaps => _isLoadingRoadmaps;
  bool get isLoadingMoments => _isLoadingMoments;
  String? get error => _error;
  
  List<SimpleWellbeingTrend> get wellbeingTrends => _wellbeingTrends;
  SimpleGoalAnalytics? get goalAnalytics => _goalAnalytics;
  SimpleQuickMomentsAnalytics? get momentsAnalytics => _momentsAnalytics;
  SimpleUserMotivationInsights? get motivationInsights => _motivationInsights;
  SimpleAnalyticsTimeframe get selectedTimeframe => _selectedTimeframe;
  
  // Available timeframes
  List<SimpleAnalyticsTimeframe> get availableTimeframes => [
    SimpleAnalyticsTimeframe.last7Days(),
    SimpleAnalyticsTimeframe.last30Days(),
    SimpleAnalyticsTimeframe(
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      endDate: DateTime.now(),
      label: 'Last 3 Months',
    ),
  ];
  
  // ============================================================================
  // MAIN ANALYTICS LOADING METHOD
  // ============================================================================
  
  Future<void> loadAllAnalytics(int userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Load all analytics in parallel for better performance
      await Future.wait([
        _loadWellbeingTrends(userId),
        _loadGoalAnalytics(userId),
        _loadMomentsAnalytics(userId),
      ]);
      
      // Generate motivation insights after all data is loaded
      await _loadMotivationInsights(userId);
      
    } catch (e) {
      _setError('Failed to load analytics: $e');
      debugPrint('❌ Analytics loading error: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ============================================================================
  // INDIVIDUAL ANALYTICS LOADING METHODS
  // ============================================================================
  
  Future<void> _loadWellbeingTrends(int userId) async {
    _setLoadingTrends(true);
    try {
      _wellbeingTrends = await _databaseService.getSimpleWellbeingTrends(userId, _selectedTimeframe);
      debugPrint('✅ Loaded ${_wellbeingTrends.length} wellbeing trends');
    } catch (e) {
      debugPrint('❌ Error loading wellbeing trends: $e');
      _wellbeingTrends = [];
    } finally {
      _setLoadingTrends(false);
    }
  }
  
  Future<void> _loadGoalAnalytics(int userId) async {
    _setLoadingGoals(true);
    try {
      _goalAnalytics = await _databaseService.getSimpleGoalAnalytics(userId, _selectedTimeframe);
      debugPrint('✅ Loaded goal analytics: ${_goalAnalytics?.totalGoals} total goals');
    } catch (e) {
      debugPrint('❌ Error loading goal analytics: $e');
      _goalAnalytics = null;
    } finally {
      _setLoadingGoals(false);
    }
  }
  
  Future<void> _loadMomentsAnalytics(int userId) async {
    _setLoadingMoments(true);
    try {
      _momentsAnalytics = await _databaseService.getSimpleQuickMomentsAnalytics(userId, _selectedTimeframe);
      debugPrint('✅ Loaded moments analytics: ${_momentsAnalytics?.totalMoments} total moments');
    } catch (e) {
      debugPrint('❌ Error loading moments analytics: $e');
      _momentsAnalytics = null;
    } finally {
      _setLoadingMoments(false);
    }
  }
  
  Future<void> _loadMotivationInsights(int userId) async {
    try {
      _motivationInsights = await _databaseService.generateSimpleMotivationInsights(userId, _selectedTimeframe);
      debugPrint('✅ Generated motivation insights with score: ${_motivationInsights?.motivationScore}');
    } catch (e) {
      debugPrint('❌ Error generating motivation insights: $e');
      _motivationInsights = null;
    }
  }
  
  // ============================================================================
  // TIMEFRAME MANAGEMENT
  // ============================================================================
  
  Future<void> changeTimeframe(SimpleAnalyticsTimeframe newTimeframe, int userId) async {
    if (_selectedTimeframe.label == newTimeframe.label) return;
    
    _selectedTimeframe = newTimeframe;
    notifyListeners();
    
    // Reload all analytics with new timeframe
    await loadAllAnalytics(userId);
  }
  
  // ============================================================================
  // REFRESH METHODS
  // ============================================================================
  
  Future<void> refreshAnalytics(int userId) async {
    await loadAllAnalytics(userId);
  }
  
  Future<void> refreshSpecificAnalytic(int userId, String analyticType) async {
    switch (analyticType) {
      case 'wellbeing':
        await _loadWellbeingTrends(userId);
        break;
      case 'goals':
        await _loadGoalAnalytics(userId);
        break;
      case 'roadmaps':
        break;
      case 'moments':
        await _loadMomentsAnalytics(userId);
        break;
      case 'motivation':
        await _loadMotivationInsights(userId);
        break;
    }
    notifyListeners();
  }
  
  // ============================================================================
  // ANALYTICS SUMMARY METHODS
  // ============================================================================
  
  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'hasData': hasAnyData,
      'wellbeingTrendsCount': _wellbeingTrends.length,
      'improvingTrendsCount': _wellbeingTrends.where((t) => t.trendDirection == 'improving').length,
      'totalGoals': _goalAnalytics?.totalGoals ?? 0,
      'completedGoals': _goalAnalytics?.completedGoals ?? 0,
      'goalCompletionRate': _goalAnalytics?.completionRate ?? 0.0,
      'roadmapStreak': 0,
      'totalMoments': _momentsAnalytics?.totalMoments ?? 0,
      'positivityRatio': _momentsAnalytics?.positivityRatio ?? 0.0,
      'motivationScore': _motivationInsights?.motivationScore ?? 0.0,
      'achievementsCount': _motivationInsights?.achievements.length ?? 0,
      'improvementsCount': _motivationInsights?.improvements.length ?? 0,
    };
  }
  
  bool get hasAnyData {
    return _wellbeingTrends.isNotEmpty ||
           _goalAnalytics != null ||
           _momentsAnalytics != null;
  }
  
  // Get the top performing metric
  String get topPerformingMetric {
    if (_wellbeingTrends.isEmpty) return 'No data available';
    
    final improvingTrends = _wellbeingTrends
        .where((t) => t.trendDirection == 'improving')
        .toList()
      ..sort((a, b) => b.improvementPercentage.compareTo(a.improvementPercentage));
    
    if (improvingTrends.isNotEmpty) {
      return improvingTrends.first.metric;
    }
    
    // If no improving trends, return the metric with highest average
    final sortedByAverage = _wellbeingTrends.toList()
      ..sort((a, b) => b.averageValue.compareTo(a.averageValue));
    
    return sortedByAverage.first.metric;
  }
  
  // Get areas that need attention
  List<String> get areasNeedingAttention {
    final areas = <String>[];
    
    // Check declining trends
    for (final trend in _wellbeingTrends) {
      if (trend.trendDirection == 'declining') {
        areas.add(trend.metric);
      }
    }
    
    // Check low goal completion rate
    if ((_goalAnalytics?.completionRate ?? 0) < 50) {
      areas.add('Goal Achievement');
    }
    
    // Skip roadmap check since we don't have roadmap analytics
    
    // Check low positivity ratio
    if ((_momentsAnalytics?.positivityRatio ?? 0) < 50) {
      areas.add('Emotional Wellbeing');
    }
    
    return areas;
  }
  
  // ============================================================================
  // CELEBRATION HELPERS
  // ============================================================================
  
  List<String> get celebrationMessages {
    final messages = <String>[];
    
    // Add achievements
    if (_motivationInsights != null) {
      messages.addAll(_motivationInsights!.achievements);
    }
    
    // Add improvement celebrations
    for (final trend in _wellbeingTrends) {
      if (trend.trendDirection == 'improving' && trend.improvementPercentage > 20) {
        messages.add('🎉 Amazing ${trend.metric} improvement: +${trend.improvementPercentage.toStringAsFixed(0)}%!');
      }
    }
    
    return messages;
  }
  
  bool get hasRecentAchievements {
    return (_motivationInsights?.achievements.isNotEmpty ?? false) ||
           _wellbeingTrends.any((t) => t.trendDirection == 'improving');
  }
  
  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _setLoadingTrends(bool loading) {
    if (_isLoadingTrends != loading) {
      _isLoadingTrends = loading;
      notifyListeners();
    }
  }
  
  void _setLoadingGoals(bool loading) {
    if (_isLoadingGoals != loading) {
      _isLoadingGoals = loading;
      notifyListeners();
    }
  }
  
  void _setLoadingRoadmaps(bool loading) {
    if (_isLoadingRoadmaps != loading) {
      _isLoadingRoadmaps = loading;
      notifyListeners();
    }
  }
  
  void _setLoadingMoments(bool loading) {
    if (_isLoadingMoments != loading) {
      _isLoadingMoments = loading;
      notifyListeners();
    }
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
  
  // ============================================================================
  // DISPOSAL
  // ============================================================================
  
  @override
  void dispose() {
    super.dispose();
  }
}