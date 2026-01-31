// lib/presentation/providers/insights_provider.dart
// Provider para gestionar el estado de los insights

import 'package:flutter/foundation.dart';
import '../../data/models/insights_models.dart';
import '../../data/services/local_insights_service.dart';

class InsightsProvider extends ChangeNotifier {
  final LocalInsightsService _insightsService;

  UserInsights? _insights;
  bool _isLoading = false;
  String? _error;

  InsightsProvider(this._insightsService);

  // Getters
  UserInsights? get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasInsights => _insights != null && _insights!.hasInsights;
  bool get needsMoreData => _insights?.needsMoreData ?? true;

  // Acceso rápido a datos específicos
  WeeklySummary? get weeklySummary => _insights?.weeklySummary;
  List<EmotionalPattern> get patterns => _insights?.patterns ?? [];
  List<HabitCorrelation> get correlations => _insights?.correlations ?? [];
  List<TrendPrediction> get predictions => _insights?.predictions ?? [];

  /// Cargar insights para un usuario
  Future<void> loadInsights(int userId) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _insights = await _insightsService.generateInsights(userId);
      debugPrint('✅ Insights cargados: ${_insights?.patterns.length} patrones');
    } catch (e) {
      _setError('Error al generar insights: $e');
      debugPrint('❌ Error cargando insights: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Forzar regeneración de insights
  Future<void> refreshInsights(int userId) async {
    _insightsService.invalidateCache();
    await loadInsights(userId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
