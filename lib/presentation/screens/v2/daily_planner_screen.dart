// ============================================================================
// DAILY PLANNER SCREEN - MODERN STEP-BASED PLANNING EXPERIENCE
// ============================================================================
// Nueva pantalla de planificación rápida, interactiva e intuitiva

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/theme_provider.dart';
import '../../providers/daily_roadmap_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/models/roadmap_activity_model.dart';
import 'components/minimal_colors.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen>
    with TickerProviderStateMixin {

  // Controllers
  late AnimationController _pulseController;
  late AnimationController _progressController;
  final _quickAddController = TextEditingController();
  final _scrollController = ScrollController();

  // State
  bool _isLoading = true;
  int _selectedTimeBlock = 0; // 0: Todo, 1: Mañana, 2: Tarde, 3: Noche
  bool _showQuickAdd = false;
  String? _focusedTaskId;

  // Time blocks
  final List<_TimeBlock> _timeBlocks = [
    _TimeBlock(name: 'Todo', icon: Icons.view_agenda_rounded, startHour: 0, endHour: 24),
    _TimeBlock(name: 'Mañana', icon: Icons.wb_sunny_rounded, startHour: 5, endHour: 12),
    _TimeBlock(name: 'Tarde', icon: Icons.wb_twilight_rounded, startHour: 12, endHour: 18),
    _TimeBlock(name: 'Noche', icon: Icons.nights_stay_rounded, startHour: 18, endHour: 24),
  ];

  // Quick suggestions
  final List<_QuickSuggestion> _suggestions = [
    _QuickSuggestion(title: 'Ejercicio', icon: Icons.fitness_center, duration: 30, category: 'Salud'),
    _QuickSuggestion(title: 'Meditar', icon: Icons.self_improvement, duration: 15, category: 'Bienestar'),
    _QuickSuggestion(title: 'Leer', icon: Icons.menu_book, duration: 30, category: 'Personal'),
    _QuickSuggestion(title: 'Trabajo profundo', icon: Icons.psychology, duration: 90, category: 'Trabajo'),
    _QuickSuggestion(title: 'Reunión', icon: Icons.groups, duration: 60, category: 'Trabajo'),
    _QuickSuggestion(title: 'Descanso', icon: Icons.coffee, duration: 15, category: 'Bienestar'),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  Future<void> _initializeData() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final roadmapProvider = context.read<DailyRoadmapProvider>();

    if (authProvider.currentUser != null) {
      await roadmapProvider.initialize(authProvider.currentUser!.id);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _quickAddController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    if (_isLoading) {
      return _buildLoadingScreen(themeProvider);
    }

    return Consumer<DailyRoadmapProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: themeProvider.primaryBg,
          body: Stack(
            children: [
              // Background gradient
              _buildBackground(themeProvider),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(provider, themeProvider),
                    _buildProgressCard(provider, themeProvider),
                    _buildTimeBlockSelector(themeProvider),
                    Expanded(
                      child: _buildTasksList(provider, themeProvider),
                    ),
                  ],
                ),
              ),

              // Quick add FAB
              _buildQuickAddButton(provider, themeProvider),

              // Quick add panel
              if (_showQuickAdd)
                _buildQuickAddPanel(provider, themeProvider),

              // Focus mode overlay
              if (_focusedTaskId != null)
                _buildFocusOverlay(provider, themeProvider),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: theme.gradientHeader),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Preparando tu día...',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryBg,
            theme.gradientHeader[0].withOpacity(0.05),
            theme.primaryBg,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DailyRoadmapProvider provider, ThemeProvider theme) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Planifica tu día',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Date badge
          GestureDetector(
            onTap: () => _showDatePicker(provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: theme.gradientHeader),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.gradientHeader[0].withOpacity(0.3),
                    blurRadius: 12,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    _getMonthShort(now.month),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DailyRoadmapProvider provider, ThemeProvider theme) {
    final total = provider.totalActivities;
    final completed = provider.completedActivities;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.borderColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Circular progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    // Background circle
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 8,
                        backgroundColor: theme.borderColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(theme.borderColor.withOpacity(0.2)),
                      ),
                    ),
                    // Progress circle
                    SizedBox.expand(
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return CircularProgressIndicator(
                            value: progress * _progressController.value,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              progress >= 1 ? theme.positiveMain : theme.gradientHeader[0],
                            ),
                          );
                        },
                      ),
                    ),
                    // Center text
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (progress >= 1)
                            Icon(Icons.check, color: theme.positiveMain, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      icon: Icons.check_circle_outline,
                      label: 'Completadas',
                      value: '$completed',
                      color: theme.positiveMain,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.pending_outlined,
                      label: 'Pendientes',
                      value: '${total - completed}',
                      color: theme.gradientHeader[0],
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      icon: Icons.schedule_outlined,
                      label: 'Horas planificadas',
                      value: _calculateTotalHours(provider),
                      color: theme.accentSecondary,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (total == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.gradientHeader[0].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: theme.gradientHeader[0], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Empieza agregando tu primera tarea del día',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                      ),
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

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeProvider theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBlockSelector(ThemeProvider theme) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _timeBlocks.length,
        itemBuilder: (context, index) {
          final block = _timeBlocks[index];
          final isSelected = _selectedTimeBlock == index;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedTimeBlock = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: theme.gradientHeader)
                    : null,
                color: isSelected ? null : theme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : theme.borderColor.withOpacity(0.3),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: theme.gradientHeader[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Icon(
                    block.icon,
                    size: 18,
                    color: isSelected ? Colors.white : theme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    block.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : theme.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTasksList(DailyRoadmapProvider provider, ThemeProvider theme) {
    final block = _timeBlocks[_selectedTimeBlock];
    final activities = provider.activitiesByTime.where((a) {
      if (_selectedTimeBlock == 0) return true;
      return a.hour >= block.startHour && a.hour < block.endHour;
    }).toList();

    if (activities.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildTaskCard(activity, provider, theme, index);
      },
    );
  }

  Widget _buildEmptyState(ThemeProvider theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_rounded,
              size: 48,
              color: theme.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin tareas programadas',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para agregar tu primera tarea',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    RoadmapActivityModel activity,
    DailyRoadmapProvider provider,
    ThemeProvider theme,
    int index,
  ) {
    final isCompleted = activity.isCompleted;
    final isCurrent = _isCurrentTimeSlot(activity.hour);

    return Dismissible(
      key: Key('task_${activity.id}'),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(true, theme),
      secondaryBackground: _buildSwipeBackground(false, theme),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        if (direction == DismissDirection.startToEnd) {
          // Complete/uncomplete
          await provider.toggleActivityCompletion(activity.id!);
          return false;
        } else {
          // Delete
          return await _showDeleteConfirmation(activity, provider);
        }
      },
      child: GestureDetector(
        onTap: () => _showEditActivity(activity, provider, theme),
        onLongPress: () {
          HapticFeedback.heavyImpact();
          setState(() => _focusedTaskId = activity.id);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrent
                  ? theme.gradientHeader[0].withOpacity(0.5)
                  : isCompleted
                      ? theme.positiveMain.withOpacity(0.3)
                      : theme.borderColor.withOpacity(0.2),
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: theme.gradientHeader[0].withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Time indicator
                Container(
                  width: 56,
                  child: Column(
                    children: [
                      Text(
                        activity.timeString,
                        style: TextStyle(
                          color: isCurrent
                              ? theme.gradientHeader[0]
                              : theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (activity.estimatedDuration != null)
                        Text(
                          '${activity.estimatedDuration}m',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),

                // Vertical line
                Container(
                  width: 3,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isCompleted
                          ? [theme.positiveMain, theme.positiveMain.withOpacity(0.3)]
                          : isCurrent
                              ? theme.gradientHeader
                              : [theme.borderColor, theme.borderColor.withOpacity(0.3)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

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
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: theme.gradientHeader,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.gradientHeader[0]
                                            .withOpacity(0.2 + _pulseController.value * 0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'AHORA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      if (activity.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          activity.description!,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (activity.category?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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

                // Checkbox
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    provider.toggleActivityCompletion(activity.id!);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? LinearGradient(colors: [theme.positiveMain, theme.positiveMain.withOpacity(0.8)])
                          : null,
                      color: isCompleted ? null : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? theme.positiveMain
                            : theme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isComplete, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isComplete ? theme.positiveMain : theme.negativeMain,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: isComplete ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        isComplete ? Icons.check_circle_outline : Icons.delete_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildQuickAddButton(DailyRoadmapProvider provider, ThemeProvider theme) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _showQuickAdd = !_showQuickAdd);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _showQuickAdd ? 0.125 : 0,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddPanel(DailyRoadmapProvider provider, ThemeProvider theme) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => setState(() => _showQuickAdd = false),
        child: Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping panel
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  Text(
                    'Agregar tarea',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick input
                  Container(
                    decoration: BoxDecoration(
                      color: theme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.borderColor.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _quickAddController,
                      autofocus: true,
                      style: TextStyle(color: theme.textPrimary),
                      decoration: InputDecoration(
                        hintText: '¿Qué quieres hacer?',
                        hintStyle: TextStyle(color: theme.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send_rounded, color: theme.gradientHeader[0]),
                          onPressed: () => _quickAddTask(provider, theme),
                        ),
                      ),
                      onSubmitted: (_) => _quickAddTask(provider, theme),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Suggestions
                  Text(
                    'Sugerencias rápidas',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _suggestions.map((s) =>
                      _buildSuggestionChip(s, provider, theme)
                    ).toList(),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    _QuickSuggestion suggestion,
    DailyRoadmapProvider provider,
    ThemeProvider theme,
  ) {
    return GestureDetector(
      onTap: () => _addSuggestion(suggestion, provider, theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.gradientHeader[0].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.gradientHeader[0].withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(suggestion.icon, size: 18, color: theme.gradientHeader[0]),
            const SizedBox(width: 8),
            Text(
              suggestion.title,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${suggestion.duration}m',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusOverlay(DailyRoadmapProvider provider, ThemeProvider theme) {
    final activity = provider.activitiesByTime.firstWhere(
      (a) => a.id == _focusedTaskId,
      orElse: () => provider.activitiesByTime.first,
    );

    return GestureDetector(
      onTap: () => setState(() => _focusedTaskId = null),
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: IconButton(
                    onPressed: () => setState(() => _focusedTaskId = null),
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  ),
                ),
              ),

              const Spacer(),

              // Focus content
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.gradientHeader,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: theme.gradientHeader[0].withOpacity(0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.center_focus_strong_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MODO ENFOQUE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (activity.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        activity.description!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          activity.timeString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (activity.estimatedDuration != null) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${activity.estimatedDuration} min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Actions
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          provider.toggleActivityCompletion(activity.id!);
                          setState(() => _focusedTaskId = null);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: theme.positiveMain,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Completar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HELPERS & ACTIONS
  // ============================================================================

  String _getGreeting(int hour) {
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getMonthShort(int month) {
    const months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
                    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return months[month - 1];
  }

  String _calculateTotalHours(DailyRoadmapProvider provider) {
    int totalMinutes = 0;
    for (var activity in provider.activitiesByTime) {
      totalMinutes += activity.estimatedDuration ?? 30;
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  bool _isCurrentTimeSlot(int hour) {
    final now = DateTime.now();
    return now.hour == hour;
  }

  void _showDatePicker(DailyRoadmapProvider provider) async {
    HapticFeedback.selectionClick();
    final date = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      provider.changeSelectedDate(date);
    }
  }

  void _quickAddTask(DailyRoadmapProvider provider, ThemeProvider theme) async {
    final title = _quickAddController.text.trim();
    if (title.isEmpty) return;

    HapticFeedback.mediumImpact();

    final now = DateTime.now();
    await provider.addActivity(
      title: title,
      hour: now.hour,
      minute: now.minute,
    );

    _quickAddController.clear();
    setState(() => _showQuickAdd = false);
  }

  void _addSuggestion(
    _QuickSuggestion suggestion,
    DailyRoadmapProvider provider,
    ThemeProvider theme,
  ) async {
    HapticFeedback.mediumImpact();

    final now = DateTime.now();
    await provider.addActivity(
      title: suggestion.title,
      hour: now.hour,
      minute: now.minute,
      estimatedDuration: suggestion.duration,
      category: suggestion.category,
    );

    setState(() => _showQuickAdd = false);
  }

  Future<bool> _showDeleteConfirmation(
    RoadmapActivityModel activity,
    DailyRoadmapProvider provider,
  ) async {
    final theme = context.read<ThemeProvider>();

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eliminar tarea',
          style: TextStyle(color: theme.textPrimary),
        ),
        content: Text(
          '¿Quieres eliminar "${activity.title}"?',
          style: TextStyle(color: theme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              provider.removeActivity(activity.id!);
              Navigator.pop(context, true);
            },
            child: Text('Eliminar', style: TextStyle(color: theme.negativeMain)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showEditActivity(
    RoadmapActivityModel activity,
    DailyRoadmapProvider provider,
    ThemeProvider theme,
  ) {
    // TODO: Implement edit modal
    HapticFeedback.selectionClick();
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

class _TimeBlock {
  final String name;
  final IconData icon;
  final int startHour;
  final int endHour;

  const _TimeBlock({
    required this.name,
    required this.icon,
    required this.startHour,
    required this.endHour,
  });
}

class _QuickSuggestion {
  final String title;
  final IconData icon;
  final int duration;
  final String category;

  const _QuickSuggestion({
    required this.title,
    required this.icon,
    required this.duration,
    required this.category,
  });
}
