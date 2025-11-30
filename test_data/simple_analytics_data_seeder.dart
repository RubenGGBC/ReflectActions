// ============================================================================
// SIMPLE ANALYTICS DATA SEEDER
// ============================================================================
// Clase simplificada para generar datos de prueba para Analytics V4
//
// USO:
// ```dart
// final seeder = SimpleAnalyticsDataSeeder(databaseService);
// await seeder.seedAllData(userId: 1);
// ```
// ============================================================================

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../lib/data/services/optimized_database_service.dart';

class SimpleAnalyticsDataSeeder {
  final OptimizedDatabaseService _db;
  final Random _random = Random();

  SimpleAnalyticsDataSeeder(this._db);

  /// Siembra todos los datos de prueba
  Future<void> seedAllData({required int userId, int daysBack = 90}) async {
    debugPrint('🌱 Iniciando generación de datos de prueba...');

    try {
      await seedDailyEntries(userId: userId, daysBack: daysBack);
      await seedQuickMoments(userId: userId, daysBack: 30);
      await seedGoals(userId: userId);

      debugPrint('✅ Datos de prueba generados exitosamente!');
      debugPrint('   📊 $daysBack días de entradas');
      debugPrint('   ⚡ ~${30 * 5} momentos interactivos');
      debugPrint('   🎯 15 metas (5 completadas, 10 activas)');
    } catch (e) {
      debugPrint('❌ Error generando datos: $e');
      rethrow;
    }
  }

  /// Genera entradas diarias con tendencia de mejora
  Future<void> seedDailyEntries({required int userId, int daysBack = 90}) async {
    debugPrint('📝 Generando entradas diarias...');

    final db = await _db.database;
    final now = DateTime.now();

    for (int i = 0; i < daysBack; i++) {
      final date = now.subtract(Duration(days: i));

      // Factor de progreso: 0.0 (hace 90 días) a 1.0 (hoy)
      final progress = (daysBack - i) / daysBack;

      // Generar métricas con tendencia de mejora
      final metrics = _generateMetrics(progress);

      final entry = {
        'user_id': userId,
        'entry_date': date.toIso8601String().split('T')[0],
        'free_reflection': _generateReflection(metrics),
        'positive_tags': _generatePositiveTags(metrics['mood_score']!),
        'negative_tags': _generateNegativeTags(metrics['stress_level']!),

        // Métricas principales
        'mood_score': metrics['mood_score'],
        'energy_level': metrics['energy_level'],
        'stress_level': metrics['stress_level'],
        'sleep_quality': metrics['sleep_quality'],
        'anxiety_level': metrics['anxiety_level'],
        'motivation_level': metrics['motivation_level'],
        'social_interaction': metrics['social_interaction'],
        'physical_activity': metrics['physical_activity'],
        'work_productivity': metrics['work_productivity'],
        'emotional_stability': metrics['emotional_stability'],
        'focus_level': metrics['focus_level'],
        'life_satisfaction': metrics['life_satisfaction'],

        // Métricas adicionales
        'sleep_hours': metrics['sleep_hours'],
        'water_intake': metrics['water_intake'],
        'meditation_minutes': i % 3 == 0 ? (10 + (progress * 20)).round() : null,
        'exercise_minutes': i % 2 == 0 ? (15 + (progress * 30)).round() : null,
        'screen_time_hours': (8.0 - (progress * 2.0) + _randomVariation(1.0)),

        'created_at': date.add(Duration(hours: 20)).toIso8601String(),
      };

      await db.insert('daily_entries', entry,
        conflictAlgorithm: ConflictAlgorithm.replace);
    }

    debugPrint('✅ $daysBack entradas diarias generadas');
  }

