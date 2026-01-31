// ============================================================================
// DAILY REVIEW PAGED SCREEN - MODERN PAGINATED EXPERIENCE
// ============================================================================
// Experiencia de revisión diaria por páginas: intuitiva, rápida y sencilla
// Sigue el estilo visual de home_screen_v2.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import 'components/minimal_colors.dart';

class DailyReviewPagedScreen extends StatefulWidget {
  final VoidCallback? onSaveComplete;
  
  const DailyReviewPagedScreen({super.key, this.onSaveComplete});

  @override
  State<DailyReviewPagedScreen> createState() => _DailyReviewPagedScreenState();
}

class _DailyReviewPagedScreenState extends State<DailyReviewPagedScreen>
    with TickerProviderStateMixin {

  // Page controller
  late PageController _pageController;
  int _currentPage = 0;
  
  // Animation controllers (matching home_screen_v2 style)
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  // Form controllers
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();

  // Core metrics (Page 2)
  int _moodScore = 7;
  int _energyLevel = 7;
  int _stressLevel = 3;
  bool? _worthIt = true;

  // Physical wellbeing (Page 3)
  int _sleepQuality = 7;
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _exerciseMinutes = 0;

  // Emotional wellbeing (Page 4)
  int _anxietyLevel = 3;
  int _motivationLevel = 7;
  int _socialBattery = 7;
  int _lifeSatisfaction = 7;

  // State
  bool _isSaving = false;

  // Pages config
  final List<_PageConfig> _pages = [
    _PageConfig(
      title: 'Reflexión',
      subtitle: '¿Cómo estuvo tu día?',
      icon: Icons.edit_note_rounded,
      emoji: '✨',
    ),
    _PageConfig(
      title: 'Estado General',
      subtitle: 'Tu ánimo y energía',
      icon: Icons.favorite_rounded,
      emoji: '💫',
    ),
    _PageConfig(
      title: 'Bienestar Físico',
      subtitle: 'Sueño y actividad',
      icon: Icons.fitness_center_rounded,
      emoji: '🏃',
    ),
    _PageConfig(
      title: 'Bienestar Mental',
      subtitle: 'Emociones y social',
      icon: Icons.psychology_rounded,
      emoji: '🧠',
    ),
    _PageConfig(
      title: 'Resumen',
      subtitle: 'Tu día completo',
      icon: Icons.auto_awesome_rounded,
      emoji: '🎯',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupAnimations();
    _loadTodayEntry();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
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

  Future<void> _loadTodayEntry() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    final entriesProvider = context.read<OptimizedDailyEntriesProvider>();

    if (authProvider.currentUser != null) {
      await entriesProvider.loadEntries(authProvider.currentUser!.id);
      final todayEntry = entriesProvider.todayEntry;

      if (mounted && todayEntry != null) {
        setState(() {
          _reflectionController.text = todayEntry.freeReflection;
          _gratitudeController.text = todayEntry.gratitudeItems ?? '';
          _moodScore = todayEntry.moodScore ?? 7;
          _energyLevel = todayEntry.energyLevel ?? 7;
          _stressLevel = todayEntry.stressLevel ?? 3;
          _worthIt = todayEntry.worthIt;
          _sleepQuality = todayEntry.sleepQuality ?? 7;
          _sleepHours = todayEntry.sleepHours ?? 8.0;
          _waterIntake = todayEntry.waterIntake ?? 8;
          _exerciseMinutes = todayEntry.exerciseMinutes ?? 0;
          _anxietyLevel = todayEntry.anxietyLevel ?? 3;
          _motivationLevel = todayEntry.motivationLevel ?? 7;
          _socialBattery = todayEntry.socialBattery ?? 7;
          _lifeSatisfaction = todayEntry.lifeSatisfaction ?? 7;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _reflectionController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      HapticFeedback.selectionClick();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      HapticFeedback.selectionClick();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveEntry() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final authProvider = context.read<OptimizedAuthProvider>();
      final entriesProvider = context.read<OptimizedDailyEntriesProvider>();

      if (authProvider.currentUser == null) return;

      final success = await entriesProvider.saveDailyEntry(
        userId: authProvider.currentUser!.id,
        freeReflection: _reflectionController.text.trim(),
        gratitudeItems: _gratitudeController.text.trim().isNotEmpty
            ? _gratitudeController.text.trim()
            : null,
        worthIt: _worthIt,
        moodScore: _moodScore,
        energyLevel: _energyLevel,
        stressLevel: _stressLevel,
        sleepQuality: _sleepQuality,
        sleepHours: _sleepHours,
        waterIntake: _waterIntake,
        exerciseMinutes: _exerciseMinutes,
        anxietyLevel: _anxietyLevel,
        motivationLevel: _motivationLevel,
        socialBattery: _socialBattery,
        lifeSatisfaction: _lifeSatisfaction,
      );

      if (success && mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✨ Entrada guardada'),
              ],
            ),
            backgroundColor: MinimalColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Navigate to home tab if callback provided, otherwise just stay
        if (widget.onSaveComplete != null) {
          widget.onSaveComplete!();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: MinimalColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: theme.primaryBg,
      body: Stack(
        children: [
          // Animated background (like home_screen_v2)
          _buildAnimatedBackground(theme),
          
          // Floating particles
          ..._buildFloatingParticles(theme),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(theme),
                  _buildProgressIndicator(theme),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildReflectionPage(theme),
                        _buildGeneralStatePage(theme),
                        _buildPhysicalPage(theme),
                        _buildEmotionalPage(theme),
                        _buildSummaryPage(theme),
                      ],
                    ),
                  ),
                  _buildNavigationBar(theme),
                ],
              ),
            ),
          ),
        ],
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
            theme.gradientHeader[0].withOpacity(0.08),
            theme.primaryBg,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles(ThemeProvider theme) {
    return List.generate(3, (index) => AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          top: 100 + (index * 180) + (math.sin(_floatingAnimation.value * math.pi * 2 + index) * 15),
          right: 30 + (index * 80) + (math.cos(_floatingAnimation.value * math.pi * 2 + index) * 20),
          child: Container(
            width: 16 + (index * 8).toDouble(),
            height: 16 + (index * 8).toDouble(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.gradientHeader[index % 2].withOpacity(0.15),
                  theme.gradientHeader[(index + 1) % 2].withOpacity(0.05),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget _buildHeader(ThemeProvider theme) {
    final config = _pages[_currentPage];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.borderColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.close_rounded, color: theme.textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title with emoji
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(config.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: theme.gradientHeader,
                      ).createShader(bounds),
                      child: Text(
                        config.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  config.subtitle,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: theme.gradientHeader),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1}/${_pages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(_pages.length, (index) {
          final isActive = index == _currentPage;
          final isCompleted = index < _currentPage;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: index < _pages.length - 1 ? 8 : 0),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: isActive || isCompleted
                            ? LinearGradient(colors: theme.gradientHeader)
                            : null,
                        color: isActive || isCompleted ? null : theme.borderColor.withOpacity(0.3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isActive ? theme.gradientHeader[0] : theme.textSecondary.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                      child: Text(_pages[index].emoji),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================================
  // PAGE 1: REFLECTION
  // ============================================================================
  Widget _buildReflectionPage(ThemeProvider theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateCard(theme),
          const SizedBox(height: 24),
          
          // Main reflection input
          _buildCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIconBadge(Icons.edit_note_rounded, theme),
                    const SizedBox(width: 12),
                    Text(
                      '¿Cómo estuvo tu día?',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reflectionController,
                  maxLines: 6,
                  style: TextStyle(color: theme.textPrimary, fontSize: 16, height: 1.6),
                  decoration: InputDecoration(
                    hintText: 'Cuéntame sobre tu día...\n¿Qué pasó? ¿Cómo te sentiste?',
                    hintStyle: TextStyle(color: theme.textHint, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Gratitude
          _buildCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIconBadge(Icons.favorite_rounded, theme, color: const Color(0xFFFF6B9D)),
                    const SizedBox(width: 12),
                    Text(
                      'Gratitud',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _gratitudeController,
                  maxLines: 3,
                  style: TextStyle(color: theme.textPrimary, fontSize: 15, height: 1.5),
                  decoration: InputDecoration(
                    hintText: '¿Por qué estás agradecido hoy?',
                    hintStyle: TextStyle(color: theme.textHint, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE 2: GENERAL STATE (Mood, Energy, Stress, Worth It)
  // ============================================================================
  Widget _buildGeneralStatePage(ThemeProvider theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Mood
          _buildQuickMetric(
            theme: theme,
            emoji: _getMoodEmoji(_moodScore),
            label: 'Estado de ánimo',
            value: _moodScore,
            color: const Color(0xFF8B5CF6),
            onChanged: (v) => setState(() => _moodScore = v),
          ),
          const SizedBox(height: 16),
          
          // Energy
          _buildQuickMetric(
            theme: theme,
            emoji: _getEnergyEmoji(_energyLevel),
            label: 'Energía',
            value: _energyLevel,
            color: const Color(0xFFF59E0B),
            onChanged: (v) => setState(() => _energyLevel = v),
          ),
          const SizedBox(height: 16),
          
          // Stress
          _buildQuickMetric(
            theme: theme,
            emoji: _getStressEmoji(_stressLevel),
            label: 'Estrés',
            value: _stressLevel,
            color: const Color(0xFFEF4444),
            onChanged: (v) => setState(() => _stressLevel = v),
            isInverted: true,
          ),
          const SizedBox(height: 24),
          
          // Worth it section
          _buildWorthItSection(theme),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE 3: PHYSICAL WELLBEING
  // ============================================================================
  Widget _buildPhysicalPage(ThemeProvider theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Sleep quality
          _buildQuickMetric(
            theme: theme,
            emoji: '😴',
            label: 'Calidad del sueño',
            value: _sleepQuality,
            color: const Color(0xFF8B5CF6),
            onChanged: (v) => setState(() => _sleepQuality = v),
          ),
          const SizedBox(height: 16),
          
          // Sleep hours
          _buildNumericInput(
            theme: theme,
            emoji: '🌙',
            label: 'Horas de sueño',
            value: _sleepHours,
            unit: 'hrs',
            min: 0,
            max: 12,
            color: const Color(0xFF6366F1),
            onChanged: (v) => setState(() => _sleepHours = v),
          ),
          const SizedBox(height: 16),
          
          // Water
          _buildNumericInput(
            theme: theme,
            emoji: '💧',
            label: 'Vasos de agua',
            value: _waterIntake.toDouble(),
            unit: 'vasos',
            min: 0,
            max: 15,
            color: const Color(0xFF06B6D4),
            onChanged: (v) => setState(() => _waterIntake = v.round()),
          ),
          const SizedBox(height: 16),
          
          // Exercise
          _buildNumericInput(
            theme: theme,
            emoji: '🏃',
            label: 'Ejercicio',
            value: _exerciseMinutes.toDouble(),
            unit: 'min',
            min: 0,
            max: 180,
            color: const Color(0xFF10B981),
            onChanged: (v) => setState(() => _exerciseMinutes = v.round()),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE 4: EMOTIONAL WELLBEING
  // ============================================================================
  Widget _buildEmotionalPage(ThemeProvider theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Anxiety
          _buildQuickMetric(
            theme: theme,
            emoji: '😰',
            label: 'Nivel de ansiedad',
            value: _anxietyLevel,
            color: const Color(0xFFEF4444),
            onChanged: (v) => setState(() => _anxietyLevel = v),
            isInverted: true,
          ),
          const SizedBox(height: 16),
          
          // Motivation
          _buildQuickMetric(
            theme: theme,
            emoji: '🔥',
            label: 'Motivación',
            value: _motivationLevel,
            color: const Color(0xFFF59E0B),
            onChanged: (v) => setState(() => _motivationLevel = v),
          ),
          const SizedBox(height: 16),
          
          // Social battery
          _buildQuickMetric(
            theme: theme,
            emoji: '🔋',
            label: 'Batería social',
            value: _socialBattery,
            color: const Color(0xFF10B981),
            onChanged: (v) => setState(() => _socialBattery = v),
          ),
          const SizedBox(height: 16),
          
          // Life satisfaction
          _buildQuickMetric(
            theme: theme,
            emoji: '✨',
            label: 'Satisfacción de vida',
            value: _lifeSatisfaction,
            color: const Color(0xFF8B5CF6),
            onChanged: (v) => setState(() => _lifeSatisfaction = v),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE 5: SUMMARY
  // ============================================================================
  Widget _buildSummaryPage(ThemeProvider theme) {
    final overallScore = (_moodScore + _energyLevel + (10 - _stressLevel) + _lifeSatisfaction) / 4;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Overall score card
          _buildOverallScoreCard(theme, overallScore),
          const SizedBox(height: 20),
          
          // Quick stats grid
          _buildStatsGrid(theme),
          const SizedBox(height: 20),
          
          // Smart suggestion
          _buildSmartSuggestion(theme),
          const SizedBox(height: 24),
          
          // Save button
          _buildSaveButton(theme),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard(ThemeProvider theme, double score) {
    final label = score >= 8 ? 'Excelente' : score >= 6 ? 'Bien' : score >= 4 ? 'Regular' : 'Mejorable';
    final emoji = score >= 8 ? '🌟' : score >= 6 ? '😊' : score >= 4 ? '😐' : '💪';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.gradientHeader[0].withOpacity(0.15),
            theme.gradientHeader[1].withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.gradientHeader[0].withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(colors: theme.gradientHeader).createShader(bounds),
            child: Text(
              '${score.toStringAsFixed(1)}/10',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bienestar General',
            style: TextStyle(
              color: theme.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeProvider theme) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(theme, '😊', 'Ánimo', '$_moodScore/10', const Color(0xFF8B5CF6))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, '⚡', 'Energía', '$_energyLevel/10', const Color(0xFFF59E0B))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, '😌', 'Estrés', '$_stressLevel/10', const Color(0xFFEF4444))),
      ],
    );
  }

  Widget _buildStatCard(ThemeProvider theme, String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: theme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestion(ThemeProvider theme) {
    String suggestion;
    String emoji;
    
    if (_moodScore <= 4) {
      suggestion = 'Recuerda: los días difíciles también pasan. ¿Qué pequeña cosa podrías hacer para sentirte mejor?';
      emoji = '💙';
    } else if (_stressLevel >= 7) {
      suggestion = 'Tu estrés está alto. Intenta respirar profundamente o dar un pequeño paseo.';
      emoji = '🌿';
    } else if (_energyLevel <= 4) {
      suggestion = 'Poca energía hoy. Asegúrate de descansar bien esta noche.';
      emoji = '🌙';
    } else {
      suggestion = '¡Buen día! Sigue así y celebra tus pequeños logros.';
      emoji = '🎉';
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.gradientHeader[1].withOpacity(0.1),
            theme.gradientHeader[0].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.gradientHeader[1].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // REUSABLE COMPONENTS
  // ============================================================================
  
  Widget _buildDateCard(ThemeProvider theme) {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    final month = _getMonthName(now.month);

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekday, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                Text(
                  '$month ${now.day}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            '${now.day}',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required ThemeProvider theme, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildIconBadge(IconData icon, ThemeProvider theme, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: color != null ? [color, color.withOpacity(0.7)] : theme.gradientHeader),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildQuickMetric({
    required ThemeProvider theme,
    required String emoji,
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
    bool isInverted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value/10',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick select buttons
          Row(
            children: List.generate(10, (index) {
              final v = index + 1;
              final isSelected = v == value;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(v);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: index < 9 ? 4 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [color, color.withOpacity(0.8)]) : null,
                      color: isSelected ? null : theme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : theme.borderColor.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$v',
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.textSecondary,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericInput({
    required ThemeProvider theme,
    required String emoji,
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} $unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItSection(ThemeProvider theme) {
    return _buildCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBadge(Icons.star_rounded, theme, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 12),
              Text(
                '¿Valió la pena?',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildWorthItOption(
                  theme: theme,
                  label: 'Sí',
                  emoji: '✅',
                  isSelected: _worthIt == true,
                  color: const Color(0xFF10B981),
                  onTap: () => setState(() => _worthIt = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWorthItOption(
                  theme: theme,
                  label: 'Más o menos',
                  emoji: '😐',
                  isSelected: _worthIt == null,
                  color: const Color(0xFFF59E0B),
                  onTap: () => setState(() => _worthIt = null),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWorthItOption(
                  theme: theme,
                  label: 'No',
                  emoji: '❌',
                  isSelected: _worthIt == false,
                  color: const Color(0xFFEF4444),
                  onTap: () => setState(() => _worthIt = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItOption({
    required ThemeProvider theme,
    required String label,
    required String emoji,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [color, color.withOpacity(0.8)]) : null,
          color: isSelected ? null : theme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : theme.borderColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(ThemeProvider theme) {
    final isLastPage = _currentPage == _pages.length - 1;
    final isFirstPage = _currentPage == 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          if (!isFirstPage)
            Expanded(
              child: GestureDetector(
                onTap: _previousPage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.borderColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, color: theme.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Anterior',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          if (!isFirstPage && !isLastPage) const SizedBox(width: 12),
          
          // Next/Save button
          Expanded(
            flex: isFirstPage ? 1 : 1,
            child: GestureDetector(
              onTap: isLastPage ? _saveEntry : _nextPage,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isLastPage ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: theme.gradientHeader),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.gradientHeader[0].withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isSaving
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage ? 'Guardar' : 'Siguiente',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSaving ? 1.0 : _pulseAnimation.value,
          child: GestureDetector(
            onTap: _isSaving ? null : _saveEntry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: theme.gradientHeader),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.gradientHeader[0].withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _isSaving
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Guardar Entrada',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================
  
  String _getMoodEmoji(int score) {
    if (score >= 9) return '😍';
    if (score >= 7) return '😊';
    if (score >= 5) return '😐';
    if (score >= 3) return '😕';
    return '😢';
  }

  String _getEnergyEmoji(int score) {
    if (score >= 8) return '⚡';
    if (score >= 6) return '💪';
    if (score >= 4) return '🔋';
    return '🪫';
  }

  String _getStressEmoji(int score) {
    if (score >= 8) return '😰';
    if (score >= 6) return '😓';
    if (score >= 4) return '😌';
    return '😎';
  }

  String _getWeekdayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
                    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }
}

class _PageConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;

  const _PageConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
  });
}
