// ============================================================================
// EJEMPLO COMPLETO DE USO - Datos de Prueba para Analytics V4
// ============================================================================
// Este archivo muestra diferentes formas de usar los seeders de datos de prueba
// en tu aplicación ReflectActions
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../lib/data/services/optimized_database_service.dart';
import '../lib/presentation/providers/optimized_providers.dart';
import 'simple_analytics_data_seeder.dart';

// ============================================================================
// EJEMPLO 1: Botón de Desarrollo en una Pantalla
// ============================================================================

class DevelopmentScreen extends StatelessWidget {
  const DevelopmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('Por favor inicia sesión primero')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('🧪 Herramientas de Desarrollo'),
        backgroundColor: Color(0xFF1A1A1A),
      ),
      backgroundColor: Color(0xFF000000),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Datos de Prueba para Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Usuario: ${currentUser.email} (ID: ${currentUser.id})',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 24),

            // Botón: Generar datos completos
            _buildActionButton(
              context,
              icon: Icons.auto_awesome,
              title: 'Generar Datos Completos',
              subtitle: '90 días de entradas, momentos y metas',
              color: Color(0xFF8b5cf6),
              onPressed: () => _generateFullData(context, currentUser.id),
            ),
            SizedBox(height: 12),

            // Botón: Solo entradas diarias
            _buildActionButton(
              context,
              icon: Icons.calendar_today,
              title: 'Solo Entradas Diarias',
              subtitle: '90 días de métricas de bienestar',
              color: Color(0xFF3b82f6),
              onPressed: () => _generateDailyEntries(context, currentUser.id),
            ),
            SizedBox(height: 12),

            // Botón: Solo momentos
            _buildActionButton(
              context,
              icon: Icons.flash_on,
              title: 'Solo Quick Moments',
              subtitle: '30 días de momentos interactivos',
              color: Color(0xFF10b981),
              onPressed: () => _generateQuickMoments(context, currentUser.id),
            ),
            SizedBox(height: 12),

            // Botón: Solo metas
            _buildActionButton(
              context,
              icon: Icons.flag,
              title: 'Solo Metas',
              subtitle: '15 metas variadas',
              color: Color(0xFFf59e0b),
              onPressed: () => _generateGoals(context, currentUser.id),
            ),
            SizedBox(height: 24),

            Divider(color: Colors.white24),
            SizedBox(height: 12),

            // Botón de limpieza
            _buildActionButton(
              context,
              icon: Icons.delete_forever,
              title: 'Limpiar Todos los Datos',
              subtitle: 'Eliminar datos de prueba',
              color: Color(0xFFef4444),
              onPressed: () => _confirmAndClearData(context, currentUser.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1A1A1A),
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
        ],
      ),
    );
  }

  Future<void> _generateFullData(BuildContext context, int userId) async {
    _showLoadingDialog(context, 'Generando datos completos...');

    try {
      final dbService = context.read<OptimizedDatabaseService>();
      final seeder = SimpleAnalyticsDataSeeder(dbService);

      await seeder.seedAllData(userId: userId, daysBack: 90);

      Navigator.pop(context); // Cierra loading
      _showSuccessDialog(context,
        'Datos generados exitosamente!\n\n'
        '✅ 90 días de entradas\n'
        '✅ ~150 momentos\n'
        '✅ 15 metas'
      );
    } catch (e) {
      Navigator.pop(context); // Cierra loading
      _showErrorDialog(context, 'Error generando datos: $e');
    }
  }

  Future<void> _generateDailyEntries(BuildContext context, int userId) async {
    _showLoadingDialog(context, 'Generando entradas diarias...');

    try {
      final dbService = context.read<OptimizedDatabaseService>();
      final seeder = SimpleAnalyticsDataSeeder(dbService);

      await seeder.seedDailyEntries(userId: userId, daysBack: 90);

      Navigator.pop(context);
      _showSuccessDialog(context, '✅ 90 entradas diarias generadas!');
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, 'Error: $e');
    }
  }

  Future<void> _generateQuickMoments(BuildContext context, int userId) async {
    _showLoadingDialog(context, 'Generando momentos interactivos...');

    try {
      final dbService = context.read<OptimizedDatabaseService>();
      final seeder = SimpleAnalyticsDataSeeder(dbService);

      await seeder.seedQuickMoments(userId: userId, daysBack: 30);

      Navigator.pop(context);
      _showSuccessDialog(context, '✅ Momentos interactivos generados!');
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, 'Error: $e');
    }
  }

  Future<void> _generateGoals(BuildContext context, int userId) async {
    _showLoadingDialog(context, 'Generando metas...');

    try {
      final dbService = context.read<OptimizedDatabaseService>();
      final seeder = SimpleAnalyticsDataSeeder(dbService);

      await seeder.seedGoals(userId: userId);

      Navigator.pop(context);
      _showSuccessDialog(context, '✅ 15 metas generadas!');
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, 'Error: $e');
    }
  }

  Future<void> _confirmAndClearData(BuildContext context, int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text('¿Confirmar eliminación?',
          style: TextStyle(color: Colors.white)),
        content: Text(
          'Esto eliminará TODOS los datos de prueba para este usuario.\n\n'
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _showLoadingDialog(context, 'Eliminando datos...');

    try {
      final dbService = context.read<OptimizedDatabaseService>();
      final seeder = SimpleAnalyticsDataSeeder(dbService);

      await seeder.clearAllData(userId: userId);

      Navigator.pop(context);
      _showSuccessDialog(context, '🗑️ Datos eliminados exitosamente');
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, 'Error: $e');
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF8b5cf6)),
            SizedBox(width: 16),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10b981)),
            SizedBox(width: 8),
            Text('Éxito', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EJEMPLO 2: Uso Programático Directo
// ============================================================================

class AnalyticsTestHelper {
  static Future<void> setupTestData({
    required BuildContext context,
    int daysBack = 90,
  }) async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final dbService = context.read<OptimizedDatabaseService>();
    final seeder = SimpleAnalyticsDataSeeder(dbService);

    // Generar datos
    await seeder.seedAllData(userId: userId, daysBack: daysBack);

    print('✅ Datos de prueba configurados para Analytics V4');
  }

  static Future<void> resetTestData({
    required BuildContext context,
  }) async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    final dbService = context.read<OptimizedDatabaseService>();
    final seeder = SimpleAnalyticsDataSeeder(dbService);

    await seeder.clearAllData(userId: userId);

    print('🗑️ Datos de prueba eliminados');
  }
}

