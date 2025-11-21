// ============================================================================
// data/services/analytics_config_service.dart - ANALYTICS CONFIGURATION SERVICE
// DYNAMIC CONFIGURATION MANAGEMENT FOR ANALYTICS V3
// ============================================================================

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/analytics_config_model.dart';
import 'optimized_database_service.dart';

class AnalyticsConfigService {
  final OptimizedDatabaseService _databaseService;
  
  // Cache for configurations
  final Map<String, AnalyticsConfig> _configCache = {};
  AnalyticsConfig? _globalConfig;

  AnalyticsConfigService(this._databaseService);

  // ============================================================================
  // DATABASE INITIALIZATION
  // ============================================================================

  /// Initialize analytics configuration tables
  Future<void> initializeTables() async {
    final db = await _databaseService.database;
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS analytics_configurations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NULL,
        config_type TEXT NOT NULL DEFAULT 'global',
        wellness_config TEXT NOT NULL,
        correlation_config TEXT NOT NULL,
        temporal_config TEXT NOT NULL,
        habit_configs TEXT NOT NULL,
        custom_settings TEXT NOT NULL DEFAULT '{}',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id, config_type)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS analytics_config_presets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        config_data TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_analytics_preferences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        preferred_preset TEXT NULL,
        custom_weights TEXT NULL,
        notification_thresholds TEXT NULL,
        analysis_frequency TEXT NOT NULL DEFAULT 'daily',
        privacy_level TEXT NOT NULL DEFAULT 'standard',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(user_id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_analytics_config_user_type 
      ON analytics_configurations (user_id, config_type, is_active)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_analytics_presets_category 
      ON analytics_config_presets (category, is_system)
    ''');

    // Initialize default configurations if they don't exist
    await _initializeDefaultConfigurations();
  }

  // ============================================================================
  // CONFIGURATION MANAGEMENT
  // ============================================================================

  /// Get analytics configuration for a user (with fallback to global)
  Future<AnalyticsConfig> getConfigForUser(int userId) async {
    final cacheKey = 'user_$userId';
    
    // Check cache first
    if (_configCache.containsKey(cacheKey)) {
      return _configCache[cacheKey]!;
    }

    final db = await _databaseService.database;
    
    // Try to get user-specific configuration first
    final userResult = await db.query(
      'analytics_configurations',
      where: 'user_id = ? AND config_type = ? AND is_active = 1',
      whereArgs: [userId, 'user_specific'],
      limit: 1,
    );

    AnalyticsConfig config;
    if (userResult.isNotEmpty) {
      config = _parseConfigFromRow(userResult.first);
    } else {
      // Fallback to global configuration
      config = await getGlobalConfig();
      
      // Create user-specific config based on global
      config = config.copyWith(
        id: 0,
        userId: userId,
        configType: 'user_specific',
      );
    }

    // Cache the configuration
    _configCache[cacheKey] = config;
    return config;
  }

  /// Get global analytics configuration
  Future<AnalyticsConfig> getGlobalConfig() async {
    if (_globalConfig != null) {
      return _globalConfig!;
    }

    final db = await _databaseService.database;
    
    final result = await db.query(
      'analytics_configurations',
      where: 'user_id IS NULL AND config_type = ? AND is_active = 1',
      whereArgs: ['global'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      _globalConfig = _parseConfigFromRow(result.first);
    } else {
      // Create default global configuration
      _globalConfig = AnalyticsConfig.getDefault();
      await saveConfig(_globalConfig!);
    }

    return _globalConfig!;
  }

  /// Save or update analytics configuration
  Future<AnalyticsConfig> saveConfig(AnalyticsConfig config) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    final configData = {
      'user_id': config.userId,
      'config_type': config.configType,
      'wellness_config': jsonEncode(config.wellnessConfig.toJson()),
      'correlation_config': jsonEncode(config.correlationConfig.toJson()),
      'temporal_config': jsonEncode(config.temporalConfig.toJson()),
      'habit_configs': jsonEncode(config.habitConfigs.map((k, v) => MapEntry(k, v.toJson()))),
      'custom_settings': jsonEncode(config.customSettings),
      'is_active': config.isActive ? 1 : 0,
      'updated_at': now.toIso8601String(),
    };

    int configId;
    if (config.id > 0) {
      // Update existing configuration
      await db.update(
        'analytics_configurations',
        configData,
        where: 'id = ?',
        whereArgs: [config.id],
      );
      configId = config.id;
    } else {
      // Insert new configuration
      configData['created_at'] = now.toIso8601String();
      configId = await db.insert('analytics_configurations', configData);
    }

    final updatedConfig = config.copyWith(
      id: configId,
      updatedAt: now,
    );

    // Update cache
    if (config.userId != null) {
      _configCache['user_${config.userId}'] = updatedConfig;
    } else if (config.configType == 'global') {
      _globalConfig = updatedConfig;
    }

    return updatedConfig;
  }

  /// Create user-specific configuration from preset
  Future<AnalyticsConfig> createUserConfigFromPreset(int userId, String presetName) async {
    final preset = await getPreset(presetName);
    if (preset == null) {
      throw ArgumentError('Preset not found: $presetName');
    }

    final userConfig = preset.config.copyWith(
      id: 0,
      userId: userId,
      configType: 'user_specific',
    );

    return await saveConfig(userConfig);
  }

  /// Update specific configuration section
  Future<AnalyticsConfig> updateConfigSection(
    int userId, 
    String section, 
    Map<String, dynamic> updates
  ) async {
    final config = await getConfigForUser(userId);
    AnalyticsConfig updatedConfig;

    switch (section) {
      case 'wellness':
        final updatedWellnessConfig = WellnessScoreConfig.fromJson({
          ...config.wellnessConfig.toJson(),
          ...updates,
        });
        updatedConfig = config.copyWith(wellnessConfig: updatedWellnessConfig);
        break;
      
      case 'correlation':
        final updatedCorrelationConfig = CorrelationConfig.fromJson({
          ...config.correlationConfig.toJson(),
          ...updates,
        });
        updatedConfig = config.copyWith(correlationConfig: updatedCorrelationConfig);
        break;
      
      case 'temporal':
        final updatedTemporalConfig = TemporalConfig.fromJson({
          ...config.temporalConfig.toJson(),
          ...updates,
        });
        updatedConfig = config.copyWith(temporalConfig: updatedTemporalConfig);
        break;
      
      case 'habits':
        final habitConfigs = Map<String, HabitConfig>.from(config.habitConfigs);
        updates.forEach((habitName, habitData) {
          if (habitData is Map<String, dynamic>) {
            habitConfigs[habitName] = HabitConfig.fromJson(habitData);
          }
        });
        updatedConfig = config.copyWith(habitConfigs: habitConfigs);
        break;
      
      case 'custom':
        final customSettings = Map<String, dynamic>.from(config.customSettings);
        customSettings.addAll(updates);
        updatedConfig = config.copyWith(customSettings: customSettings);
        break;
      
      default:
        throw ArgumentError('Unknown configuration section: $section');
    }

    return await saveConfig(updatedConfig);
  }

  // ============================================================================
  // PRESET MANAGEMENT
  // ============================================================================

  /// Get all available presets
  Future<List<AnalyticsConfigPreset>> getAllPresets() async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      'analytics_config_presets',
      orderBy: 'category ASC, name ASC',
    );

    return result.map((row) => AnalyticsConfigPreset.fromJson({
      'name': row['name'],
      'description': row['description'],
      'category': row['category'],
      'config': jsonDecode(row['config_data'] as String),
    })).toList();
  }

  /// Get preset by name
  Future<AnalyticsConfigPreset?> getPreset(String name) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      'analytics_config_presets',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (result.isEmpty) return null;
    
    final row = result.first;
    return AnalyticsConfigPreset.fromJson({
      'name': row['name'],
      'description': row['description'],
      'category': row['category'],
      'config': jsonDecode(row['config_data'] as String),
    });
  }

  /// Save preset
  Future<void> savePreset(AnalyticsConfigPreset preset, {bool isSystem = false}) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    await db.insert(
      'analytics_config_presets',
      {
        'name': preset.name,
        'description': preset.description,
        'category': preset.category,
        'config_data': jsonEncode(preset.config.toJson()),
        'is_system': isSystem ? 1 : 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================================================================
  // USER PREFERENCES
  // ============================================================================

  /// Get user analytics preferences
  Future<Map<String, dynamic>> getUserPreferences(int userId) async {
    final db = await _databaseService.database;
    
    final result = await db.query(
      'user_analytics_preferences',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return _getDefaultUserPreferences();
    }

    final row = result.first;
    return {
      'preferred_preset': row['preferred_preset'],
      'custom_weights': row['custom_weights'] != null 
        ? jsonDecode(row['custom_weights'] as String) 
        : null,
      'notification_thresholds': row['notification_thresholds'] != null 
        ? jsonDecode(row['notification_thresholds'] as String) 
        : null,
      'analysis_frequency': row['analysis_frequency'],
      'privacy_level': row['privacy_level'],
    };
  }

  /// Save user analytics preferences
  Future<void> saveUserPreferences(int userId, Map<String, dynamic> preferences) async {
    final db = await _databaseService.database;
    final now = DateTime.now();
    
    final data = {
      'user_id': userId,
      'preferred_preset': preferences['preferred_preset'],
      'custom_weights': preferences['custom_weights'] != null 
        ? jsonEncode(preferences['custom_weights']) 
        : null,
      'notification_thresholds': preferences['notification_thresholds'] != null 
        ? jsonEncode(preferences['notification_thresholds']) 
        : null,
      'analysis_frequency': preferences['analysis_frequency'] ?? 'daily',
      'privacy_level': preferences['privacy_level'] ?? 'standard',
      'updated_at': now.toIso8601String(),
    };

    // Try to update first
    final updateCount = await db.update(
      'user_analytics_preferences',
      data,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // If no rows were updated, insert new record
    if (updateCount == 0) {
      data['created_at'] = now.toIso8601String();
      await db.insert('user_analytics_preferences', data);
    }
  }

  // ============================================================================
  // ADAPTIVE CONFIGURATION
  // ============================================================================

  /// Auto-adjust configuration based on user data patterns
  Future<AnalyticsConfig> adaptConfigToUserData(int userId) async {
    final config = await getConfigForUser(userId);
    final db = await _databaseService.database;
    
    // Analyze user's data patterns
    final dataAnalysis = await _analyzeUserDataPatterns(userId);
    
    // Adjust wellness weights based on data availability
    final adjustedWeights = _adjustWellnessWeights(
      config.wellnessConfig.componentWeights,
      dataAnalysis['data_availability'] as Map<String, double>,
    );
    
    // Adjust correlation thresholds based on data variance
    final adjustedCorrelationConfig = _adjustCorrelationConfig(
      config.correlationConfig,
      dataAnalysis['data_variance'] as double,
    );
    
    // Adjust habit targets based on user's historical performance
    final adjustedHabitConfigs = await _adjustHabitTargets(
      userId,
      config.habitConfigs,
    );

    final adaptedConfig = config.copyWith(
      wellnessConfig: config.wellnessConfig.copyWith(
        componentWeights: adjustedWeights,
      ),
      correlationConfig: adjustedCorrelationConfig,
      habitConfigs: adjustedHabitConfigs,
      customSettings: {
        ...config.customSettings,
        'auto_adapted': true,
        'adaptation_date': DateTime.now().toIso8601String(),
        'adaptation_reason': 'data_pattern_analysis',
      },
    );

    return await saveConfig(adaptedConfig);
  }

  /// Get configuration optimized for user's experience level
  Future<AnalyticsConfig> getOptimizedConfigForUser(int userId) async {
    final db = await _databaseService.database;
    
    // Calculate user's experience level based on usage patterns
    final experienceLevel = await _calculateUserExperienceLevel(userId);
    
    // Get base configuration
    AnalyticsConfig baseConfig;
    switch (experienceLevel) {
      case 'beginner':
        final preset = await getPreset('Principiante');
        baseConfig = preset!.config;
        break;
      case 'intermediate':
        final preset = await getPreset('Intermedio');
        baseConfig = preset!.config;
        break;
      case 'advanced':
        final preset = await getPreset('Avanzado');
        baseConfig = preset!.config;
        break;
      default:
        baseConfig = await getGlobalConfig();
    }

    // Customize for user
    return baseConfig.copyWith(
      userId: userId,
      configType: 'user_specific',
      customSettings: {
        ...baseConfig.customSettings,
        'experience_level': experienceLevel,
        'optimized_date': DateTime.now().toIso8601String(),
      },
    );
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Clear configuration cache
  void clearCache() {
    _configCache.clear();
    _globalConfig = null;
  }

  /// Invalidate cache for specific user
  void invalidateUserCache(int userId) {
    _configCache.remove('user_$userId');
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  AnalyticsConfig _parseConfigFromRow(Map<String, dynamic> row) {
    return AnalyticsConfig(
      id: row['id'],
      userId: row['user_id'],
      configType: row['config_type'],
      wellnessConfig: WellnessScoreConfig.fromJson(
        jsonDecode(row['wellness_config'] as String),
      ),
      correlationConfig: CorrelationConfig.fromJson(
        jsonDecode(row['correlation_config'] as String),
      ),
      temporalConfig: TemporalConfig.fromJson(
        jsonDecode(row['temporal_config'] as String),
      ),
      habitConfigs: _parseHabitConfigs(row['habit_configs'] as String),
      customSettings: jsonDecode(row['custom_settings'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      isActive: (row['is_active'] as int) == 1,
    );
  }

  Map<String, HabitConfig> _parseHabitConfigs(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final Map<String, HabitConfig> habitConfigs = {};
    
    data.forEach((key, value) {
      habitConfigs[key] = HabitConfig.fromJson(value as Map<String, dynamic>);
    });
    
    return habitConfigs;
  }

  Future<void> _initializeDefaultConfigurations() async {
    // Initialize global configuration
    final globalConfig = await getGlobalConfig();
    
    // Initialize default presets
    final presets = AnalyticsConfigPreset.getDefaultPresets();
    for (final preset in presets) {
      try {
        await savePreset(preset, isSystem: true);
      } catch (e) {
        // Preset might already exist, continue
      }
    }
  }

  Map<String, dynamic> _getDefaultUserPreferences() => {
    'preferred_preset': 'Intermedio',
    'custom_weights': null,
    'notification_thresholds': null,
    'analysis_frequency': 'daily',
    'privacy_level': 'standard',
  };

  Future<Map<String, dynamic>> _analyzeUserDataPatterns(int userId) async {
    final db = await _databaseService.database;
    
    // Get data availability for the last 30 days
    final result = await db.rawQuery('''
      SELECT 
        COUNT(CASE WHEN mood_score IS NOT NULL THEN 1 END) as mood_count,
        COUNT(CASE WHEN energy_level IS NOT NULL THEN 1 END) as energy_count,
        COUNT(CASE WHEN stress_level IS NOT NULL THEN 1 END) as stress_count,
        COUNT(CASE WHEN sleep_hours IS NOT NULL THEN 1 END) as sleep_count,
        COUNT(CASE WHEN anxiety_level IS NOT NULL THEN 1 END) as anxiety_count,
        COUNT(*) as total_entries,
        AVG(CASE WHEN mood_score IS NOT NULL THEN mood_score END) as avg_mood,
        AVG(CASE WHEN energy_level IS NOT NULL THEN energy_level END) as avg_energy
      FROM daily_entries 
      WHERE user_id = ? AND entry_date >= date('now', '-30 days')
    ''', [userId]);

    if (result.isEmpty) {
      return {
        'data_availability': <String, double>{},
        'data_variance': 0.0,
      };
    }

    final row = result.first;
    final totalEntries = (row['total_entries'] as int).toDouble();
    
    return {
      'data_availability': {
        'mood': (row['mood_count'] as int) / totalEntries,
        'energy': (row['energy_count'] as int) / totalEntries,
        'stress': (row['stress_count'] as int) / totalEntries,
        'sleep': (row['sleep_count'] as int) / totalEntries,
        'anxiety': (row['anxiety_count'] as int) / totalEntries,
      },
      'data_variance': _calculateDataVariance(row),
    };
  }

  Map<String, double> _adjustWellnessWeights(
    Map<String, double> currentWeights,
    Map<String, double> dataAvailability,
  ) {
    final adjustedWeights = Map<String, double>.from(currentWeights);
    
    // Redistribute weights based on data availability
    dataAvailability.forEach((component, availability) {
      if (availability < 0.3) {
        // Reduce weight for components with low data availability
        adjustedWeights[component] = (adjustedWeights[component] ?? 0.0) * 0.5;
      } else if (availability > 0.8) {
        // Increase weight for components with high data availability
        adjustedWeights[component] = (adjustedWeights[component] ?? 0.0) * 1.2;
      }
    });

    // Normalize weights to sum to 1.0
    final totalWeight = adjustedWeights.values.reduce((a, b) => a + b);
    if (totalWeight > 0) {
      adjustedWeights.updateAll((key, value) => value / totalWeight);
    }

    return adjustedWeights;
  }

  CorrelationConfig _adjustCorrelationConfig(
    CorrelationConfig currentConfig,
    double dataVariance,
  ) {
    // Adjust thresholds based on data variance
    if (dataVariance < 0.5) {
      // Low variance - use more sensitive thresholds
      return CorrelationConfig(
        minimumDataPoints: currentConfig.minimumDataPoints,
        strengthThresholds: {
          'strong': 0.6,
          'moderate': 0.4,
          'weak': 0.2,
          'negligible': 0.0,
        },
        significanceThresholds: currentConfig.significanceThresholds,
        confidenceLevel: currentConfig.confidenceLevel,
      );
    } else if (dataVariance > 1.5) {
      // High variance - use less sensitive thresholds
      return CorrelationConfig(
        minimumDataPoints: currentConfig.minimumDataPoints + 3,
        strengthThresholds: {
          'strong': 0.8,
          'moderate': 0.6,
          'weak': 0.4,
          'negligible': 0.0,
        },
        significanceThresholds: currentConfig.significanceThresholds,
        confidenceLevel: currentConfig.confidenceLevel,
      );
    }

    return currentConfig;
  }

  Future<Map<String, HabitConfig>> _adjustHabitTargets(
    int userId,
    Map<String, HabitConfig> currentConfigs,
  ) async {
    final db = await _databaseService.database;
    final adjustedConfigs = <String, HabitConfig>{};

    for (final entry in currentConfigs.entries) {
      final habitName = entry.key;
      final habitConfig = entry.value;
      
      // Calculate user's historical performance for this habit
      final result = await db.rawQuery('''
        SELECT 
          AVG(CAST(${habitConfig.column} as REAL)) as avg_value,
          COUNT(*) as entry_count
        FROM daily_entries 
        WHERE user_id = ? AND ${habitConfig.column} IS NOT NULL
          AND entry_date >= date('now', '-60 days')
      ''', [userId]);

      if (result.isNotEmpty && result.first['entry_count'] as int >= 10) {
        final avgValue = (result.first['avg_value'] as double?) ?? 0.0;
        
        // Adjust target to be slightly above user's average performance
        final adjustedTarget = avgValue * 1.15; // 15% above average
        
        final updatedTargets = Map<String, double>.from(habitConfig.targets);
        updatedTargets['personalized'] = adjustedTarget;
        
        adjustedConfigs[habitName] = HabitConfig(
          habitName: habitConfig.habitName,
          displayName: habitConfig.displayName,
          column: habitConfig.column,
          targets: updatedTargets,
          scoreRanges: habitConfig.scoreRanges,
          unit: habitConfig.unit,
          isInverted: habitConfig.isInverted,
        );
      } else {
        adjustedConfigs[habitName] = habitConfig;
      }
    }

    return adjustedConfigs;
  }

  Future<String> _calculateUserExperienceLevel(int userId) async {
    final db = await _databaseService.database;
    
    // Get user's usage statistics
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entries,
        COUNT(DISTINCT entry_date) as unique_days,
        MIN(entry_date) as first_entry,
        COUNT(CASE WHEN mood_score IS NOT NULL AND energy_level IS NOT NULL 
               AND stress_level IS NOT NULL AND sleep_hours IS NOT NULL THEN 1 END) as complete_entries
      FROM daily_entries 
      WHERE user_id = ?
    ''', [userId]);

