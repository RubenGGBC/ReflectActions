// lib/presentation/providers/enhanced_goals_provider.dart
// ============================================================================
// SIMPLIFIED ENHANCED GOALS PROVIDER
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';

import '../../data/models/goal_model.dart';
import '../../data/services/enhanced_goals_service.dart';
import '../../data/services/optimized_database_service.dart';

/// Provider simplificado para gestión de objetivos
class EnhancedGoalsProvider extends ChangeNotifier {
  final EnhancedGoalsService _goalsService;
  final OptimizedDatabaseService _databaseService;
  final Logger _logger = Logger();

  EnhancedGoalsProvider(this._databaseService, [EnhancedGoalsService? goalsService])
      : _goalsService = goalsService ?? EnhancedGoalsService() {
    _goalsService.initialize(_databaseService);
  }

  // ============================================================================
  // STATE MANAGEMENT
  // ============================================================================

  List<GoalModel> _goals = [];
  final Map<String, StreakData> _streakData = {};
  bool _isLoading = false;
  String? _error;
  GoalCategory? _selectedCategory;
  String _searchQuery = '';
  String _sortOption = 'createdAt';


  // ============================================================================  
  // GETTERS
  // ============================================================================

  List<GoalModel> get goals => List.unmodifiable(_goals);
  Map<String, StreakData> get streakData => Map.unmodifiable(_streakData);
  bool get isLoading => _isLoading;
  String? get error => _error;
  GoalCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption;

