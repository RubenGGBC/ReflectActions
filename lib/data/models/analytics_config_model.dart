// ============================================================================
// data/models/analytics_config_model.dart - ANALYTICS CONFIGURATION MODELS
// DYNAMIC CONFIGURATION SYSTEM FOR ANALYTICS V3
// ============================================================================


// ============================================================================
// WELLNESS SCORE CONFIGURATION
// ============================================================================
class WellnessScoreConfig {
  final Map<String, double> componentWeights;
  final Map<String, double> wellnessThresholds;
  final Map<String, double> defaultScores;
  final int minimumDataPoints;
  final double significanceThreshold;

  const WellnessScoreConfig({
    required this.componentWeights,
    required this.wellnessThresholds,
    required this.defaultScores,
    required this.minimumDataPoints,
    required this.significanceThreshold,
  });

  Map<String, dynamic> toJson() => {
    'componentWeights': componentWeights,
    'wellnessThresholds': wellnessThresholds,
    'defaultScores': defaultScores,
    'minimumDataPoints': minimumDataPoints,
    'significanceThreshold': significanceThreshold,
  };

  factory WellnessScoreConfig.fromJson(Map<String, dynamic> json) =>
      WellnessScoreConfig(
        componentWeights: Map<String, double>.from(json['componentWeights']),
        wellnessThresholds: Map<String, double>.from(json['wellnessThresholds']),
        defaultScores: Map<String, double>.from(json['defaultScores']),
        minimumDataPoints: json['minimumDataPoints'],
        significanceThreshold: json['significanceThreshold'].toDouble(),
      );

  static WellnessScoreConfig getDefault() => WellnessScoreConfig(
    componentWeights: {
      'mood': 0.25,
      'energy': 0.20,
      'stress': 0.20,
      'sleep': 0.15,
      'anxiety': 0.10,
      'motivation': 0.05,
      'emotional_stability': 0.03,
      'life_satisfaction': 0.02,
    },
    wellnessThresholds: {
      'excellent': 8.0,
      'good': 6.5,
      'average': 5.0,
      'poor': 0.0,
    },
    defaultScores: {
      'mood': 5.0,
      'energy': 5.0,
      'stress': 5.0,
      'sleep': 5.0,
      'anxiety': 5.0,
      'motivation': 5.0,
      'emotional_stability': 5.0,
      'life_satisfaction': 5.0,
    },
    minimumDataPoints: 3,
    significanceThreshold: 0.05,
  );

  /// Create a copy with updated values
  WellnessScoreConfig copyWith({
    Map<String, double>? componentWeights,
    Map<String, double>? wellnessThresholds,
    Map<String, double>? defaultScores,
    int? minimumDataPoints,
    double? significanceThreshold,
  }) {
    return WellnessScoreConfig(
      componentWeights: componentWeights ?? this.componentWeights,
      wellnessThresholds: wellnessThresholds ?? this.wellnessThresholds,
      defaultScores: defaultScores ?? this.defaultScores,
      minimumDataPoints: minimumDataPoints ?? this.minimumDataPoints,
      significanceThreshold: significanceThreshold ?? this.significanceThreshold,
    );
  }
}

// ============================================================================
// CORRELATION ANALYSIS CONFIGURATION
// ============================================================================
class CorrelationConfig {
  final int minimumDataPoints;
  final Map<String, double> strengthThresholds;
  final Map<String, double> significanceThresholds;
  final double confidenceLevel;

  const CorrelationConfig({
    required this.minimumDataPoints,
    required this.strengthThresholds,
    required this.significanceThresholds,
    required this.confidenceLevel,
  });

  Map<String, dynamic> toJson() => {
    'minimumDataPoints': minimumDataPoints,
    'strengthThresholds': strengthThresholds,
    'significanceThresholds': significanceThresholds,
    'confidenceLevel': confidenceLevel,
  };

  factory CorrelationConfig.fromJson(Map<String, dynamic> json) =>
      CorrelationConfig(
        minimumDataPoints: json['minimumDataPoints'],
        strengthThresholds: Map<String, double>.from(json['strengthThresholds']),
        significanceThresholds: Map<String, double>.from(json['significanceThresholds']),
        confidenceLevel: json['confidenceLevel'].toDouble(),
      );

  static CorrelationConfig getDefault() => CorrelationConfig(
    minimumDataPoints: 7,
    strengthThresholds: {
      'strong': 0.7,
      'moderate': 0.5,
      'weak': 0.3,
      'negligible': 0.0,
    },
    significanceThresholds: {
      'p_value': 0.05,
      'confidence': 0.95,
    },
    confidenceLevel: 0.95,
  );

