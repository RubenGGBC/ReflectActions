// ============================================================================
// GOAL PROGRESS TIMELINE WIDGET - LIFETIME PROGRESS VISUALIZATION
// ============================================================================

import 'package:flutter/material.dart';
import '../../data/models/goal_model.dart';
import '../screens/v2/components/minimal_colors.dart';

class GoalProgressTimelineWidget extends StatelessWidget {
  final GoalModel goal;
  final List<GoalProgressEntry> progressHistory;
  final bool showDetailedView;

  const GoalProgressTimelineWidget({
    super.key,
    required this.goal,
    required this.progressHistory,
    this.showDetailedView = false,
  });

  @override
  Widget build(BuildContext context) {
    if (progressHistory.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        if (showDetailedView) 
          _buildDetailedTimeline(context)
        else
          _buildCompactTimeline(context),
        const SizedBox(height: 12),
        _buildProgressStats(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.timeline,
          size: 20,
          color: MinimalColors.textSecondary(context),
        ),
        const SizedBox(width: 8),
        Text(
          'Progreso en el Tiempo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${progressHistory.length} registros',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MinimalColors.textSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedTimeline(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        itemCount: progressHistory.length,
        itemBuilder: (context, index) {
          final entry = progressHistory[index];
          final isLast = index == progressHistory.length - 1;
          final progress = entry.currentValue / goal.targetValue;
          
          return _buildTimelineEntry(context, entry, progress, isLast);
        },
      ),
    );
  }

  Widget _buildCompactTimeline(BuildContext context) {
    final recentEntries = progressHistory.take(5).toList();
    
    return Column(
      children: recentEntries.asMap().entries.map((entry) {
        final index = entry.key;
        final progressEntry = entry.value;
        final isLast = index == recentEntries.length - 1;
        final progress = progressEntry.currentValue / goal.targetValue;
        
        return _buildTimelineEntry(context, progressEntry, progress, isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineEntry(BuildContext context, GoalProgressEntry entry, double progress, bool isLast) {
    final Color progressColor = _getProgressColor(progress);
    final bool isCompleted = progress >= 1.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted ? MinimalColors.success : progressColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: isCompleted 
                  ? Icon(
                      Icons.check,
                      size: 8,
                      color: Colors.white,
                    )
                  : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        progressColor.withValues(alpha: 0.5),
                        progressColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Entry content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: progressColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatProgressChange(entry),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: MinimalColors.textPrimary(context),
                          ),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(entry.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: MinimalColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: MinimalColors.backgroundSecondary(context).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted 
                              ? [MinimalColors.success, MinimalColors.success.withValues(alpha: 0.8)]
                              : [progressColor, progressColor.withValues(alpha: 0.8)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Text(
                        '${entry.currentValue}/${goal.targetValue} ${goal.suggestedUnit}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: MinimalColors.textSecondary(context),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // Notes if available
                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MinimalColors.backgroundSecondary(context).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note,
                            size: 14,
                            color: MinimalColors.textSecondary(context),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.notes!,
                              style: TextStyle(
                                fontSize: 11,
                                color: MinimalColors.textSecondary(context),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats(BuildContext context) {
    final totalDays = _calculateTotalDays();
    final averageProgress = _calculateAverageProgressPerDay();
    final streakDays = _calculateCurrentStreak();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
            MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Días Activos',
              '$totalDays',
              Icons.calendar_today,
              MinimalColors.accentGradient(context)[0],
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Progreso/Día',
              '+${averageProgress.toStringAsFixed(1)}',
              Icons.trending_up,
              MinimalColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Racha Actual',
              '${streakDays}d',
              Icons.local_fire_department,
              MinimalColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: MinimalColors.textSecondary(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: MinimalColors.textSecondary(context).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Sin Historial de Progreso',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los registros de progreso aparecerán aquí una vez que comiences a actualizar tu objetivo.',
            style: TextStyle(
              fontSize: 13,
              color: MinimalColors.textSecondary(context),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Show current progress for context
          if (goal.currentValue > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Progreso Actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.currentValue}/${goal.targetValue} ${goal.suggestedUnit}',
                    style: TextStyle(
                      fontSize: 16,
                      color: MinimalColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(goal.progress * 100).toStringAsFixed(1)}% completado',
                    style: TextStyle(
                      fontSize: 11,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Helper methods
  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return MinimalColors.success;
    if (progress >= 0.75) return MinimalColors.primary;
    if (progress >= 0.5) return MinimalColors.warning;
    if (progress >= 0.25) return MinimalColors.accent;
    return MinimalColors.error;
  }

  String _formatProgressChange(GoalProgressEntry entry) {
    if (entry.previousValue == null) {
      return 'Objetivo iniciado';
    }
    
    final change = entry.currentValue - entry.previousValue!;
    if (change > 0) {
      return '+$change ${goal.suggestedUnit}';
    } else if (change < 0) {
      return '$change ${goal.suggestedUnit}';
    } else {
      return 'Sin cambios';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }

  int _calculateTotalDays() {
    if (progressHistory.isEmpty) return 0;
    
    final firstEntry = progressHistory.last;
    final lastEntry = progressHistory.first;
    return lastEntry.createdAt.difference(firstEntry.createdAt).inDays + 1;
  }

  double _calculateAverageProgressPerDay() {
    if (progressHistory.isEmpty) return 0;
    
    final totalDays = _calculateTotalDays();
    if (totalDays == 0) return 0;
    
    final firstValue = progressHistory.last.currentValue;
    final lastValue = progressHistory.first.currentValue;
    final totalProgress = lastValue - firstValue;
    
    return totalProgress / totalDays;
  }

  int _calculateCurrentStreak() {
    if (progressHistory.isEmpty) {
      // Si no hay historial pero hay progreso actual, mostrar al menos 1 día
      return goal.currentValue > 0 ? 1 : 0;
    }
    
    if (progressHistory.length == 1) {
      // Si solo hay una entrada, verificar si fue en los últimos 2 días
      final daysSinceEntry = DateTime.now().difference(progressHistory.first.createdAt).inDays;
      return daysSinceEntry <= 1 ? 1 : 0;
    }
    
    // Ordenar por fecha (más reciente primero) para cálculo correcto
    final sortedHistory = List<GoalProgressEntry>.from(progressHistory)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streak = 0;
    DateTime? previousDate;
    
    for (int i = 0; i < sortedHistory.length; i++) {
      final entry = sortedHistory[i];
      final entryDate = entry.createdAt;
      
      if (i == 0) {
        // Primera entrada (más reciente)
        final daysSinceEntry = DateTime.now().difference(entryDate).inDays;
        if (daysSinceEntry <= 1) { // Permitir 1 día de gracia
          streak = 1;
          previousDate = entryDate;
        } else {
          // Si la entrada más reciente es muy antigua, no hay racha activa
          break;
        }
      } else {
        // Entradas siguientes
        if (previousDate != null) {
          final daysDiff = previousDate.difference(entryDate).inDays;
          if (daysDiff >= 1 && daysDiff <= 2) { // Entre 1 y 2 días de diferencia
            streak++;
            previousDate = entryDate;
          } else {
            // Rompe la racha si hay más de 2 días de diferencia
            break;
          }
        }
      }
    }
    
    return streak;
  }
}

// Helper class for progress entries
class GoalProgressEntry {
  final int id;
  final int goalId;
  final double currentValue;
  final double? previousValue;
  final String? notes;
  final DateTime createdAt;

  const GoalProgressEntry({
    required this.id,
    required this.goalId,
    required this.currentValue,
    this.previousValue,
    this.notes,
    required this.createdAt,
  });

  factory GoalProgressEntry.fromMap(Map<String, dynamic> map) {
    return GoalProgressEntry(
      id: map['id'] as int,
      goalId: map['goal_id'] as int,
      currentValue: (map['current_value'] as num).toDouble(),
      previousValue: map['previous_value'] != null ? (map['previous_value'] as num).toDouble() : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
    );
  }
}