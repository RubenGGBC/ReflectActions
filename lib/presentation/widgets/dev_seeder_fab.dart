// ============================================================================
// DEV SEEDER FAB - Botón Flotante para Ejecutar Seeder
// ============================================================================
// Widget flotante que ejecuta el seeder de datos de Analytics V4
//
// USO: Agrégalo a cualquier pantalla temporalmente:
//
// Scaffold(
//   body: ...,
//   floatingActionButton: DevSeederFAB(), // <- Agregar aquí
// )
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../test_data/run_analytics_seeder.dart';

class DevSeederFAB extends StatefulWidget {
  final int? userId;

  const DevSeederFAB({Key? key, this.userId}) : super(key: key);

  @override
  State<DevSeederFAB> createState() => _DevSeederFABState();
}

class _DevSeederFABState extends State<DevSeederFAB> {
  bool _isExecuting = false;
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en modo debug
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menú de opciones
        if (_showMenu) ...[
          _buildMenuButton(
            'Generar Datos',
            Icons.auto_awesome,
            Colors.green,
            _generateData,
          ),
          const SizedBox(height: 8),
          _buildMenuButton(
            'Ver Estado',
            Icons.info,
            Colors.blue,
            _checkStatus,
          ),
          const SizedBox(height: 8),
          _buildMenuButton(
            'Limpiar Datos',
            Icons.delete,
            Colors.red,
            _clearData,
          ),
          const SizedBox(height: 8),
        ],

        // Botón principal
        FloatingActionButton(
          onPressed: _isExecuting ? null : () {
            setState(() => _showMenu = !_showMenu);
          },
          backgroundColor: _isExecuting
              ? Colors.grey
              : (_showMenu ? Colors.purple : Colors.deepPurple),
          child: _isExecuting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(_showMenu ? Icons.close : Icons.science),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return MaterialButton(
      onPressed: _isExecuting ? null : onPressed,
      color: color,
      textColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _generateData() async {
    setState(() {
      _isExecuting = true;
      _showMenu = false;
    });

    try {
      final userId = widget.userId ?? 1;

      _showSnackBar('🌱 Generando datos... (10-15 seg)', Colors.orange);

      await runAnalyticsSeeder(userId: userId);

      _showSnackBar(
        '✅ Datos generados! Ve a Analytics V4',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('❌ Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isExecuting = false);
      }
    }
  }

  Future<void> _checkStatus() async {
    setState(() => _showMenu = false);

    try {
      final userId = widget.userId ?? 1;

      await checkDataStatus(userId: userId);

      _showSnackBar('ℹ️ Revisa la consola de debug', Colors.blue);
    } catch (e) {
      _showSnackBar('❌ Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _clearData() async {
    // Confirmar primero
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Limpiar datos?'),
        content: const Text(
          'Esto eliminará todos los datos de prueba de Analytics.\n\n¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isExecuting = true;
      _showMenu = false;
    });

    try {
      final userId = widget.userId ?? 1;

      await clearAnalyticsData(userId: userId);

      _showSnackBar('🗑️ Datos eliminados', Colors.orange);
    } catch (e) {
      _showSnackBar('❌ Error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isExecuting = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