    if (result.isEmpty) return 'beginner';

    final row = result.first;
    final totalEntries = row['total_entries'] as int;
    final uniqueDays = row['unique_days'] as int;
    final completeEntries = row['complete_entries'] as int;
    
    // Calculate days since first entry
    final firstEntry = DateTime.parse(row['first_entry'] as String);
    final daysSinceStart = DateTime.now().difference(firstEntry).inDays;
    
    // Calculate experience score
    final consistencyScore = uniqueDays / (daysSinceStart + 1);
    final completenessScore = totalEntries > 0 ? completeEntries / totalEntries : 0.0;
    final experienceScore = (consistencyScore * 0.6) + (completenessScore * 0.4);
    
    if (experienceScore >= 0.7 && uniqueDays >= 30) {
      return 'advanced';
    } else if (experienceScore >= 0.4 && uniqueDays >= 14) {
      return 'intermediate';
    } else {
      return 'beginner';
    }
  }

  double _calculateDataVariance(Map<String, dynamic> data) {
    final avgMood = (data['avg_mood'] as double?) ?? 5.0;
    final avgEnergy = (data['avg_energy'] as double?) ?? 5.0;
    
    // Simple variance calculation (could be improved with more sophisticated analysis)
    final variance = (avgMood - 5.0).abs() + (avgEnergy - 5.0).abs();
    return variance / 2.0;
  }
}