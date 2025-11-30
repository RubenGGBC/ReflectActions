// ============================================================================
// EJECUTOR TEMPORAL DE SEEDER - ANALYTICS V4
// ============================================================================
// Este archivo ejecuta el seeder de datos para Analytics V4
//
// EJECUTAR:
// dart execute_seeder.dart
// ============================================================================

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  print('');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  🌱 EJECUTANDO SEEDER DE DATOS PARA ANALYTICS V4          ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  try {
    // Inicializar sqflite_ffi para desarrollo en desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Buscar la base de datos
    final dbPath = await _findDatabase();
    if (dbPath == null) {
      print('❌ No se pudo encontrar la base de datos.');
      print('   Ejecuta la app primero para crear la base de datos.');
      exit(1);
    }

    print('📁 Base de datos encontrada: $dbPath');
    print('');

    // Abrir base de datos
    final db = await openDatabase(dbPath);

    // Paso 1: Verificar/crear usuario
    print('🔍 [1/4] Verificando usuario...');
    final userId = await _ensureUserExists(db);
    print('    ✅ Usuario ID: $userId');
    print('');

    // Paso 2: Limpiar datos existentes
    print('🧹 [2/4] Limpiando datos existentes...');
    await _clearExistingData(db, userId);
    print('');

    // Paso 3: Insertar datos de prueba
    print('🌱 [3/4] Insertando datos de prueba...');
    print('    ⏳ Esto puede tomar 10-15 segundos...');
    await _insertTestData(db, userId);
    print('');

    // Paso 4: Verificar datos insertados
    print('✅ [4/4] Verificando datos insertados...');
    await _verifyData(db, userId);
    print('');

    await db.close();

    print('╔════════════════════════════════════════════════════════════╗');
    print('║  ✅ SEEDER EJECUTADO EXITOSAMENTE                          ║');
    print('╚════════════════════════════════════════════════════════════╝');
    print('');
    print('🎉 ¡Listo! Abre la app y navega a Analytics V4 para ver los datos.');
    print('');

  } catch (e, stackTrace) {
    print('');
    print('╔════════════════════════════════════════════════════════════╗');
    print('║  ❌ ERROR AL EJECUTAR SEEDER                               ║');
    print('╚════════════════════════════════════════════════════════════╝');
    print('');
    print('Error: $e');
    print('');
    print('Stack trace:');
    print('$stackTrace');
    print('');
    exit(1);
  }
}

Future<String?> _findDatabase() async {
  // Posibles ubicaciones de la base de datos
  final possiblePaths = [
    // Windows
    path.join(Platform.environment['APPDATA'] ?? '', 'ReflectActions', 'databases', 'reflect_zen.db'),
    // Desarrollo local
    'databases/reflect_zen.db',
    '.dart_tool/sqflite_common_ffi/databases/reflect_zen.db',
  ];

  for (final dbPath in possiblePaths) {
    if (await File(dbPath).exists()) {
      return dbPath;
    }
  }

  return null;
}

Future<int> _ensureUserExists(Database db) async {
  final users = await db.query('users', limit: 1);

  if (users.isNotEmpty) {
    return users.first['id'] as int;
  }

  // Crear usuario de prueba
  final userId = await db.insert('users', {
    'email': 'test@analytics.com',
    'password_hash': 'test_hash_${DateTime.now().millisecondsSinceEpoch}',
    'name': 'Test User Analytics',
    'created_at': DateTime.now().toIso8601String(),
  });

  return userId;
}

Future<void> _clearExistingData(Database db, int userId) async {
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

  print('    🗑️  Eliminadas $deletedEntries entradas diarias');
  print('    🗑️  Eliminados $deletedMoments momentos');
  print('    🗑️  Eliminadas $deletedGoals metas');
}