// ============================================================================
// EJEMPLO 3: Integración en Main (Solo Desarrollo)
// ============================================================================

/*
// En tu main.dart, solo en modo debug:

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... tu código de inicialización ...

  runApp(MyApp());

  // SOLO EN DEBUG: Generar datos de prueba automáticamente
  if (kDebugMode) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Esperar a que el contexto esté disponible
      await Future.delayed(Duration(seconds: 2));

      // Obtener el contexto del navigator key
      final context = navigatorKey.currentContext;
      if (context != null) {
        try {
          await AnalyticsTestHelper.setupTestData(context: context);
          print('🧪 Datos de prueba cargados automáticamente');
        } catch (e) {
          print('⚠️ Error cargando datos de prueba: $e');
        }
      }
    });
  }
}
*/

// ============================================================================
// EJEMPLO 4: Comando de Consola Rápido
// ============================================================================

/*
// Crea un archivo separado test_data/generate_data.dart:

import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // Conectar a la base de datos directamente
  final dbPath = join(await getDatabasesPath(), 'reflect_zen.db');
  final db = await openDatabase(dbPath);

  print('🌱 Generando datos de prueba...');

  // Ejecutar el script SQL
  final sqlScript = await File('test_data/analytics_test_data.sql').readAsString();

  // Dividir y ejecutar cada statement
  final statements = sqlScript.split(';');
  for (final stmt in statements) {
    final trimmed = stmt.trim();
    if (trimmed.isNotEmpty && !trimmed.startsWith('--')) {
      await db.execute(trimmed);
    }
  }

  print('✅ Datos de prueba generados!');
  await db.close();
}

// Ejecutar desde terminal:
// dart test_data/generate_data.dart
*/