  /// Create a copy with updated values
  CorrelationConfig copyWith({
    int? minimumDataPoints,
    Map<String, double>? strengthThresholds,
    Map<String, double>? significanceThresholds,
    double? confidenceLevel,
  }) {
    return CorrelationConfig(
      minimumDataPoints: minimumDataPoints ?? this.minimumDataPoints,
      strengthThresholds: strengthThresholds ?? this.strengthThresholds,
      significanceThresholds: significanceThresholds ?? this.significanceThresholds,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    );
  }
}

// ============================================================================
// HABIT TRACKING CONFIGURATION
// ============================================================================
class HabitConfig {
  final String habitName;
  final String displayName;
  final String column;
  final Map<String, double> targets;
  final Map<String, double> scoreRanges;
  final String unit;
  final bool isInverted;

  const HabitConfig({
    required this.habitName,
    required this.displayName,
    required this.column,
    required this.targets,
    required this.scoreRanges,
    required this.unit,
    this.isInverted = false,
  });

  Map<String, dynamic> toJson() => {
    'habitName': habitName,
    'displayName': displayName,
    'column': column,
    'targets': targets,
    'scoreRanges': scoreRanges,
    'unit': unit,
    'isInverted': isInverted,
  };

  factory HabitConfig.fromJson(Map<String, dynamic> json) =>
      HabitConfig(
        habitName: json['habitName'],
        displayName: json['displayName'],
        column: json['column'],
        targets: Map<String, double>.from(json['targets']),
        scoreRanges: Map<String, double>.from(json['scoreRanges']),
        unit: json['unit'],
        isInverted: json['isInverted'] ?? false,
      );

  /// Get target value for specific level
  double getHabitTarget(String level) {
    return targets[level] ?? targets['recommended'] ?? targets.values.first;
  }
}

// ============================================================================
// TEMPORAL PATTERN CONFIGURATION
// ============================================================================
class TemporalConfig {
  final int minimumDataPoints;
  final Map<String, double> timeRanges;
  final Map<String, double> varianceThresholds;
  final double significanceThreshold;

  const TemporalConfig({
    required this.minimumDataPoints,
    required this.timeRanges,
    required this.varianceThresholds,
    required this.significanceThreshold,
  });

  Map<String, dynamic> toJson() => {
    'minimumDataPoints': minimumDataPoints,
    'timeRanges': timeRanges,
    'varianceThresholds': varianceThresholds,
    'significanceThreshold': significanceThreshold,
  };

  factory TemporalConfig.fromJson(Map<String, dynamic> json) =>
      TemporalConfig(
        minimumDataPoints: json['minimumDataPoints'],
        timeRanges: Map<String, double>.from(json['timeRanges']),
        varianceThresholds: Map<String, double>.from(json['varianceThresholds']),
        significanceThreshold: json['significanceThreshold'].toDouble(),
      );

  static TemporalConfig getDefault() => TemporalConfig(
    minimumDataPoints: 5,
    timeRanges: {
      'morning_start': 6.0,
      'morning_end': 12.0,
      'afternoon_start': 12.0,
      'afternoon_end': 18.0,
      'evening_start': 18.0,
      'evening_end': 22.0,
    },
    varianceThresholds: {
      'consistent': 0.1,
      'irregular': 0.25,
      'high_variance': 0.5,
    },
    significanceThreshold: 0.3,
  );

  /// Create a copy with updated values
  TemporalConfig copyWith({
    int? minimumDataPoints,
    Map<String, double>? timeRanges,
    Map<String, double>? varianceThresholds,
    double? significanceThreshold,
  }) {
    return TemporalConfig(
      minimumDataPoints: minimumDataPoints ?? this.minimumDataPoints,
      timeRanges: timeRanges ?? this.timeRanges,
      varianceThresholds: varianceThresholds ?? this.varianceThresholds,
      significanceThreshold: significanceThreshold ?? this.significanceThreshold,
    );
  }
}

