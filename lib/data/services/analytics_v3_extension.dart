// ============================================================================
// data/services/analytics_v3_extension.dart - ANALYTICS V3 DATABASE EXTENSION
// NEW ANALYTICS SERVICE - EXTENDS EXISTING DATABASE WITHOUT MODIFICATIONS
// NOW WITH DYNAMIC CONFIGURATION SUPPORT
// ============================================================================

import 'dart:math' as math;
import '../models/analytics_v3_models.dart';
import '../models/analytics_config_model.dart';
import 'optimized_database_service.dart';
import 'analytics_config_service.dart';

class AnalyticsV3Extension {
  final OptimizedDatabaseService _databaseService;
  final AnalyticsConfigService configService;

  // Cache for user configurations to avoid repeated database calls
  final Map<int, AnalyticsConfig> _userConfigCache = {};

  AnalyticsV3Extension(this._databaseService) 
      : configService = AnalyticsConfigService(_databaseService);

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize the analytics extension and configuration tables
  Future<void> initialize() async {
    await configService.initializeTables();
  }

  /// Get user configuration with caching and validation
  Future<AnalyticsConfig> _getUserConfig(int userId) async {
    if (_userConfigCache.containsKey(userId)) {
      final cachedConfig = _userConfigCache[userId]!;
      if (_validateConfig(cachedConfig)) {
        return cachedConfig;
      } else {
        // Remove invalid cached config
        _userConfigCache.remove(userId);
      }
    }
    
    try {
      final config = await configService.getConfigForUser(userId);
      
      if (_validateConfig(config)) {
        _userConfigCache[userId] = config;
        return config;
      } else {
        print('❌ Invalid configuration for user $userId, using defaults');
        final defaultConfig = AnalyticsConfig.getDefault();
        _userConfigCache[userId] = defaultConfig;
        return defaultConfig;
      }
    } catch (e) {
      print('❌ Failed to load configuration for user $userId: $e');
      final defaultConfig = AnalyticsConfig.getDefault();
      _userConfigCache[userId] = defaultConfig;
      return defaultConfig;
    }
  }
  
  /// Validate configuration integrity
  bool _validateConfig(AnalyticsConfig config) {
    try {
      // Validate wellness configuration
      final wellnessConfig = config.wellnessConfig;
      if (wellnessConfig.minimumDataPoints <= 0 || wellnessConfig.minimumDataPoints > 100) {
        print('❌ Config validation: Invalid wellness minimumDataPoints: ${wellnessConfig.minimumDataPoints}');
        return false;
      }
      
      if (wellnessConfig.componentWeights.isEmpty) {
        print('❌ Config validation: Empty component weights');
        return false;
      }
      
      // Validate correlation configuration
      final corrConfig = config.correlationConfig;
      if (corrConfig.minimumDataPoints <= 0 || corrConfig.minimumDataPoints > 1000) {
        print('❌ Config validation: Invalid correlation minimumDataPoints: ${corrConfig.minimumDataPoints}');
        return false;
      }
      
      if (corrConfig.strengthThresholds.isEmpty) {
        print('❌ Config validation: Empty strength thresholds');
        return false;
      }
      
      // Validate that thresholds are in valid ranges
      final thresholds = corrConfig.strengthThresholds;
      if ((thresholds['weak'] ?? 0.0) < 0.0 || (thresholds['weak'] ?? 0.0) > 1.0 ||
          (thresholds['moderate'] ?? 0.0) < 0.0 || (thresholds['moderate'] ?? 0.0) > 1.0 ||
          (thresholds['strong'] ?? 0.0) < 0.0 || (thresholds['strong'] ?? 0.0) > 1.0) {
        print('❌ Config validation: Invalid threshold values');
        return false;
      }
      
      return true;
    } catch (e) {
      print('❌ Config validation error: $e');
      return false;
    }
  }

  /// Clear configuration cache
  void clearConfigCache() {
    _userConfigCache.clear();
    configService.clearCache();
  }

  // ============================================================================
  // COMPREHENSIVE ANALYTICS GENERATION
  // ============================================================================
  
  Future<AnalyticsV3Model> generateComprehensiveAnalytics(int userId, int periodDays) async {
    print('🚀 Analytics Extension: Starting comprehensive analytics for user $userId, period $periodDays days');
    
    // Generate all analytics components
    print('📊 Calculating wellness score...');
    final wellnessScore = await calculateWellnessScore(userId, periodDays);
    print('✅ Wellness score: ${wellnessScore.overallScore}');
    
    print('🔗 Analyzing activity correlations...');
    final activityCorrelations = await analyzeActivityCorrelations(userId, periodDays);
    print('✅ Found ${activityCorrelations.length} correlations');
    
    print('😴 Analyzing sleep patterns...');
    final sleepPattern = await analyzeSleepPatterns(userId, periodDays);
    print('✅ Sleep pattern: ${sleepPattern.sleepPattern}');
    
    print('😰 Analyzing stress management...');
    final stressManagement = await analyzeStressManagement(userId, periodDays);
    print('✅ Stress trend: ${stressManagement.stressTrend}');
    
    print('🎯 Analyzing goal performance...');
    final goalAnalytics = await analyzeGoalPerformance(userId, periodDays);
    print('✅ Goal performance: ${goalAnalytics.performanceTrend}');
    
    print('⏰ Analyzing temporal patterns...');
    final temporalPatterns = await analyzeTemporalPatterns(userId, periodDays);
    print('✅ Temporal patterns analyzed');
    
    // Generate summary metrics
    print('📈 Generating summary metrics...');
    final summaryMetrics = await _generateSummaryMetrics(userId, periodDays);
    print('✅ Summary metrics generated');
    
    // Generate key insights
    print('💡 Generating key insights...');
    final keyInsights = _generateKeyInsights(
      wellnessScore, 
      activityCorrelations, 
      sleepPattern, 
      stressManagement,
      goalAnalytics
    );
    print('✅ Generated ${keyInsights.length} key insights');

    final analyticsModel = AnalyticsV3Model(
      generatedAt: DateTime.now(),
      userId: userId,
      periodDays: periodDays,
      wellnessScore: wellnessScore,
      activityCorrelations: activityCorrelations,
      sleepPattern: sleepPattern,
      stressManagement: stressManagement,
      goalAnalytics: goalAnalytics,
      temporalPatterns: temporalPatterns,
      summaryMetrics: summaryMetrics,
      keyInsights: keyInsights,
    );
    
    print('🎉 Analytics Extension: Comprehensive analytics completed successfully');
    return analyticsModel;
  }

  // ============================================================================
  // WELLNESS SCORE CALCULATION
  // ============================================================================
  
