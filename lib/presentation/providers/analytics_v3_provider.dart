// ============================================================================
// presentation/providers/analytics_v3_provider.dart - ANALYTICS V3 PROVIDER
// NEW ANALYTICS PROVIDER - NO CONFLICTS WITH EXISTING PROVIDERS
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../data/models/analytics_v3_models.dart';
import '../../data/models/analytics_config_model.dart';
import '../../data/services/analytics_v3_extension.dart';
import '../../data/services/analytics_config_service.dart';
import '../../data/services/optimized_database_service.dart';

class AnalyticsV3Provider extends ChangeNotifier {
  final AnalyticsV3Extension _analyticsExtension;
  
  // Initialization state
  bool _isInitialized = false;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingWellness = false;
  bool _isLoadingCorrelations = false;
  bool _isLoadingSleep = false;
  bool _isLoadingStress = false;
  bool _isLoadingGoals = false;
  bool _isLoadingTemporal = false;
  
  // Error handling
  String? _error;
  
  // Data cache
  AnalyticsV3Model? _analyticsData;
  WellnessScoreModel? _wellnessScore;
  List<ActivityCorrelationModel> _activityCorrelations = [];
  SleepPatternModel? _sleepPattern;
  StressManagementModel? _stressManagement;
  GoalAnalyticsModel? _goalAnalytics;
  TemporalPatternModel? _temporalPatterns;
  
  // Filter states
  int _selectedPeriodDays = 30;
  String _selectedMetric = 'wellness'; // wellness, sleep, stress, goals, correlations, temporal
  
  // Chart data cache
  final Map<String, List<Map<String, dynamic>>> _chartDataCache = {};
  
