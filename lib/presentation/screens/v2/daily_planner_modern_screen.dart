// ============================================================================
// DAILY PLANNER MODERN - ULTRA SIMPLE TIMELINE EXPERIENCE
// ============================================================================
// Nueva pantalla de planificación: intuitiva, rápida y sencilla
// Sigue el estilo visual de home_screen_v2.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/theme_provider.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/models/roadmap_activity_model.dart';

class DailyPlannerModernScreen extends StatefulWidget {
  const DailyPlannerModernScreen({super.key});

  @override
  State<DailyPlannerModernScreen> createState() => _DailyPlannerModernScreenState();
}

class _DailyPlannerModernScreenState extends State<DailyPlannerModernScreen>
    with TickerProviderStateMixin {

  // Animation controllers (matching home_screen_v2)
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  // Controllers
  final _taskController = TextEditingController();
  final _scrollController = ScrollController();

  // State
  bool _isLoading = true;
  bool _showAddTask = false;
  int _selectedHour = DateTime.now().hour;
  int _selectedDuration = 30;

  // Quick suggestions
  final List<_QuickTask> _quickTasks = [
    _QuickTask(title: 'Ejercicio', emoji: '🏃', duration: 30, category: 'Salud'),
    _QuickTask(title: 'Meditar', emoji: '🧘', duration: 15, category: 'Bienestar'),
    _QuickTask(title: 'Leer', emoji: '📚', duration: 30, category: 'Personal'),
    _QuickTask(title: 'Trabajo profundo', emoji: '💻', duration: 90, category: 'Trabajo'),
    _QuickTask(title: 'Reunión', emoji: '👥', duration: 60, category: 'Trabajo'),
    _QuickTask(title: 'Descanso', emoji: '☕', duration: 15, category: 'Bienestar'),
    _QuickTask(title: 'Comer', emoji: '🍽️', duration: 30, category: 'Salud'),
    _QuickTask(title: 'Pasear', emoji: '🚶', duration: 20, category: 'Bienestar'),
  ];

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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _pulseAnimation = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _floatingController, curve: Curves.linear));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _floatingController.repeat();
  }

  Future<void> _initializeData() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final roadmapProvider = context.read<DailyRoadmapProvider>();

    if (authProvider.currentUser != null) {
      await roadmapProvider.initialize(authProvider.currentUser!.id);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _slideController.dispose();
    _taskController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    if (_isLoading) {
      return _buildLoadingScreen(theme);
    }

    return Consumer<DailyRoadmapProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: theme.primaryBg,
          body: Stack(
            children: [
              // Animated background
              _buildAnimatedBackground(theme),

              // Floating particles
              ..._buildFloatingParticles(theme),

              // Main content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildHeader(provider, theme),
                      _buildProgressBar(provider, theme),
                      Expanded(
                        child: _buildTimeline(provider, theme),
                      ),
                    ],
                  ),
                ),
              ),

              // FAB
              _buildAddButton(theme),

              // Quick add panel
              if (_showAddTask)
                _buildQuickAddOverlay(provider, theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen(ThemeProvider theme) {
    return Scaffold(
      backgroundColor: theme.primaryBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: theme.gradientHeader),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.gradientHeader[0].withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Cargando tu día...',
              style: TextStyle(color: theme.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryBg,
            theme.gradientHeader[0].withOpacity(0.06),
            theme.primaryBg,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles(ThemeProvider theme) {
    return List.generate(4, (index) => AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          top: 80 + (index * 160) + (math.sin(_floatingAnimation.value * math.pi * 2 + index) * 12),
          right: 20 + (index * 70) + (math.cos(_floatingAnimation.value * math.pi * 2 + index) * 15),
          child: Container(
            width: 12 + (index * 6).toDouble(),
            height: 12 + (index * 6).toDouble(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.gradientHeader[index % 2].withOpacity(0.12),
                  theme.gradientHeader[(index + 1) % 2].withOpacity(0.04),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget _buildHeader(DailyRoadmapProvider provider, ThemeProvider theme) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.borderColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.arrow_back_rounded, color: theme.textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(color: theme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: theme.gradientHeader,
                  ).createShader(bounds),
                  child: const Text(
                    'Mi Día',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: theme.gradientHeader),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: theme.gradientHeader[0].withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${now.day}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                Text(
                  _getMonthShort(now.month),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(DailyRoadmapProvider provider, ThemeProvider theme) {
    final total = provider.totalActivities;
    final completed = provider.completedActivities;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress circle
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 6,
                        backgroundColor: theme.borderColor.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(theme.borderColor.withOpacity(0.15)),
                      ),
                    ),
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          progress >= 1 ? theme.positiveMain : theme.gradientHeader[0],
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Stats
              Expanded(
                child: Row(
                  children: [
                    _buildMiniStat(
                      emoji: '✅',
                      value: '$completed',
                      label: 'Hechas',
                      theme: theme,
                    ),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                      emoji: '⏳',
                      value: '${total - completed}',
                      label: 'Pendientes',
                      theme: theme,
                    ),
                    const SizedBox(width: 16),
                    _buildMiniStat(
                      emoji: '🕐',
                      value: _getTotalHours(provider),
                      label: 'Horas',
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Quick tip if empty
          if (total == 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.gradientHeader[0].withOpacity(0.1),
                    theme.gradientHeader[1].withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Toca el + para agregar tu primera tarea',
                      style: TextStyle(color: theme.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String emoji,
    required String value,
    required String label,
    required ThemeProvider theme,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: theme.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTimeline(DailyRoadmapProvider provider, ThemeProvider theme) {
    final activities = provider.activitiesByTime;
    final currentHour = DateTime.now().hour;

    if (activities.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isNow = activity.hour == currentHour;

        return _buildTimelineItem(activity, provider, theme, isNow, index == activities.length - 1);
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.gradientHeader[0].withOpacity(0.1),
                        theme.gradientHeader[1].withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text('📅', style: const TextStyle(fontSize: 48)),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Tu día está vacío',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tareas para organizar tu día',
            style: TextStyle(color: theme.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    RoadmapActivityModel activity,
    DailyRoadmapProvider provider,
    ThemeProvider theme,
    bool isNow,
    bool isLast,
  ) {
    final isCompleted = activity.isCompleted;

    return Dismissible(
      key: Key('timeline_${activity.id}'),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(true, theme),
      secondaryBackground: _buildDismissBackground(false, theme),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          await provider.toggleActivityCompletion(activity.id!);
          return false;
        } else {
          return await _showDeleteDialog(activity, provider, theme);
        }
      },
      child: GestureDetector(
        onTap: () => _showEditTask(activity, provider, theme),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    // Time
                    Text(
                      activity.timeString,
                      style: TextStyle(
                        color: isNow ? theme.gradientHeader[0] : theme.textPrimary,
                        fontSize: 14,
                        fontWeight: isNow ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Duration
                    if (activity.estimatedDuration != null)
                      Text(
                        '${activity.estimatedDuration}m',
                        style: TextStyle(
                          color: theme.textHint,
                          fontSize: 11,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Dot
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCompleted
                            ? LinearGradient(colors: [theme.positiveMain, theme.positiveMain.withOpacity(0.7)])
                            : isNow
                                ? LinearGradient(colors: theme.gradientHeader)
                                : null,
                        color: isCompleted || isNow ? null : theme.borderColor,
                        border: Border.all(
                          color: isCompleted ? theme.positiveMain : isNow ? theme.gradientHeader[0] : theme.borderColor,
                          width: 2,
                        ),
                        boxShadow: isNow ? [
                          BoxShadow(
                            color: theme.gradientHeader[0].withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ] : null,
                      ),
                      child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 8) : null,
                    ),
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isCompleted ? theme.positiveMain : theme.borderColor.withOpacity(0.5),
                                theme.borderColor.withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Card
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isNow
                          ? theme.gradientHeader[0].withOpacity(0.4)
                          : isCompleted
                              ? theme.positiveMain.withOpacity(0.3)
                              : theme.borderColor.withOpacity(0.2),
                      width: isNow ? 2 : 1,
                    ),
                    boxShadow: isNow ? [
                      BoxShadow(
                        color: theme.gradientHeader[0].withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    activity.title,
                                    style: TextStyle(
                                      color: theme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                if (isNow)
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, _) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: theme.gradientHeader),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.gradientHeader[0].withOpacity(0.15 + _pulseController.value * 0.15),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'AHORA',
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            if (activity.category?.isNotEmpty == true) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.gradientHeader[0].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  activity.category!,
                                  style: TextStyle(
                                    color: theme.gradientHeader[0],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Checkbox
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          provider.toggleActivityCompletion(activity.id!);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? LinearGradient(colors: [theme.positiveMain, theme.positiveMain.withOpacity(0.8)])
                                : null,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? theme.positiveMain : theme.borderColor,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(bool isComplete, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isComplete ? theme.positiveMain : theme.negativeMain,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        isComplete ? Icons.check_circle_outline : Icons.delete_outline,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _buildAddButton(ThemeProvider theme) {
    // Calculate bottom padding to avoid nav bar overlap
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 70.0; // Approximate nav bar height + margins
    final safeBottom = navBarHeight + bottomPadding + 16;
    
    return Positioned(
      bottom: safeBottom,
      right: 20,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _showAddTask = true);
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _showAddTask ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: theme.gradientHeader),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.gradientHeader[0].withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickAddOverlay(DailyRoadmapProvider provider, ThemeProvider theme) {
    // Calculate bottom padding to avoid nav bar overlap
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBarHeight = 70.0; // Approximate nav bar height + margins
    final safeBottom = navBarHeight + bottomPadding + 8;
    
    return GestureDetector(
      onTap: () => setState(() => _showAddTask = false),
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {}, // Prevent close
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 16, 16, safeBottom),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(colors: theme.gradientHeader).createShader(bounds),
                          child: const Text(
                            'Nueva Tarea',
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick suggestions
                    Text(
                      'Sugerencias rápidas',
                      style: TextStyle(color: theme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _quickTasks.map((task) => _buildQuickTaskChip(task, provider, theme)).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Custom input
                    Text(
                      'O escribe tu propia tarea',
                      style: TextStyle(color: theme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: theme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.borderColor.withOpacity(0.3)),
                            ),
                            child: TextField(
                              controller: _taskController,
                              style: TextStyle(color: theme.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Ej: Llamar a mamá...',
                                hintStyle: TextStyle(color: theme.textHint),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _addCustomTask(provider),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _addCustomTask(provider),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: theme.gradientHeader),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time selector
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimePicker(theme),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDurationPicker(theme),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTaskChip(_QuickTask task, DailyRoadmapProvider provider, ThemeProvider theme) {
    return GestureDetector(
      onTap: () => _addQuickTask(task, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.borderColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(task.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              task.title,
              style: TextStyle(color: theme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: theme.gradientHeader[0], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedHour,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: theme.surface,
              style: TextStyle(color: theme.textPrimary, fontSize: 14),
              items: List.generate(24, (h) => DropdownMenuItem(
                value: h,
                child: Text('${h.toString().padLeft(2, '0')}:00'),
              )),
              onChanged: (v) => setState(() => _selectedHour = v ?? _selectedHour),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPicker(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timelapse_rounded, color: theme.gradientHeader[1], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedDuration,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: theme.surface,
              style: TextStyle(color: theme.textPrimary, fontSize: 14),
              items: [15, 30, 45, 60, 90, 120].map((d) => DropdownMenuItem(
                value: d,
                child: Text('$d min'),
              )).toList(),
              onChanged: (v) => setState(() => _selectedDuration = v ?? _selectedDuration),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addQuickTask(_QuickTask task, DailyRoadmapProvider provider) async {
    HapticFeedback.mediumImpact();

    await provider.addActivity(
      title: task.title,
      hour: _selectedHour,
      minute: 0,
      estimatedDuration: task.duration,
      category: task.category,
    );
    setState(() => _showAddTask = false);
  }

  Future<void> _addCustomTask(DailyRoadmapProvider provider) async {
    if (_taskController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();

    await provider.addActivity(
      title: _taskController.text.trim(),
      hour: _selectedHour,
      minute: 0,
      estimatedDuration: _selectedDuration,
    );
    _taskController.clear();
    setState(() => _showAddTask = false);
  }

  Future<bool> _showDeleteDialog(RoadmapActivityModel activity, DailyRoadmapProvider provider, ThemeProvider theme) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Eliminar tarea?', style: TextStyle(color: theme.textPrimary)),
        content: Text(
          'Se eliminará "${activity.title}"',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await provider.removeActivity(activity.id);
              Navigator.pop(context, false);
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showEditTask(RoadmapActivityModel activity, DailyRoadmapProvider provider, ThemeProvider theme) {
    final titleController = TextEditingController(text: activity.title);
    int editHour = activity.hour;
    int editDuration = activity.estimatedDuration ?? 30;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('✏️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    'Editar Tarea',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.borderColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: titleController,
                  style: TextStyle(color: theme.textPrimary, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Nombre de la tarea',
                    hintStyle: TextStyle(color: theme.textHint),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded, color: theme.gradientHeader[0], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<int>(
                              value: editHour,
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 14),
                              items: List.generate(24, (h) => DropdownMenuItem(
                                value: h,
                                child: Text('${h.toString().padLeft(2, '0')}:00'),
                              )),
                              onChanged: (v) => setModalState(() => editHour = v ?? editHour),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timelapse_rounded, color: theme.gradientHeader[1], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<int>(
                              value: editDuration,
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: theme.surface,
                              style: TextStyle(color: theme.textPrimary, fontSize: 14),
                              items: [15, 30, 45, 60, 90, 120].map((d) => DropdownMenuItem(
                                value: d,
                                child: Text('$d min'),
                              )).toList(),
                              onChanged: (v) => setModalState(() => editDuration = v ?? editDuration),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await provider.removeActivity(activity.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (titleController.text.trim().isEmpty) return;

                        final updated = activity.copyWith(
                          title: titleController.text.trim(),
                          hour: editHour,
                          minute: 0,
                          estimatedDuration: editDuration,
                        );

                        await provider.updateActivity(updated);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: theme.gradientHeader),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
  String _getGreeting(int hour) {
    if (hour < 12) return '🌅 Buenos días';
    if (hour < 19) return '☀️ Buenas tardes';
    return '🌙 Buenas noches';
  }

  String _getMonthShort(int month) {
    const months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return months[month - 1];
  }

  String _getTotalHours(DailyRoadmapProvider provider) {
    int totalMinutes = 0;
    for (final activity in provider.activitiesByTime) {
      totalMinutes += activity.estimatedDuration ?? 0;
    }
    final hours = totalMinutes / 60;
    return hours.toStringAsFixed(1);
  }
}

class _QuickTask {
  final String title;
  final String emoji;
  final int duration;
  final String category;

  const _QuickTask({
    required this.title,
    required this.emoji,
    required this.duration,
    required this.category,
  });
}
