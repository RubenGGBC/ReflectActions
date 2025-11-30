// ============================================================================
// RUN ANALYTICS SEEDER - STANDALONE SCRIPT
// ============================================================================
// Este script ejecuta el seeder de datos para Analytics V4
//
// EJECUCIÓN:
// flutter run lib/test_data/run_analytics_seeder.dart
//
// O desde una pantalla de desarrollo:
// await runAnalyticsSeeder(userId: 1);
// ============================================================================

import 'package:flutter/foundation.dart';
import '../data/services/optimized_database_service.dart';
import 'v4_analytics_test_data_seeder.dart';

/// Ejecuta el seeder de datos para Analytics V4
Future<void> runAnalyticsSeeder({int userId = 1}) async {
  if (!kDebugMode) {
    debugPrint('⚠️ Este script solo se ejecuta en modo debug');
    return;
  }

  debugPrint('');
  debugPrint('╔════════════════════════════════════════════════════════════╗');
  debugPrint('║  🌱 SEEDER DE DATOS PARA ANALYTICS V4                      ║');
  debugPrint('╚════════════════════════════════════════════════════════════╝');
  debugPrint('');
  debugPrint('👤 Usuario ID: $userId');
  debugPrint('');

  try {
    // Paso 1: Inicializar servicio de base de datos
    debugPrint('📦 [1/4] Inicializando servicio de base de datos...');
    final databaseService = OptimizedDatabaseService();
    final db = await databaseService.database;
    debugPrint('    ✅ Base de datos inicializada');
    debugPrint('');

    // Paso 2: Verificar si el usuario existe
    debugPrint('🔍 [2/4] Verificando usuario...');
    final userCheck = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userCheck.isEmpty) {
      debugPrint('    ⚠️  Usuario no encontrado, creando usuario de prueba...');

      // Crear usuario de prueba
      await db.insert('users', {
        'id': userId,
        'email': 'test@analytics.com',
        'password_hash': 'test_hash_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test User',
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('    ✅ Usuario de prueba creado');
    } else {
      final user = userCheck.first;
      debugPrint('    ✅ Usuario encontrado: ${user['email']}');
    }
    debugPrint('');

    // Paso 3: Limpiar datos existentes (opcional)
    debugPrint('🧹 [3/4] Limpiando datos existentes...');
    final deletedEntries = await db.delete(
      'daily_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final deletedMoments = await db.delete(
      'interactive_moments',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final deletedGoals = await db.delete(
      'user_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    debugPrint('    🗑️  Eliminadas $deletedEntries entradas diarias');
    debugPrint('    🗑️  Eliminados $deletedMoments momentos');
    debugPrint('    🗑️  Eliminadas $deletedGoals metas');
    debugPrint('');

    // Paso 4: Ejecutar el seeder
    debugPrint('🌱 [4/4] Generando datos de prueba...');
    debugPrint('    ⏳ Esto puede tomar 10-15 segundos...');
    debugPrint('');

    final seeder = V4AnalyticsTestDataSeeder(databaseService);
    await seeder.seedV4AnalyticsData(userId);

    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════════╗');
    debugPrint('║  ✅ DATOS GENERADOS EXITOSAMENTE                           ║');
    debugPrint('╚════════════════════════════════════════════════════════════╝');
    debugPrint('');
    debugPrint('📊 Resumen de datos generados:');

    // Verificar y mostrar resumen
    final entriesCount = await db.query(
      'daily_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final momentsCount = await db.query(
      'interactive_moments',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final goalsCount = await db.query(
      'user_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    debugPrint('   📝 ${entriesCount.length} entradas diarias');
    debugPrint('   ⚡ ${momentsCount.length} momentos interactivos');
    debugPrint('   🎯 ${goalsCount.length} metas');
    debugPrint('');
    debugPrint('🎉 ¡Listo! Ahora puedes abrir Analytics V4 para ver los datos.');
    debugPrint('');

  } catch (e, stackTrace) {
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════════╗');
    debugPrint('║  ❌ ERROR AL GENERAR DATOS                                 ║');
    debugPrint('╚════════════════════════════════════════════════════════════╝');
    debugPrint('');
    debugPrint('Error: $e');
    debugPrint('');
    debugPrint('Stack trace:');
    debugPrint('$stackTrace');
    debugPrint('');

    rethrow;
  }
}

/// Verifica el estado actual de los datos
Future<void> checkDataStatus({int userId = 1}) async {
  debugPrint('');
  debugPrint('📊 Verificando estado de datos para usuario $userId...');
  debugPrint('');

  try {
    final databaseService = OptimizedDatabaseService();
    final db = await databaseService.database;

    final entries = await db.query(
      'daily_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final moments = await db.query(
      'interactive_moments',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final goals = await db.query(
      'user_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final completedGoals = goals.where((g) => g['status'] == 'completed').length;
    final activeGoals = goals.where((g) => g['status'] == 'active').length;

    debugPrint('Estado actual:');
    debugPrint('  📝 Entradas diarias: ${entries.length}');
    debugPrint('  ⚡ Momentos interactivos: ${moments.length}');
    debugPrint('  🎯 Metas totales: ${goals.length}');
    debugPrint('     ✅ Completadas: $completedGoals');
    debugPrint('     🔄 Activas: $activeGoals');
    debugPrint('');

    if (entries.isEmpty && moments.isEmpty && goals.isEmpty) {
      debugPrint('⚠️  No hay datos. Ejecuta runAnalyticsSeeder() para generar.');
    } else {
      debugPrint('✅ Datos presentes. Analytics V4 debería mostrar información.');
    }

  } catch (e) {
    debugPrint('❌ Error verificando datos: $e');
  }

  debugPrint('');
}

/// Limpia todos los datos de prueba
Future<void> clearAnalyticsData({int userId = 1}) async {
  debugPrint('');
  debugPrint('🧹 Limpiando datos de Analytics para usuario $userId...');
  debugPrint('');

  try {
    final databaseService = OptimizedDatabaseService();
    final db = await databaseService.database;

    await db.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('user_goals', where: 'user_id = ?', whereArgs: [userId]);

    debugPrint('✅ Datos eliminados exitosamente');
    debugPrint('');
  } catch (e) {
    debugPrint('❌ Error limpiando datos: $e');
    debugPrint('');
  }
}
