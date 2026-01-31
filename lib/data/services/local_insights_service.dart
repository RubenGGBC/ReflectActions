// lib/data/services/local_insights_service.dart
// Motor de análisis local para generar insights automáticos

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/insights_models.dart';
import 'optimized_database_service.dart';

class LocalInsightsService {
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  // Cache de insights
  UserInsights? _cachedInsights;
  DateTime? _cacheTime;
  int? _cachedUserId;

  static const _cacheValidityHours = 6;

  LocalInsightsService(this._databaseService);

  /// Genera todos los insights para un usuario
  Future<UserInsights> generateInsights(int userId) async {
    // Verificar cache
    if (_isCacheValid(userId)) {
      _logger.d('📊 Usando insights cacheados');
      return _cachedInsights!;
    }

    _logger.i('🔄 Generando nuevos insights para usuario $userId');

    try {
      final db = await _databaseService.database;
      
      // Obtener datos de los últimos 90 días
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 90));
      
      final entries = await db.query(
        'daily_entries',
        where: 'user_id = ? AND entry_date >= ?',
        whereArgs: [userId, startDate.toIso8601String().split('T')[0]],
        orderBy: 'entry_date DESC',
      );

      if (entries.isEmpty) {
        return UserInsights.empty();
      }

      // Generar cada tipo de insight
      final weeklySummary = await _generateWeeklySummary(userId, entries);
      final patterns = _detectPatterns(entries);
      final correlations = _findCorrelations(entries);
      final predictions = _generatePredictions(entries);

      final insights = UserInsights(
        weeklySummary: weeklySummary,
        patterns: patterns,
        correlations: correlations,
        predictions: predictions,
        generatedAt: now,
        totalDaysAnalyzed: entries.length,
      );

      // Guardar en cache
      _cachedInsights = insights;
      _cacheTime = now;
      _cachedUserId = userId;

