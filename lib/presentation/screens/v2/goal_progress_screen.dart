// lib/presentation/screens/v2/goal_progress_screen.dart
// ============================================================================
// GOAL PROGRESS SCREEN - Shows all progress made for a specific goal
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models and Services
import '../../../data/models/goal_model.dart';

// Providers
import '../../providers/enhanced_goals_provider.dart';

// Components
import 'components/minimal_colors.dart';
import '../../widgets/progress_visualizations.dart';
import 'goal_lifetime_screen.dart';

class GoalProgressScreen extends StatefulWidget {
  final GoalModel? goal; // Made optional to support general progress view
  final bool showAllGoals; // Flag to show all goals or just one

  const GoalProgressScreen({
    super.key,
    this.goal,
    this.showAllGoals = false,
  });

  @override
  State<GoalProgressScreen> createState() => _GoalProgressScreenState();
}

class _GoalProgressScreenState extends State<GoalProgressScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late TabController _tabController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tabController = TabController(length: widget.showAllGoals ? 2 : 1, vsync: this);
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedGoalsProvider>(
      builder: (context, goalsProvider, child) {
        if (widget.showAllGoals) {
          return _buildAllGoalsView(context, goalsProvider);
        } else {
          final streakData = widget.goal?.id != null 
              ? goalsProvider.getStreakDataForGoal(widget.goal!.id!) 
              : null;
          return _buildSingleGoalView(context, goalsProvider, streakData);
        }
      },
    );
  }

  Widget _buildAllGoalsView(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MinimalColors.backgroundPrimary(context),
              MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
              MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildAllGoalsAppBar(context, goalsProvider),
                _buildTabBar(context, goalsProvider),
                Expanded(
                  child: _buildTabBarView(context, goalsProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleGoalView(BuildContext context, EnhancedGoalsProvider goalsProvider, StreakData? streakData) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MinimalColors.backgroundPrimary(context),
              MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
              MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                _buildMainContent(context, streakData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: MinimalColors.textPrimary(context),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getCategoryGradient(),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getCategoryIconData(widget.goal!.categoryIcon),
                        color: MinimalColors.textPrimaryStatic,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal!.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: MinimalColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Progreso del Objetivo',
                            style: TextStyle(
                              fontSize: 16,
                              color: MinimalColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, StreakData? streakData) {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 20),
        
        // Progress Overview Card
        _buildProgressOverview(context),
        
        const SizedBox(height: 20),
        
        const SizedBox(height: 20),
        
        // Statistics Card
        _buildStatistics(context, streakData),
        
        const SizedBox(height: 20),
        
        const SizedBox(height: 20),
        
        // Additional Details
        _buildAdditionalDetails(context),
        
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progreso General',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MinimalColors.textPrimary(context),
                ),
              ),
              if (widget.goal!.isCompleted) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [MinimalColors.success, MinimalColors.success.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'COMPLETADO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.goal!.currentValue}/${widget.goal!.targetValue}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: MinimalColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      widget.goal!.suggestedUnit,
                      style: TextStyle(
                        fontSize: 14,
                        color: MinimalColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: widget.goal!.progress,
                      backgroundColor: MinimalColors.backgroundSecondary(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MinimalColors.primaryGradient(context)[0],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              ProgressRingWidget(
                progress: widget.goal!.progress,
                size: 80,
                strokeWidth: 8,
                colors: _getCategoryGradient(),
                centerChild: Text(
                  '${(widget.goal!.progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatistics(BuildContext context, StreakData? streakData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Progreso',
              '${widget.goal!.progressPercentage}%',
              Icons.trending_up,
              widget.goal!.isCompleted 
                  ? [MinimalColors.success, MinimalColors.success.withValues(alpha: 0.8)]
                  : MinimalColors.primaryGradient(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              widget.goal!.isCompleted ? 'Completado' : 'Días Rest.',
              widget.goal!.isCompleted 
                  ? _getTimeSinceCompletion()
                  : '${_getEstimatedDaysRemaining()}',
              widget.goal!.isCompleted ? Icons.check_circle : Icons.schedule,
              widget.goal!.isCompleted
                  ? [MinimalColors.success, MinimalColors.success.withValues(alpha: 0.8)]
                  : MinimalColors.accentGradient(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Racha',
              _getStreakValue(streakData),
              Icons.local_fire_department,
              _getStreakColors(context, streakData),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeSinceCompletion() {
    final completedAt = widget.goal!.completedAt;
    if (completedAt == null) return 'Hoy';
    
    final difference = DateTime.now().difference(completedAt).inDays;
    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    return 'Hace $difference días';
  }

  int _getEstimatedDaysRemaining() {
    if (widget.goal!.isCompleted) return 0;
    
    final now = DateTime.now();
    final daysElapsed = now.difference(widget.goal!.createdAt).inDays + 1; // +1 to include today
    final progress = widget.goal!.progress;
    
    // Si no hay progreso aún, devolver duración original menos días transcurridos
    if (progress == 0) {
      final remaining = widget.goal!.durationDays - daysElapsed;
      return remaining.clamp(0, widget.goal!.durationDays);
    }
    
    // Si hay progreso, calcular basado en la tasa actual
    if (daysElapsed <= 0) return widget.goal!.durationDays;
    
    final progressRate = progress / daysElapsed;
    if (progressRate <= 0) {
      final remaining = widget.goal!.durationDays - daysElapsed;
      return remaining.clamp(0, widget.goal!.durationDays);
    }
    
    final remainingProgress = 1.0 - progress;
    final estimatedDaysRemaining = (remainingProgress / progressRate).ceil();
    
    // Limitar el resultado a un rango razonable
    return estimatedDaysRemaining.clamp(0, widget.goal!.durationDays * 3);
  }

  String _getStreakValue(StreakData? streakData) {
    if (widget.goal!.isCompleted) {
      return '✓';
    }
    
    if (streakData == null) {
      // Calculate basic streak based on progress and goal activity
      if (widget.goal!.currentValue > 0) {
        // Check if the goal was updated recently (within last 2 days)
        final lastUpdate = widget.goal!.lastUpdated ?? widget.goal!.createdAt;
        final daysSinceUpdate = DateTime.now().difference(lastUpdate).inDays;
        
        if (daysSinceUpdate <= 1) {
          return '1'; // Active streak
        } else {
          return '0'; // Streak broken
        }
      }
      return '0';
    }
    
    // Use the streak data but validate it's still active
    final currentStreak = streakData.currentStreak;
    if (currentStreak > 0 && streakData.isStreakActive) {
      return '$currentStreak';
    }
    
    // Fallback to basic calculation if streak data seems outdated
    return widget.goal!.currentValue > 0 ? '1' : '0';
  }

  List<Color> _getStreakColors(BuildContext context, StreakData? streakData) {
    if (widget.goal!.isCompleted) {
      return [MinimalColors.success, MinimalColors.success.withValues(alpha: 0.8)];
    }
    
    // Check if there's an active streak
    final streakValue = _getStreakValue(streakData);
    final hasActiveStreak = streakValue != '0' && streakValue != '✓';
    
    if (hasActiveStreak) {
      final streakNum = int.tryParse(streakValue) ?? 0;
      if (streakNum >= 7) {
        // Long streak - fire colors
        return [MinimalColors.error, MinimalColors.warning];
      } else if (streakNum >= 3) {
        // Medium streak - warm colors
        return [MinimalColors.warning, MinimalColors.warning.withValues(alpha: 0.8)];
      } else {
        // Short streak - accent colors
        return MinimalColors.accentGradient(context);
      }
    }
    
    // No active streak
    return [MinimalColors.textMuted(context).withValues(alpha: 0.5), MinimalColors.textMuted(context).withValues(alpha: 0.3)];
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    List<Color> gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: MinimalColors.textPrimaryStatic,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: MinimalColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildAdditionalDetails(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del Objetivo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(context, 'Categoría', widget.goal!.categoryDisplayName),
          _buildDetailRow(context, 'Dificultad', widget.goal!.difficultyDisplayName),
          _buildDetailRow(context, 'Unidad', widget.goal!.suggestedUnit),
          
          if (widget.goal!.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Descripción',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.goal!.description,
              style: TextStyle(
                fontSize: 13,
                color: MinimalColors.textSecondary(context),
                height: 1.4,
              ),
            ),
          ],
          
          if (widget.goal!.hasNotes) ...[
            const SizedBox(height: 16),
            Text(
              'Notas de Progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.goal!.progressNotes ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: MinimalColors.textSecondary(context),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: MinimalColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  // Methods for All Goals View
  Widget _buildAllGoalsAppBar(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: MinimalColors.textPrimary(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso de Objetivos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MinimalColors.textPrimary(context),
                  ),
                ),
                Text(
                  '${goalsProvider.activeGoals.length} activos • ${goalsProvider.completedGoals.length} completados',
                  style: TextStyle(
                    fontSize: 14,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: MinimalColors.textSecondary(context),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag, size: 16),
                const SizedBox(width: 8),
                Text('Activos (${goalsProvider.activeGoals.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 16),
                const SizedBox(width: 8),
                Text('Completados (${goalsProvider.completedGoals.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGoalsList(context, goalsProvider.activeGoals, goalsProvider, false),
        _buildGoalsList(context, goalsProvider.completedGoals, goalsProvider, true),
      ],
    );
  }

  Widget _buildGoalsList(BuildContext context, List<GoalModel> goals, EnhancedGoalsProvider goalsProvider, bool isCompleted) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context).map((c) => c.withValues(alpha: 0.3)).toList(),
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle_outline : Icons.flag_outlined,
                size: 48,
                color: MinimalColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isCompleted ? 'No tienes objetivos completados aún' : 'No tienes objetivos activos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted 
                  ? 'Los objetivos completados aparecerán aquí'
                  : 'Crea un objetivo para comenzar tu progreso',
              style: TextStyle(
                fontSize: 14,
                color: MinimalColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final streakData = goal.id != null ? goalsProvider.getStreakDataForGoal(goal.id!) : null;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted 
                  ? MinimalColors.success.withValues(alpha: 0.3)
                  : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? MinimalColors.success : MinimalColors.primaryGradient(context)[0])
                    .withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalLifetimeScreen(goal: goal),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getCategoryGradientForGoal(goal),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIconData(goal.categoryIcon),
                          color: MinimalColors.textPrimaryStatic,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    goal.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: MinimalColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                                if (isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [MinimalColors.success, MinimalColors.success.withValues(alpha: 0.8)]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '✓ Completado',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal.categoryDisplayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: MinimalColors.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ProgressRingWidget(
                        progress: goal.progress,
                        size: 50,
                        strokeWidth: 4,
                        colors: _getCategoryGradientForGoal(goal),
                        centerChild: Text(
                          '${(goal.progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: MinimalColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progreso',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MinimalColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        '${goal.currentValue}/${goal.targetValue} ${goal.suggestedUnit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: MinimalColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: MinimalColors.backgroundSecondary(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? MinimalColors.success : MinimalColors.primaryGradient(context)[0],
                    ),
                  ),
                  if (isCompleted && goal.completedAt != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: MinimalColors.textSecondary(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completado el ${goal.completedAt!.toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: MinimalColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods
  List<Color> _getCategoryGradient() {
    final colorHex = widget.goal!.categoryColorHex;
    final baseColor = Color(int.parse('FF$colorHex', radix: 16));
    return [
      baseColor,
      baseColor.withValues(alpha: 0.8),
    ];
  }

  List<Color> _getCategoryGradientForGoal(GoalModel goal) {
    final colorHex = goal.categoryColorHex;
    final baseColor = Color(int.parse('FF$colorHex', radix: 16));
    return [
      baseColor,
      baseColor.withValues(alpha: 0.8),
    ];
  }

  IconData _getCategoryIconData(String iconName) {
    switch (iconName) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'psychology':
        return Icons.psychology;
      case 'bedtime':
        return Icons.bedtime;
      case 'people':
        return Icons.people;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'favorite':
        return Icons.favorite;
      case 'trending_up':
        return Icons.trending_up;
      case 'repeat':
        return Icons.repeat;
      default:
        return Icons.flag;
    }
  }
}