  Future<WellnessScoreModel> calculateWellnessScore(int userId, int periodDays) async {
    print('📊 Wellness Score: Calculating for user $userId, period $periodDays days');
    
    try {
      // Validate input parameters
      if (userId <= 0 || periodDays <= 0) {
        throw ArgumentError('Invalid parameters: userId ($userId) and periodDays ($periodDays) must be positive');
      }
      
      // Get user configuration with error handling
      late AnalyticsConfig config;
      late WellnessScoreConfig wellnessConfig;
      
      try {
        config = await _getUserConfig(userId);
        wellnessConfig = config.wellnessConfig;
        print('✅ Wellness Score: Configuration loaded successfully');
      } catch (configError) {
        print('❌ Wellness Score: Configuration error - $configError');
        // Return insufficient data model instead of throwing
        return _createDefaultWellnessScore(WellnessScoreConfig.getDefault());
      }
      
      // Database operations with comprehensive error handling
      late List<Map<String, Object?>> result;
      try {
        final db = await _databaseService.database;
        final endDate = DateTime.now();
        final startDate = endDate.subtract(Duration(days: periodDays));
        
        print('📅 Wellness Score: Querying data from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
        
        result = await db.rawQuery('''
          SELECT 
            AVG(CAST(mood_score as REAL)) as avg_mood,
            AVG(CAST(energy_level as REAL)) as avg_energy,
            AVG(CAST(stress_level as REAL)) as avg_stress,
            AVG(CAST(sleep_quality as REAL)) as avg_sleep_quality,
            AVG(CAST(anxiety_level as REAL)) as avg_anxiety,
            AVG(CAST(motivation_level as REAL)) as avg_motivation,
            AVG(CAST(emotional_stability as REAL)) as avg_emotional_stability,
            AVG(CAST(life_satisfaction as REAL)) as avg_life_satisfaction,
            COUNT(*) as total_entries,
            COUNT(CASE WHEN mood_score IS NOT NULL THEN 1 END) as mood_entries,
            COUNT(CASE WHEN stress_level IS NOT NULL THEN 1 END) as stress_entries,
            COUNT(CASE WHEN anxiety_level IS NOT NULL THEN 1 END) as anxiety_entries
          FROM daily_entries 
          WHERE user_id = ? AND entry_date BETWEEN ? AND ?
            AND (mood_score IS NOT NULL OR energy_level IS NOT NULL)
        ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);
        
        print('✅ Wellness Score: Database query executed successfully');
        
      } catch (dbError) {
        print('❌ Wellness Score: Database query failed - $dbError');
        return _createDefaultWellnessScore(wellnessConfig);
      }

    print('🔍 Wellness Score: Query returned ${result.length} rows');
    if (result.isNotEmpty) {
      final data = result.first;
      print('📈 Wellness Score Data:');
      print('   - Total entries: ${data['total_entries']}');
      print('   - Mood entries: ${data['mood_entries']}');
      print('   - Avg mood: ${data['avg_mood']}');
      print('   - Avg energy: ${data['avg_energy']}');
      print('   - Avg stress: ${data['avg_stress']}');
      print('   - Minimum required: ${wellnessConfig.minimumDataPoints}');
    }

    if (result.isEmpty || result.first['total_entries'] == 0) {
      print('⚠️ Wellness Score: No data found, returning default score');
      return _createDefaultWellnessScore(wellnessConfig);
    }

    final data = result.first;
    final totalEntries = _safeIntCast(data['total_entries'], 'total_entries');
    
    // Use dynamic minimum data points from configuration
    if (totalEntries < wellnessConfig.minimumDataPoints) {
      print('⚠️ Wellness Score: Insufficient data - found $totalEntries entries, need ${wellnessConfig.minimumDataPoints}');
      return _createDefaultWellnessScore(wellnessConfig);
    }
    
    print('✅ Wellness Score: Sufficient data found - $totalEntries entries >= ${wellnessConfig.minimumDataPoints} required');
    
    // Calculate component scores with proper validation and normalization
    final moodScore = _validateAndNormalizeScore(
      _safeDoubleCast(data['avg_mood'], 'avg_mood'), 
      'mood', 
      wellnessConfig.defaultScores['mood']!
    );
    final energyScore = _validateAndNormalizeScore(
      _safeDoubleCast(data['avg_energy'], 'avg_energy'), 
      'energy', 
      wellnessConfig.defaultScores['energy']!
    );
    
    // Enhanced stress/anxiety inversion with configuration-based thresholds
    final stressCount = _safeIntCast(data['stress_entries'], 'stress_entries');
    final anxietyCount = _safeIntCast(data['anxiety_entries'], 'anxiety_entries');
    
    final rawStress = _safeDoubleCast(data['avg_stress'], 'avg_stress');
    final rawAnxiety = _safeDoubleCast(data['avg_anxiety'], 'avg_anxiety');
    
    // Use configuration to determine minimum entries for inversion
    final minEntriesForInversion = math.max(2, wellnessConfig.minimumDataPoints ~/ 2);
    
    final stressScore = (stressCount >= minEntriesForInversion && rawStress >= 1.0 && rawStress <= 10.0) 
        ? math.max(0.0, math.min(10.0, 11.0 - rawStress)) 
        : _validateAndNormalizeScore(rawStress, 'stress', wellnessConfig.defaultScores['stress']!);
        
    final anxietyScore = (anxietyCount >= minEntriesForInversion && rawAnxiety >= 1.0 && rawAnxiety <= 10.0) 
        ? math.max(0.0, math.min(10.0, 11.0 - rawAnxiety)) 
        : _validateAndNormalizeScore(rawAnxiety, 'anxiety', wellnessConfig.defaultScores['anxiety']!);
    
    final sleepScore = _validateAndNormalizeScore(
      _safeDoubleCast(data['avg_sleep_quality'], 'avg_sleep_quality'), 
      'sleep', 
      wellnessConfig.defaultScores['sleep']!
    );
    final motivationScore = _validateAndNormalizeScore(
      _safeDoubleCast(data['avg_motivation'], 'avg_motivation'), 
      'motivation', 
      wellnessConfig.defaultScores['motivation']!
    );
    final emotionalScore = _validateAndNormalizeScore(
      _safeDoubleCast(data['avg_emotional_stability'], 'avg_emotional_stability'), 
      'emotional_stability', 
      wellnessConfig.defaultScores['emotional_stability']!
    );
    final satisfactionScore = _validateAndNormalizeScore(
      _safeDoubleCast(data['avg_life_satisfaction'], 'avg_life_satisfaction'), 
      'life_satisfaction', 
      wellnessConfig.defaultScores['life_satisfaction']!
    );

    final componentScores = {
      'mood': moodScore,
      'energy': energyScore,
      'stress': stressScore,
      'sleep': sleepScore,
      'anxiety': anxietyScore,
      'motivation': motivationScore,
      'emotional_stability': emotionalScore,
      'life_satisfaction': satisfactionScore,
    };

    // Calculate weighted overall score using dynamic weights from configuration
    final weights = wellnessConfig.componentWeights;
    final overallScore = (
      moodScore * (weights['mood'] ?? 0.0) +
      energyScore * (weights['energy'] ?? 0.0) +
      stressScore * (weights['stress'] ?? 0.0) +
      sleepScore * (weights['sleep'] ?? 0.0) +
      anxietyScore * (weights['anxiety'] ?? 0.0) +
      motivationScore * (weights['motivation'] ?? 0.0) +
      emotionalScore * (weights['emotional_stability'] ?? 0.0) +
      satisfactionScore * (weights['life_satisfaction'] ?? 0.0)
    );

    // Determine wellness level using dynamic thresholds
    final wellnessLevel = config.getWellnessLevel(overallScore);

    // Generate dynamic recommendations based on configuration and scores
    final recommendations = _generateWellnessRecommendations(
      componentScores, 
      overallScore, 
      wellnessConfig,
      data
    );

    // Calculate data quality metrics
    final dataQuality = _calculateDataQuality(data, totalEntries);

      return WellnessScoreModel(
        overallScore: overallScore,
        componentScores: componentScores,
        wellnessLevel: wellnessLevel,
        recommendations: recommendations,
        calculatedAt: DateTime.now(),
        rawMetrics: {
          'total_entries': totalEntries,
          'period_days': periodDays,
          'data_quality': dataQuality,
          'configuration_version': config.id,
          'mood_variance': data['mood_stddev'] ?? 0.0,
          'energy_variance': data['energy_stddev'] ?? 0.0,
        },
      );
      
    } catch (error, stackTrace) {
      print('❌ Wellness Score: Unexpected error - $error');
      print('📍 Wellness Score Stack Trace: $stackTrace');
      
      // Return safe default instead of crashing
      return _createDefaultWellnessScore(WellnessScoreConfig.getDefault());
    }
  }

  // ============================================================================
  // ACTIVITY CORRELATION ANALYSIS
  // ============================================================================
  
  Future<List<ActivityCorrelationModel>> analyzeActivityCorrelations(int userId, int periodDays) async {
    print('🔗 Activity Correlations: Starting analysis for user $userId, period $periodDays days');
    
    try {
      // Validate input parameters
      if (userId <= 0 || periodDays <= 0) {
        print('❌ Activity Correlations: Invalid parameters - userId: $userId, periodDays: $periodDays');
        return []; // Return empty list instead of throwing
      }
      
      final correlations = <ActivityCorrelationModel>[];
      
      // Try correlations with columns that actually have data
    // Energy vs Stress (both have data according to wellness calculation)
    print('⚡ Analyzing Energy vs Stress correlation...');
    final energyStressCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'energy_level', 'stress_level', 'Nivel de Energía', 'Nivel de Estrés', invertTarget: true
    );
    if (energyStressCorr != null) {
      print('✅ Energy-Stress correlation found: ${energyStressCorr.correlationStrength}');
      correlations.add(energyStressCorr);
    } else {
      print('❌ Energy-Stress correlation returned null');
    }

    // Try some backup correlations with columns that might have data
    print('😴 Analyzing Sleep Hours vs Energy correlation...');
    final sleepEnergyCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'sleep_hours', 'energy_level', 'Horas de Sueño', 'Nivel de Energía'
    );
    if (sleepEnergyCorr != null) {
      print('✅ Sleep Hours-Energy correlation found: ${sleepEnergyCorr.correlationStrength}');
      correlations.add(sleepEnergyCorr);
    } else {
      print('❌ Sleep Hours-Energy correlation returned null');
    }

    print('🏃 Analyzing Exercise Minutes vs Energy correlation...');
    final exerciseEnergyCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'exercise_minutes', 'energy_level', 'Minutos de Ejercicio', 'Nivel de Energía'
    );
    if (exerciseEnergyCorr != null) {
      print('✅ Exercise Minutes-Energy correlation found: ${exerciseEnergyCorr.correlationStrength}');
      correlations.add(exerciseEnergyCorr);
    } else {
      print('❌ Exercise Minutes-Energy correlation returned null');
    }

    print('🧘 Analyzing Meditation vs Stress correlation...');
    final meditationStressCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'meditation_minutes', 'stress_level', 'Minutos de Meditación', 'Nivel de Estrés', invertTarget: true
    );
    if (meditationStressCorr != null) {
      print('✅ Meditation-Stress correlation found: ${meditationStressCorr.correlationStrength}');
      correlations.add(meditationStressCorr);
    } else {
      print('❌ Meditation-Stress correlation returned null');
    }

    print('💧 Analyzing Water vs Energy correlation...');
    final waterEnergyCorr = await _calculateActivityCorrelation(
      userId, periodDays, 'water_intake', 'energy_level', 'Consumo de Agua', 'Nivel de Energía'
    );
    if (waterEnergyCorr != null) {
      print('✅ Water-Energy correlation found: ${waterEnergyCorr.correlationStrength}');
      correlations.add(waterEnergyCorr);
    } else {
      print('❌ Water-Energy correlation returned null');
    }

      print('🔗 Activity Correlations: Final count = ${correlations.length}');
      return correlations;
      
    } catch (error, stackTrace) {
      print('❌ Activity Correlations: Unexpected error - $error');
      print('📍 Activity Correlations Stack Trace: $stackTrace');
      
      // Return empty list instead of crashing
      return [];
    }
  }

  Future<ActivityCorrelationModel?> _calculateActivityCorrelation(
    int userId, int periodDays, String activityColumn, String targetColumn, 
    String activityName, String targetName, {bool invertTarget = false}
  ) async {
    print('📊 Correlation Analysis: $activityName vs $targetName');
    print('   Activity column: $activityColumn, Target column: $targetColumn');
    
    // Get user configuration for correlation analysis
    final config = await _getUserConfig(userId);
    final correlationConfig = config.correlationConfig;
    
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        entry_date,
        CAST($activityColumn as REAL) as activity_value,
        CAST($targetColumn as REAL) as target_value
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND $activityColumn IS NOT NULL AND $targetColumn IS NOT NULL
        AND CAST($activityColumn as REAL) BETWEEN 0 AND 20  -- Basic outlier filtering
        AND CAST($targetColumn as REAL) BETWEEN 0 and 10   -- Basic range validation
      ORDER BY entry_date
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    print('📈 Correlation Data: Found ${result.length} data points');
    print('   Required minimum: ${correlationConfig.minimumDataPoints}');
    
    if (result.isNotEmpty) {
      final firstRow = result.first;
      print('   Sample data: activity=${firstRow['activity_value']}, target=${firstRow['target_value']}');
    }

    // Use dynamic minimum data points from configuration
    if (result.length < correlationConfig.minimumDataPoints) {
      print('⚠️ Insufficient data for correlation: ${result.length} < ${correlationConfig.minimumDataPoints}');
      // Return null for insufficient data instead of a 0-strength correlation
      return null;
    }

    // Enhanced data point validation and safe casting
    final dataPoints = <CorrelationDataPoint>[];
    int invalidDataPoints = 0;
    
    for (final row in result) {
      try {
        // Safe casting with validation
        final activityValue = _safeDoubleCast(row['activity_value'], 'activity_value');
        final rawTargetValue = _safeDoubleCast(row['target_value'], 'target_value');
        final dateString = row['entry_date'] as String?;
        
        // Validate data quality
        if (activityValue == 0.0 || rawTargetValue == 0.0 || dateString == null) {
          invalidDataPoints++;
          print('⚠️ Correlation: Skipping invalid data point - activity: $activityValue, target: $rawTargetValue, date: $dateString');
          continue;
        }
        
        // Apply target inversion if needed
        final targetValue = invertTarget 
          ? math.max(0.0, math.min(10.0, 11.0 - rawTargetValue))
          : rawTargetValue;
        
        // Validate ranges
        if (activityValue < 0 || activityValue > 20 || targetValue < 0 || targetValue > 10) {
          invalidDataPoints++;
          print('⚠️ Correlation: Skipping out-of-range data - activity: $activityValue, target: $targetValue');
          continue;
        }
        
        dataPoints.add(CorrelationDataPoint(
          date: DateTime.parse(dateString),
          activityValue: activityValue,
          metricValue: targetValue,
        ));
      } catch (e) {
        invalidDataPoints++;
        print('❌ Correlation: Error processing data point - $e');
        continue;
      }
    }
    
    // Check data quality after filtering
    if (invalidDataPoints > result.length * 0.3) {
      print('⚠️ Correlation: High invalid data ratio - ${invalidDataPoints}/${result.length} invalid points');
    }
    
    // Re-check minimum data after filtering
    if (dataPoints.length < correlationConfig.minimumDataPoints) {
      print('⚠️ Correlation: Insufficient valid data points after filtering: ${dataPoints.length} < ${correlationConfig.minimumDataPoints}');
      return null;
    }

    // Calculate Pearson correlation
    final correlation = _calculatePearsonCorrelation(
      dataPoints.map((dp) => dp.activityValue).toList(),
      dataPoints.map((dp) => dp.metricValue).toList(),
    );

    // Calculate statistical significance using configuration thresholds
    final significance = _calculateCorrelationSignificance(
      correlation, 
      dataPoints.length, 
      correlationConfig
    );
    
    // Determine correlation type using dynamic thresholds from configuration
    String correlationType;
    final absCorr = correlation.abs();
    final thresholds = correlationConfig.strengthThresholds;
    
    if (!significance.isSignificant) {
      correlationType = 'not_significant';
    } else if (absCorr >= thresholds['strong']!) {
      correlationType = correlation > 0 ? 'strong_positive' : 'strong_negative';
    } else if (absCorr >= thresholds['moderate']!) {
      correlationType = correlation > 0 ? 'moderate_positive' : 'moderate_negative';
    } else if (absCorr >= thresholds['weak']!) {
      correlationType = correlation > 0 ? 'weak_positive' : 'weak_negative';
    } else {
      correlationType = 'negligible';
    }

    // Generate insights and recommendations
    final insight = _generateCorrelationInsight(activityName, targetName, correlation, correlationType);
    final recommendation = _generateCorrelationRecommendation(activityName, targetName, correlation);

    return ActivityCorrelationModel(
      activityName: activityName,
      targetMetric: targetName,
      correlationStrength: correlation,
      correlationType: correlationType,
      dataPoints: dataPoints,
      insight: insight,
      recommendation: recommendation,
      dataPointsCount: dataPoints.length,
    );
  }

  // ============================================================================
  // SLEEP PATTERN ANALYSIS
  // ============================================================================
  
  Future<SleepPatternModel> analyzeSleepPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    // Get sleep data
    final result = await db.rawQuery('''
      SELECT 
        entry_date,
        CAST(sleep_hours as REAL) as hours,
        CAST(sleep_quality as REAL) as quality,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND (sleep_hours IS NOT NULL OR sleep_quality IS NOT NULL)
      ORDER BY entry_date
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return _createDefaultSleepPattern();
    }

    // Calculate averages
    final validHours = result.where((r) => r['hours'] != null).map((r) => r['hours'] as double).toList();
    final validQuality = result.where((r) => r['quality'] != null).map((r) => r['quality'] as double).toList();
    
    final avgHours = validHours.isNotEmpty ? validHours.reduce((a, b) => a + b) / validHours.length : 7.0;
    final avgQuality = validQuality.isNotEmpty ? validQuality.reduce((a, b) => a + b) / validQuality.length : 5.0;

    // Weekly pattern analysis
    final weeklyPattern = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayHours = dayData.where((r) => r['hours'] != null).map((r) => r['hours'] as double).toList();
        final dayAvg = dayHours.isNotEmpty ? dayHours.reduce((a, b) => a + b) / dayHours.length : avgHours;
        weeklyPattern[dayNames[i]] = dayAvg;
      }
    }

    // Determine sleep pattern with improved variance analysis
    final hoursVariance = validHours.length >= 3 ? _calculateVariance(validHours) : 0.0;
    
    // Calculate coefficient of variation for better pattern assessment
    final coefficientOfVariation = avgHours > 0 ? (math.sqrt(hoursVariance) / avgHours) : 0.0;
    
    String sleepPattern;
    if (validHours.length < 3) {
      sleepPattern = 'needs_data';
    } else if (coefficientOfVariation < 0.1) { // Less than 10% variation
      sleepPattern = 'consistent';
    } else if (coefficientOfVariation > 0.25) { // More than 25% variation
      sleepPattern = 'irregular';
    } else {
      sleepPattern = avgHours >= 7.0 ? 'improving' : 'needs_attention';
    }

    // Enhanced quality trend analysis with chronological ordering
    String qualityTrend = 'stable';
    if (validQuality.length >= 7) {
      // Ensure we have chronological data by using result entries with dates
      final chronologicalQuality = result
          .where((r) => r['quality'] != null)
          .map((r) => r['quality'] as double)
          .toList();
      
      if (chronologicalQuality.length >= 7) {
        final splitPoint = chronologicalQuality.length ~/ 2;
        final firstHalf = chronologicalQuality.take(splitPoint).toList();
        final secondHalf = chronologicalQuality.skip(splitPoint).toList();
        
        if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
          final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
          final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
          final difference = secondAvg - firstAvg;
          
          // Use statistical significance threshold based on data variance
          final qualityVariance = _calculateVariance(chronologicalQuality);
          final threshold = math.max(0.3, math.sqrt(qualityVariance) * 0.5);
          
          if (difference > threshold) {
            qualityTrend = 'improving';
          } else if (difference < -threshold) {
            qualityTrend = 'declining';
          }
        }
      }
    }

    // Generate insights
    final insights = _generateSleepInsights(avgHours, avgQuality, sleepPattern, hoursVariance);

    // Calculate correlations
    final correlations = await _calculateSleepCorrelations(userId, periodDays);

    return SleepPatternModel(
      averageSleepHours: avgHours,
      averageSleepQuality: avgQuality,
      sleepPattern: sleepPattern,
      weeklyPattern: weeklyPattern,
      insights: insights,
      optimalSleepHours: _calculateOptimalSleepHours(avgHours, avgQuality),
      qualityTrend: qualityTrend,
      correlations: correlations,
    );
  }

