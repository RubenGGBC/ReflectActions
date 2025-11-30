// 🔍 Script de Verificación de Datos Seedeados
// Ejecuta este script para verificar que los datos se insertaron correctamente

import 'package:flutter/material.dart';
import '../data/services/optimized_database_service.dart';

Future<Map<String, dynamic>> verifySeededData({int userId = 1}) async {
  final databaseService = OptimizedDatabaseService();
  final db = await databaseService.database;

  final results = <String, dynamic>{};

  try {
    // Verificar entradas diarias
    final entriesResult = await db.rawQuery(
      'SELECT COUNT(*) as count, MIN(entry_date) as oldest, MAX(entry_date) as newest FROM daily_entries WHERE user_id = ?',
      [userId]
    );
    results['daily_entries'] = {
      'count': entriesResult.first['count'],
      'oldest_date': entriesResult.first['oldest'],
      'newest_date': entriesResult.first['newest'],
    };

    // Verificar momentos interactivos
    final momentsResult = await db.rawQuery(
      'SELECT COUNT(*) as count, type, COUNT(*) as type_count FROM interactive_moments WHERE user_id = ? GROUP BY type',
      [userId]
    );
    final totalMoments = await db.rawQuery(
      'SELECT COUNT(*) as count FROM interactive_moments WHERE user_id = ?',
      [userId]
    );
    results['interactive_moments'] = {
      'total': totalMoments.first['count'],
      'by_type': momentsResult,
    };

    // Verificar metas
    final goalsResult = await db.rawQuery(
      'SELECT COUNT(*) as count, status, COUNT(*) as status_count FROM user_goals WHERE user_id = ? GROUP BY status',
      [userId]
    );
    final totalGoals = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_goals WHERE user_id = ?',
      [userId]
    );
    results['user_goals'] = {
      'total': totalGoals.first['count'],
      'by_status': goalsResult,
    };

    // Verificar promedio de métricas recientes (últimos 7 días)
    final metricsResult = await db.rawQuery('''
      SELECT
        AVG(mood_score) as avg_mood,
        AVG(energy_level) as avg_energy,
        AVG(stress_level) as avg_stress,
        AVG(motivation_score) as avg_motivation
      FROM daily_entries
      WHERE user_id = ? AND entry_date >= date('now', '-7 days')
    ''', [userId]);
    results['recent_metrics'] = metricsResult.first;

    debugPrint('\n═══════════════════════════════════════════════');
    debugPrint('📊 VERIFICACIÓN DE DATOS SEEDEADOS');
    debugPrint('═══════════════════════════════════════════════\n');

    debugPrint('📝 Entradas Diarias:');
    debugPrint('   Total: ${results['daily_entries']['count']}');
    debugPrint('   Rango: ${results['daily_entries']['oldest']} → ${results['daily_entries']['newest']}\n');

    debugPrint('⚡ Momentos Interactivos:');
    debugPrint('   Total: ${results['interactive_moments']['total']}');
    for (final typeRow in results['interactive_moments']['by_type']) {
      debugPrint('   ${typeRow['type']}: ${typeRow['type_count']}');
    }
    debugPrint('');

    debugPrint('🎯 Metas:');
    debugPrint('   Total: ${results['user_goals']['total']}');
    for (final statusRow in results['user_goals']['by_status']) {
      debugPrint('   ${statusRow['status']}: ${statusRow['status_count']}');
    }
    debugPrint('');

    debugPrint('📈 Métricas Promedio (últimos 7 días):');
    debugPrint('   Mood: ${(results['recent_metrics']['avg_mood'] as num?)?.toStringAsFixed(1) ?? 'N/A'}/10');
    debugPrint('   Energy: ${(results['recent_metrics']['avg_energy'] as num?)?.toStringAsFixed(1) ?? 'N/A'}/10');
    debugPrint('   Stress: ${(results['recent_metrics']['avg_stress'] as num?)?.toStringAsFixed(1) ?? 'N/A'}/10');
    debugPrint('   Motivation: ${(results['recent_metrics']['avg_motivation'] as num?)?.toStringAsFixed(1) ?? 'N/A'}/10\n');

    debugPrint('═══════════════════════════════════════════════\n');

    // Verificar que los datos esperados están presentes
    final entriesCount = results['daily_entries']['count'] as int;
    final momentsCount = results['interactive_moments']['total'] as int;
    final goalsCount = results['user_goals']['total'] as int;

    if (entriesCount >= 60 && momentsCount >= 100 && goalsCount >= 10) {
      debugPrint('✅ VERIFICACIÓN EXITOSA - Todos los datos están presentes\n');
      return {'success': true, 'results': results};
    } else {
      debugPrint('⚠️ ADVERTENCIA - Algunos datos faltan:');
      if (entriesCount < 60) debugPrint('   - Entradas: esperado 60, encontrado $entriesCount');
      if (momentsCount < 100) debugPrint('   - Momentos: esperado 150+, encontrado $momentsCount');
      if (goalsCount < 10) debugPrint('   - Metas: esperado 12+, encontrado $goalsCount');
      debugPrint('');
      return {'success': false, 'results': results};
    }

  } catch (e) {
    debugPrint('❌ Error verificando datos: $e');
    return {'success': false, 'error': e.toString()};
  }
}