      _logger.i('✅ Insights generados: ${patterns.length} patrones, ${correlations.length} correlaciones');
      return insights;

    } catch (e) {
      _logger.e('❌ Error generando insights: $e');
      return UserInsights.empty();
    }
  }

  bool _isCacheValid(int userId) {
    if (_cachedInsights == null || _cacheTime == null || _cachedUserId != userId) {
      return false;
    }
    final hoursSinceCache = DateTime.now().difference(_cacheTime!).inHours;
    return hoursSinceCache < _cacheValidityHours;
  }

  void invalidateCache() {
    _cachedInsights = null;
    _cacheTime = null;
    _cachedUserId = null;
  }

  // ============================================================================
  // RESUMEN SEMANAL
  // ============================================================================

  Future<WeeklySummary?> _generateWeeklySummary(int userId, List<Map<String, dynamic>> allEntries) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    // Filtrar entradas de esta semana
    final weekEntries = allEntries.where((e) {
      final date = DateTime.parse(e['entry_date'] as String);
      return date.isAfter(weekStartDate.subtract(const Duration(days: 1)));
    }).toList();

    if (weekEntries.isEmpty) return null;

    // Calcular promedios
    double sumMood = 0, sumEnergy = 0, sumStress = 0, sumSleep = 0;
    int countMood = 0, countEnergy = 0, countStress = 0, countSleep = 0;
    
    DaySummary? bestDay;
    DaySummary? worstDay;
    double bestMood = -1, worstMood = 11;
    
    final positiveTags = <String, int>{};
    final negativeTags = <String, int>{};

    for (final entry in weekEntries) {
      final mood = (entry['mood_score'] as num?)?.toDouble() ?? 5.0;
      final energy = (entry['energy_level'] as num?)?.toDouble() ?? 5.0;
      final stress = (entry['stress_level'] as num?)?.toDouble() ?? 5.0;
      final sleep = (entry['sleep_hours'] as num?)?.toDouble();
      final date = DateTime.parse(entry['entry_date'] as String);

      if (entry['mood_score'] != null) { sumMood += mood; countMood++; }
      if (entry['energy_level'] != null) { sumEnergy += energy; countEnergy++; }
      if (entry['stress_level'] != null) { sumStress += stress; countStress++; }
      if (sleep != null) { sumSleep += sleep; countSleep++; }

      // Mejor/peor día
      if (mood > bestMood) {
        bestMood = mood;
        bestDay = DaySummary(
          date: date,
          mood: mood,
          energy: energy,
          dayName: _getDayName(date.weekday),
        );
      }
      if (mood < worstMood) {
        worstMood = mood;
        worstDay = DaySummary(
          date: date,
          mood: mood,
          energy: energy,
          dayName: _getDayName(date.weekday),
        );
      }

      // Tags
      _countTags(entry['positive_tags'] as String?, positiveTags);
      _countTags(entry['negative_tags'] as String?, negativeTags);
    }

    // Calcular comparación con semana anterior
    final comparison = await _calculateWeekComparison(userId, allEntries, weekStartDate);

    return WeeklySummary(
      weekStart: weekStartDate,
      weekEnd: weekStartDate.add(const Duration(days: 6)),
      averageMood: countMood > 0 ? sumMood / countMood : 5.0,
      averageEnergy: countEnergy > 0 ? sumEnergy / countEnergy : 5.0,
      averageStress: countStress > 0 ? sumStress / countStress : 5.0,
      averageSleep: countSleep > 0 ? sumSleep / countSleep : 7.0,
      totalEntries: weekEntries.length,
      totalMoments: 0, // TODO: contar momentos
      bestDay: bestDay,
      worstDay: worstDay,
      comparison: comparison,
      topPositiveTags: _getTopTags(positiveTags, 3),
      topNegativeTags: _getTopTags(negativeTags, 3),
    );
  }

  Future<WeekComparison?> _calculateWeekComparison(
    int userId, 
    List<Map<String, dynamic>> allEntries,
    DateTime currentWeekStart,
  ) async {
    final prevWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final prevWeekEnd = currentWeekStart.subtract(const Duration(days: 1));

    final prevEntries = allEntries.where((e) {
      final date = DateTime.parse(e['entry_date'] as String);
      return date.isAfter(prevWeekStart.subtract(const Duration(days: 1))) &&
             date.isBefore(currentWeekStart);
    }).toList();

    final currEntries = allEntries.where((e) {
      final date = DateTime.parse(e['entry_date'] as String);
      return date.isAfter(currentWeekStart.subtract(const Duration(days: 1)));
    }).toList();

    if (prevEntries.isEmpty || currEntries.isEmpty) return null;

    double prevMood = _average(prevEntries, 'mood_score');
    double currMood = _average(currEntries, 'mood_score');
    double prevEnergy = _average(prevEntries, 'energy_level');
    double currEnergy = _average(currEntries, 'energy_level');
    double prevStress = _average(prevEntries, 'stress_level');
    double currStress = _average(currEntries, 'stress_level');

    return WeekComparison(
      moodChange: prevMood > 0 ? (currMood - prevMood) / prevMood : 0,
      energyChange: prevEnergy > 0 ? (currEnergy - prevEnergy) / prevEnergy : 0,
      stressChange: prevStress > 0 ? (currStress - prevStress) / prevStress : 0,
      entriesChange: currEntries.length - prevEntries.length,
    );
  }

  // ============================================================================
  // DETECCIÓN DE PATRONES
  // ============================================================================

  List<EmotionalPattern> _detectPatterns(List<Map<String, dynamic>> entries) {
    final patterns = <EmotionalPattern>[];

    if (entries.length < 14) return patterns;

    // Patrón 1: Día de la semana con peor ánimo
    final weekdayPattern = _detectWeekdayPattern(entries);
    if (weekdayPattern != null) patterns.add(weekdayPattern);

    // Patrón 2: Impacto del sueño
    final sleepPattern = _detectSleepPattern(entries);
    if (sleepPattern != null) patterns.add(sleepPattern);

    // Patrón 3: Trigger de estrés
    final stressPattern = _detectStressTrigger(entries);
    if (stressPattern != null) patterns.add(stressPattern);

    return patterns;
  }

  EmotionalPattern? _detectWeekdayPattern(List<Map<String, dynamic>> entries) {
    final moodByDay = <int, List<double>>{};
    
    for (final entry in entries) {
      final date = DateTime.parse(entry['entry_date'] as String);
      final mood = (entry['mood_score'] as num?)?.toDouble();
      if (mood != null) {
        moodByDay.putIfAbsent(date.weekday, () => []).add(mood);
      }
    }

    if (moodByDay.length < 5) return null;

    // Encontrar día con peor promedio
    int? worstDay;
    double worstAvg = 11;
    double overallAvg = 0;
    int totalCount = 0;

    for (final entry in moodByDay.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg < worstAvg && entry.value.length >= 2) {
        worstAvg = avg;
        worstDay = entry.key;
      }
      overallAvg += entry.value.reduce((a, b) => a + b);
      totalCount += entry.value.length;
    }

    if (worstDay == null || totalCount == 0) return null;
    
    overallAvg /= totalCount;
    final difference = ((overallAvg - worstAvg) / overallAvg * 100);

    if (difference < 15) return null; // No es significativo

    return EmotionalPattern(
      type: PatternType.weekdayPattern,
      title: 'Patrón de ${_getDayName(worstDay)}',
      description: 'Tu ánimo los ${_getDayName(worstDay).toLowerCase()} es ${difference.toStringAsFixed(0)}% menor que otros días.',
      suggestion: 'Intenta planificar actividades que disfrutes para los ${_getDayName(worstDay).toLowerCase()}.',
      confidence: math.min(0.9, 0.5 + (moodByDay[worstDay]!.length * 0.05)),
      icon: Icons.calendar_today,
      color: Colors.orange,
      data: {'day': worstDay, 'difference': difference},
    );
  }

  EmotionalPattern? _detectSleepPattern(List<Map<String, dynamic>> entries) {
    final goodSleepMoods = <double>[];
    final badSleepMoods = <double>[];

    for (final entry in entries) {
      final sleep = (entry['sleep_hours'] as num?)?.toDouble();
      final mood = (entry['mood_score'] as num?)?.toDouble();
      
      if (sleep != null && mood != null) {
        if (sleep >= 7) {
          goodSleepMoods.add(mood);
        } else if (sleep < 6) {
          badSleepMoods.add(mood);
        }
      }
    }

    if (goodSleepMoods.length < 5 || badSleepMoods.length < 5) return null;

    final goodAvg = goodSleepMoods.reduce((a, b) => a + b) / goodSleepMoods.length;
    final badAvg = badSleepMoods.reduce((a, b) => a + b) / badSleepMoods.length;
    final improvement = ((goodAvg - badAvg) / badAvg * 100);

    if (improvement < 10) return null;

    return EmotionalPattern(
      type: PatternType.sleepImpact,
      title: 'Impacto del sueño',
      description: 'Cuando duermes +7 horas, tu ánimo es ${improvement.toStringAsFixed(0)}% mejor.',
      suggestion: 'Prioriza dormir al menos 7 horas para mantener un mejor estado de ánimo.',
      confidence: math.min(0.9, 0.6 + (goodSleepMoods.length * 0.02)),
      icon: Icons.bedtime,
      color: Colors.indigo,
      data: {'improvement': improvement},
    );
  }

  EmotionalPattern? _detectStressTrigger(List<Map<String, dynamic>> entries) {
    final highStressTags = <String, int>{};
    
    for (final entry in entries) {
      final stress = (entry['stress_level'] as num?)?.toDouble() ?? 5;
      if (stress >= 7) {
        _countTags(entry['negative_tags'] as String?, highStressTags);
      }
    }

    if (highStressTags.isEmpty) return null;

    final topTrigger = highStressTags.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    if (topTrigger.value < 3) return null;

    return EmotionalPattern(
      type: PatternType.stressTrigger,
      title: 'Trigger de estrés',
      description: '"${topTrigger.key}" aparece frecuentemente en días de alto estrés (${topTrigger.value} veces).',
      suggestion: 'Identifica formas de manejar o reducir la exposición a "${topTrigger.key}".',
      confidence: math.min(0.85, 0.5 + (topTrigger.value * 0.1)),
      icon: Icons.warning_amber,
      color: Colors.red.shade400,
      data: {'trigger': topTrigger.key, 'count': topTrigger.value},
    );
  }

  // ============================================================================
  // CORRELACIONES
  // ============================================================================

  List<HabitCorrelation> _findCorrelations(List<Map<String, dynamic>> entries) {
    final correlations = <HabitCorrelation>[];

    if (entries.length < 14) return correlations;

    // Correlación Sueño ↔ Mood
    final sleepMoodCorr = _calculateCorrelation(entries, 'sleep_hours', 'mood_score');
    if (sleepMoodCorr != null && sleepMoodCorr.abs() >= 0.25) {
      correlations.add(HabitCorrelation(
        habit: 'Horas de sueño',
        outcome: 'Estado de ánimo',
        correlation: sleepMoodCorr,
        dataPoints: entries.length,
        interpretation: sleepMoodCorr > 0 
            ? 'Dormir más se asocia con mejor ánimo'
            : 'Curiosamente, menos sueño se asocia con mejor ánimo',
        icon: Icons.bedtime,
      ));
    }

    // Correlación Ejercicio ↔ Energía
    final exerciseEnergyCorr = _calculateCorrelation(entries, 'exercise_minutes', 'energy_level');
    if (exerciseEnergyCorr != null && exerciseEnergyCorr.abs() >= 0.25) {
      correlations.add(HabitCorrelation(
        habit: 'Minutos de ejercicio',
        outcome: 'Nivel de energía',
        correlation: exerciseEnergyCorr,
        dataPoints: entries.length,
        interpretation: exerciseEnergyCorr > 0
            ? 'Más ejercicio se relaciona con mayor energía'
            : 'Posible sobreentrenamiento detectado',
        icon: Icons.fitness_center,
      ));
    }

    // Correlación Estrés ↔ Sueño
    final stressSleepCorr = _calculateCorrelation(entries, 'stress_level', 'sleep_quality');
    if (stressSleepCorr != null && stressSleepCorr.abs() >= 0.25) {
      correlations.add(HabitCorrelation(
        habit: 'Nivel de estrés',
        outcome: 'Calidad de sueño',
        correlation: stressSleepCorr,
        dataPoints: entries.length,
        interpretation: stressSleepCorr < 0
            ? 'Mayor estrés afecta negativamente tu sueño'
            : 'Tu sueño parece resistente al estrés',
        icon: Icons.psychology,
      ));
    }

    return correlations;
  }

  double? _calculateCorrelation(
    List<Map<String, dynamic>> entries,
    String field1,
    String field2,
  ) {
    final pairs = <List<double>>[];

    for (final entry in entries) {
      final val1 = (entry[field1] as num?)?.toDouble();
      final val2 = (entry[field2] as num?)?.toDouble();
      if (val1 != null && val2 != null) {
        pairs.add([val1, val2]);
      }
    }

    if (pairs.length < 10) return null;

    // Pearson correlation coefficient
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
    final n = pairs.length;

    for (final pair in pairs) {
      sumX += pair[0];
      sumY += pair[1];
      sumXY += pair[0] * pair[1];
      sumX2 += pair[0] * pair[0];
      sumY2 += pair[1] * pair[1];
    }

    final numerator = (n * sumXY) - (sumX * sumY);
    final denominator = math.sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));

    if (denominator == 0) return null;
    return numerator / denominator;
  }

  // ============================================================================
  // PREDICCIONES
  // ============================================================================

  List<TrendPrediction> _generatePredictions(List<Map<String, dynamic>> entries) {
    final predictions = <TrendPrediction>[];

    if (entries.length < 7) return predictions;

    // Predicción de mood
    final moodPrediction = _predictTrend(entries, 'mood_score', 'Estado de ánimo');
    if (moodPrediction != null) predictions.add(moodPrediction);

    // Predicción de energía
    final energyPrediction = _predictTrend(entries, 'energy_level', 'Nivel de energía');
    if (energyPrediction != null) predictions.add(energyPrediction);

    return predictions;
  }

  TrendPrediction? _predictTrend(
    List<Map<String, dynamic>> entries,
    String field,
    String metricName,
  ) {
    // Tomar últimos 14 días
    final recent = entries.take(14).toList();
    final values = <double>[];

    for (final entry in recent) {
      final val = (entry[field] as num?)?.toDouble();
      if (val != null) values.add(val);
    }

    if (values.length < 7) return null;

    // Media móvil exponencial
    final alpha = 0.3;
    double ema = values.last;
    for (int i = values.length - 2; i >= 0; i--) {
      ema = alpha * values[i] + (1 - alpha) * ema;
    }

    final current = values.first;
    final predicted = ema;
    
    TrendDirection direction;
    String insight;
    
    if ((predicted - current).abs() < 0.3) {
      direction = TrendDirection.stable;
      insight = 'Tu $metricName se mantiene estable.';
    } else if (predicted > current) {
      direction = TrendDirection.up;
      insight = 'Tu $metricName muestra una tendencia positiva.';
    } else {
      direction = TrendDirection.down;
      insight = 'Tu $metricName podría necesitar atención.';
    }

    return TrendPrediction(
      metric: metricName,
      currentValue: current,
      predictedValue: predicted,
      direction: direction,
      confidence: 0.6 + (values.length * 0.02),
      insight: insight,
    );
  }

  // ============================================================================
  // UTILIDADES
  // ============================================================================

  String _getDayName(int weekday) {
    const days = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday];
  }

  void _countTags(String? tagsJson, Map<String, int> counter) {
    if (tagsJson == null || tagsJson.isEmpty) return;
    try {
      final tags = tagsJson.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty);
      for (final tag in tags) {
        counter[tag] = (counter[tag] ?? 0) + 1;
      }
    } catch (e) {
      // Ignorar errores de parsing
    }
  }

  List<String> _getTopTags(Map<String, int> tags, int limit) {
    final sorted = tags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  double _average(List<Map<String, dynamic>> entries, String field) {
    double sum = 0;
    int count = 0;
    for (final entry in entries) {
      final val = (entry[field] as num?)?.toDouble();
      if (val != null) {
        sum += val;
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }
}
