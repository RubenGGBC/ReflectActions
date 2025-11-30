// ============================================================================
// PANTALLA DE DESARROLLO - SEEDER DE ANALYTICS V4
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../test_data/run_analytics_seeder.dart';
import '../../providers/optimized_providers.dart';
import '../../../core/theme/minimal_colors.dart';

class AnalyticsSeederScreen extends StatefulWidget {
  const AnalyticsSeederScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsSeederScreen> createState() => _AnalyticsSeederScreenState();
}

class _AnalyticsSeederScreenState extends State<AnalyticsSeederScreen> {
  bool _isLoading = false;
  String _status = 'Listo para generar datos de prueba';
  String _details = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: MinimalColors.backgroundDark,
      appBar: AppBar(
        title: const Text('🧪 Analytics Seeder'),
        backgroundColor: MinimalColors.backgroundMedium,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            _buildHeaderCard(currentUser),

            const SizedBox(height: 20),

            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 20),

            // Actions
            _buildActionButton(
              icon: Icons.auto_awesome,
              title: 'Generar Datos Completos',
              subtitle: '60 días de datos + metas + momentos',
              color: MinimalColors.primary,
              onPressed: _isLoading ? null : () => _generateData(currentUser?.id ?? 1),
            ),

            const SizedBox(height: 12),

            _buildActionButton(
              icon: Icons.info_outline,
              title: 'Verificar Estado',
              subtitle: 'Revisar datos existentes',
              color: MinimalColors.blue,
              onPressed: _isLoading ? null : () => _checkStatus(currentUser?.id ?? 1),
            ),

            const SizedBox(height: 12),

            _buildActionButton(
              icon: Icons.delete_forever,
              title: 'Limpiar Datos',
              subtitle: 'Eliminar todos los datos de prueba',
              color: MinimalColors.error,
              onPressed: _isLoading ? null : () => _clearData(currentUser?.id ?? 1),
            ),

            const SizedBox(height: 32),

            // Info Card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MinimalColors.primary,
            MinimalColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics V4 Seeder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user != null
                          ? 'Usuario: ${user.email}'
                          : 'No hay usuario activo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isLoading
              ? MinimalColors.warning.withOpacity(0.3)
              : MinimalColors.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(MinimalColors.primary),
                  ),
                )
              else
                Icon(
                  Icons.check_circle,
                  color: MinimalColors.success,
                  size: 20,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _status,
                  style: const TextStyle(
                    color: MinimalColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_details.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _details,
              style: const TextStyle(
                color: MinimalColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: MinimalColors.backgroundMedium,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: MinimalColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: MinimalColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: MinimalColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: MinimalColors.info, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Datos Generados',
                style: TextStyle(
                  color: MinimalColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('📝', '60 días de entradas diarias'),
          _buildInfoRow('⚡', '150+ momentos interactivos'),
          _buildInfoRow('🎯', '12 metas (4 completadas)'),
          _buildInfoRow('📈', 'Tendencias de mejora realistas'),
          _buildInfoRow('🎨', 'Datos variados para todas las vistas'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: MinimalColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateData(int userId) async {
    setState(() {
      _isLoading = true;
      _status = 'Generando datos...';
      _details = 'Por favor espera, esto puede tomar 10-15 segundos';
    });

    try {
      await runAnalyticsSeeder(userId: userId);

      setState(() {
        _isLoading = false;
        _status = '✅ Datos generados exitosamente!';
        _details = 'Navega a Analytics V4 para ver los datos';
      });

      _showSnackBar('Datos generados exitosamente', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error al generar datos';
        _details = e.toString();
      });

      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _checkStatus(int userId) async {
    setState(() {
      _isLoading = true;
      _status = 'Verificando datos...';
      _details = '';
    });

    try {
      await checkDataStatus(userId: userId);

      setState(() {
        _isLoading = false;
        _status = 'Verificación completada';
        _details = 'Revisa la consola de debug para detalles';
      });

      _showSnackBar('Estado verificado, revisa la consola', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error al verificar';
        _details = e.toString();
      });

      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _clearData(int userId) async {
    // Confirmar primero
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundMedium,
        title: const Text(
          '¿Confirmar eliminación?',
          style: TextStyle(color: MinimalColors.textPrimary),
        ),
        content: const Text(
          'Esto eliminará TODOS los datos de prueba.\n\nEsta acción no se puede deshacer.',
          style: TextStyle(color: MinimalColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: MinimalColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _status = 'Eliminando datos...';
      _details = '';
    });

    try {
      await clearAnalyticsData(userId: userId);

      setState(() {
        _isLoading = false;
        _status = '🗑️ Datos eliminados';
        _details = 'Todos los datos de prueba han sido eliminados';
      });

      _showSnackBar('Datos eliminados exitosamente', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error al eliminar';
        _details = e.toString();
      });

      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? MinimalColors.error : MinimalColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