/// Widget para mostrar la verificación de datos
class DataVerificationScreen extends StatefulWidget {
  const DataVerificationScreen({Key? key}) : super(key: key);

  @override
  State<DataVerificationScreen> createState() => _DataVerificationScreenState();
}

class _DataVerificationScreenState extends State<DataVerificationScreen> {
  Map<String, dynamic>? _verificationResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _verifyData();
  }

  Future<void> _verifyData() async {
    setState(() => _isLoading = true);
    final results = await verifySeededData(userId: 1);
    setState(() {
      _verificationResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Datos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _verificationResults == null
              ? const Center(child: Text('Sin datos'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildResults(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _verifyData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildResults() {
    final success = _verificationResults!['success'] as bool;
    final results = _verificationResults!['results'] as Map<String, dynamic>?;

    if (results == null) {
      return Card(
        color: Colors.red[100],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: ${_verificationResults!['error']}',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Estado general
        Card(
          color: success ? Colors.green[100] : Colors.orange[100],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.warning,
                  color: success ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    success
                        ? 'Verificación Exitosa'
                        : 'Algunos datos faltan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: success ? Colors.green[900] : Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Entradas diarias
        _buildDataCard(
          title: 'Entradas Diarias',
          icon: Icons.calendar_today,
          color: Colors.blue,
          data: results['daily_entries'],
          expected: '60+',
        ),

        // Momentos
        _buildDataCard(
          title: 'Momentos Interactivos',
          icon: Icons.flash_on,
          color: Colors.purple,
          data: results['interactive_moments'],
          expected: '150+',
        ),

        // Metas
        _buildDataCard(
          title: 'Metas',
          icon: Icons.flag,
          color: Colors.orange,
          data: results['user_goals'],
          expected: '12+',
        ),

        // Métricas
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Métricas Promedio (7 días)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMetricRow('Mood', results['recent_metrics']['avg_mood']),
                _buildMetricRow('Energy', results['recent_metrics']['avg_energy']),
                _buildMetricRow('Stress', results['recent_metrics']['avg_stress']),
                _buildMetricRow('Motivation', results['recent_metrics']['avg_motivation']),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard({
    required String title,
    required IconData icon,
    required Color color,
    required dynamic data,
    required String expected,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${data['total'] ?? data['count']} (esperado: $expected)',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value) {
    final doubleValue = (value as num?)?.toDouble() ?? 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            doubleValue > 0 ? '${doubleValue.toStringAsFixed(1)}/10' : 'N/A',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
