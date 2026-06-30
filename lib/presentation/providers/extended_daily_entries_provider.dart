// lib/presentation/providers/extended_daily_entries_provider.dart
// ============================================================================
// PROVIDER EXTENDIDO QUE USA IA REAL PARA GENERAR GOALS
// ============================================================================

import 'package:logger/logger.dart';

import '../../data/services/optimized_database_service.dart';
// AI services removed
import 'optimized_providers.dart';

class ExtendedDailyEntriesProvider extends OptimizedDailyEntriesProvider {
  // AI service removed
  final Logger _logger = Logger();

  // AI recommendations removed

  // ✅ CONSTRUCTOR CORREGIDO: Almacenar la referencia
  ExtendedDailyEntriesProvider(OptimizedDatabaseService databaseService)
      : super(databaseService);

  // AI getters removed

  /// ✅ MÉTODO EXTENDIDO: Guardar entrada Y usar IA REAL para generar goals
  @override
  Future<bool> saveDailyEntry({
    required int userId,
    required String freeReflection,
    String? innerReflection,
    List<String> completedActivitiesToday = const [],
    List<String> goalsSummary = const [],
    List<String> positiveTags = const [],
    List<String> negativeTags = const [],
    bool? worthIt,
    int? moodScore,
    int? energyLevel,
    int? stressLevel,
    int? sleepQuality,
    int? anxietyLevel,
    int? motivationLevel,
    int? socialInteraction,
    int? physicalActivity,
    int? workProductivity,
    double? sleepHours,
    int? waterIntake,
    int? meditationMinutes,
    int? exerciseMinutes,
    double? screenTimeHours,
    String? gratitudeItems,
    int? weatherMoodImpact,
    int? socialBattery,
    int? creativeEnergy,
    int? emotionalStability,
    int? focusLevel,
    int? lifeSatisfaction,
    String? voiceRecordingPath,

    // ✅ NUEVOS PARÁMETROS
    String userName = 'Usuario',
    // AI parameter removed
  }) async {

    // 1. Primero guardar la entrada normalmente
    final success = await super.saveDailyEntry(
      userId: userId,
      freeReflection: freeReflection,
      innerReflection: innerReflection,
      completedActivitiesToday: completedActivitiesToday,
      goalsSummary: goalsSummary,
      positiveTags: positiveTags,
      negativeTags: negativeTags,
      worthIt: worthIt,
      moodScore: moodScore,
      energyLevel: energyLevel,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
      anxietyLevel: anxietyLevel,
      motivationLevel: motivationLevel,
      socialInteraction: socialInteraction,
      physicalActivity: physicalActivity,
      workProductivity: workProductivity,
      sleepHours: sleepHours,
      waterIntake: waterIntake,
      meditationMinutes: meditationMinutes,
      exerciseMinutes: exerciseMinutes,
      screenTimeHours: screenTimeHours,
      gratitudeItems: gratitudeItems,
      weatherMoodImpact: weatherMoodImpact,
      socialBattery: socialBattery,
      creativeEnergy: creativeEnergy,
      emotionalStability: emotionalStability,
      focusLevel: focusLevel,
      lifeSatisfaction: lifeSatisfaction,
      voiceRecordingPath: voiceRecordingPath,
    );

    // AI recommendations removed

    return success;
  }

  // AI recommendations method removed

  // AI recommendation methods removed

  /// 🔄 Regenerar recomendaciones manualmente (AI removed)
  Future<void> regenerateRecommendations(int userId, String userName) async {
    if (todayEntry == null) {
      _logger.w('❌ No hay entrada de hoy para analizar');
      return;
    }

    // AI recommendations removed
    _logger.i('✅ Recommendations generation disabled - AI removed');
  }
}