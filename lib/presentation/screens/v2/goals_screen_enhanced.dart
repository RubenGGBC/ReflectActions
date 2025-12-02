// lib/presentation/screens/v2/goals_screen_enhanced.dart
// ============================================================================
// ENHANCED GOALS SCREEN - PHASE 1 IMPLEMENTATION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Onboarding
import '../../widgets/screen_onboarding_overlay.dart';
import '../../../data/services/onboarding_service.dart';

// Models and Services
import '../../../data/models/goal_model.dart';

// Providers
import '../../providers/optimized_providers.dart';
import '../../providers/enhanced_goals_provider.dart';
import '../../providers/theme_provider.dart';

// Components
import 'components/minimal_colors.dart';
import '../../widgets/enhanced_goal_card.dart';
import '../../widgets/progress_entry_dialog.dart';
import '../../widgets/enhanced_create_goal_dialog.dart';

// New Advanced Screens  
import 'goal_progress_screen.dart';
import 'goal_lifetime_screen.dart';

class GoalsScreenEnhanced extends StatefulWidget {
  const GoalsScreenEnhanced({super.key});

  @override
  State<GoalsScreenEnhanced> createState() => _GoalsScreenEnhancedState();
}

class _GoalsScreenEnhancedState extends State<GoalsScreenEnhanced>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _fabController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabAnimation;

  bool _isInitialized = false;
  
  final List<GoalCategory> _categories = GoalCategory.values;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
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
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.elasticOut));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabController.forward();
    });
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;
    
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final goalsProvider = context.read<EnhancedGoalsProvider>();
      final user = authProvider.currentUser;
      
      if (user != null) {
        await goalsProvider.loadGoals(user.id);
        
        
        _isInitialized = true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inicializando datos: $e')),
        );
      }
    }
  }

  Future<void> _refreshGoals() async {
    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final goalsProvider = context.read<EnhancedGoalsProvider>();
      final user = authProvider.currentUser;
      
      if (user != null) {
        print('🔄 Refrescando objetivos para usuario: ${user.id}');
        await goalsProvider.loadGoals(user.id);
        
        
        print('✅ Objetivos refrescados exitosamente');
      }
    } catch (e) {
      print('❌ Error refrescando objetivos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refrescando objetivos: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedGoalsProvider>(
      builder: (context, goalsProvider, child) {
        // Initialize data if needed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeData();
        });

        return ScreenOnboardingOverlay(
          screenKey: OnboardingScreens.metas,
          steps: const [
            OnboardingStep(
              title: 'Define tus Metas',
              description: 'Establece objetivos claros y alcanzables. Divide grandes metas en pasos más pequeños.',
              icon: Icons.flag_outlined,
            ),
            OnboardingStep(
              title: 'Haz Seguimiento',
              description: 'Monitorea tu progreso y celebra cada logro, por pequeño que sea.',
              icon: Icons.timeline,
            ),
            OnboardingStep(
              title: 'Mantente Motivado',
              description: 'Visualiza tu progreso y mantén la motivación viendo cuánto has avanzado.',
              icon: Icons.celebration,
            ),
          ],
          child: Scaffold(
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
                  child: goalsProvider.isLoading
                      ? _buildLoadingState(context)
                      : _buildMainContent(context, goalsProvider),
                ),
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(context),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: MinimalColors.primaryGradient(context),
                        ).createShader(bounds),
                        child: Text(
                          'Mis Objetivos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${goalsProvider.activeGoals.length} activos • ${goalsProvider.completedGoals.length} completados',
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Button to view all goals with completed section
                IconButton(
                  onPressed: () => _navigateToAllGoalsView(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.view_list,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Ver todos los objetivos',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<EnhancedGoalsProvider>(
      builder: (context, goalsProvider, child) {
        final stats = goalsProvider.goalStatistics;
        final activeGoals = goalsProvider.activeGoals;
        final completedGoals = goalsProvider.completedGoals;
        final averageProgress = stats['completionRate'] as double;
        
        // DEBUG: Log current metrics
        print('📊 Quick Stats Update:');
        print('  Active Goals: ${activeGoals.length}');
        print('  Completed Goals: ${completedGoals.length}');
        print('  Average Progress: ${(averageProgress * 100).round()}%');

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Activos',
                '${activeGoals.length}',
                Icons.flag,
                MinimalColors.primaryGradient(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Completados',
                '${completedGoals.length}',
                Icons.check_circle,
                [MinimalColors.success, MinimalColors.positiveGradient(context)[1]],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Progreso',
                '${(averageProgress * 100).round()}%',
                Icons.trending_up,
                MinimalColors.accentGradient(context),
              ),
            ),
          ],
        );
      },
    );
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
            color: gradient[0].withValues(alpha: 0.2),
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
              color: MinimalColors.textPrimary(context),
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(context, goalsProvider, null, 'Todos');
          }
          
          final category = _categories[index - 1];
          return _buildCategoryChip(context, goalsProvider, category, _getCategoryDisplayName(category));
        },
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, EnhancedGoalsProvider goalsProvider, GoalCategory? category, String label) {
    final isSelected = goalsProvider.selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        goalsProvider.setCategory(category);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: MinimalColors.primaryGradient(context))
              : null,
          color: !isSelected 
              ? MinimalColors.backgroundCard(context)
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : MinimalColors.textMuted(context).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              Icon(
                _getCategoryIcon(category),
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : MinimalColors.textSecondary(context),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white 
                    : MinimalColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildHeader(context, goalsProvider),
              _buildCategoryFilter(context, goalsProvider),
            ],
          ),
        ),
        _buildGoalsSlivers(context, goalsProvider),
      ],
    );
  }

  Widget _buildGoalsSlivers(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    final filteredGoals = goalsProvider.filteredGoals;
    
    if (filteredGoals.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(context, goalsProvider),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final goal = filteredGoals[index];
          final streakData = goal.id != null ? goalsProvider.getStreakDataForGoal(goal.id!) : null;
          
          return SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: index == 0 ? 16 : 8,
                bottom: index == filteredGoals.length - 1 ? 100 : 8,
              ),
              child: EnhancedGoalCard(
                goal: goal,
                streakData: streakData,
                onTap: () => _showGoalDetails(goal),
                onProgressUpdate: () => _showProgressUpdateDialog(goal, goalsProvider),
                onAddNote: () => _showAddNoteDialog(goal),
              ),
            ),
          );
        },
        childCount: filteredGoals.length,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, EnhancedGoalsProvider goalsProvider) {
    return Center(
      child: SingleChildScrollView(
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
              Icons.flag_outlined,
              size: 48,
              color: MinimalColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            goalsProvider.selectedCategory != null ? 'No tienes objetivos en esta categoría' : 'No tienes objetivos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: MinimalColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer objetivo para comenzar tu viaje de bienestar',
            style: TextStyle(
              fontSize: 14,
              color: MinimalColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton.icon(
              onPressed: _showCreateGoalDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Crear Objetivo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              MinimalColors.primaryGradient(context)[0],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando objetivos...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    // Detectar si hay botones de navegación del sistema
    final hasSystemNavButtons = bottomPadding > 0;

    // Altura aproximada de la barra de navegación custom (60px) + márgenes (2-8px)
    final navigationBarHeight = 60.0;
    final navigationMargin = hasSystemNavButtons ? bottomPadding + 2.0 : 2.0;

    // Espacio total que ocupa la navegación
    final totalNavigationSpace = navigationBarHeight + navigationMargin + 16.0; // +16 de separación

    return Padding(
      padding: EdgeInsets.only(
        bottom: totalNavigationSpace,
      ),
      child: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: "goals_fab",
            onPressed: _showCreateGoalDialog,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child:  Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods

  String _getCategoryDisplayName(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness: return 'Mindfulness';
      case GoalCategory.stress: return 'Estrés';
      case GoalCategory.sleep: return 'Sueño';
      case GoalCategory.social: return 'Social';
      case GoalCategory.physical: return 'Físico';
      case GoalCategory.emotional: return 'Emocional';
      case GoalCategory.productivity: return 'Productividad';
      case GoalCategory.habits: return 'Hábitos';
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness: return Icons.self_improvement;
      case GoalCategory.stress: return Icons.psychology;
      case GoalCategory.sleep: return Icons.bedtime;
      case GoalCategory.social: return Icons.people;
      case GoalCategory.physical: return Icons.fitness_center;
      case GoalCategory.emotional: return Icons.favorite;
      case GoalCategory.productivity: return Icons.trending_up;
      case GoalCategory.habits: return Icons.repeat;
    }
  }

  // Action methods
  void _showGoalDetails(GoalModel goal) {
    // Navigate to the enhanced goal lifetime screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalLifetimeScreen(goal: goal),
      ),
    ).then((_) {
      // Refresh goals when returning from progress screen
      _refreshGoals();
    });
  }

  void _showProgressUpdateDialog(GoalModel goal, EnhancedGoalsProvider goalsProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressEntryDialog(
        goal: goal,
        onEntryCreated: (entry) async {
          try {
            // DEBUG: Log los valores ANTES de actualizar
            print('🎯 ========== ANTES DE ACTUALIZAR ==========');
            print('  Goal ID: ${goal.id}');
            print('  Goal Title: ${goal.title}');
            print('  Current Value: ${goal.currentValue}');
            print('  Target Value: ${goal.targetValue}');
            print('  Entry Primary Value: ${entry.primaryValue}');
            print('  Current Progress: ${goal.progress} (${goal.progressPercentage}%)');
            print('  Days Since Created: ${goal.daysSinceCreated}');
            print('  Estimated Days Remaining: ${goal.estimatedDaysRemaining}');
            print('  Duration Days: ${goal.durationDays}');

            await goalsProvider.addProgressEntry(entry);
            await goalsProvider.updateGoalProgress(
              goal.id!,
              entry.primaryValue,
              notes: entry.notes,
              metrics: entry.metrics,
            );

            // DEBUG: Log los valores DESPUÉS de actualizar
            final updatedGoal = goalsProvider.goals.firstWhere((g) => g.id == goal.id);
            print('🎯 ========== DESPUÉS DE ACTUALIZAR ==========');
            print('  Current Value: ${updatedGoal.currentValue}');
            print('  Current Progress: ${updatedGoal.progress} (${updatedGoal.progressPercentage}%)');
            print('  Status: ${updatedGoal.status}');
            print('  Is Completed: ${updatedGoal.isCompleted}');
            print('  Days Since Created: ${updatedGoal.daysSinceCreated}');
            print('  Estimated Days Remaining: ${updatedGoal.estimatedDaysRemaining}');
            print('  Last Updated: ${updatedGoal.lastUpdated}');
            print('🎯 ============================================');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Progreso actualizado exitosamente')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error actualizando progreso: $e')),
            );
          }
        },
      ),
    );
  }

  void _showAddNoteDialog(GoalModel goal) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        title: Text(
          'Agregar Nota',
          style: TextStyle(color: MinimalColors.textPrimary(context)),
        ),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          style: TextStyle(color: MinimalColors.textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Escribe tu reflexión sobre este objetivo...',
            hintStyle: TextStyle(color: MinimalColors.textSecondary(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: MinimalColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Save note to goal
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota agregada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MinimalColors.primaryGradient(context)[0],
            ),
            child: Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedCreateGoalDialog(
        onGoalCreated: (goal) async {
          try {
            final goalsProvider = context.read<EnhancedGoalsProvider>();
            await goalsProvider.createGoal(goal);
            _refreshGoals();
            
            if (mounted) {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '¡Objetivo creado exitosamente!',
                    style: TextStyle(
                      color: !themeProvider.isDarkMode ? Colors.white : Colors.white,
                    ),
                  ),
                  backgroundColor: MinimalColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error al crear objetivo: $e',
                    style: TextStyle(
                      color: !themeProvider.isDarkMode ? Colors.white : Colors.white,
                    ),
                  ),
                  backgroundColor: MinimalColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _navigateToAllGoalsView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GoalProgressScreen(showAllGoals: true),
      ),
    );
  }
}