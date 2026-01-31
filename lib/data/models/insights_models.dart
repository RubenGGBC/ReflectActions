// lib/data/models/insights_models.dart
// Modelos para el sistema de Insights Automáticos Locales

import 'package:flutter/material.dart';

/// Resumen semanal completo
class WeeklySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double averageMood;
  final double averageEnergy;
  final double averageStress;
  final double averageSleep;
  final int totalEntries;
  final int totalMoments;
  final DaySummary? bestDay;
  final DaySummary? worstDay;
  final WeekComparison? comparison;
  final List<String> topPositiveTags;
  final List<String> topNegativeTags;
  final String? highlightMoment;

  WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.averageMood,
    required this.averageEnergy,
    required this.averageStress,
    required this.averageSleep,
    required this.totalEntries,
    required this.totalMoments,
    this.bestDay,
    this.worstDay,
    this.comparison,
    this.topPositiveTags = const [],
    this.topNegativeTags = const [],
    this.highlightMoment,
  });

  bool get hasEnoughData => totalEntries >= 3;
  
  String get moodEmoji {
    if (averageMood >= 8) return '😊';
    if (averageMood >= 6) return '🙂';
    if (averageMood >= 4) return '😐';
    if (averageMood >= 2) return '😔';
    return '😢';
  }
}

/// Resumen de un día específico
class DaySummary {
  final DateTime date;
  final double mood;
  final double energy;
  final String? mainActivity;
  final String dayName;

  DaySummary({
    required this.date,
    required this.mood,
    required this.energy,
    this.mainActivity,
    required this.dayName,
  });
}

/// Comparación con semana anterior
class WeekComparison {
  final double moodChange;
  final double energyChange;
  final double stressChange;
  final int entriesChange;

  WeekComparison({
    required this.moodChange,
    required this.energyChange,
    required this.stressChange,
    required this.entriesChange,
  });

  bool get isMoodImproved => moodChange > 0;
  bool get isEnergyImproved => energyChange > 0;
  bool get isStressReduced => stressChange < 0;

  String get moodChangeText {
    if (moodChange == 0) return 'sin cambios';
    final sign = moodChange > 0 ? '+' : '';
    return '$sign${(moodChange * 100).toStringAsFixed(0)}%';
  }
}

/// Patrón emocional detectado
class EmotionalPattern {
  final PatternType type;
  final String title;
  final String description;
  final String suggestion;
  final double confidence;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> data;

  EmotionalPattern({
    required this.type,
    required this.title,
    required this.description,
    required this.suggestion,
    required this.confidence,
    required this.icon,
    required this.color,
    this.data = const {},
  });

  bool get isHighConfidence => confidence >= 0.7;
}

enum PatternType {
  weekdayPattern,
  sleepImpact,
  activityTrigger,
  moodCycle,
  stressTrigger,
  energyPattern,
}

/// Correlación entre hábitos y bienestar
class HabitCorrelation {
  final String habit;
  final String outcome;
  final double correlation;
  final int dataPoints;
  final String interpretation;
  final IconData icon;

  HabitCorrelation({
    required this.habit,
    required this.outcome,
    required this.correlation,
    required this.dataPoints,
    required this.interpretation,
    required this.icon,
  });

  bool get isSignificant => correlation.abs() >= 0.3 && dataPoints >= 14;
  bool get isPositive => correlation > 0;
  
  String get strengthLabel {
    final abs = correlation.abs();
    if (abs >= 0.7) return 'Muy fuerte';
    if (abs >= 0.5) return 'Fuerte';
    if (abs >= 0.3) return 'Moderada';
    return 'Débil';
  }

  Color get strengthColor {
    final abs = correlation.abs();
    if (abs >= 0.7) return Colors.green;
    if (abs >= 0.5) return Colors.teal;
    if (abs >= 0.3) return Colors.orange;
    return Colors.grey;
  }
}

/// Predicción de tendencia
class TrendPrediction {
  final String metric;
  final double currentValue;
  final double predictedValue;
  final TrendDirection direction;
  final double confidence;
  final String insight;

  TrendPrediction({
    required this.metric,
    required this.currentValue,
    required this.predictedValue,
    required this.direction,
    required this.confidence,
    required this.insight,
  });

  double get changePercent => 
      currentValue > 0 ? ((predictedValue - currentValue) / currentValue) * 100 : 0;
}

enum TrendDirection { up, down, stable }

/// Contenedor de todos los insights
class UserInsights {
  final WeeklySummary? weeklySummary;
  final List<EmotionalPattern> patterns;
  final List<HabitCorrelation> correlations;
  final List<TrendPrediction> predictions;
  final DateTime generatedAt;
  final int totalDaysAnalyzed;

  UserInsights({
    this.weeklySummary,
    this.patterns = const [],
    this.correlations = const [],
    this.predictions = const [],
    required this.generatedAt,
    required this.totalDaysAnalyzed,
  });

  bool get hasInsights => 
      weeklySummary != null || patterns.isNotEmpty || correlations.isNotEmpty;
  
  bool get needsMoreData => totalDaysAnalyzed < 7;

  factory UserInsights.empty() => UserInsights(
    generatedAt: DateTime.now(),
    totalDaysAnalyzed: 0,
  );
}