  // ============================================================================
  // STRESS MANAGEMENT ANALYSIS
  // ============================================================================
  
  Future<StressManagementModel> analyzeStressManagement(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    // Get stress data
    final result = await db.rawQuery('''
      SELECT 
        entry_date,
        CAST(stress_level as REAL) as stress,
        strftime('%H', created_at, 'unixepoch') as hour,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND stress_level IS NOT NULL
      ORDER BY entry_date
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return _createDefaultStressManagement();
    }

    final stressLevels = result.map((r) => r['stress'] as double).toList();
    final avgStress = stressLevels.reduce((a, b) => a + b) / stressLevels.length;
    
    // Calculate trend
    String stressTrend = 'stable';
    if (stressLevels.length >= 7) {
      final firstHalf = stressLevels.take(stressLevels.length ~/ 2).toList();
      final secondHalf = stressLevels.skip(stressLevels.length ~/ 2).toList();
      final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
      
      if (secondAvg - firstAvg > 0.5) {
        stressTrend = 'worsening';
      } else if (firstAvg - secondAvg > 0.5) {
        stressTrend = 'improving';
      }
    }

    // Time patterns
    final stressByHour = <String, double>{};
    final stressByDay = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];

    // Group by time of day
    for (int hour = 0; hour < 24; hour++) {
      final hourData = result.where((r) => r['hour'] == hour.toString()).toList();
      if (hourData.isNotEmpty) {
        final hourStress = hourData.map((r) => r['stress'] as double).toList();
        stressByHour[hour.toString()] = hourStress.reduce((a, b) => a + b) / hourStress.length;
      }
    }

    // Group by day of week
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayStress = dayData.map((r) => r['stress'] as double).toList();
        stressByDay[dayNames[i]] = dayStress.reduce((a, b) => a + b) / dayStress.length;
      }
    }

    // Identify triggers (simplified)
    final triggers = _identifyStressTriggers(result, avgStress);
    
    // Identify effective methods (simplified)
    final effectiveMethods = await _identifyStressReliefMethods(userId, periodDays);

    // Generate recommendations
    final recommendations = _generateStressRecommendations(avgStress, stressTrend, triggers);

    final highStressDays = stressLevels.where((s) => s >= 7.0).length;

    return StressManagementModel(
      averageStressLevel: avgStress,
      stressTrend: stressTrend,
      identifiedTriggers: triggers,
      effectiveMethods: effectiveMethods,
      stressByTimeOfDay: stressByHour,
      stressByDayOfWeek: stressByDay,
      recommendations: recommendations,
      highStressDaysCount: highStressDays,
    );
  }

  // ============================================================================
  // GOAL ANALYTICS
  // ============================================================================
  
  Future<GoalAnalyticsModel> analyzeGoalPerformance(int userId, int periodDays) async {
    final goals = await _databaseService.getUserGoals(userId);
    
    if (goals.isEmpty) {
      return _createDefaultGoalAnalytics();
    }

    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final inProgressGoals = totalGoals - completedGoals;
    final completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    // Completion by category
    final completionByCategory = <String, double>{};
    final categories = goals.map((g) => g.category.toString().split('.').last).toSet();
    
    for (final category in categories) {
      final categoryGoals = goals.where((g) => g.category.toString().split('.').last == category).toList();
      final categoryCompleted = categoryGoals.where((g) => g.isCompleted).length;
      completionByCategory[category] = categoryGoals.isNotEmpty ? categoryCompleted / categoryGoals.length : 0.0;
    }

    // Calculate average completion time for completed goals
    final completedGoalsWithDates = goals.where((g) => g.isCompleted && g.lastUpdated != null).toList();
    double averageCompletionTime = 0.0;
    
    if (completedGoalsWithDates.isNotEmpty) {
      final completionTimes = completedGoalsWithDates.map((g) {
        return g.lastUpdated!.difference(g.createdAt).inDays.toDouble();
      }).toList();
      averageCompletionTime = completionTimes.reduce((a, b) => a + b) / completionTimes.length;
    }

    // Performance trend (simplified)
    String performanceTrend = 'stable';
    if (completionRate > 0.7) {
      performanceTrend = 'improving';
    } else if (completionRate < 0.3) {
      performanceTrend = 'declining';
    }

    // Generate insights
    final insights = _generateGoalInsights(completionRate, completionByCategory, averageCompletionTime);

    // Success factors
    final successFactors = _identifySuccessFactors(goals, completionRate);

    return GoalAnalyticsModel(
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      inProgressGoals: inProgressGoals,
      completionRate: completionRate,
      completionByCategory: completionByCategory,
      insights: insights,
      performanceTrend: performanceTrend,
      averageCompletionTime: averageCompletionTime,
      successFactors: successFactors,
    );
  }

  // ============================================================================
  // TEMPORAL PATTERN ANALYSIS
  // ============================================================================
  
  Future<TemporalPatternModel> analyzeTemporalPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    // Get mood data with timestamps
    final result = await db.rawQuery('''
      SELECT 
        CAST(mood_score as REAL) as mood,
        strftime('%H', created_at, 'unixepoch') as hour,
        strftime('%w', entry_date) as day_of_week,
        strftime('%m', entry_date) as month
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND mood_score IS NOT NULL
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return _createDefaultTemporalPattern();
    }

    // Hourly patterns
    final hourlyPatterns = <String, double>{};
    for (int hour = 0; hour < 24; hour++) {
      final hourData = result.where((r) => r['hour'] == hour.toString()).toList();
      if (hourData.isNotEmpty) {
        final hourMoods = hourData.map((r) => r['mood'] as double).toList();
        hourlyPatterns[hour.toString()] = hourMoods.reduce((a, b) => a + b) / hourMoods.length;
      }
    }

    // Daily patterns
    final dailyPatterns = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayMoods = dayData.map((r) => r['mood'] as double).toList();
        dailyPatterns[dayNames[i]] = dayMoods.reduce((a, b) => a + b) / dayMoods.length;
      }
    }

    // Monthly trends (simplified)
    final monthlyTrends = <String, double>{};
    final currentMonth = DateTime.now().month;
    for (int month = math.max(1, currentMonth - 2); month <= currentMonth; month++) {
      final monthData = result.where((r) => int.parse(r['month'] as String) == month).toList();
      if (monthData.isNotEmpty) {
        final monthMoods = monthData.map((r) => r['mood'] as double).toList();
        monthlyTrends[month.toString()] = monthMoods.reduce((a, b) => a + b) / monthMoods.length;
      }
    }

    // Determine optimal time and patterns
    final optimalTimeOfDay = _determineOptimalTimeOfDay(hourlyPatterns);
    final weeklyPattern = _determineWeeklyPattern(dailyPatterns);

    // Generate insights
    final insights = _generateTemporalInsights(hourlyPatterns, dailyPatterns, optimalTimeOfDay);

    return TemporalPatternModel(
      hourlyPatterns: hourlyPatterns,
      dailyPatterns: dailyPatterns,
      monthlyTrends: monthlyTrends,
      optimalTimeOfDay: optimalTimeOfDay,
      weeklyPattern: weeklyPattern,
      insights: insights,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  double _calculatePearsonCorrelation(List<double> x, List<double> y) {
    // Enhanced validation for reliable correlation analysis
    if (x.isEmpty || y.isEmpty || x.length != y.length) return 0.0;
    
    // Require minimum 7 data points for reliable correlation
    if (x.length < 7) return 0.0;
    
    // Check for valid numeric values
    if (x.any((v) => !v.isFinite) || y.any((v) => !v.isFinite)) return 0.0;
    
    final n = x.length;
    
    // Calculate means for validation
    final meanX = x.reduce((a, b) => a + b) / n;
    final meanY = y.reduce((a, b) => a + b) / n;
    
    // Check for zero variance (constant values)
    final varianceX = x.map((v) => math.pow(v - meanX, 2)).reduce((a, b) => a + b) / n;
    final varianceY = y.map((v) => math.pow(v - meanY, 2)).reduce((a, b) => a + b) / n;
    
    if (varianceX < 0.001 || varianceY < 0.001) return 0.0; // Insufficient variance
    
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = y.map((v) => v * v).reduce((a, b) => a + b);
    
    final numerator = n * sumXY - sumX * sumY;
    final denominatorPart1 = n * sumX2 - sumX * sumX;
    final denominatorPart2 = n * sumY2 - sumY * sumY;
    
    // Enhanced denominator validation
    if (denominatorPart1 <= 0 || denominatorPart2 <= 0) return 0.0;
    
    final denominator = math.sqrt(denominatorPart1 * denominatorPart2);
    
    if (denominator == 0 || !denominator.isFinite) return 0.0;
    
    final correlation = numerator / denominator;
    
    // Clamp result to valid range [-1, 1]
    return math.max(-1.0, math.min(1.0, correlation));
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  // ============================================================================
  // SAFE TYPE CASTING METHODS
  // ============================================================================
  
  /// Safely cast a value to int with validation and error handling
  int _safeIntCast(dynamic value, String fieldName) {
    if (value == null) {
      print('⚠️ SafeCast: $fieldName is null, defaulting to 0');
      return 0;
    }
    
    if (value is int) {
      return value;
    }
    
    if (value is double) {
      if (!value.isFinite) {
        print('❌ SafeCast: $fieldName is not finite ($value), defaulting to 0');
        return 0;
      }
      return value.round();
    }
    
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null) {
        print('❌ SafeCast: Could not parse $fieldName string "$value" to int, defaulting to 0');
        return 0;
      }
      return parsed;
    }
    
    print('❌ SafeCast: $fieldName has unsupported type ${value.runtimeType}, defaulting to 0');
    return 0;
  }
  
  /// Safely cast a value to double with validation and error handling
  double _safeDoubleCast(dynamic value, String fieldName) {
    if (value == null) {
      print('⚠️ SafeCast: $fieldName is null, defaulting to 0.0');
      return 0.0;
    }
    
    if (value is double) {
      if (!value.isFinite) {
        print('❌ SafeCast: $fieldName is not finite ($value), defaulting to 0.0');
        return 0.0;
      }
      return value;
    }
    
    if (value is int) {
      return value.toDouble();
    }
    
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null || !parsed.isFinite) {
        print('❌ SafeCast: Could not parse $fieldName string "$value" to double, defaulting to 0.0');
        return 0.0;
      }
      return parsed;
    }
    
    print('❌ SafeCast: $fieldName has unsupported type ${value.runtimeType}, defaulting to 0.0');
    return 0.0;
  }

  /// Validates and normalizes a score to the 0-10 range with proper error handling
  /// Now uses configuration-based default values
  double _validateAndNormalizeScore(double? value, String scoreType, double defaultValue) {
    // Enhanced validation with detailed logging
    if (value == null) {
      print('⚠️ Validation: $scoreType value is null, using default: $defaultValue');
      return 0.0; // Use 0.0 to indicate missing data instead of fake defaults
    }
    
    if (!value.isFinite || value.isNaN) {
      print('❌ Validation: $scoreType value is not finite ($value), marking as invalid');
      return 0.0; // Use 0.0 to indicate invalid data instead of fake defaults
    }
    
    // Enhanced range validation based on score type
    double minValue = 0.0;
    double maxValue = 10.0;
    
    switch (scoreType) {
      case 'sleep':
        // Sleep quality should be 1-10, but sleep hours could be 0-24
        if (scoreType.contains('quality')) {
          minValue = 1.0;
        } else if (scoreType.contains('hours')) {
          minValue = 0.0;
          maxValue = 24.0;
        }
        break;
      case 'stress':
      case 'anxiety':
        minValue = 1.0; // Stress/anxiety typically start from 1
        break;
      case 'water_intake':
        minValue = 0.0;
        maxValue = 20.0; // Reasonable max for daily water (glasses/liters)
        break;
      case 'exercise_minutes':
        minValue = 0.0;
        maxValue = 1440.0; // Max minutes in a day
        break;
      default:
        minValue = 0.0;
        maxValue = 10.0;
    }
    
    // Check if value is within reasonable bounds
    if (value < minValue || value > maxValue) {
      print('⚠️ Validation: $scoreType value $value is outside valid range [$minValue-$maxValue], clamping');
    }
    
    // Clamp to valid range 
    final clampedValue = math.max(minValue, math.min(maxValue, value));
    
    // For 1-10 scales, ensure we don't have exactly 0 unless it's truly missing
    if (maxValue == 10.0 && clampedValue == 0.0 && value != 0.0) {
      print('⚠️ Validation: $scoreType clamped to 0, but original was $value - this may indicate data quality issues');
    }
    
    return clampedValue;
  }

  /// Calculate statistical significance of a correlation coefficient using configuration
  CorrelationSignificance _calculateCorrelationSignificance(
    double correlation, 
    int sampleSize, 
    CorrelationConfig config
  ) {
    if (sampleSize < 3) {
      return CorrelationSignificance(isSignificant: false, pValue: 1.0, confidence: 0.0);
    }
    
    // Calculate t-statistic for Pearson correlation
    final absR = correlation.abs();
    final degreesOfFreedom = sampleSize - 2;
    
    if (absR >= 1.0 || degreesOfFreedom <= 0) {
      return CorrelationSignificance(isSignificant: false, pValue: 1.0, confidence: 0.0);
    }
    
    final tStatistic = absR * math.sqrt(degreesOfFreedom / (1 - absR * absR));
    
    // Get target p-value from configuration
    final targetPValue = config.significanceThresholds['p_value'] ?? 0.05;
    final targetConfidence = config.confidenceLevel;
    
    // Enhanced significance thresholds based on degrees of freedom and configuration
    double criticalValue;
    if (targetPValue <= 0.01) {
      // More stringent threshold for p < 0.01
      if (degreesOfFreedom >= 30) {
        criticalValue = 2.756;
      } else if (degreesOfFreedom >= 20) {
        criticalValue = 2.845;
      } else if (degreesOfFreedom >= 10) {
        criticalValue = 3.169;
      } else if (degreesOfFreedom >= 5) {
        criticalValue = 3.707;
      } else {
        criticalValue = 4.604;
      }
    } else {
      // Standard threshold for p < 0.05
      if (degreesOfFreedom >= 30) {
        criticalValue = 2.042;
      } else if (degreesOfFreedom >= 20) {
        criticalValue = 2.086;
      } else if (degreesOfFreedom >= 10) {
        criticalValue = 2.228;
      } else if (degreesOfFreedom >= 5) {
        criticalValue = 2.571;
      } else {
        criticalValue = 3.182;
      }
    }
    
    final isSignificant = tStatistic > criticalValue;
    final confidence = isSignificant ? targetConfidence : 0.0;
    
    // Improved p-value estimation based on t-statistic
    double pValue;
    if (tStatistic > criticalValue) {
      pValue = math.max(0.001, targetPValue * (criticalValue / tStatistic));
    } else {
      pValue = math.min(0.5, targetPValue * (tStatistic / criticalValue + 1));
    }
    
    return CorrelationSignificance(
      isSignificant: isSignificant,
      pValue: pValue,
      confidence: confidence,
    );
  }

  // Default models for when there's insufficient data
  WellnessScoreModel _createDefaultWellnessScore(WellnessScoreConfig config) {
    // Don't provide fake scores - indicate insufficient data
    final emptyComponentScores = <String, double>{};
    config.defaultScores.keys.forEach((key) {
      emptyComponentScores[key] = 0.0; // Zero indicates no data, not a real score
    });
    
    return WellnessScoreModel(
      overallScore: 0.0, // Zero indicates insufficient data, not a real wellness score
      componentScores: emptyComponentScores,
      wellnessLevel: 'insufficient_data',
      recommendations: [
        'Necesitas registrar al menos ${config.minimumDataPoints} días de datos para obtener un análisis confiable de bienestar',
        'Continúa usando la app diariamente para generar insights personalizados',
        'Registra tu estado de ánimo, nivel de energía y calidad de sueño regularmente'
      ],
      calculatedAt: DateTime.now(),
      rawMetrics: {
        'total_entries': 0, 
        'minimum_required': config.minimumDataPoints,
        'data_quality': 0.0,
        'data_status': 'insufficient',
        'requires_more_days': config.minimumDataPoints,
      },
    );
  }

  SleepPatternModel _createDefaultSleepPattern() {
    return SleepPatternModel(
      averageSleepHours: 0.0, // Zero indicates no data available
      averageSleepQuality: 0.0, // Zero indicates no data available
      sleepPattern: 'insufficient_data',
      weeklyPattern: {},
      insights: [
        SleepInsight(
          title: 'Datos Insuficientes',
          description: 'Necesitas al menos 7 días de registros de sueño para generar insights confiables',
          category: 'data',
          severity: 'info',
          recommendation: 'Registra tu sueño durante al menos una semana'
        )
      ],
      optimalSleepHours: 0.0, // Cannot determine without data
      qualityTrend: 'insufficient_data',
      correlations: {
        'data_status': 'insufficient',
        'required_entries': 7,
        'message': 'Registra tu sueño durante al menos una semana'
      },
    );
  }

  StressManagementModel _createDefaultStressManagement() {
    return StressManagementModel(
      averageStressLevel: 0.0, // Zero indicates no data available
      stressTrend: 'insufficient_data',
      identifiedTriggers: [],
      effectiveMethods: [],
      stressByTimeOfDay: {},
      stressByDayOfWeek: {},
      recommendations: [
        'Registra tus niveles de estrés diariamente para identificar patrones',
        'Necesitas al menos 7 días de datos para análisis de tendencias confiables',
        'Incluye información sobre actividades y situaciones que afectan tu estrés',
        'No se pueden generar insights sin datos reales de estrés'
      ],
      highStressDaysCount: 0, // Cannot determine without data
    );
  }

  GoalAnalyticsModel _createDefaultGoalAnalytics() {
    return GoalAnalyticsModel(
      totalGoals: 0,
      completedGoals: 0,
      inProgressGoals: 0,
      completionRate: 0.0,
      completionByCategory: {},
      insights: [], // Empty list for insufficient data
      performanceTrend: 'insufficient_data',
      averageCompletionTime: 0.0,
      successFactors: [
        'Define metas claras y alcanzables',
        'Revisa y actualiza el progreso de tus metas regularmente',
        'Establece fechas límite realistas para tus objetivos'
      ],
    );
  }

  TemporalPatternModel _createDefaultTemporalPattern() {
    return TemporalPatternModel(
      hourlyPatterns: {}, // Empty indicates no data patterns found
      dailyPatterns: {}, // Empty indicates no data patterns found  
      monthlyTrends: {}, // Empty indicates no data patterns found
      optimalTimeOfDay: 'insufficient_data',
      weeklyPattern: 'insufficient_data', // More explicit than 'needs_more_data'
      insights: [
        TemporalInsight(
          pattern: 'insufficient_data',
          description: 'Se requieren al menos 14 días de datos para identificar patrones temporales confiables',
          recommendation: 'Registra actividades a diferentes horas del día para obtener insights',
          confidence: 0.0,
        ),
        TemporalInsight(
          pattern: 'no_data',
          description: 'No hay suficiente data temporal para generar análisis',
          recommendation: 'Continúa registrando tus actividades diarias',
          confidence: 0.0,
        ),
      ],
    );
  }

  // Enhanced insight generation methods with dynamic configuration
  List<String> _generateWellnessRecommendations(
    Map<String, double> scores, 
    double overall, 
    WellnessScoreConfig config,
    Map<String, dynamic> rawData
  ) {
    final recommendations = <String>[];
    final thresholds = config.wellnessThresholds;
    
    // Dynamic threshold for component recommendations (60% of excellent threshold)
    final componentThreshold = thresholds['excellent']! * 0.6;
    
    // Mood recommendations with data-driven insights
    if (scores['mood']! < componentThreshold) {
      final moodVariance = rawData['mood_stddev'] as double? ?? 0.0;
      if (moodVariance > 2.0) {
        recommendations.add('Tu estado de ánimo muestra alta variabilidad. Considera técnicas de regulación emocional y mantén una rutina estable');
      } else {
        recommendations.add('Considera actividades que mejoren tu estado de ánimo como ejercicio, tiempo en naturaleza o socialización');
      }
    }
    
    // Energy recommendations
    if (scores['energy']! < componentThreshold) {
      final energyVariance = rawData['energy_stddev'] as double? ?? 0.0;
      if (energyVariance > 2.0) {
        recommendations.add('Tus niveles de energía son inconsistentes. Revisa tus patrones de sueño, alimentación y actividad física');
      } else {
        recommendations.add('Optimiza tu sueño (7-9 horas), nutrición y considera hacer ejercicio regular para aumentar tu energía');
      }
    }
    
    // Stress recommendations with personalized approach
    if (scores['stress']! < componentThreshold) {
      recommendations.add('Practica técnicas de manejo del estrés como respiración profunda, meditación mindfulness o ejercicio físico');
    }
    
    // Sleep recommendations
    if (scores['sleep']! < componentThreshold) {
      recommendations.add('Establece una rutina de sueño consistente: acuéstate y levántate a la misma hora, evita pantallas antes de dormir');
    }
    
    // Anxiety-specific recommendations
    if (scores.containsKey('anxiety') && scores['anxiety']! < componentThreshold) {
      recommendations.add('Para manejar la ansiedad: practica técnicas de grounding, ejercicios de respiración y considera hablar con un profesional');
    }
    
    // Motivation recommendations
    if (scores.containsKey('motivation') && scores['motivation']! < componentThreshold) {
      recommendations.add('Aumenta tu motivación estableciendo metas pequeñas y alcanzables, celebra tus logros y busca actividades que disfrutes');
    }
    
    // Overall wellness recommendations
    if (overall >= thresholds['excellent']!) {
      recommendations.add('¡Excelente bienestar general! Mantén tus hábitos saludables actuales y considera ser un ejemplo para otros');
    } else if (overall >= thresholds['good']!) {
      recommendations.add('Buen nivel de bienestar. Identifica las áreas más bajas y enfócate en mejorarlas gradualmente');
    } else if (overall >= thresholds['average']!) {
      recommendations.add('Tu bienestar está en nivel promedio. Prioriza las 2-3 áreas con menor puntaje para obtener mejores resultados');
    } else {
      recommendations.add('Tu bienestar necesita atención. Considera comenzar con cambios pequeños en sueño y actividad física, y busca apoyo si es necesario');
    }
    
    // Data quality recommendations
    final totalEntries = rawData['total_entries'] as int? ?? 0;
    if (totalEntries < config.minimumDataPoints * 2) {
      recommendations.add('Registra datos más frecuentemente para obtener recomendaciones más precisas y personalizadas');
    }
    
    return recommendations.isNotEmpty ? recommendations : ['Continúa registrando tus datos para obtener recomendaciones personalizadas'];
  }
  
  /// Calculate data quality score based on completeness and consistency
  double _calculateDataQuality(Map<String, dynamic> data, int totalEntries) {
    if (totalEntries == 0) return 0.0;
    
    // Calculate completeness score (how many different metrics are recorded)
    final metricsWithData = [
      data['mood_entries'],
      data['stress_entries'], 
      data['anxiety_entries']
    ].where((count) => (count as int?) != null && (count as int) > 0).length;
    
    final completenessScore = metricsWithData / 3.0; // 3 main metrics
    
    // Calculate consistency score based on variance
    final moodVariance = data['mood_stddev'] as double? ?? 0.0;
    final energyVariance = data['energy_stddev'] as double? ?? 0.0;
    final avgVariance = (moodVariance + energyVariance) / 2.0;
    
    // Lower variance indicates more consistent data (better quality)
    final consistencyScore = math.max(0.0, 1.0 - (avgVariance / 5.0));
    
    // Combined quality score
    return (completenessScore * 0.6) + (consistencyScore * 0.4);
  }

  String _generateCorrelationInsight(String activity, String target, double correlation, String type) {
    final strength = correlation.abs() >= 0.7 ? 'fuerte' : correlation.abs() >= 0.3 ? 'moderada' : 'débil';
    final direction = correlation > 0 ? 'positiva' : 'negativa';
    
    return 'Se detectó una correlación $strength $direction entre $activity y $target (${(correlation * 100).toStringAsFixed(0)}%)';
  }

  String _generateCorrelationRecommendation(String activity, String target, double correlation) {
    if (correlation > 0.5) {
      return 'Incrementa $activity para mejorar tu $target';
    } else if (correlation < -0.5) {
      return 'Reduce $activity para mejorar tu $target';
    } else {
      return 'El impacto de $activity en $target es limitado, considera otros factores';
    }
  }

  // Additional helper methods would go here...
  // (Due to length constraints, showing key structure)

  Future<Map<String, dynamic>> _generateSummaryMetrics(int userId, int periodDays) async {
    return {
      'period_days': periodDays,
      'analysis_date': DateTime.now().toIso8601String(),
      'user_id': userId,
    };
  }

  List<String> _generateKeyInsights(
    WellnessScoreModel wellness,
    List<ActivityCorrelationModel> correlations,
    SleepPatternModel sleep,
    StressManagementModel stress,
    GoalAnalyticsModel goals,
  ) {
    final insights = <String>[];
    
    if (wellness.overallScore >= 8.0) {
      insights.add('Tu bienestar general está en excelente estado');
    } else if (wellness.overallScore < 5.0) {
      insights.add('Hay oportunidades importantes para mejorar tu bienestar');
    }
    
    final strongCorrelations = correlations.where((c) => c.correlationStrength.abs() > 0.6);
    if (strongCorrelations.isNotEmpty) {
      insights.add('Se encontraron ${strongCorrelations.length} correlaciones fuertes en tus actividades');
    }
    
    if (sleep.averageSleepHours < 7.0) {
      insights.add('Podrías beneficiarte de más horas de sueño');
    }
    
    if (stress.averageStressLevel > 6.0) {
      insights.add('Tus niveles de estrés están por encima del promedio');
    }
    
    if (goals.completionRate > 0.7) {
      insights.add('¡Excelente progreso en tus metas!');
    }
    
    return insights.isNotEmpty ? insights : ['Continúa registrando datos para generar insights personalizados'];
  }

  // ============================================================================
  // COMPREHENSIVE PRODUCTIVITY ANALYTICS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeProductivityPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        work_productivity,
        focus_level,
        creative_energy,
        energy_level,
        stress_level,
        meditation_minutes,
        exercise_minutes,
        sleep_hours,
        sleep_quality,
        screen_time_hours,
        strftime('%w', entry_date) as day_of_week,
        strftime('%H', created_at, 'unixepoch') as hour
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND work_productivity IS NOT NULL
      ORDER BY entry_date DESC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'insights': [
          'No hay datos de productividad disponibles',
          'Registra tu nivel de productividad y concentración diariamente'
        ],
        'peak_hours': [],
        'recommendations': [
          'Necesitas al menos 7 días de datos para identificar patrones de productividad',
          'Incluye información sobre tu trabajo y nivel de concentración',
          'Registra la hora en que te sientes más productivo'
        ],
        'productivity_score': 0.0,
        'status': 'insufficient_data'
      };
    }

    // Analyze productivity by hour
    final productivityByHour = <int, List<double>>{};
    final focusByHour = <int, List<double>>{};
    
    for (final row in result) {
      final hourStr = row['hour']?.toString();
      final productivity = (row['work_productivity'] as num?)?.toDouble();
      final focus = (row['focus_level'] as num?)?.toDouble();
      
      // Validate data quality
      if (productivity == null || focus == null || 
          !productivity.isFinite || !focus.isFinite ||
          productivity < 0 || productivity > 10 ||
          focus < 0 || focus > 10) {
        continue; // Skip invalid data
      }
      
      int hour;
      if (hourStr != null) {
        hour = int.tryParse(hourStr) ?? -1;
        if (hour < 0 || hour > 23) {
          continue; // Skip invalid hours
        }
      } else {
        continue; // Skip entries without time data
      }
      
      productivityByHour.putIfAbsent(hour, () => []).add(productivity);
      focusByHour.putIfAbsent(hour, () => []).add(focus);
    }

    // Find peak productivity hours
    final peakHours = <Map<String, dynamic>>[];
    productivityByHour.forEach((hour, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      if (avg >= 7.0) {
        peakHours.add({
          'hour': hour,
          'productivity': avg,
          'sessions': values.length,
        });
      }
    });
    peakHours.sort((a, b) => (b['productivity'] as double).compareTo(a['productivity'] as double));

    // Analyze productivity factors
    final insights = <String>[];
    final recommendations = <String>[];

    // Sleep impact analysis
    final sleepProductivityCorr = _analyzeFactorCorrelation(result, 'sleep_hours', 'work_productivity');
    if (sleepProductivityCorr > 0.3) {
      insights.add('Dormir más horas mejora tu productividad (${(sleepProductivityCorr * 100).toStringAsFixed(0)}% correlación)');
      if (_getAverageValue(result, 'sleep_hours') < 7.0) {
        recommendations.add('Intenta dormir al menos 7-8 horas para maximizar tu productividad');
      }
    }

    // Exercise impact
    final exerciseProductivityCorr = _analyzeFactorCorrelation(result, 'exercise_minutes', 'work_productivity');
    if (exerciseProductivityCorr > 0.2) {
      insights.add('El ejercicio aumenta tu productividad (${(exerciseProductivityCorr * 100).toStringAsFixed(0)}% correlación)');
      recommendations.add('Incluye 20-30 minutos de ejercicio antes del trabajo');
    }

    // Meditation impact
    final meditationFocusCorr = _analyzeFactorCorrelation(result, 'meditation_minutes', 'focus_level');
    if (meditationFocusCorr > 0.25) {
      insights.add('La meditación mejora tu capacidad de concentración');
      recommendations.add('Dedica 10-15 minutos a meditar antes de tareas importantes');
    }

    // Screen time analysis
    final screenProductivityCorr = _analyzeFactorCorrelation(result, 'screen_time_hours', 'work_productivity');
    if (screenProductivityCorr < -0.2) {
      insights.add('Demasiado tiempo de pantalla reduce tu productividad');
      recommendations.add('Limita el tiempo de pantalla no relacionado con trabajo');
    }

    return {
      'peak_hours': peakHours.take(3).toList(),
      'insights': insights,
      'recommendations': recommendations,
      'productivity_factors': {
        'sleep_correlation': sleepProductivityCorr,
        'exercise_correlation': exerciseProductivityCorr,
        'meditation_correlation': meditationFocusCorr,
        'screen_correlation': screenProductivityCorr,
      }
    };
  }

  // ============================================================================
  // ADVANCED MOOD STABILITY ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeMoodStability(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        mood_score,
        emotional_stability,
        stress_level,
        anxiety_level,
        social_interaction,
        physical_activity,
        meditation_minutes,
        weather_mood_impact,
        entry_date
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND mood_score IS NOT NULL
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.length < 5) {
      return {
        'stability_score': 5.0,
        'insights': [
          'Necesitas al menos 5 días de datos para analizar la estabilidad del ánimo',
          'Registra tu estado de ánimo diariamente para detectar patrones emocionales'
        ],
        'triggers': [],
        'recommendations': [
          'Continúa registrando tu estado de ánimo diariamente',
          'Incluye notas sobre eventos o situaciones que afectan tu ánimo',
          'Mantén consistencia en tus registros para mejores insights'
        ],
        'mood_variance': 0.0,
        'status': 'insufficient_data'
      };
    }

    // Calculate mood variance (stability indicator)
    final moodScores = result.map((r) => (r['mood_score'] as num).toDouble()).toList();
    final moodVariance = _calculateVariance(moodScores);
    final stabilityScore = math.max(0.0, 10.0 - (moodVariance * 2));

    // Detect mood drops and their triggers
    final moodTriggers = <Map<String, dynamic>>[];
    for (int i = 1; i < result.length; i++) {
      final prevMood = (result[i-1]['mood_score'] as num).toDouble();
      final currMood = (result[i]['mood_score'] as num).toDouble();
      
      if (prevMood - currMood >= 2.0) { // Significant mood drop
        final triggers = <String>[];
        
        // Check potential triggers
        final stress = (result[i]['stress_level'] as num?)?.toDouble() ?? 5.0;
        final anxiety = (result[i]['anxiety_level'] as num?)?.toDouble() ?? 5.0;
        final social = (result[i]['social_interaction'] as num?)?.toDouble() ?? 5.0;
        final exercise = (result[i]['physical_activity'] as num?)?.toDouble() ?? 5.0;
        
        if (stress >= 7.0) triggers.add('Alto estrés');
        if (anxiety >= 7.0) triggers.add('Alta ansiedad');
        if (social <= 3.0) triggers.add('Baja interacción social');
        if (exercise <= 3.0) triggers.add('Poca actividad física');
        
        if (triggers.isNotEmpty) {
          moodTriggers.add({
            'date': result[i]['entry_date'],
            'mood_drop': prevMood - currMood,
            'triggers': triggers,
          });
        }
      }
    }

    // Analyze protective factors
    final protectiveFactors = <String>[];
    final highMoodDays = result.where((r) => (r['mood_score'] as num) >= 7).toList();
    
    if (highMoodDays.isNotEmpty) {
      final avgSocial = _getAverageFromSubset(highMoodDays, 'social_interaction');
      final avgExercise = _getAverageFromSubset(highMoodDays, 'physical_activity');
      final avgMeditation = _getAverageFromSubset(highMoodDays, 'meditation_minutes');
      
      if (avgSocial >= 6.0) protectiveFactors.add('Interacción social regular');
      if (avgExercise >= 6.0) protectiveFactors.add('Actividad física constante');
      if (avgMeditation >= 10.0) protectiveFactors.add('Práctica de meditación');
    }

    return {
      'stability_score': stabilityScore,
      'mood_variance': moodVariance,
      'mood_triggers': moodTriggers.take(5).toList(),
      'protective_factors': protectiveFactors,
      'insights': _generateMoodStabilityInsights(stabilityScore, moodVariance, protectiveFactors),
      'recommendations': _generateMoodStabilityRecommendations(stabilityScore, moodTriggers, protectiveFactors),
    };
  }

  // ============================================================================
  // LIFESTYLE BALANCE ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeLifestyleBalance(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    print('🔄 DEBUG LIFESTYLE BALANCE ANALYSIS:');
    print('   User ID: $userId, Period: $periodDays days');
    print('   Date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
    
    final result = await db.rawQuery('''
      SELECT 
        work_productivity,
        social_interaction,
        physical_activity,
        creative_energy,
        meditation_minutes,
        exercise_minutes,
        sleep_hours,
        screen_time_hours,
        water_intake,
        life_satisfaction,
        emotional_stability
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      ORDER BY entry_date DESC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    print('   Found ${result.length} entries');

    if (result.isEmpty) {
      return {
        'balance_score': 5.0,
        'areas': {},
        'recommendations': [
          'Registra datos en diferentes áreas de tu vida para analizar el equilibrio',
          'Incluye información sobre trabajo, actividad física, vida social y bienestar',
          'Necesitas al menos 10 días de datos para un análisis de balance confiable'
        ],
        'insights': [
          'No hay suficientes datos para evaluar tu equilibrio de vida',
          'Registra actividades en diferentes categorías para obtener insights'
        ],
        'status': 'insufficient_data'
      };
    }

    // Calculate balance scores for different life areas
    final workScore = _getAverageValue(result, 'work_productivity');
    final socialScore = _getAverageValue(result, 'social_interaction');
    final physicalScore = _getAverageValue(result, 'physical_activity');
    final creativityScore = _getAverageValue(result, 'creative_energy');
    final wellnessScore = _getAverageValue(result, 'life_satisfaction');
    
    // Calculate quantitative wellness metrics
    final avgSleep = _getAverageValue(result, 'sleep_hours');
    final avgExercise = _getAverageValue(result, 'exercise_minutes');
    final avgMeditation = _getAverageValue(result, 'meditation_minutes');
    final avgWater = _getAverageValue(result, 'water_intake');
    final avgScreen = _getAverageValue(result, 'screen_time_hours');

    print('   Raw averages from database:');
    print('     Work: $workScore, Social: $socialScore, Physical: $physicalScore');
    print('     Creativity: $creativityScore, Wellness: $wellnessScore');
    print('     Sleep: ${avgSleep}h, Exercise: ${avgExercise}min, Meditation: ${avgMeditation}min');
    print('     Water: ${avgWater} glasses, Screen: ${avgScreen}h');

    // Normalize quantitative metrics to 1-10 scale
    final sleepNormalized = _normalizeSleepScore(avgSleep);
    final exerciseNormalized = _normalizeExerciseScore(avgExercise);
    final meditationNormalized = _normalizeMeditationScore(avgMeditation);
    final hydrationNormalized = _normalizeHydrationScore(avgWater);
    final screenNormalized = _normalizeScreenScore(avgScreen);

    print('   Normalized scores:');
    print('     Sleep: $sleepNormalized, Exercise: $exerciseNormalized');
    print('     Meditation: $meditationNormalized, Hydration: $hydrationNormalized, Screen: $screenNormalized');

    final areas = {
      'trabajo': workScore,
      'social': socialScore,
      'fisico': physicalScore,
      'creatividad': creativityScore,
      'bienestar': wellnessScore,
      'sueño': sleepNormalized,
      'ejercicio': exerciseNormalized,
      'meditacion': meditationNormalized,
      'hidratacion': hydrationNormalized,
      'pantallas': screenNormalized,
    };

    print('   Final area scores: $areas');

    // Calculate overall balance score (penalize extreme imbalances)
    final scores = areas.values.where((s) => s > 0).toList();
    final balanceVariance = _calculateVariance(scores);
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final balanceScore = math.max(1.0, avgScore - (balanceVariance * 0.5));

    print('   Balance calculation:');
    print('     Valid scores: $scores');
    print('     Average score: $avgScore');
    print('     Balance variance: $balanceVariance');
    print('     Final balance score: $balanceScore');

    // Identify imbalanced areas
    final recommendations = <String>[];
    areas.forEach((area, score) {
      if (score < 4.0) {
        recommendations.add(_getAreaImprovementRecommendation(area, score));
      } else if (score > 8.0 && _shouldModerateArea(area)) {
        recommendations.add(_getAreaModerationRecommendation(area));
      }
    });

    return {
      'balance_score': balanceScore,
      'areas': areas,
      'balance_variance': balanceVariance,
      'recommendations': recommendations,
      'insights': _generateBalanceInsights(areas, balanceScore),
    };
  }

  // ============================================================================
  // ENERGY PATTERNS ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeEnergyPatterns(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        energy_level,
        sleep_hours,
        sleep_quality,
        physical_activity,
        exercise_minutes,
        water_intake,
        stress_level,
        meditation_minutes,
        strftime('%H', created_at, 'unixepoch') as hour,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND energy_level IS NOT NULL
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'energy_pattern': 'insufficient_data',
        'peak_times': [],
        'energy_boosters': [],
        'recommendations': [
          'Registra tu nivel de energía a diferentes horas del día',
          'Necesitas al menos 10 días de datos para identificar patrones de energía',
          'Incluye factores como sueño, ejercicio e hidratación en tus registros'
        ],
        'insights': [
          'No hay datos suficientes para analizar tus patrones de energía',
          'Registra tu nivel de energía junto con actividades y horarios'
        ],
        'status': 'insufficient_data'
      };
    }

    // Analyze energy by time of day with improved error handling
    final energyByHour = <int, List<double>>{};
    int invalidTimeEntries = 0;
    
    for (final row in result) {
      final hourStr = row['hour']?.toString();
      final energy = (row['energy_level'] as num?)?.toDouble();
      
      if (energy == null || !energy.isFinite || energy < 0 || energy > 10) {
        continue; // Skip invalid energy values
      }
      
      int hour;
      if (hourStr != null) {
        hour = int.tryParse(hourStr) ?? -1;
        if (hour < 0 || hour > 23) {
          invalidTimeEntries++;
          continue; // Skip invalid hours
        }
      } else {
        invalidTimeEntries++;
        continue; // Skip entries without time data
      }
      
      energyByHour.putIfAbsent(hour, () => []).add(energy);
    }
    
    // Check if we have enough valid data
    if (energyByHour.isEmpty || invalidTimeEntries > result.length * 0.5) {
      return {
        'energy_pattern': 'insufficient_data',
        'peak_times': [],
        'energy_boosters': [],
        'recommendations': [
          'Muchos registros tienen datos de hora inválidos o faltan',
          'Asegúrate de registrar tu energía con la hora correcta',
          'Necesitas datos válidos durante al menos 7 días diferentes'
        ],
        'insights': [
          'Datos de tiempo insuficientes o inválidos para analizar patrones de energía',
          'Verifica que tus registros incluyan información de hora precisa'
        ],
        'status': 'invalid_data'
      };
    }

    // Calculate average energy per hour
    final hourlyAverages = <int, double>{};
    energyByHour.forEach((hour, values) {
      hourlyAverages[hour] = values.reduce((a, b) => a + b) / values.length;
    });

    // Identify peak energy times
    final peakTimes = <Map<String, dynamic>>[];
    hourlyAverages.forEach((hour, avgEnergy) {
      if (avgEnergy >= 7.0) {
        peakTimes.add({
          'hour': hour,
          'energy': avgEnergy,
          'time_label': _getTimeLabel(hour),
        });
      }
    });
    peakTimes.sort((a, b) => (b['energy'] as double).compareTo(a['energy'] as double));

    // Analyze energy boosters (factors that correlate with high energy)
    final energyBoosters = <Map<String, dynamic>>[];
    
    // Sleep correlation
    final sleepEnergyCorr = _analyzeFactorCorrelation(result, 'sleep_hours', 'energy_level');
    if (sleepEnergyCorr > 0.2) {
      energyBoosters.add({
        'factor': 'Horas de sueño',
        'correlation': sleepEnergyCorr,
        'recommendation': 'Mantén 7-8 horas de sueño para mejor energía',
      });
    }

    // Exercise correlation
    final exerciseEnergyCorr = _analyzeFactorCorrelation(result, 'physical_activity', 'energy_level');
    if (exerciseEnergyCorr > 0.15) {
      energyBoosters.add({
        'factor': 'Actividad física',
        'correlation': exerciseEnergyCorr,
        'recommendation': 'El ejercicio regular aumenta tus niveles de energía',
      });
    }

    // Hydration correlation
    final waterEnergyCorr = _analyzeFactorCorrelation(result, 'water_intake', 'energy_level');
    if (waterEnergyCorr > 0.1) {
      energyBoosters.add({
        'factor': 'Hidratación',
        'correlation': waterEnergyCorr,
        'recommendation': 'Mantente bien hidratado durante el día',
      });
    }

    // Stress correlation (negative)
    final stressEnergyCorr = _analyzeFactorCorrelation(result, 'stress_level', 'energy_level');
    if (stressEnergyCorr < -0.2) {
      energyBoosters.add({
        'factor': 'Manejo del estrés',
        'correlation': stressEnergyCorr.abs(),
        'recommendation': 'Reducir el estrés mejora significativamente tu energía',
      });
    }

    // Determine energy pattern with statistical significance
    final morningEnergy = _getAverageEnergyForTimeRange(hourlyAverages, 6, 12);
    final afternoonEnergy = _getAverageEnergyForTimeRange(hourlyAverages, 12, 18);
    final eveningEnergy = _getAverageEnergyForTimeRange(hourlyAverages, 18, 22);
    
    // Calculate overall variance to determine if differences are significant
    final allPeriodValues = [morningEnergy, afternoonEnergy, eveningEnergy]
        .where((v) => v > 0)
        .toList();
    
    String energyPattern;
    if (allPeriodValues.length < 2) {
      energyPattern = 'insufficient_data';
    } else {
      final periodVariance = _calculateVariance(allPeriodValues);
      final significanceThreshold = math.sqrt(periodVariance) * 0.5; // 0.5 standard deviations
      
      if (significanceThreshold < 0.3) {
        energyPattern = 'consistent'; // Very little variation
      } else if (morningEnergy > afternoonEnergy + significanceThreshold && 
                 morningEnergy > eveningEnergy + significanceThreshold) {
        energyPattern = 'morning_person';
      } else if (afternoonEnergy > morningEnergy + significanceThreshold && 
                 afternoonEnergy > eveningEnergy + significanceThreshold) {
        energyPattern = 'afternoon_peak';
      } else if (eveningEnergy > morningEnergy + significanceThreshold && 
                 eveningEnergy > afternoonEnergy + significanceThreshold) {
        energyPattern = 'evening_person';
      } else {
        energyPattern = 'balanced';
      }
    }

    return {
      'energy_pattern': energyPattern,
      'peak_times': peakTimes.take(3).toList(),
      'energy_boosters': energyBoosters,
      'hourly_averages': hourlyAverages,
      'pattern_analysis': {
        'morning': morningEnergy,
        'afternoon': afternoonEnergy,
        'evening': eveningEnergy,
      },
      'recommendations': _generateEnergyRecommendations(energyPattern, energyBoosters),
    };
  }

  // ============================================================================
  // SOCIAL WELLNESS ANALYSIS
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeSocialWellness(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        social_interaction,
        social_battery,
        mood_score,
        emotional_stability,
        stress_level,
        anxiety_level,
        strftime('%w', entry_date) as day_of_week
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
        AND social_interaction IS NOT NULL
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'social_wellness_score': 5.0,
        'patterns': {},
        'recommendations': [
          'Registra tu nivel de interacción social diariamente',
          'Incluye información sobre cómo te sientes después de actividades sociales',
          'Necesitas al menos 7 días de datos para analizar tu bienestar social'
        ],
        'insights': [
          'No hay suficientes datos para evaluar tu bienestar social',
          'Registra tanto actividades sociales como momentos de soledad'
        ],
        'social_battery_pattern': 'unknown',
        'status': 'insufficient_data'
      };
    }

    // Calculate social wellness metrics
    final avgSocial = _getAverageValue(result, 'social_interaction');
    final avgSocialBattery = _getAverageValue(result, 'social_battery');
    final socialWellnessScore = (avgSocial + avgSocialBattery) / 2.0;

    // Analyze social impact on mood
    final socialMoodCorrelation = _analyzeFactorCorrelation(result, 'social_interaction', 'mood_score');
    final socialStressCorrelation = _analyzeFactorCorrelation(result, 'social_interaction', 'stress_level');

    // Weekly social patterns
    final weeklyPatterns = <String, double>{};
    final dayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    
    for (int i = 0; i < 7; i++) {
      final dayData = result.where((r) => r['day_of_week'] == i.toString()).toList();
      if (dayData.isNotEmpty) {
        final dayAvgSocial = _getAverageFromSubset(dayData, 'social_interaction');
        weeklyPatterns[dayNames[i]] = dayAvgSocial;
      }
    }

    // Social preferences analysis
    final socialPreferences = <String>[];
    final highSocialDays = result.where((r) => (r['social_interaction'] as num) >= 7).toList();
    final lowSocialDays = result.where((r) => (r['social_interaction'] as num) <= 3).toList();

    if (highSocialDays.isNotEmpty && lowSocialDays.isNotEmpty) {
      final highSocialMood = _getAverageFromSubset(highSocialDays, 'mood_score');
      final lowSocialMood = _getAverageFromSubset(lowSocialDays, 'mood_score');
      
      if (highSocialMood > lowSocialMood + 1.0) {
        socialPreferences.add('Extrovertido: La interacción social mejora tu estado de ánimo');
      } else if (lowSocialMood > highSocialMood + 1.0) {
        socialPreferences.add('Introvertido: Valoras el tiempo a solas para recargar energías');
      } else {
        socialPreferences.add('Ambivertido: Disfrutas tanto del tiempo social como del tiempo a solas');
      }
    }

    // Generate insights and recommendations
    final insights = <String>[];
    final recommendations = <String>[];

    if (socialMoodCorrelation > 0.3) {
      insights.add('La interacción social tiene un fuerte impacto positivo en tu estado de ánimo');
      recommendations.add('Programa actividades sociales regulares para mantener tu bienestar');
    } else if (socialMoodCorrelation < -0.2) {
      insights.add('Demasiada interacción social podría estar agotándote');
      recommendations.add('Equilibra tu tiempo social con momentos de soledad para recargar');
    }

    if (avgSocialBattery < 5.0) {
      recommendations.add('Tu batería social está baja - considera tomar descansos sociales');
    }

    return {
      'social_wellness_score': socialWellnessScore,
      'weekly_patterns': weeklyPatterns,
      'social_preferences': socialPreferences,
      'correlations': {
        'mood': socialMoodCorrelation,
        'stress': socialStressCorrelation,
      },
      'insights': insights,
      'recommendations': recommendations,
    };
  }

  // ============================================================================
  // COMPREHENSIVE HABIT TRACKING
  // ============================================================================
  
  Future<Map<String, dynamic>> analyzeHabitConsistency(int userId, int periodDays) async {
    final db = await _databaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: periodDays));
    
    final result = await db.rawQuery('''
      SELECT 
        meditation_minutes,
        exercise_minutes,
        water_intake,
        sleep_hours,
        physical_activity,
        entry_date
      FROM daily_entries 
      WHERE user_id = ? AND entry_date BETWEEN ? AND ?
      ORDER BY entry_date ASC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    if (result.isEmpty) {
      return {
        'habits': {},
        'overall_consistency': 0.0,
        'streaks': {},
        'recommendations': [
          'Registra hábitos como meditación, ejercicio e hidratación diariamente',
          'Necesitas al menos 14 días de datos para analizar la consistencia de hábitos',
          'Establece metas realistas para cada hábito que quieras desarrollar'
        ],
        'insights': [
          'No hay datos suficientes para evaluar la consistencia de tus hábitos',
          'Comienza registrando hábitos simples como beber agua o hacer ejercicio'
        ],
        'consistency_score': 0.0,
        'status': 'insufficient_data'
      };
    }

    final habits = <String, Map<String, dynamic>>{};

    // Calculate dynamic targets based on user's historical data and configuration
    final dynamicTargets = await _calculateDynamicTargets(userId, result);
    
    // Analyze meditation habit
    habits['meditation'] = _analyzeHabitPattern(
      result, 
      'meditation_minutes', 
      'Meditación',
      targetValue: dynamicTargets['meditation'] ?? 10.0,
      isMinutes: true
    );

    // Analyze exercise habit
    habits['exercise'] = _analyzeHabitPattern(
      result, 
      'exercise_minutes', 
      'Ejercicio',
      targetValue: dynamicTargets['exercise'] ?? 30.0,
      isMinutes: true
    );

    // Analyze hydration habit
    habits['hydration'] = _analyzeHabitPattern(
      result, 
      'water_intake', 
      'Hidratación',
      targetValue: dynamicTargets['hydration'] ?? 8.0,
      isGlasses: true
    );

    // Analyze sleep habit
    habits['sleep'] = _analyzeHabitPattern(
      result, 
      'sleep_hours', 
      'Sueño',
      targetValue: dynamicTargets['sleep'] ?? 7.5,
      isHours: true
    );

    // Analyze physical activity habit
    habits['physical_activity'] = _analyzeHabitPattern(
      result, 
      'physical_activity', 
      'Actividad Física',
      targetValue: dynamicTargets['physical_activity'] ?? 6.0,
      isRating: true
    );

    // Calculate overall consistency
    final consistencyScores = habits.values.map((h) => h['consistency'] as double).toList();
    final overallConsistency = consistencyScores.reduce((a, b) => a + b) / consistencyScores.length;

    // Generate habit insights
    final insights = <String>[];
    final recommendations = <String>[];

    habits.forEach((key, habit) {
      final consistency = habit['consistency'] as double;
      final name = habit['name'] as String;
      
      if (consistency >= 0.8) {
        insights.add('Excelente consistencia en $name (${(consistency * 100).toStringAsFixed(0)}%)');
      } else if (consistency >= 0.6) {
        insights.add('Buena consistencia en $name, pero hay espacio para mejorar');
        recommendations.add('Intenta ser más consistente con $name');
      } else {
        insights.add('$name necesita más atención y consistencia');
        recommendations.add('Establece recordatorios para $name y comienza con metas pequeñas');
      }
    });

    return {
      'habits': habits,
      'overall_consistency': overallConsistency,
      'insights': insights,
      'recommendations': recommendations,
      'best_habit': _findBestHabit(habits),
      'needs_improvement': _findHabitsNeedingImprovement(habits),
    };
  }

  // ============================================================================
  // HELPER METHODS FOR NEW ANALYTICS
  // ============================================================================

  double _analyzeFactorCorrelation(List<Map<String, Object?>> data, String factor, String target) {
    final factorValues = <double>[];
    final targetValues = <double>[];
    
    for (final row in data) {
      final factorVal = (row[factor] as num?)?.toDouble();
      final targetVal = (row[target] as num?)?.toDouble();
      
      if (factorVal != null && targetVal != null) {
        factorValues.add(factorVal);
        targetValues.add(targetVal);
      }
    }
    
    if (factorValues.length < 3) return 0.0;
    return _calculatePearsonCorrelation(factorValues, targetValues);
  }

  double _getAverageValue(List<Map<String, Object?>> data, String column) {
    final values = data
        .map((r) => (r[column] as num?)?.toDouble())
        .where((v) => v != null)
        .cast<double>()
        .toList();
    
    return values.isEmpty ? 5.0 : values.reduce((a, b) => a + b) / values.length;
  }

  double _getAverageFromSubset(List<Map<String, Object?>> data, String column) {
    return _getAverageValue(data, column);
  }

  double _normalizeSleepScore(double hours) {
    if (hours >= 7.5 && hours <= 9.0) return 10.0;
    if (hours >= 7.0 && hours < 7.5) return 8.0;
    if (hours >= 6.5 && hours < 7.0) return 6.0;
    if (hours >= 6.0 && hours < 6.5) return 4.0;
    return 2.0;
  }

  double _normalizeExerciseScore(double minutes) {
    if (minutes >= 30) return 10.0;
    if (minutes >= 20) return 8.0;
    if (minutes >= 10) return 6.0;
    if (minutes > 0) return 4.0;
    return 1.0;
  }

  double _normalizeMeditationScore(double minutes) {
    if (minutes >= 20) return 10.0;
    if (minutes >= 15) return 8.0;
    if (minutes >= 10) return 7.0;
    if (minutes >= 5) return 5.0;
    if (minutes > 0) return 3.0;
    return 1.0;
  }

  double _normalizeHydrationScore(double glasses) {
    if (glasses >= 8) return 10.0;
    if (glasses >= 6) return 8.0;
    if (glasses >= 4) return 6.0;
    if (glasses >= 2) return 4.0;
    return 2.0;
  }

  double _normalizeScreenScore(double hours) {
    // Less screen time is better (inverted)
    if (hours <= 2) return 10.0;
    if (hours <= 4) return 8.0;
    if (hours <= 6) return 6.0;
    if (hours <= 8) return 4.0;
    return 2.0;
  }

  String _getTimeLabel(int hour) {
    if (hour >= 6 && hour < 12) return 'Mañana';
    if (hour >= 12 && hour < 18) return 'Tarde';
    if (hour >= 18 && hour < 22) return 'Noche';
    return 'Madrugada';
  }

  double _getAverageEnergyForTimeRange(Map<int, double> hourlyData, int startHour, int endHour) {
    final values = <double>[];
    for (int hour = startHour; hour < endHour; hour++) {
      if (hourlyData.containsKey(hour)) {
        values.add(hourlyData[hour]!);
      }
    }
    return values.isEmpty ? 5.0 : values.reduce((a, b) => a + b) / values.length;
  }

  Map<String, dynamic> _analyzeHabitPattern(
    List<Map<String, Object?>> data, 
    String column, 
    String name, {
    required double targetValue,
    bool isMinutes = false,
    bool isHours = false,
    bool isGlasses = false,
    bool isRating = false,
  }) {
    final values = data
        .map((r) => (r[column] as num?)?.toDouble())
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) {
      return {
        'name': name,
        'consistency': 0.0,
        'average': 0.0,
        'target_met_days': 0,
        'streak': 0,
      };
    }

    final average = values.reduce((a, b) => a + b) / values.length;
    final targetMetDays = values.where((v) => v >= targetValue).length;
    final consistency = targetMetDays / values.length;

    // Calculate current streak with proper chronological handling
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    
    // Process data chronologically (assuming data is ordered by entry_date)
    for (int i = 0; i < values.length; i++) {
      if (values[i] >= targetValue) {
        tempStreak++;
        longestStreak = math.max(longestStreak, tempStreak);
      } else {
        tempStreak = 0;
      }
    }
    
    // Calculate current streak from the end
    for (int i = values.length - 1; i >= 0; i--) {
      if (values[i] >= targetValue) {
        currentStreak++;
      } else {
        break;
      }
    }

    return {
      'name': name,
      'consistency': consistency,
      'average': average,
      'target_met_days': targetMetDays,
      'total_days': values.length,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'target': targetValue,
    };
  }

  /// Calculate dynamic targets based on user's historical performance and configuration
  Future<Map<String, double>> _calculateDynamicTargets(
    int userId, 
    List<Map<String, Object?>> data
  ) async {
    final config = await _getUserConfig(userId);
    final targets = <String, double>{};
    
    if (data.isEmpty) {
      // Use configuration-based defaults
      config.habitConfigs.forEach((habitName, habitConfig) {
        targets[habitName] = habitConfig.getHabitTarget('recommended');
      });
      return targets;
    }
    
    config.habitConfigs.forEach((habitName, habitConfig) {
      final columnName = habitConfig.column;
      final values = data
          .map((r) => (r[columnName] as num?)?.toDouble())
          .where((v) => v != null && v > 0)
          .cast<double>()
          .toList();
      
      if (values.length >= 5) {
        values.sort();
        // Use 75th percentile as achievable goal
        final percentile75Index = (values.length * 0.75).floor();
        var target = values[math.min(percentile75Index, values.length - 1)];
        
        // Apply configuration-based bounds
        final configTargets = habitConfig.targets;
        final minTarget = configTargets['minimum'] ?? configTargets.values.reduce(math.min);
        final maxTarget = configTargets['maximum'] ?? configTargets.values.reduce(math.max);
        
        target = math.max(minTarget, math.min(maxTarget, target));
        
        // For inverted habits (like screen time), adjust the logic
        if (habitConfig.isInverted) {
          // For inverted habits, use 25th percentile (lower is better)
          final percentile25Index = (values.length * 0.25).floor();
          target = values[math.max(0, percentile25Index)];
        }
        
        targets[habitName] = target;
      } else {
        // Use configured recommended target for insufficient data
        targets[habitName] = habitConfig.targets['recommended'] ?? 
                             habitConfig.targets.values.first;
      }
    });
    
    return targets;
  }

  /// Get habit target using configuration
  double _getHabitTarget(String habitName, AnalyticsConfig config, {String level = 'recommended'}) {
    final habitConfig = config.habitConfigs[habitName];
    if (habitConfig != null) {
      return habitConfig.targets[level] ?? habitConfig.targets.values.first;
    }
    
    // Fallback defaults
    final defaults = {
      'meditation': 10.0,
      'exercise': 30.0,
      'hydration': 8.0,
      'sleep': 7.5,
      'physical_activity': 6.0,
    };
    
    return defaults[habitName] ?? 5.0;
  }

  /// Normalize habit score using configuration
  double _normalizeHabitScore(double value, HabitConfig habitConfig) {
    final ranges = habitConfig.scoreRanges;
    
    if (habitConfig.isInverted) {
      // For inverted habits (less is better), reverse the logic
      if (value <= ranges['excellent']!) return 10.0;
      if (value <= ranges['good']!) return 8.0;
      if (value <= ranges['average']!) return 6.0;
      if (value <= ranges['poor']!) return 4.0;
      return 2.0;
    } else {
      // For normal habits (more is better)
      if (value >= ranges['excellent']!) return 10.0;
      if (value >= ranges['good']!) return 8.0;
      if (value >= ranges['average']!) return 6.0;
      if (value >= ranges['poor']!) return 4.0;
      if (value > 0) return 2.0;
      return 1.0;
    }
  }

  Map<String, dynamic> _findBestHabit(Map<String, Map<String, dynamic>> habits) {
    Map<String, dynamic>? best;
    double bestScore = 0.0;
    
    habits.forEach((key, habit) {
      final consistency = habit['consistency'] as double;
      if (consistency > bestScore) {
        bestScore = consistency;
        best = habit;
      }
    });
    
    return best ?? {'name': 'Ninguno', 'consistency': 0.0};
  }

  List<String> _findHabitsNeedingImprovement(Map<String, Map<String, dynamic>> habits) {
    final needsImprovement = <String>[];
    
    habits.forEach((key, habit) {
      final consistency = habit['consistency'] as double;
      if (consistency < 0.6) {
        needsImprovement.add(habit['name'] as String);
      }
    });
    
    return needsImprovement;
  }

  // Additional helper methods
  List<String> _generateMoodStabilityInsights(double stability, double variance, List<String> protectiveFactors) {
    final insights = <String>[];
    
    if (stability >= 8.0) {
      insights.add('Tu estado de ánimo es muy estable');
    } else if (stability >= 6.0) {
      insights.add('Tu estado de ánimo es moderadamente estable');
    } else {
      insights.add('Tu estado de ánimo presenta variaciones significativas');
    }
    
    if (protectiveFactors.isNotEmpty) {
      insights.add('Factores protectores identificados: ${protectiveFactors.join(", ")}');
    }
    
    return insights;
  }

  List<String> _generateMoodStabilityRecommendations(double stability, List<Map<String, dynamic>> triggers, List<String> protectiveFactors) {
    final recommendations = <String>[];
    
    if (stability < 6.0) {
      recommendations.add('Practica técnicas de regulación emocional como respiración profunda');
      recommendations.add('Mantén una rutina diaria estable');
    }
    
    if (triggers.isNotEmpty) {
      recommendations.add('Identifica y maneja tus principales desencadenantes de estrés');
    }
    
    if (protectiveFactors.isNotEmpty) {
      recommendations.add('Mantén y fortalece tus factores protectores actuales');
    }
    
    return recommendations;
  }

  List<String> _generateBalanceInsights(Map<String, double> areas, double balanceScore) {
    final insights = <String>[];
    
    if (balanceScore >= 7.0) {
      insights.add('Tienes un buen equilibrio general en tu estilo de vida');
    } else if (balanceScore >= 5.0) {
      insights.add('Tu equilibrio de vida es moderado, con oportunidades de mejora');
    } else {
      insights.add('Hay desequilibrios significativos que requieren atención');
    }
    
    final strongAreas = areas.entries.where((e) => e.value >= 7.0).map((e) => e.key).toList();
    final weakAreas = areas.entries.where((e) => e.value < 4.0).map((e) => e.key).toList();
    
    if (strongAreas.isNotEmpty) {
      insights.add('Fortalezas: ${strongAreas.join(", ")}');
    }
    
    if (weakAreas.isNotEmpty) {
      insights.add('Áreas que necesitan atención: ${weakAreas.join(", ")}');
    }
    
    return insights;
  }

  String _getAreaImprovementRecommendation(String area, double score) {
    final recommendations = {
      'trabajo': 'Mejora tu productividad con técnicas de gestión del tiempo',
      'social': 'Dedica más tiempo a actividades sociales que disfrutes',
      'fisico': 'Incrementa tu actividad física gradualmente',
      'creatividad': 'Busca tiempo para actividades creativas que te inspiren',
      'bienestar': 'Practica autocuidado y mindfulness',
      'sueño': 'Establece una rutina de sueño más consistente',
      'ejercicio': 'Comienza con 15-20 minutos de ejercicio diario',
      'meditacion': 'Prueba con 5-10 minutos de meditación diaria',
      'hidratacion': 'Aumenta tu consumo de agua gradualmente',
      'pantallas': 'Reduce el tiempo de pantalla no productivo',
    };
    
    return recommendations[area] ?? 'Dedica más atención a esta área de tu vida';
  }

  String _getAreaModerationRecommendation(String area) {
    final recommendations = {
      'trabajo': 'Considera equilibrar trabajo con descanso',
      'pantallas': 'Excelente control del tiempo de pantalla, manténlo así',
    };
    
    return recommendations[area] ?? 'Mantén este buen nivel';
  }

  bool _shouldModerateArea(String area) {
    return ['trabajo', 'pantallas'].contains(area);
  }

  List<String> _generateEnergyRecommendations(String pattern, List<Map<String, dynamic>> boosters) {
    final recommendations = <String>[];
    
    switch (pattern) {
      case 'morning_person':
        recommendations.add('Programa tareas importantes en las mañanas cuando tienes más energía');
        break;
      case 'afternoon_peak':
        recommendations.add('Aprovecha las tardes para tu trabajo más exigente');
        break;
      case 'evening_person':
        recommendations.add('Las noches son tu momento de mayor productividad');
        break;
      default:
        recommendations.add('Mantén una energía consistente durante el día');
    }
    
    for (final booster in boosters) {
      recommendations.add(booster['recommendation'] as String);
    }
    
    return recommendations;
  }

  // Placeholder implementations for additional methods
  List<SleepInsight> _generateSleepInsights(double avgHours, double avgQuality, String pattern, double variance) => [];
  Future<Map<String, dynamic>> _calculateSleepCorrelations(int userId, int periodDays) async => {};
  double _calculateOptimalSleepHours(double avgHours, double avgQuality) => math.max(7.0, avgHours);
  List<StressTrigger> _identifyStressTriggers(List<Map<String, Object?>> data, double avgStress) => [];
  Future<List<StressReliefMethod>> _identifyStressReliefMethods(int userId, int periodDays) async => [];
  List<String> _generateStressRecommendations(double avgStress, String trend, List<StressTrigger> triggers) => [];
  List<GoalPerformanceInsight> _generateGoalInsights(double completionRate, Map<String, double> byCategory, double avgTime) => [];
  List<String> _identifySuccessFactors(List<dynamic> goals, double completionRate) => [];
  String _determineOptimalTimeOfDay(Map<String, double> hourlyPatterns) => 'morning';
  String _determineWeeklyPattern(Map<String, double> dailyPatterns) => 'consistent';
  List<TemporalInsight> _generateTemporalInsights(Map<String, double> hourly, Map<String, double> daily, String optimal) => [];
}