  /// Objetivos filtrados según criterios actuales
  List<GoalModel> get filteredGoals {
    return _goals.where((goal) {
      // Filtro por categoría
      if (_selectedCategory != null && goal.category != _selectedCategory) {
        return false;
      }
      
      // Filtro por búsqueda
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return goal.title.toLowerCase().contains(query) ||
               goal.description.toLowerCase().contains(query);
      }
      
      return true;
    }).toList()..sort(_getSortComparator());
  }

  /// Comparador para ordenamiento
  int Function(GoalModel, GoalModel) _getSortComparator() {
    switch (_sortOption) {
      case 'title':
        return (a, b) => a.title.compareTo(b.title);
      case 'progress':
        return (a, b) => (b.currentValue / b.targetValue).compareTo(a.currentValue / a.targetValue);
      case 'createdAt':
        return (a, b) => b.createdAt.compareTo(a.createdAt);
      case 'category':
        return (a, b) => a.category.toString().compareTo(b.category.toString());
      default:
        return (a, b) => b.createdAt.compareTo(a.createdAt);
    }
  }

  /// Objetivos activos
  List<GoalModel> get activeGoals {
    return _goals.where((goal) => goal.status == GoalStatus.active).toList();
  }

  /// Objetivos completados
  List<GoalModel> get completedGoals {
    return _goals.where((goal) => goal.status == GoalStatus.completed).toList();
  }

  // ============================================================================
  // METHODS
  // ============================================================================

  /// Cargar objetivos
  Future<void> loadGoals(int userId) async {
    
    _setLoading(true);
    _clearError();
    
    try {
      _goals = await _databaseService.getUserGoals(userId);
      
      // Log para debug
      _logger.i('📋 Objetivos cargados desde BD:');
      for (final goal in _goals) {
        _logger.i('  - ${goal.title}: ${goal.currentValue}/${goal.targetValue} (${goal.progress * 100}%) - Status: ${goal.status}');
      }
      
      // Cargar datos de racha y verificar historial de progreso para cada objetivo
      for (final goal in _goals) {
        if (goal.id != null) {
          _streakData[goal.id.toString()] = const StreakData(
            currentStreak: 0,
            bestStreak: 0,
            daysSinceLastActivity: 0,
            momentumScore: 0.0,
            isStreakActive: false,
          );
          
        }
      }
      
      _logger.i('✅ ${_goals.length} objetivos cargados - Activos: ${activeGoals.length}, Completados: ${completedGoals.length}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error cargando objetivos: $e');
      _setError('Error cargando objetivos');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresca un objetivo específico desde la base de datos
  Future<void> refreshGoal(int goalId, int userId) async {
    try {
      _logger.i('🔄 Refrescando objetivo $goalId desde la base de datos...');
      final refreshedGoals = await _databaseService.getUserGoals(userId);
      final refreshedGoal = refreshedGoals.where((g) => g.id == goalId).firstOrNull;

      if (refreshedGoal != null) {
        final index = _goals.indexWhere((goal) => goal.id == goalId);
        if (index != -1) {
          final oldGoal = _goals[index];
          _goals[index] = refreshedGoal;
          _logger.i('🔄 Objetivo refrescado: ${refreshedGoal.title}');
          _logger.i('  📊 Progreso: ${oldGoal.progress} → ${refreshedGoal.progress}');
          _logger.i('  📈 Valores: ${oldGoal.currentValue}/${oldGoal.targetValue} → ${refreshedGoal.currentValue}/${refreshedGoal.targetValue}');
          _logger.i('  ⏱️ Días estimados: ${oldGoal.estimatedDaysRemaining} → ${refreshedGoal.estimatedDaysRemaining}');
          _logger.i('  🏷️ Status: ${refreshedGoal.status}');
          notifyListeners();
        }
      } else {
        _logger.w('⚠️ No se encontró el objetivo $goalId en la BD');
      }
    } catch (e) {
      _logger.e('❌ Error refrescando objetivo: $e');
    }
  }

  /// Manualmente marca un objetivo como completado (para casos de debugging)
  Future<void> forceCompleteGoal(int goalId, {String? notes}) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) {
        _logger.e('❌ Objetivo no encontrado para completar: $goalId');
        return;
      }

      final goal = _goals[index];
      _logger.i('🎯 Forzando completación manual de objetivo: ${goal.title}');
      
      // Marcar como completado en memoria
      _goals[index] = goal.markAsCompleted(completionNote: notes);
      
      // Actualizar en la base de datos
      await _databaseService.updateGoalStatus(goalId, GoalStatus.completed);
      await _databaseService.setGoalCompletedAt(goalId, DateTime.now());
      await _databaseService.updateGoalProgress(goalId, goal.targetValue.toDouble());
      
      _logger.i('✅ Objetivo completado manualmente: ${_goals[index].title} - Status: ${_goals[index].status}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error completando objetivo manualmente: $e');
    }
  }

  /// TEST: Simula completar un objetivo con valores específicos
  Future<void> testCompleteGoal(int goalId) async {
    try {
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) {
        _logger.e('❌ TEST: Objetivo no encontrado: $goalId');
        return;
      }

      final goal = _goals[index];
      _logger.i('🧪 TEST: Completando objetivo ${goal.title} (${goal.currentValue}/${goal.targetValue})');
      
      // Simular actualización de progreso al 100%
      await updateGoalProgress(goalId, goal.targetValue, notes: 'Test completación automática');
      
    } catch (e) {
      _logger.e('❌ TEST: Error: $e');
    }
  }

  /// Filtrar por categoría
  void filterByCategory(GoalCategory? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  void setSortOption(String option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _sortOption = 'createdAt';
    notifyListeners();
  }

  /// Crear objetivo
  Future<void> createGoal(GoalModel goal) async {
    _setLoading(true);
    _clearError();
    
    try {
      _logger.i('📝 Creando objetivo: ${goal.title}');
      
      final createdGoal = await _databaseService.addGoal(goal.userId, goal);
      
      if (createdGoal != null) {
        final goalWithId = goal.copyWith(id: createdGoal);
        
        _goals.add(goalWithId);
        
        
        // Inicializar datos de racha
        _streakData[createdGoal.toString()] = const StreakData(
          currentStreak: 0,
          bestStreak: 0,
          daysSinceLastActivity: 0,
          momentumScore: 0.0,
          isStreakActive: false,
        );
        
        _logger.i('✅ Objetivo creado con ID: $createdGoal');
      } else {
        throw Exception('Failed to create goal - no ID returned');
      }
      
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error creando objetivo: $e');
      _setError('Error creando objetivo');
    } finally {
      _setLoading(false);
    }
  }

  /// Actualiza el progreso de un objetivo
  Future<void> updateGoalProgress(int goalId, int newValue, {
    String? notes,
    Map<String, dynamic>? metrics,
  }) async {
    try {
      _logger.i('📊 Actualizando progreso del objetivo $goalId: $newValue');
      
      // Encontrar el objetivo en memoria primero
      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index == -1) {
        _logger.e('❌ Objetivo no encontrado en memoria: $goalId');
        return;
      }

      final originalGoal = _goals[index];
      _logger.i('📋 Objetivo original - Current: ${originalGoal.currentValue}, Target: ${originalGoal.targetValue}, Status: ${originalGoal.status}');
      
      // Verificar si se va a completar ANTES de actualizar la BD
      final willComplete = newValue >= originalGoal.targetValue && originalGoal.status != GoalStatus.completed;
      _logger.i('🔍 ¿Se completará? $willComplete (newValue: $newValue >= target: ${originalGoal.targetValue})');
      
      
      // Actualizar progreso en la base de datos
      await _databaseService.updateGoalProgress(goalId, newValue.toDouble());
      
      // Actualizar en memoria
      _goals[index] = originalGoal.copyWith(
        currentValue: newValue,
        lastUpdated: DateTime.now(),
        progressNotes: notes != null 
            ? (originalGoal.progressNotes != null 
                ? '${originalGoal.progressNotes}\n$notes' 
                : notes)
            : originalGoal.progressNotes,
      );
      
      // Si se completó, marcar como completado
      if (willComplete) {
        _logger.i('🎉 ¡Objetivo completado automáticamente! ID: $goalId');
        
        final completedGoal = _goals[index].markAsCompleted(
          completionNote: notes ?? 'Objetivo completado automáticamente al alcanzar el 100%'
        );
        
        _goals[index] = completedGoal;
        
        // Actualizar en la base de datos
        await _databaseService.updateGoalStatus(goalId, GoalStatus.completed);
        await _databaseService.setGoalCompletedAt(goalId, DateTime.now());
        
        _logger.i('✅ Objetivo marcado como completado en BD: $goalId');
        _logger.i('📋 Objetivo completado - Status: ${_goals[index].status}, Completed: ${_goals[index].isCompleted}');
      }
      
      // Actualizar datos de racha solo si es necesario
      _streakData[goalId.toString()] = _streakData[goalId.toString()] ?? const StreakData(
        currentStreak: 1,
        bestStreak: 1,
        daysSinceLastActivity: 0,
        momentumScore: 1.0,
        isStreakActive: true,
      );
      
      _logger.i('✅ Progreso actualizado correctamente: $goalId');

      // DEBUG: Verificar estado final
      final finalGoal = _goals.firstWhere((g) => g.id == goalId);
      _logger.i('🔍 DEBUG Estado final - ID: $goalId');
      _logger.i('  📊 Progress: ${finalGoal.progress} (${finalGoal.progressPercentage}%)');
      _logger.i('  📈 Values: ${finalGoal.currentValue}/${finalGoal.targetValue}');
      _logger.i('  🏷️ Status: ${finalGoal.status} (isCompleted: ${finalGoal.isCompleted})');
      _logger.i('  📅 CompletedAt: ${finalGoal.completedAt}');
      _logger.i('  ⏱️ Días estimados restantes: ${finalGoal.estimatedDaysRemaining}');
      _logger.i('  📆 Días desde creación: ${finalGoal.daysSinceCreated}');

      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error actualizando progreso: $e');
      _setError('Error actualizando progreso: $e');
    }
  }

  /// Obtiene datos de racha para un objetivo
  StreakData getStreakDataForGoal(int goalId) {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final cachedStreak = _streakData[goalId.toString()];
      
      // Calculate streak based on goal's recent activity
      final lastUpdate = goal.lastUpdated ?? goal.createdAt;
      final daysSinceUpdate = DateTime.now().difference(lastUpdate).inDays;
      final hasRecentProgress = goal.currentValue > 0 && daysSinceUpdate <= 1;
      
      // If we have cached data, validate it's still relevant
      if (cachedStreak != null) {
        return StreakData(
          currentStreak: hasRecentProgress ? cachedStreak.currentStreak.clamp(1, 100) : 0,
          bestStreak: cachedStreak.bestStreak,
          daysSinceLastActivity: daysSinceUpdate,
          momentumScore: hasRecentProgress ? 1.0 : 0.0,
          isStreakActive: hasRecentProgress,
        );
      }
      
      // Create basic streak data based on goal activity
      return StreakData(
        currentStreak: hasRecentProgress ? 1 : 0,
        bestStreak: hasRecentProgress ? 1 : 0,
        daysSinceLastActivity: daysSinceUpdate,
        momentumScore: hasRecentProgress ? 1.0 : 0.0,
        isStreakActive: hasRecentProgress,
      );
    } catch (e) {
      // Goal not found or error occurred, return default streak data
      return const StreakData(
        currentStreak: 0,
        bestStreak: 0,
        daysSinceLastActivity: 0,
        momentumScore: 0.0,
        isStreakActive: false,
      );
    }
  }

  /// Get goal statistics
  Map<String, dynamic> get goalStatistics {
    final total = _goals.length;
    final completed = _goals.where((g) => g.status == GoalStatus.completed).length;
    final active = _goals.where((g) => g.status == GoalStatus.active).length;
    
    return {
      'total': total,
      'completed': completed,
      'active': active,
      'completionRate': total > 0 ? completed / total : 0.0,
    };
  }

  /// Set category filter
  void setCategory(GoalCategory? category) {
    filterByCategory(category);
  }

  /// Add progress entry
  Future<void> addProgressEntry(dynamic entry) async {
    try {
      _logger.i('📝 Añadiendo entrada de progreso para objetivo: ${entry.goalId}');
      
      await _goalsService.addProgressEntry(entry);
      
      // Actualizar datos de racha
      _streakData[entry.goalId] = const StreakData(
        currentStreak: 0,
        bestStreak: 0,
        daysSinceLastActivity: 0,
        momentumScore: 0.0,
        isStreakActive: false,
      );
      
      _logger.i('✅ Entrada de progreso añadida: ${entry.goalId}');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error añadiendo entrada de progreso: $e');
      _setError('Error añadiendo entrada de progreso');
    }
  }

  /// Update goal
  Future<void> updateGoal(GoalModel updatedGoal) async {
    try {
      _logger.i('📊 Actualizando objetivo: ${updatedGoal.title}');
      
      final index = _goals.indexWhere((goal) => goal.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
        _logger.i('✅ Objetivo actualizado: ${updatedGoal.id}');
      }
    } catch (e) {
      _logger.e('❌ Error actualizando objetivo: $e');
      _setError('Error actualizando objetivo');
    }
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }


  /// Delete a goal and clear its progress history from cache
  Future<void> deleteGoal(int goalId) async {
    try {
      // Use the enhanced goals service to delete the goal (which now also deletes progress history)
      await _goalsService.deleteGoal(goalId);
      
      // Remove the goal from our local cache
      _goals.removeWhere((goal) => goal.id == goalId);
      
      
      // Clear streak data cache
      _streakData.remove(goalId.toString());
      
      _logger.i('✅ Goal $goalId deleted successfully');
      notifyListeners();
    } catch (e) {
      _logger.e('❌ Error deleting goal $goalId: $e');
      rethrow;
    }
  }

}

// ============================================================================
// SORT OPTIONS
// ============================================================================

class GoalSortOptions {
  static const String title = 'title';
  static const String progress = 'progress';
  static const String createdAt = 'createdAt';
  static const String category = 'category';
  static const String priority = 'priority';
  static const String difficulty = 'difficulty';
  
  static String getDisplayName(String option) {
    switch (option) {
      case title: return 'Título';
      case progress: return 'Progreso';
      case createdAt: return 'Fecha de creación';
      case category: return 'Categoría';
      case priority: return 'Reciente';
      case difficulty: return 'Duración';
      default: return 'Desconocido';
    }
  }
}