  /// Genera momentos interactivos (Quick Moments)
  Future<void> seedQuickMoments({required int userId, int daysBack = 30}) async {
    debugPrint('⚡ Generando momentos interactivos...');

    final db = await _db.database;
    final now = DateTime.now();
    int totalMoments = 0;

    for (int day = 0; day < daysBack; day++) {
      final date = now.subtract(Duration(days: day));
      final momentsPerDay = 3 + _random.nextInt(5); // 3-7 momentos por día

      for (int i = 0; i < momentsPerDay; i++) {
        final hour = 6 + _random.nextInt(16); // 6 AM - 10 PM
        final minute = _random.nextInt(60);
        final timestamp = DateTime(date.year, date.month, date.day, hour, minute);

        final moment = _generateMoment(hour);

        final momentData = {
          'user_id': userId,
          'entry_date': date.toIso8601String().split('T')[0],
          'emoji': moment['emoji'],
          'text': moment['text'],
          'type': moment['type'],
          'intensity': moment['intensity'],
          'category': moment['category'],
          'time_str': '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          'created_at': timestamp.toIso8601String(),
        };

        await db.insert('interactive_moments', momentData);
        totalMoments++;
      }
    }

    debugPrint('✅ $totalMoments momentos interactivos generados');
  }

  /// Genera metas de usuario
  Future<void> seedGoals({required int userId}) async {
    debugPrint('🎯 Generando metas...');

    final db = await _db.database;
    final now = DateTime.now();

    final goals = [
      // Metas completadas
      _createGoalData(userId, 'Práctica Diaria de Meditación',
        'Meditar 10 minutos cada día', 'mindfulness', true, 30, 30, 45, 15),
      _createGoalData(userId, 'Caminatas Matutinas',
        'Caminar 20 minutos cada mañana', 'physical', true, 21, 21, 35, 14),
      _createGoalData(userId, 'Diario de Gratitud',
        'Escribir 3 cosas por las que estoy agradecido', 'emotional', true, 14, 14, 25, 11),
      _createGoalData(userId, 'Desintoxicación Digital',
        'No pantallas después de 9 PM', 'habits', true, 10, 10, 20, 10),
      _createGoalData(userId, 'Conexión Social Semanal',
        'Llamar a un amigo cada semana', 'social', true, 4, 4, 30, 2),

      // Metas activas (en progreso)
      _createGoalData(userId, 'Horario de Sueño Saludable',
        'Dormir a las 10:30 PM', 'sleep', false, 30, 18, 20, null),
      _createGoalData(userId, 'Manejo del Estrés',
        'Practicar respiración profunda', 'stress', false, 20, 12, 15, null),
      _createGoalData(userId, 'Hábito de Lectura',
        'Leer 30 minutos antes de dormir', 'productivity', false, 15, 8, 12, null),
      _createGoalData(userId, 'Meta de Hidratación',
        'Beber 8 vasos de agua al día', 'physical', false, 21, 9, 10, null),
      _createGoalData(userId, 'Alimentación Consciente',
        'Comer sin distracciones', 'mindfulness', false, 14, 6, 8, null),

      // Metas recién iniciadas
      _createGoalData(userId, 'Conexión con Naturaleza',
        'Tiempo en naturaleza semanalmente', 'emotional', false, 4, 1, 7, null),
      _createGoalData(userId, 'Rutina Matutina',
        'Completar rutina antes de 8 AM', 'productivity', false, 10, 3, 5, null),
      _createGoalData(userId, 'Ejercicio Regular',
        'Ejercicio 3 veces por semana', 'physical', false, 12, 2, 4, null),
      _createGoalData(userId, 'Práctica de Mindfulness',
        'Momentos de atención plena', 'mindfulness', false, 7, 2, 3, null),
      _createGoalData(userId, 'Reducción de Cafeína',
        'Máximo 2 cafés por día', 'habits', false, 7, 1, 1, null),
    ];

    for (final goal in goals) {
      await db.insert('user_goals', goal);
    }

    debugPrint('✅ ${goals.length} metas generadas (5 completadas, 10 activas)');
  }

  // ========================================================================
  // MÉTODOS AUXILIARES
  // ========================================================================