Future<void> _insertTestData(Database db, int userId) async {
  // Leer el archivo SQL
  final sqlFile = File('test_data/analytics_test_data.sql');

  if (!await sqlFile.exists()) {
    print('    ⚠️  Archivo SQL no encontrado, generando datos programáticamente...');
    await _generateDataProgrammatically(db, userId);
    return;
  }

  // Ejecutar el SQL
  final sqlContent = await sqlFile.readAsString();

  // Dividir en statements individuales
  final statements = sqlContent
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && !s.startsWith('--'))
      .toList();

  int executed = 0;
  for (final stmt in statements) {
    if (stmt.trim().isEmpty) continue;

    try {
      // Reemplazar user_id = 1 con el userId actual
      final modifiedStmt = stmt.replaceAll('user_id, 1,', 'user_id, $userId,');
      await db.execute(modifiedStmt);
      executed++;

      if (executed % 10 == 0) {
        print('    📝 Ejecutados $executed statements...');
      }
    } catch (e) {
      // Ignorar errores de sintaxis en comentarios
      if (!stmt.startsWith('--')) {
        print('    ⚠️  Error en statement: ${stmt.substring(0, 50)}...');
      }
    }
  }

  print('    ✅ $executed statements ejecutados');
}

Future<void> _generateDataProgrammatically(Database db, int userId) async {
  final now = DateTime.now();
  int totalInserted = 0;

  // Generar 30 días de entradas diarias
  print('    📝 Generando entradas diarias...');
  for (int i = 0; i < 30; i++) {
    final date = now.subtract(Duration(days: i));
    final progress = (30 - i) / 30.0; // 0.0 a 1.0

    await db.insert('daily_entries', {
      'user_id': userId,
      'entry_date': date.toIso8601String().split('T')[0],
      'mood_score': (4 + (progress * 5)).round(),
      'energy_level': (4 + (progress * 5)).round(),
      'stress_level': (8 - (progress * 5)).round(),
      'sleep_quality': (4 + (progress * 4)).round(),
      'anxiety_level': (7 - (progress * 4)).round(),
      'motivation_level': (4 + (progress * 4)).round(),
      'social_interaction': (4 + (progress * 4)).round(),
      'physical_activity': (3 + (progress * 5)).round(),
      'work_productivity': (5 + (progress * 3)).round(),
      'emotional_stability': (4 + (progress * 4)).round(),
      'focus_level': (4 + (progress * 4)).round(),
      'life_satisfaction': (4 + (progress * 4)).round(),
      'sleep_hours': 6.0 + (progress * 2.0),
      'water_intake': (4 + (progress * 5)).round(),
      'free_reflection': 'Día ${i + 1} de seguimiento.',
      'created_at': date.toIso8601String(),
    });
    totalInserted++;
  }

  // Generar 50 momentos
  print('    ⚡ Generando momentos interactivos...');
  for (int i = 0; i < 50; i++) {
    final date = now.subtract(Duration(days: i % 15));
    final hour = 6 + (i % 14);

    await db.insert('interactive_moments', {
      'user_id': userId,
      'entry_date': date.toIso8601String().split('T')[0],
      'emoji': '☕',
      'text': 'Momento interactivo #${i + 1}',
      'type': i % 3 == 0 ? 'negative' : 'positive',
      'intensity': 5 + (i % 4),
      'category': 'general',
      'time_str': '${hour.toString().padLeft(2, '0')}:00',
      'created_at': date.add(Duration(hours: hour)).toIso8601String(),
    });
    totalInserted++;
  }

  // Generar 10 metas
  print('    🎯 Generando metas...');
  final goals = [
    ['Meditación Diaria', 'mindfulness', true, 30, 30],
    ['Ejercicio Regular', 'physical', true, 21, 21],
    ['Lectura Nocturna', 'productivity', false, 14, 8],
    ['Hidratación', 'physical', false, 21, 12],
    ['Sueño Saludable', 'sleep', false, 30, 18],
  ];

  for (final goal in goals) {
    await db.insert('user_goals', {
      'user_id': userId,
      'title': goal[0],
      'description': 'Meta de ${goal[0]}',
      'target_value': goal[3],
      'current_value': goal[4],
      'status': goal[2] as bool ? 'completed' : 'active',
      'category': goal[1],
      'created_at': now.subtract(const Duration(days: 30)).toIso8601String(),
      'completed_at': goal[2] as bool ? now.subtract(const Duration(days: 5)).toIso8601String() : null,
    });
    totalInserted++;
  }

  print('    ✅ $totalInserted registros insertados');
}

Future<void> _verifyData(Database db, int userId) async {
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

  print('    📊 Resumen de datos insertados:');
  print('       📝 ${entries.length} entradas diarias');
  print('       ⚡ ${moments.length} momentos interactivos');
  print('       🎯 ${goals.length} metas');
}
