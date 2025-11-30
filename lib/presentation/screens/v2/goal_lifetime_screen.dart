// lib/presentation/screens/v2/goal_lifetime_screen.dart
// ============================================================================
// GOAL LIFETIME SCREEN - Complete version with progress history
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Models and Services
import '../../../data/models/goal_model.dart';
import '../../../data/services/enhanced_goals_service.dart';
import '../../../injection_container_clean.dart' as clean_di;

// Providers
import '../../providers/enhanced_goals_provider.dart';

// Components
import 'components/minimal_colors.dart';
import '../../widgets/progress_entry_dialog.dart';

class GoalLifetimeScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalLifetimeScreen({
    super.key,
    required this.goal,
  });

  @override
  State<GoalLifetimeScreen> createState() => _GoalLifetimeScreenState();
}

class _GoalLifetimeScreenState extends State<GoalLifetimeScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<ProgressEntry> _progressHistory = [];
  StreakData? _streakData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProgressHistory();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadProgressHistory() async {
    if (widget.goal.id == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final goalsService = clean_di.sl<EnhancedGoalsService>();

      final history = await goalsService.getProgressEntries(widget.goal.id!.toString());
      final streak = await goalsService.calculateStreakData(widget.goal.id!.toString());

      if (mounted) {
        setState(() {
          _progressHistory = history;
          _streakData = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error cargando historial: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGoalHeader(),
                        const SizedBox(height: 24),
                        _buildStatisticsCards(),
                        const SizedBox(height: 24),
                        _buildProgressHistorySection(),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddProgressFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: MinimalColors.textPrimary(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Historial de Progreso',
        style: TextStyle(
          color: MinimalColors.textPrimary(context),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGoalHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.gradientShadow(context, alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(widget.goal.category),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryName(widget.goal.category),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.goal.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progreso',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.goal.currentValue}/${widget.goal.targetValue}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Completado',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.goal.progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.goal.progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_streakData == null && !_isLoading) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Racha Actual',
            value: _streakData?.currentStreak.toString() ?? '-',
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.show_chart_rounded,
            label: 'Actualizaciones',
            value: _progressHistory.length.toString(),
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Mejor Racha',
            value: _streakData?.bestStreak.toString() ?? '-',
            color: const Color(0xFF8B7EFF),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              color: MinimalColors.textPrimary(context),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Historial de Actualizaciones',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          _buildLoadingState()
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_progressHistory.isEmpty)
          _buildEmptyState()
        else
          _buildHistoryTimeline(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              MinimalColors.primaryGradient(context)[0],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando historial...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: const Color(0xFFFF6B6B),
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el historial',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadProgressHistory,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.shadow(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_rounded,
            size: 64,
            color: MinimalColors.textTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin actualizaciones todavía',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera actualización para empezar a trackear tu progreso',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTimeline() {
    return Column(
      children: _progressHistory.asMap().entries.map((entry) {
        final index = entry.key;
        final progressEntry = entry.value;
        final isLast = index == _progressHistory.length - 1;

        return _buildHistoryEntry(progressEntry, isLast);
      }).toList(),
    );
  }

  Widget _buildHistoryEntry(ProgressEntry entry, bool isLast) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'es');
    final hasNotes = entry.notes != null && entry.notes!.isNotEmpty;
    final hasPhotos = entry.photoUrls.isNotEmpty;
    final hasMetrics = entry.metrics.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.gradientShadow(context, alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    entry.primaryValue.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.5),
                        MinimalColors.shadow(context),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MinimalColors.shadow(context),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: MinimalColors.textSecondary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateFormat.format(entry.timestamp),
                          style: TextStyle(
                            color: MinimalColors.textSecondary(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (hasNotes) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B7EFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8B7EFF).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        entry.notes!,
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],

                  if (hasMetrics) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildMetricChips(entry.metrics),
                    ),
                  ],

                  if (hasPhotos) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _viewPhoto(entry.photoUrls[index]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(entry.photoUrls[index]),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
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

  List<Widget> _buildMetricChips(Map<String, dynamic> metrics) {
    final chips = <Widget>[];

    if (metrics['quality'] != null) {
      chips.add(_buildMetricChip('Calidad', metrics['quality'].toString(), const Color(0xFF4ECDC4)));
    }
    if (metrics['mood_before'] != null) {
      chips.add(_buildMetricChip('Ánimo Inicial', metrics['mood_before'].toString(), const Color(0xFF8B7EFF)));
    }
    if (metrics['mood_after'] != null) {
      chips.add(_buildMetricChip('Ánimo Final', metrics['mood_after'].toString(), const Color(0xFFFF6B9D)));
    }
    if (metrics['energy'] != null) {
      chips.add(_buildMetricChip('Energía', metrics['energy'].toString(), const Color(0xFFFFA726)));
    }
    if (metrics['difficulty'] != null) {
      chips.add(_buildMetricChip('Dificultad', metrics['difficulty'].toString(), const Color(0xFFFF6B6B)));
    }

    return chips;
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPhoto(String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(photoPath)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddProgressFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ProgressEntryDialog(
            goal: widget.goal,
            onEntryCreated: (entry) async {
              try {
                final goalsProvider = context.read<EnhancedGoalsProvider>();
                await goalsProvider.addProgressEntry(entry);
                await goalsProvider.updateGoalProgress(
                  widget.goal.id!,
                  entry.primaryValue,
                  notes: entry.notes,
                  metrics: entry.metrics,
                );

                // Reload history
                await _loadProgressHistory();

                HapticFeedback.mediumImpact();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Progreso actualizado!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        );
      },
      icon: const Icon(Icons.add_rounded),
      label: const Text('Actualizar Progreso'),
      backgroundColor: MinimalColors.primaryGradient(context)[0],
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness:
        return Icons.self_improvement_rounded;
      case GoalCategory.stress:
        return Icons.spa_rounded;
      case GoalCategory.sleep:
        return Icons.bedtime_rounded;
      case GoalCategory.social:
        return Icons.people_rounded;
      case GoalCategory.physical:
        return Icons.fitness_center_rounded;
      case GoalCategory.emotional:
        return Icons.favorite_rounded;
      case GoalCategory.productivity:
        return Icons.trending_up_rounded;
      case GoalCategory.habits:
        return Icons.check_circle_rounded;
    }
  }

  String _getCategoryName(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness:
        return 'Mindfulness';
      case GoalCategory.stress:
        return 'Manejo del Estrés';
      case GoalCategory.sleep:
        return 'Mejora del Sueño';
      case GoalCategory.social:
        return 'Conexiones Sociales';
      case GoalCategory.physical:
        return 'Actividad Física';
      case GoalCategory.emotional:
        return 'Bienestar Emocional';
      case GoalCategory.productivity:
        return 'Productividad';
      case GoalCategory.habits:
        return 'Formación de Hábitos';
    }
  }
}