  /// Genera métricas con tendencia de mejora
  Map<String, int> _generateMetrics(double progress) {
    // progress: 0.0 (peor) a 1.0 (mejor)

    return {
      'mood_score': _trendingValue(4, 9, progress, 2),
      'energy_level': _trendingValue(4, 9, progress, 2),
      'stress_level': _trendingValue(8, 3, progress, 2), // Disminuye
      'sleep_quality': _trendingValue(4, 8, progress, 2),
      'anxiety_level': _trendingValue(7, 3, progress, 2), // Disminuye
      'motivation_level': _trendingValue(4, 8, progress, 2),
      'social_interaction': _trendingValue(4, 8, progress, 2),
      'physical_activity': _trendingValue(3, 8, progress, 3),
      'work_productivity': _trendingValue(5, 8, progress, 2),
      'emotional_stability': _trendingValue(4, 8, progress, 2),
      'focus_level': _trendingValue(4, 8, progress, 2),
      'life_satisfaction': _trendingValue(4, 8, progress, 2),
      'sleep_hours': _trendingValue(5, 8, progress, 1),
      'water_intake': _trendingValue(4, 9, progress, 2),
    };
  }

  /// Calcula un valor con tendencia y variación aleatoria
  int _trendingValue(int min, int max, double progress, int variation) {
    final base = min + ((max - min) * progress);
    final randomOffset = _randomVariation(variation.toDouble());
    return (base + randomOffset).round().clamp(1, 10);
  }

  /// Genera variación aleatoria
  double _randomVariation(double range) {
    return (_random.nextDouble() - 0.5) * range * 2;
  }

  /// Genera reflexión basada en métricas
  String _generateReflection(Map<String, int> metrics) {
    final mood = metrics['mood_score']!;
    final energy = metrics['energy_level']!;

    if (mood >= 8 && energy >= 8) {
      return _pickRandom([
        'Día increíble! Me siento energizado y motivado.',
        'Excelente día con alta energía y buen ánimo.',
        'Todo fluyó naturalmente hoy, me siento genial.',
      ]);
    } else if (mood >= 7) {
      return _pickRandom([
        'Buen día en general, me siento positivo.',
        'Día productivo y balanceado.',
        'Me siento satisfecho con el progreso de hoy.',
      ]);
    } else if (mood >= 5) {
      return _pickRandom([
        'Día normal, con altibajos pero estable.',
        'Me siento equilibrado, nada extraordinario.',
        'Día tranquilo sin grandes eventos.',
      ]);
    } else {
      return _pickRandom([
        'Día retador, pero sigo comprometido.',
        'No fue mi mejor día, pero mañana será mejor.',
        'Aprendiendo a ser paciente conmigo mismo.',
      ]);
    }
  }

  /// Genera tags positivos
  String _generatePositiveTags(int mood) {
    final allTags = [
      'agradecido', 'motivado', 'enfocado', 'energizado', 'tranquilo',
      'optimista', 'productivo', 'confiado', 'equilibrado', 'satisfecho'
    ];

    final count = mood >= 7 ? 3 : (mood >= 5 ? 2 : 1);
    allTags.shuffle(_random);

    return '"[' + allTags.take(count).map((t) => '"$t"').join(', ') + ']"';
  }

  /// Genera tags negativos
  String _generateNegativeTags(int stress) {
    if (stress <= 4) return '"[]"';

    final allTags = [
      'estresado', 'cansado', 'ansioso', 'abrumado', 'distraído'
    ];

    final count = stress >= 7 ? 2 : 1;
    allTags.shuffle(_random);

    return '"[' + allTags.take(count).map((t) => '"$t"').join(', ') + ']"';
  }