  AnalyticsV3Provider(OptimizedDatabaseService databaseService) 
      : _analyticsExtension = AnalyticsV3Extension(databaseService);

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize the analytics provider and configuration system
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) print('🔄 Analytics V3: Already initialized');
      return;
    }
    
    try {
      if (kDebugMode) print('🚀 Analytics V3: Starting initialization');
      await _analyticsExtension.initialize();
      _isInitialized = true;
      if (kDebugMode) print('✅ Analytics V3: Initialization completed successfully');
    } catch (e) {
      _setError('Error initializing analytics: $e');
      if (kDebugMode) print('❌ Analytics V3 Initialization Error: $e');
      rethrow;
    }
  }

  /// Ensure provider is initialized before performing operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ============================================================================
  // GETTERS
  // ============================================================================
  
  bool get isLoading => _isLoading;
  bool get isLoadingWellness => _isLoadingWellness;
  bool get isLoadingCorrelations => _isLoadingCorrelations;
  bool get isLoadingSleep => _isLoadingSleep;
  bool get isLoadingStress => _isLoadingStress;
  bool get isLoadingGoals => _isLoadingGoals;
  bool get isLoadingTemporal => _isLoadingTemporal;
  
  String? get error => _error;
  
  AnalyticsV3Model? get analyticsData => _analyticsData;
  WellnessScoreModel? get wellnessScore => _wellnessScore;
  List<ActivityCorrelationModel> get activityCorrelations => _activityCorrelations;
  SleepPatternModel? get sleepPattern => _sleepPattern;
  StressManagementModel? get stressManagement => _stressManagement;
  GoalAnalyticsModel? get goalAnalytics => _goalAnalytics;
  TemporalPatternModel? get temporalPatterns => _temporalPatterns;
  
  int get selectedPeriodDays => _selectedPeriodDays;
  String get selectedMetric => _selectedMetric;
  
  bool get hasData {
    final result = _analyticsData != null;
    if (kDebugMode) print('🔍 Provider hasData: $result (analyticsData is ${_analyticsData != null ? "not null" : "null"})');
    return result;
  }
  
  // Chart data getters
  List<Map<String, dynamic>> get wellnessChartData => _getWellnessChartData();
  List<Map<String, dynamic>> get sleepChartData => _getSleepChartData();
  List<Map<String, dynamic>> get stressChartData => _getStressChartData();
  List<Map<String, dynamic>> get correlationChartData => _getCorrelationChartData();
  List<Map<String, dynamic>> get temporalChartData => _getTemporalChartData();

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================
  
  /// Load comprehensive analytics for the specified user and period
  Future<void> loadAnalytics(int userId, {int? periodDays}) async {
    if (kDebugMode) print('🔍 Analytics V3: Starting loadAnalytics for user $userId');
    
    await _ensureInitialized();
    if (kDebugMode) print('✅ Analytics V3: Initialization completed');
    
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoading(true);
    _clearError();
    
    try {
      if (kDebugMode) print('📊 Analytics V3: Generating comprehensive analytics for $period days');
      final analytics = await _analyticsExtension.generateComprehensiveAnalytics(userId, period);
      if (kDebugMode) print('✅ Analytics V3: Generated analytics successfully');
      
      _analyticsData = analytics;
      _wellnessScore = analytics.wellnessScore;
      _activityCorrelations = analytics.activityCorrelations;
      _sleepPattern = analytics.sleepPattern;
      _stressManagement = analytics.stressManagement;
      _goalAnalytics = analytics.goalAnalytics;
      _temporalPatterns = analytics.temporalPatterns;
      
      _selectedPeriodDays = period;
      _invalidateChartCache();
      
      if (kDebugMode) {
        print('📈 Analytics V3: Data loaded successfully');
        print('   - Wellness Score: ${_wellnessScore?.overallScore}');
        print('   - Activity Correlations: ${_activityCorrelations.length}');
        print('   - Sleep Pattern: ${_sleepPattern?.averageSleepHours}h');
        print('   - Stress Management: ${_stressManagement?.averageStressLevel}');
        print('   - Goal Analytics: ${_goalAnalytics?.completionRate}');
        print('   - Has Data: $hasData');
      }
      
    } catch (e, stackTrace) {
      // Enhanced error categorization and user-friendly messages
      String userMessage;
      String debugMessage = 'Analytics V3 Error: $e';
      
      if (e.toString().contains('database') || e.toString().contains('sql')) {
        userMessage = 'Error de base de datos. Inténtalo de nuevo en unos momentos.';
        debugMessage = 'Database Error in Analytics: $e';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        userMessage = 'Error de conexión. Verifica tu conexión a internet.';
        debugMessage = 'Network Error in Analytics: $e';
      } else if (e.toString().contains('configuration') || e.toString().contains('config')) {
        userMessage = 'Error de configuración. Algunas funciones pueden estar limitadas.';
        debugMessage = 'Configuration Error in Analytics: $e';
      } else if (e is ArgumentError) {
        userMessage = 'Parámetros inválidos. Inténtalo de nuevo.';
        debugMessage = 'Parameter Error in Analytics: $e';
      } else {
        userMessage = 'Error inesperado al cargar analytics. Inténtalo más tarde.';
        debugMessage = 'Unexpected Error in Analytics: $e';
      }
      
      _setError(userMessage);
      
      if (kDebugMode) {
        print('❌ $debugMessage');
        print('📍 Stack trace: $stackTrace');
        print('🔧 Error type: ${e.runtimeType}');
      }
      
      // Clear partial data on error to prevent inconsistent state
      _clearPartialData();
      
    } finally {
      _setLoading(false);
    }
  }

  /// Load only wellness score (faster for quick updates)
  Future<void> loadWellnessScore(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingWellness(true);
    _clearError();
    
    try {
      _wellnessScore = await _analyticsExtension.calculateWellnessScore(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar score de bienestar: $e');
    } finally {
      _setLoadingWellness(false);
    }
  }

  /// Load only activity correlations
  Future<void> loadActivityCorrelations(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingCorrelations(true);
    _clearError();
    
    try {
      _activityCorrelations = await _analyticsExtension.analyzeActivityCorrelations(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar correlaciones: $e');
    } finally {
      _setLoadingCorrelations(false);
    }
  }

  /// Load only sleep patterns
  Future<void> loadSleepPattern(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingSleep(true);
    _clearError();
    
    try {
      _sleepPattern = await _analyticsExtension.analyzeSleepPatterns(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar patrones de sueño: $e');
    } finally {
      _setLoadingSleep(false);
    }
  }

  /// Load only stress management data
  Future<void> loadStressManagement(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingStress(true);
    _clearError();
    
    try {
      _stressManagement = await _analyticsExtension.analyzeStressManagement(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar análisis de estrés: $e');
    } finally {
      _setLoadingStress(false);
    }
  }

  /// Load only goal analytics
  Future<void> loadGoalAnalytics(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingGoals(true);
    _clearError();
    
    try {
      _goalAnalytics = await _analyticsExtension.analyzeGoalPerformance(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar análisis de metas: $e');
    } finally {
      _setLoadingGoals(false);
    }
  }

  /// Load only temporal patterns
  Future<void> loadTemporalPatterns(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingTemporal(true);
    _clearError();
    
    try {
      _temporalPatterns = await _analyticsExtension.analyzeTemporalPatterns(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar patrones temporales: $e');
    } finally {
      _setLoadingTemporal(false);
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAnalytics(int userId) async {
    await loadAnalytics(userId, periodDays: _selectedPeriodDays);
  }

  /// Change the analysis period
  void setPeriodDays(int days) {
    if (_selectedPeriodDays != days) {
      _selectedPeriodDays = days;
      _invalidateChartCache();
      notifyListeners();
    }
  }

  /// Change the selected metric view
  void setSelectedMetric(String metric) {
    if (_selectedMetric != metric) {
      _selectedMetric = metric;
      notifyListeners();
    }
  }

  /// Clear all cached data
  void clearCache() {
    _analyticsData = null;
    _wellnessScore = null;
    _activityCorrelations.clear();
    _sleepPattern = null;
    _stressManagement = null;
    _goalAnalytics = null;
    _temporalPatterns = null;
    
    // Clear new analytics data
    _productivityPatterns = null;
    _moodStability = null;
    _lifestyleBalance = null;
    _energyPatterns = null;
    _socialWellness = null;
    _habitConsistency = null;
    
    _chartDataCache.clear();
    _clearError();
    
    // Clear configuration cache in extension
    _analyticsExtension.clearConfigCache();
    
    notifyListeners();
  }

  // ============================================================================
  // CHART DATA PREPARATION
  // ============================================================================
  
  List<Map<String, dynamic>> _getWellnessChartData() {
    final cacheKey = 'wellness_$_selectedPeriodDays';
    if (_chartDataCache.containsKey(cacheKey)) {
      return _chartDataCache[cacheKey]!;
    }

    if (_wellnessScore == null) return [];

    final data = <Map<String, dynamic>>[];
    
    // Component scores for radar chart - use actual values, not wellness scores
    _wellnessScore!.componentScores.forEach((component, score) {
      // For stress and anxiety, show the raw values (not inverted wellness scores)
      double displayValue = score;
      if (component == 'stress' || component == 'anxiety') {
        // Reverse the inversion: if score is inverted (11 - raw), get back raw value
        displayValue = 11.0 - score;
      }
      
      data.add({
        'category': _translateComponent(component),
        'value': displayValue,
        'color': _getComponentColor(component),
        'maxValue': 10.0,
      });
    });

    _chartDataCache[cacheKey] = data;
    return data;
  }

  List<Map<String, dynamic>> _getSleepChartData() {
    final cacheKey = 'sleep_$_selectedPeriodDays';
    if (_chartDataCache.containsKey(cacheKey)) {
      return _chartDataCache[cacheKey]!;
    }

    if (_sleepPattern == null) return [];

    final data = <Map<String, dynamic>>[];
    
    // Weekly sleep pattern
    _sleepPattern!.weeklyPattern.forEach((day, hours) {
      data.add({
        'day': day,
        'hours': hours,
        'quality': _sleepPattern!.averageSleepQuality,
        'optimal': _sleepPattern!.optimalSleepHours,
      });
    });

    _chartDataCache[cacheKey] = data;
    return data;
  }

  List<Map<String, dynamic>> _getStressChartData() {
    final cacheKey = 'stress_$_selectedPeriodDays';
    if (_chartDataCache.containsKey(cacheKey)) {
      return _chartDataCache[cacheKey]!;
    }

    if (_stressManagement == null) return [];

    final data = <Map<String, dynamic>>[];
    
    // Stress by day of week
    _stressManagement!.stressByDayOfWeek.forEach((day, stress) {
      data.add({
        'day': day,
        'stress': stress,
        'average': _stressManagement!.averageStressLevel,
        'isHigh': stress > 6.0,
      });
    });

    _chartDataCache[cacheKey] = data;
    return data;
  }

  List<Map<String, dynamic>> _getCorrelationChartData() {
    final cacheKey = 'correlations_$_selectedPeriodDays';
    if (_chartDataCache.containsKey(cacheKey)) {
      return _chartDataCache[cacheKey]!;
    }

    final data = <Map<String, dynamic>>[];
    
    for (final correlation in _activityCorrelations) {
      data.add({
        'activity': correlation.activityName,
        'metric': correlation.targetMetric,
        'strength': correlation.correlationStrength,
        'type': correlation.correlationType,
        'dataPoints': correlation.dataPointsCount,
        'color': _getCorrelationColor(correlation.correlationStrength),
      });
    }

    _chartDataCache[cacheKey] = data;
    return data;
  }

  List<Map<String, dynamic>> _getTemporalChartData() {
    final cacheKey = 'temporal_$_selectedPeriodDays';
    if (_chartDataCache.containsKey(cacheKey)) {
      return _chartDataCache[cacheKey]!;
    }

    if (_temporalPatterns == null) return [];

    final data = <Map<String, dynamic>>[];
    
    // Daily patterns
    _temporalPatterns!.dailyPatterns.forEach((day, value) {
      data.add({
        'day': day,
        'value': value,
        'type': 'daily',
      });
    });

    _chartDataCache[cacheKey] = data;
    return data;
  }

  // ============================================================================
  // NEW ANALYTICS METHODS
  // ============================================================================

  // New analytics data cache
  Map<String, dynamic>? _productivityPatterns;
  Map<String, dynamic>? _moodStability;
  Map<String, dynamic>? _lifestyleBalance;
  Map<String, dynamic>? _energyPatterns;
  Map<String, dynamic>? _socialWellness;
  Map<String, dynamic>? _habitConsistency;

  // Loading states for new methods
  bool _isLoadingProductivity = false;
  bool _isLoadingMoodStability = false;
  bool _isLoadingLifestyle = false;
  bool _isLoadingEnergy = false;
  bool _isLoadingSocial = false;
  bool _isLoadingHabits = false;

  // Getters for new analytics
  Map<String, dynamic>? get productivityPatterns => _productivityPatterns;
  Map<String, dynamic>? get moodStability => _moodStability;
  Map<String, dynamic>? get lifestyleBalance => _lifestyleBalance;
  Map<String, dynamic>? get energyPatterns => _energyPatterns;
  Map<String, dynamic>? get socialWellness => _socialWellness;
  Map<String, dynamic>? get habitConsistency => _habitConsistency;

  bool get isLoadingProductivity => _isLoadingProductivity;
  bool get isLoadingMoodStability => _isLoadingMoodStability;
  bool get isLoadingLifestyle => _isLoadingLifestyle;
  bool get isLoadingEnergy => _isLoadingEnergy;
  bool get isLoadingSocial => _isLoadingSocial;
  bool get isLoadingHabits => _isLoadingHabits;

  /// Load productivity patterns analysis
  Future<void> loadProductivityPatterns(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    if (kDebugMode) print('🔄 Loading productivity patterns for user $userId, period $period days');
    
    _setLoadingProductivity(true);
    _clearError();
    
    try {
      _productivityPatterns = await _analyticsExtension.analyzeProductivityPatterns(userId, period);
      if (kDebugMode) {
        print('✅ Productivity patterns loaded: ${_productivityPatterns != null ? "success" : "null"}');
        if (_productivityPatterns != null) {
          print('📊 Productivity data keys: ${_productivityPatterns!.keys}');
        }
      }
      _invalidateChartCache();
    } catch (e) {
      if (kDebugMode) print('❌ Error loading productivity patterns: $e');
      _setError('Error al cargar patrones de productividad: $e');
    } finally {
      _setLoadingProductivity(false);
    }
  }

  /// Load mood stability analysis
  Future<void> loadMoodStability(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingMoodStability(true);
    _clearError();
    
    try {
      _moodStability = await _analyticsExtension.analyzeMoodStability(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar estabilidad del ánimo: $e');
    } finally {
      _setLoadingMoodStability(false);
    }
  }

  /// Load lifestyle balance analysis
  Future<void> loadLifestyleBalance(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingLifestyle(true);
    _clearError();
    
    try {
      _lifestyleBalance = await _analyticsExtension.analyzeLifestyleBalance(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar balance de estilo de vida: $e');
    } finally {
      _setLoadingLifestyle(false);
    }
  }

  /// Load energy patterns analysis
  Future<void> loadEnergyPatterns(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingEnergy(true);
    _clearError();
    
    try {
      _energyPatterns = await _analyticsExtension.analyzeEnergyPatterns(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar patrones de energía: $e');
    } finally {
      _setLoadingEnergy(false);
    }
  }

  /// Load social wellness analysis
  Future<void> loadSocialWellness(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingSocial(true);
    _clearError();
    
    try {
      _socialWellness = await _analyticsExtension.analyzeSocialWellness(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar bienestar social: $e');
    } finally {
      _setLoadingSocial(false);
    }
  }

  /// Load habit consistency analysis
  Future<void> loadHabitConsistency(int userId, {int? periodDays}) async {
    final period = periodDays ?? _selectedPeriodDays;
    
    _setLoadingHabits(true);
    _clearError();
    
    try {
      _habitConsistency = await _analyticsExtension.analyzeHabitConsistency(userId, period);
      _invalidateChartCache();
    } catch (e) {
      _setError('Error al cargar consistencia de hábitos: $e');
    } finally {
      _setLoadingHabits(false);
    }
  }

  /// Load all new analytics methods with enhanced error handling
  Future<void> loadAllNewAnalytics(int userId, {int? periodDays}) async {
    if (kDebugMode) print('🔄 Provider: Starting loadAllNewAnalytics for user $userId');
    
    try {
      // Load analytics with individual error handling instead of failing all on one error
      final results = await Future.wait([
        loadProductivityPatterns(userId, periodDays: periodDays).catchError((e) {
          if (kDebugMode) print('❌ Provider: Productivity patterns failed: $e');
          return Future<void>.value(); // Continue with other analytics
        }),
        loadMoodStability(userId, periodDays: periodDays).catchError((e) {
          if (kDebugMode) print('❌ Provider: Mood stability failed: $e');
          return Future<void>.value();
        }),
        loadLifestyleBalance(userId, periodDays: periodDays).catchError((e) {
          if (kDebugMode) print('❌ Provider: Lifestyle balance failed: $e');
          return Future<void>.value();
        }),
        loadEnergyPatterns(userId, periodDays: periodDays).catchError((e) {
          if (kDebugMode) print('❌ Provider: Energy patterns failed: $e');
          return Future<void>.value();
        }),
        loadSocialWellness(userId, periodDays: periodDays).catchError((e) {
          if (kDebugMode) print('❌ Provider: Social wellness failed: $e');
          return Future<void>.value();
        }),
        loadHabitConsistency(userId, periodDays: periodDays).catchError((e) {
          if (kDebugMode) print('❌ Provider: Habit consistency failed: $e');
          return Future<void>.value();
        }),
      ]);
      
      if (kDebugMode) {
        print('✅ Provider: New analytics loading completed (some may have failed individually)');
        print('   - productivityPatterns: ${_productivityPatterns != null ? "loaded" : "null"}');
        print('   - moodStability: ${_moodStability != null ? "loaded" : "null"}');
        print('   - lifestyleBalance: ${_lifestyleBalance != null ? "loaded" : "null"}');
        print('   - energyPatterns: ${_energyPatterns != null ? "loaded" : "null"}');
        print('   - socialWellness: ${_socialWellness != null ? "loaded" : "null"}');
        print('   - habitConsistency: ${_habitConsistency != null ? "loaded" : "null"}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Provider: Critical error in loadAllNewAnalytics: $e');
      // Don't rethrow - allow app to continue with partial data
    }
  }

  // ============================================================================
  // CONFIGURATION MANAGEMENT
  // ============================================================================

  /// Get analytics configuration service for direct access
  AnalyticsConfigService get configService => _analyticsExtension.configService;

  /// Update user configuration
  Future<void> updateUserConfiguration(int userId, Map<String, dynamic> updates) async {
    await _ensureInitialized();
    
    try {
      await configService.updateConfigSection(userId, 'custom', updates);
      clearCache(); // Clear cache to force reload with new configuration
      notifyListeners();
    } catch (e) {
      _setError('Error updating configuration: $e');
    }
  }

  /// Get user configuration
  Future<AnalyticsConfig?> getUserConfiguration(int userId) async {
    await _ensureInitialized();
    
    try {
      return await configService.getConfigForUser(userId);
    } catch (e) {
      _setError('Error getting configuration: $e');
      return null;
    }
  }

  /// Adapt configuration to user data patterns
  Future<void> adaptConfigurationToUser(int userId) async {
    await _ensureInitialized();
    
    try {
      await configService.adaptConfigToUserData(userId);
      clearCache(); // Clear cache to use new configuration
      notifyListeners();
    } catch (e) {
      _setError('Error adapting configuration: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingWellness(bool loading) {
    _isLoadingWellness = loading;
    notifyListeners();
  }

  void _setLoadingCorrelations(bool loading) {
    _isLoadingCorrelations = loading;
    notifyListeners();
  }

  void _setLoadingSleep(bool loading) {
    _isLoadingSleep = loading;
    notifyListeners();
  }

  void _setLoadingStress(bool loading) {
    _isLoadingStress = loading;
    notifyListeners();
  }

  void _setLoadingGoals(bool loading) {
    _isLoadingGoals = loading;
    notifyListeners();
  }

  void _setLoadingTemporal(bool loading) {
    _isLoadingTemporal = loading;
    notifyListeners();
  }

  void _setLoadingProductivity(bool loading) {
    _isLoadingProductivity = loading;
    notifyListeners();
  }

  void _setLoadingMoodStability(bool loading) {
    _isLoadingMoodStability = loading;
    notifyListeners();
  }

  void _setLoadingLifestyle(bool loading) {
    _isLoadingLifestyle = loading;
    notifyListeners();
  }

  void _setLoadingEnergy(bool loading) {
    _isLoadingEnergy = loading;
    notifyListeners();
  }

  void _setLoadingSocial(bool loading) {
    _isLoadingSocial = loading;
    notifyListeners();
  }

  void _setLoadingHabits(bool loading) {
    _isLoadingHabits = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
  
  /// Clear partial data to prevent inconsistent state after errors
  void _clearPartialData() {
    if (kDebugMode) print('🧹 Analytics V3: Clearing partial data due to error');
    // Only clear data that might be in an inconsistent state, preserve what's valid
    // Don't clear everything as some parts might have loaded successfully
  }

  void _invalidateChartCache() {
    _chartDataCache.clear();
  }

  String _translateComponent(String component) {
    final translations = {
      'mood': 'Estado de Ánimo',
      'energy': 'Energía',
      'stress': 'Estrés',
      'sleep': 'Sueño',
      'anxiety': 'Ansiedad',
      'motivation': 'Motivación',
      'emotional_stability': 'Estabilidad Emocional',
      'life_satisfaction': 'Satisfacción',
    };
    return translations[component] ?? component;
  }

  int _getComponentColor(String component) {
    final colors = {
      'mood': 0xFF4CAF50,      // Green
      'energy': 0xFFFF9800,    // Orange
      'stress': 0xFFF44336,    // Red
      'sleep': 0xFF3F51B5,     // Indigo
      'anxiety': 0xFF9C27B0,   // Purple
      'motivation': 0xFF2196F3, // Blue
      'emotional_stability': 0xFF00BCD4, // Cyan
      'life_satisfaction': 0xFFFFEB3B,   // Yellow
    };
    return colors[component] ?? 0xFF9E9E9E;
  }

  int _getCorrelationColor(double strength) {
    final absStrength = strength.abs();
    if (absStrength >= 0.7) {
      return strength > 0 ? 0xFF4CAF50 : 0xFFF44336; // Strong: Green/Red
    } else if (absStrength >= 0.3) {
      return strength > 0 ? 0xFF8BC34A : 0xFFFF5722; // Moderate: Light Green/Deep Orange
    } else {
      return 0xFF9E9E9E; // Weak: Grey
    }
  }

  // ============================================================================
  // CONVENIENCE GETTERS FOR UI
  // ============================================================================
  
  String get wellnessLevelDisplay {
    if (_wellnessScore == null) return 'Sin datos';
    
    final translations = {
      'excellent': 'Excelente',
      'good': 'Bueno',
      'average': 'Promedio',
      'poor': 'Necesita atención',
      'insufficient_data': 'Datos insuficientes',
    };
    
    return translations[_wellnessScore!.wellnessLevel] ?? _wellnessScore!.wellnessLevel;
  }

  String get sleepPatternDisplay {
    if (_sleepPattern == null) return 'Sin datos';
    
    final translations = {
      'consistent': 'Consistente',
      'irregular': 'Irregular',
      'improving': 'Mejorando',
      'needs_attention': 'Necesita atención',
      'needs_data': 'Faltan datos',
      'insufficient_data': 'Datos insuficientes',
      'needs_more_data': 'Necesita más datos',
    };
    
    return translations[_sleepPattern!.sleepPattern] ?? _sleepPattern!.sleepPattern;
  }

  String get stressTrendDisplay {
    if (_stressManagement == null) return 'Sin datos';
    
    final translations = {
      'improving': 'Mejorando',
      'worsening': 'Empeorando',
      'stable': 'Estable',
      'insufficient_data': 'Datos insuficientes',
    };
    
    return translations[_stressManagement!.stressTrend] ?? _stressManagement!.stressTrend;
  }

  String get goalPerformanceDisplay {
    if (_goalAnalytics == null) return 'Sin datos';
    
    final translations = {
      'improving': 'Mejorando',
      'declining': 'Declinando',
      'stable': 'Estable',
      'insufficient_data': 'Datos insuficientes',
    };
    
    return translations[_goalAnalytics!.performanceTrend] ?? _goalAnalytics!.performanceTrend;
  }

  List<String> get topInsights {
    if (_analyticsData == null) return [];
    return _analyticsData!.keyInsights.take(3).toList();
  }

  List<String> get topRecommendations {
    final recommendations = <String>[];
    
    if (_wellnessScore != null) {
      recommendations.addAll(_wellnessScore!.recommendations.take(2));
    }
    
    if (_stressManagement != null) {
      recommendations.addAll(_stressManagement!.recommendations.take(2));
    }
    
    return recommendations.take(4).toList();
  }

  // Period options for UI
  List<int> get availablePeriods => [7, 30, 90];
  
  String getPeriodLabel(int days) {
    final labels = {
      7: 'Última semana',
      30: 'Último mes',
      90: 'Últimos 3 meses',
    };
    return labels[days] ?? '$days días';
  }

  // Metric options for UI
  List<String> get availableMetrics => ['wellness', 'sleep', 'stress', 'goals', 'correlations', 'temporal'];
  
  String getMetricLabel(String metric) {
    final labels = {
      'wellness': 'Bienestar',
      'sleep': 'Sueño',
      'stress': 'Estrés',
      'goals': 'Metas',
      'correlations': 'Correlaciones',
      'temporal': 'Patrones Temporales',
    };
    return labels[metric] ?? metric;
  }

  // ============================================================================
  // INSUFFICIENT DATA HELPERS
  // ============================================================================
  
  /// Check if there's sufficient data for overall analytics
  bool get hasSufficientData {
    if (kDebugMode) {
      print('🔍 Provider hasSufficientData check:');
      print('   - Wellness level: ${_wellnessScore?.wellnessLevel}');
      print('   - Sleep pattern: ${_sleepPattern?.sleepPattern}');
      print('   - Stress trend: ${_stressManagement?.stressTrend}');
      print('   - Goal performance: ${_goalAnalytics?.performanceTrend}');
      print('   - Has data: $hasData');
    }
    
    if (_wellnessScore?.wellnessLevel == 'insufficient_data') return false;
    if (_sleepPattern?.sleepPattern == 'insufficient_data') return false;
    if (_stressManagement?.stressTrend == 'insufficient_data') return false;
    if (_goalAnalytics?.performanceTrend == 'insufficient_data') return false;
    return hasData;
  }
  
  /// Get insufficient data message based on current analytics state
  String get insufficientDataMessage {
    final messages = <String>[];
    
    if (_wellnessScore?.wellnessLevel == 'insufficient_data') {
      messages.add('• Registra tu estado de ánimo y energía durante al menos 3 días');
    }
    
    if (_sleepPattern?.sleepPattern == 'insufficient_data') {
      messages.add('• Incluye tus horas de sueño durante al menos 5 días');
    }
    
    if (_stressManagement?.stressTrend == 'insufficient_data') {
      messages.add('• Registra tus niveles de estrés durante al menos 7 días');
    }
    
    if (_goalAnalytics?.performanceTrend == 'insufficient_data') {
      messages.add('• Crea al menos 3 metas para analizar tu progreso');
    }
    
    if (messages.isEmpty) {
      return 'Continúa usando la app regularmente para obtener insights más detallados.';
    }
    
    return 'Para obtener análisis más precisos:\n\n${messages.join('\n')}';
  }
  
  /// Get motivational message for continued app usage
  String get motivationalMessage {
    final daysSinceStart = _selectedPeriodDays;
    
    if (daysSinceStart < 7) {
      return '🌱 ¡Excelente inicio! Cada día que registras datos mejora la precisión de tus insights.';
    } else if (daysSinceStart < 30) {
      return '💪 ¡Vas muy bien! Tus datos están generando insights cada vez más útiles.';
    } else {
      return '🎆 ¡Increíble dedicación! Tus insights son muy precisos gracias a tu consistencia.';
    }
  }
  
  /// Check if specific analytics have insufficient data
  bool get hasInsufficientWellnessData => _wellnessScore?.wellnessLevel == 'insufficient_data';
  bool get hasInsufficientSleepData => _sleepPattern?.sleepPattern == 'insufficient_data';
  bool get hasInsufficientStressData => _stressManagement?.stressTrend == 'insufficient_data';
  bool get hasInsufficientGoalData => _goalAnalytics?.performanceTrend == 'insufficient_data';
}