// ============================================================================
// COMPREHENSIVE ANALYTICS CONFIGURATION
// ============================================================================
class AnalyticsConfig {
  final int id;
  final int? userId; // null para configuración global
  final String configType; // 'global', 'user_specific', 'premium'
  final WellnessScoreConfig wellnessConfig;
  final CorrelationConfig correlationConfig;
  final TemporalConfig temporalConfig;
  final Map<String, HabitConfig> habitConfigs;
  final Map<String, dynamic> customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const AnalyticsConfig({
    required this.id,
    this.userId,
    required this.configType,
    required this.wellnessConfig,
    required this.correlationConfig,
    required this.temporalConfig,
    required this.habitConfigs,
    required this.customSettings,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'configType': configType,
    'wellnessConfig': wellnessConfig.toJson(),
    'correlationConfig': correlationConfig.toJson(),
    'temporalConfig': temporalConfig.toJson(),
    'habitConfigs': habitConfigs.map((k, v) => MapEntry(k, v.toJson())),
    'customSettings': customSettings,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
  };

  factory AnalyticsConfig.fromJson(Map<String, dynamic> json) {
    final habitConfigsJson = json['habitConfigs'] as Map<String, dynamic>;
    final habitConfigs = <String, HabitConfig>{};
    
    habitConfigsJson.forEach((key, value) {
      habitConfigs[key] = HabitConfig.fromJson(value as Map<String, dynamic>);
    });

    return AnalyticsConfig(
      id: json['id'],
      userId: json['userId'],
      configType: json['configType'],
      wellnessConfig: WellnessScoreConfig.fromJson(json['wellnessConfig']),
      correlationConfig: CorrelationConfig.fromJson(json['correlationConfig']),
      temporalConfig: TemporalConfig.fromJson(json['temporalConfig']),
      habitConfigs: habitConfigs,
      customSettings: json['customSettings'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  static AnalyticsConfig getDefault({int? userId}) {
    final now = DateTime.now();
    
    return AnalyticsConfig(
      id: 0,
      userId: userId,
      configType: userId != null ? 'user_specific' : 'global',
      wellnessConfig: WellnessScoreConfig.getDefault(),
      correlationConfig: CorrelationConfig.getDefault(),
      temporalConfig: TemporalConfig.getDefault(),
      habitConfigs: _getDefaultHabitConfigs(),
      customSettings: {},
      createdAt: now,
      updatedAt: now,
    );
  }

  static Map<String, HabitConfig> _getDefaultHabitConfigs() => {
    'meditation': HabitConfig(
      habitName: 'meditation',
      displayName: 'Meditación',
      column: 'meditation_minutes',
      targets: {
        'beginner': 5.0,
        'intermediate': 15.0,
        'advanced': 30.0,
        'expert': 60.0,
      },
      scoreRanges: {
        'excellent': 20.0,
        'good': 15.0,
        'average': 10.0,
        'poor': 5.0,
        'none': 0.0,
      },
      unit: 'minutos',
    ),
    'exercise': HabitConfig(
      habitName: 'exercise',
      displayName: 'Ejercicio',
      column: 'exercise_minutes',
      targets: {
        'beginner': 15.0,
        'intermediate': 30.0,
        'advanced': 60.0,
        'expert': 90.0,
      },
      scoreRanges: {
        'excellent': 45.0,
        'good': 30.0,
        'average': 20.0,
        'poor': 10.0,
        'none': 0.0,
      },
      unit: 'minutos',
    ),
    'hydration': HabitConfig(
      habitName: 'hydration',
      displayName: 'Hidratación',
      column: 'water_intake',
      targets: {
        'minimum': 4.0,
        'recommended': 8.0,
        'optimal': 10.0,
        'maximum': 12.0,
      },
      scoreRanges: {
        'excellent': 8.0,
        'good': 6.0,
        'average': 4.0,
        'poor': 2.0,
        'none': 0.0,
      },
      unit: 'vasos',
    ),
    'sleep': HabitConfig(
      habitName: 'sleep',
      displayName: 'Sueño',
      column: 'sleep_hours',
      targets: {
        'minimum': 6.0,
        'recommended': 7.5,
        'optimal': 8.0,
        'maximum': 9.0,
      },
      scoreRanges: {
        'excellent': 8.0,
        'good': 7.5,
        'average': 7.0,
        'poor': 6.5,
        'insufficient': 6.0,
      },
      unit: 'horas',
    ),
    'screen_time': HabitConfig(
      habitName: 'screen_time',
      displayName: 'Tiempo de Pantalla',
      column: 'screen_time_hours',
      targets: {
        'excellent': 2.0,
        'good': 4.0,
        'moderate': 6.0,
        'excessive': 8.0,
      },
      scoreRanges: {
        'excellent': 2.0,
        'good': 4.0,
        'average': 6.0,
        'poor': 8.0,
        'excessive': 10.0,
      },
      unit: 'horas',
      isInverted: true, // Less is better
    ),
  };

  /// Get habit config by name with fallback to default
  HabitConfig getHabitConfig(String habitName) {
    return habitConfigs[habitName] ?? _getDefaultHabitConfigs()[habitName]!;
  }

  /// Get target value for a habit based on user level
  double getHabitTarget(String habitName, {String level = 'recommended'}) {
    final habitConfig = getHabitConfig(habitName);
    return habitConfig.targets[level] ?? habitConfig.targets.values.first;
  }

  /// Get wellness level from score
  String getWellnessLevel(double score) {
    if (score >= wellnessConfig.wellnessThresholds['excellent']!) {
      return 'excellent';
    } else if (score >= wellnessConfig.wellnessThresholds['good']!) {
      return 'good';
    } else if (score >= wellnessConfig.wellnessThresholds['average']!) {
      return 'average';
    } else {
      return 'poor';
    }
  }

  /// Get correlation strength category
  String getCorrelationStrength(double correlation) {
    final absCorr = correlation.abs();
    if (absCorr >= correlationConfig.strengthThresholds['strong']!) {
      return 'strong';
    } else if (absCorr >= correlationConfig.strengthThresholds['moderate']!) {
      return 'moderate';
    } else if (absCorr >= correlationConfig.strengthThresholds['weak']!) {
      return 'weak';
    } else {
      return 'negligible';
    }
  }

  /// Create a copy with updated values
  AnalyticsConfig copyWith({
    int? id,
    int? userId,
    String? configType,
    WellnessScoreConfig? wellnessConfig,
    CorrelationConfig? correlationConfig,
    TemporalConfig? temporalConfig,
    Map<String, HabitConfig>? habitConfigs,
    Map<String, dynamic>? customSettings,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AnalyticsConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      configType: configType ?? this.configType,
      wellnessConfig: wellnessConfig ?? this.wellnessConfig,
      correlationConfig: correlationConfig ?? this.correlationConfig,
      temporalConfig: temporalConfig ?? this.temporalConfig,
      habitConfigs: habitConfigs ?? this.habitConfigs,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }
}

// ============================================================================
// ANALYTICS CONFIGURATION PRESET
// ============================================================================
class AnalyticsConfigPreset {
  final String name;
  final String description;
  final String category; // 'beginner', 'intermediate', 'advanced', 'custom'
  final AnalyticsConfig config;

  const AnalyticsConfigPreset({
    required this.name,
    required this.description,
    required this.category,
    required this.config,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'category': category,
    'config': config.toJson(),
  };

  factory AnalyticsConfigPreset.fromJson(Map<String, dynamic> json) =>
      AnalyticsConfigPreset(
        name: json['name'],
        description: json['description'],
        category: json['category'],
        config: AnalyticsConfig.fromJson(json['config']),
      );

  static List<AnalyticsConfigPreset> getDefaultPresets() => [
    AnalyticsConfigPreset(
      name: 'Principiante',
      description: 'Configuración básica para usuarios nuevos con métricas simples',
      category: 'beginner',
      config: _createBeginnerConfig(),
    ),
    AnalyticsConfigPreset(
      name: 'Intermedio',
      description: 'Análisis más detallado con correlaciones y patrones temporales',
      category: 'intermediate',
      config: _createIntermediateConfig(),
    ),
    AnalyticsConfigPreset(
      name: 'Avanzado',
      description: 'Análisis completo con todas las métricas y alta sensibilidad',
      category: 'advanced',
      config: _createAdvancedConfig(),
    ),
  ];

  static AnalyticsConfig _createBeginnerConfig() {
    final base = AnalyticsConfig.getDefault();
    return base.copyWith(
      wellnessConfig: base.wellnessConfig.copyWith(
        componentWeights: {
          'mood': 0.4,
          'energy': 0.3,
          'sleep': 0.2,
          'stress': 0.1,
        },
        wellnessThresholds: {
          'excellent': 7.5,
          'good': 6.0,
          'average': 4.5,
          'poor': 0.0,
        },
        minimumDataPoints: 2,
        significanceThreshold: 0.1,
      ),
    );
  }

  static AnalyticsConfig _createIntermediateConfig() {
    return AnalyticsConfig.getDefault();
  }

  static AnalyticsConfig _createAdvancedConfig() {
    final base = AnalyticsConfig.getDefault();
    return base.copyWith(
      correlationConfig: base.correlationConfig.copyWith(
        minimumDataPoints: 5,
        strengthThresholds: {
          'strong': 0.6,
          'moderate': 0.4,
          'weak': 0.2,
          'negligible': 0.0,
        },
        significanceThresholds: {
          'p_value': 0.01,
          'confidence': 0.99,
        },
        confidenceLevel: 0.99,
      ),
    );
  }
}