  /// Genera un momento interactivo
  Map<String, dynamic> _generateMoment(int hour) {
    final isMorning = hour <= 10;
    final isEvening = hour >= 18;
    final isPositive = _random.nextDouble() < 0.75; // 75% positivos

    if (isPositive) {
      if (isMorning) {
        return _pickRandomMap([
          {'emoji': '☕', 'text': 'Perfecto café de la mañana', 'category': 'routine'},
          {'emoji': '🌅', 'text': 'Hermoso amanecer', 'category': 'nature'},
          {'emoji': '💪', 'text': 'Gran sesión de ejercicio', 'category': 'exercise'},
          {'emoji': '🧘‍♀️', 'text': 'Meditación centrada', 'category': 'mindfulness'},
        ], 'positive', 7);
      } else if (isEvening) {
        return _pickRandomMap([
          {'emoji': '🌙', 'text': 'Reflexión nocturna tranquila', 'category': 'reflection'},
          {'emoji': '👨‍👩‍👧‍👦', 'text': 'Tiempo de calidad con familia', 'category': 'family'},
          {'emoji': '📖', 'text': 'Lectura relajante', 'category': 'leisure'},
          {'emoji': '🎵', 'text': 'Música perfecta para el momento', 'category': 'entertainment'},
        ], 'positive', 8);
      } else {
        return _pickRandomMap([
          {'emoji': '🎯', 'text': 'Logré tarea importante', 'category': 'productivity'},
          {'emoji': '🥗', 'text': 'Almuerzo saludable', 'category': 'nutrition'},
          {'emoji': '📞', 'text': 'Conversación inspiradora', 'category': 'social'},
          {'emoji': '✅', 'text': 'Completé mi objetivo', 'category': 'achievement'},
        ], 'positive', 8);
      }
    } else {
      return _pickRandomMap([
        {'emoji': '😓', 'text': 'Momento de estrés', 'category': 'stress'},
        {'emoji': '😟', 'text': 'Preocupación temporal', 'category': 'anxiety'},
        {'emoji': '😴', 'text': 'Bajón de energía', 'category': 'energy'},
        {'emoji': '📱', 'text': 'Demasiado tiempo en pantalla', 'category': 'habits'},
      ], 'negative', 5);
    }
  }

  /// Selecciona momento aleatorio y añade tipo e intensidad
  Map<String, dynamic> _pickRandomMap(List<Map<String, String>> options,
      String type, int baseIntensity) {
    final moment = options[_random.nextInt(options.length)];
    return {
      ...moment,
      'type': type,
      'intensity': baseIntensity + _random.nextInt(3) - 1, // ±1
    };
  }

  /// Crea datos de meta
  Map<String, dynamic> _createGoalData(
    int userId, String title, String description, String category,
    bool isCompleted, int targetValue, int currentValue,
    int createdDaysAgo, int? completedDaysAgo
  ) {
    final now = DateTime.now();
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'target_value': targetValue,
      'current_value': currentValue,
      'status': isCompleted ? 'completed' : 'active',
      'category': category,
      'created_at': now.subtract(Duration(days: createdDaysAgo)).toIso8601String(),
      'completed_at': completedDaysAgo != null
        ? now.subtract(Duration(days: completedDaysAgo)).toIso8601String()
        : null,
    };
  }

  /// Selecciona elemento aleatorio de lista
  T _pickRandom<T>(List<T> items) => items[_random.nextInt(items.length)];

  /// Limpia todos los datos de prueba
  Future<void> clearAllData({required int userId}) async {
    debugPrint('🗑️ Limpiando datos de prueba...');

    final db = await _db.database;

    await db.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('user_goals', where: 'user_id = ?', whereArgs: [userId]);

    debugPrint('✅ Datos de prueba eliminados');
  }
}

// ============================================================================
// EJEMPLO DE USO
// ============================================================================
/*
import 'package:your_app/test_data/simple_analytics_data_seeder.dart';
import 'package:your_app/data/services/optimized_database_service.dart';

// En tu código de prueba o desarrollo:
final dbService = OptimizedDatabaseService();
final seeder = SimpleAnalyticsDataSeeder(dbService);

// Generar todos los datos
await seeder.seedAllData(userId: 1, daysBack: 90);

// O generar componentes individuales
await seeder.seedDailyEntries(userId: 1, daysBack: 60);
await seeder.seedQuickMoments(userId: 1, daysBack: 30);
await seeder.seedGoals(userId: 1);

// Limpiar datos cuando termines
await seeder.clearAllData(userId: 1);
*/
