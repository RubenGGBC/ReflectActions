// ============================================================================
// DAILY REVIEW STEPPER SCREEN - STEP-BY-STEP REVIEW EXPERIENCE
// ============================================================================
// Versión con flujo por pasos para una experiencia más rápida e intuitiva

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../../data/models/optimized_models.dart';
import 'components/minimal_colors.dart';
import '../../widgets/voice_recording_widget.dart';
import 'calendar_screen_v2.dart';
import 'package:image_picker/image_picker.dart';

class DailyReviewStepperScreen extends StatefulWidget {
  const DailyReviewStepperScreen({super.key});

  @override
  State<DailyReviewStepperScreen> createState() => _DailyReviewStepperScreenState();
}

class _DailyReviewStepperScreenState extends State<DailyReviewStepperScreen>
    with TickerProviderStateMixin {

  // Page controller
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalPages = 5;

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  // Form controllers
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();

  // Core metrics
  int _moodScore = 7;
  int _energyLevel = 7;
  int _stressLevel = 3;
  bool? _worthIt = true;

  // Physical wellbeing
  int _sleepQuality = 7;
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _exerciseMinutes = 0;

  // Emotional wellbeing
  int _anxietyLevel = 3;
  int _motivationLevel = 7;
  int _socialInteraction = 7;
  int _socialBattery = 7;

  // Productivity
  int _workProductivity = 7;
  int _focusLevel = 7;
  int _lifeSatisfaction = 7;

  // Voice & Photos
  String? _voiceRecordingPath;
  List<String> _dailyPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSaving = false;
  bool _isLoading = true;

  // Step info - Usando paleta de colores de la app
  List<_StepInfo> get _steps => [
    _StepInfo(
      title: 'Reflexiona',
      subtitle: 'Cuéntame sobre tu día',
      icon: Icons.edit_note_rounded,
      color: const Color(0xFF7C3AED), // Púrpura del gradiente
    ),
    _StepInfo(
      title: 'Estado General',
      subtitle: '¿Cómo te sientes?',
      icon: Icons.mood_rounded,
      color: const Color(0xFF3B82F6), // Azul accent
    ),
    _StepInfo(
      title: 'Bienestar Físico',
      subtitle: 'Cuerpo y energía',
      icon: Icons.fitness_center_rounded,
      color: const Color(0xFF10B981), // Verde positivo
    ),
    _StepInfo(
      title: 'Bienestar Emocional',
      subtitle: 'Mente y emociones',
      icon: Icons.psychology_rounded,
      color: const Color(0xFF1E3A8A), // Azul oscuro del gradiente
    ),
    _StepInfo(
      title: 'Resumen',
      subtitle: 'Tu día completo',
      icon: Icons.summarize_rounded,
      color: const Color(0xFF7C3AED), // Púrpura del gradiente
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
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1.0,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
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
          _socialInteraction = todayEntry.socialInteraction ?? 7;
          _socialBattery = todayEntry.socialBattery ?? 7;
          _workProductivity = todayEntry.workProductivity ?? 7;
          _focusLevel = todayEntry.focusLevel ?? 7;
          _lifeSatisfaction = todayEntry.lifeSatisfaction ?? 7;
          _voiceRecordingPath = todayEntry.voiceRecordingPath;
        });
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;

    HapticFeedback.selectionClick();
    _fadeController.forward(from: 0);

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  Future<void> _saveEntry() async {
    if (_reflectionController.text.trim().isEmpty) {
      _showSnackBar('Escribe algo sobre tu día primero', isError: true);
      _goToPage(0);
      return;
    }

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
        socialInteraction: _socialInteraction,
        socialBattery: _socialBattery,
        workProductivity: _workProductivity,
        focusLevel: _focusLevel,
        lifeSatisfaction: _lifeSatisfaction,
        voiceRecordingPath: _voiceRecordingPath,
      );

      if (success) {
        HapticFeedback.heavyImpact();
        _showSnackBar('Entrada guardada exitosamente');
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('Error al guardar', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    _reflectionController.dispose();
    _gratitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MinimalColors.backgroundPrimary(context),
        body: Center(
          child: CircularProgressIndicator(
            color: _steps[0].color,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  HapticFeedback.selectionClick();
                },
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildReflectionPage(),
                  _buildGeneralStatePage(),
                  _buildPhysicalWellbeingPage(),
                  _buildEmotionalWellbeingPage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final step = _steps[_currentPage];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MinimalColors.shadow(context),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                color: MinimalColors.textSecondary(context),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    step.title,
                    key: ValueKey(step.title),
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    step.subtitle,
                    key: ValueKey(step.subtitle),
                    style: TextStyle(
                      color: MinimalColors.textTertiary(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [step.color, step.color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: step.color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(step.icon, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final isActive = index == _currentPage;
              final isPast = index < _currentPage;
              final step = _steps[index];

              return GestureDetector(
                onTap: () => _goToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: isActive ? 32 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: (isActive || isPast)
                        ? LinearGradient(colors: [step.color, step.color.withOpacity(0.7)])
                        : null,
                    color: (isActive || isPast) ? null : MinimalColors.shadow(context),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: step.color.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Step counter
          Text(
            'Paso ${_currentPage + 1} de $_totalPages',
            style: TextStyle(
              color: MinimalColors.textTertiary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == _totalPages - 1;
    final step = _steps[_currentPage];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (!isFirstPage)
            GestureDetector(
              onTap: _previousPage,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundPrimary(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MinimalColors.shadow(context),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: MinimalColors.textSecondary(context),
                  size: 24,
                ),
              ),
            )
          else
            const SizedBox(width: 56),

          const SizedBox(width: 12),

          // Main action button
          Expanded(
            child: GestureDetector(
              onTap: isLastPage ? _saveEntry : _nextPage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLastPage
                        ? [const Color(0xFF10B981), const Color(0xFF3B82F6)]
                        : [step.color, step.color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isLastPage ? const Color(0xFF10B981) : step.color)
                          .withOpacity(0.4),
                      blurRadius: 16,
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
                            strokeWidth: 2.5,
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
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLastPage
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Skip button (optional)
          if (!isLastPage)
            GestureDetector(
              onTap: () => _goToPage(_totalPages - 1),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundPrimary(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MinimalColors.shadow(context),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.skip_next_rounded,
                  color: MinimalColors.textTertiary(context),
                  size: 24,
                ),
              ),
            )
          else
            const SizedBox(width: 56),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE 1: REFLECTION
  // ============================================================================
  Widget _buildReflectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateCard(),
          const SizedBox(height: 24),

          // Main reflection
          _buildQuestionCard(
            question: '¿Cómo estuvo tu día?',
            hint: 'Cuéntame lo que pasó, cómo te sentiste, qué aprendiste...',
            controller: _reflectionController,
            maxLines: 8,
            color: _steps[0].color,
          ),
          const SizedBox(height: 20),

          // Voice recording
          _buildVoiceSection(),
          const SizedBox(height: 20),

          // Gratitude
          _buildQuestionCard(
            question: '¿Por qué estás agradecido hoy?',
            hint: 'Algo pequeño o grande que aprecias...',
            controller: _gratitudeController,
            maxLines: 3,
            color: const Color(0xFF7C3AED),
            icon: Icons.favorite_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    final month = _getMonthName(now.month);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_steps[0].color, _steps[0].color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _steps[0].color.withOpacity(0.3),
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
                Text(
                  weekday,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$month ${now.day}, ${now.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${now.day}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required String question,
    required String hint,
    required TextEditingController controller,
    int maxLines = 4,
    required Color color,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: MinimalColors.textTertiary(context),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.mic_rounded, color: Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'O graba una nota de voz',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        VoiceRecordingWidget(
          existingRecordingPath: _voiceRecordingPath,
          onRecordingComplete: (path) => setState(() => _voiceRecordingPath = path),
          isExpanded: true,
          onExpand: () {},
        ),
      ],
    );
  }

  // ============================================================================
  // PAGE 2: GENERAL STATE
  // ============================================================================
  Widget _buildGeneralStatePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Mood - Main focus
          _buildEmojiSelector(
            title: '¿Cómo te sientes?',
            value: _moodScore,
            onChanged: (v) => setState(() => _moodScore = v),
            emojis: const ['😢', '😕', '😐', '🙂', '😊', '😁'],
            colors: [
              const Color(0xFFEF4444),
              const Color(0xFFFBBF24),
              const Color(0xFFF59E0B),
              const Color(0xFF34D399),
              const Color(0xFF10B981),
              const Color(0xFF10B981),
            ],
          ),
          const SizedBox(height: 28),

          // Energy level
          _buildQuickSlider(
            label: 'Nivel de energía',
            emoji: _getEnergyEmoji(_energyLevel),
            value: _energyLevel,
            onChanged: (v) => setState(() => _energyLevel = v),
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 20),

          // Stress level
          _buildQuickSlider(
            label: 'Nivel de estrés',
            emoji: _getStressEmoji(_stressLevel),
            value: _stressLevel,
            onChanged: (v) => setState(() => _stressLevel = v),
            color: const Color(0xFFEF4444),
            isInverted: true,
          ),
          const SizedBox(height: 28),

          // Worth it section
          _buildWorthItSelector(),
        ],
      ),
    );
  }

  Widget _buildEmojiSelector({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    required List<String> emojis,
    required List<Color> colors,
  }) {
    // Map value (1-10) to emoji index (0-5)
    final selectedIndex = ((value - 1) / 10 * emojis.length).floor().clamp(0, emojis.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(emojis.length, (index) {
            final isSelected = index == selectedIndex;
            final mappedValue = ((index / (emojis.length - 1)) * 9 + 1).round();

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(mappedValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 16 : 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors[index].withOpacity(0.2)
                      : MinimalColors.backgroundCard(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? colors[index] : MinimalColors.shadow(context),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors[index].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  emojis[index],
                  style: TextStyle(fontSize: isSelected ? 36 : 28),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Value display
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: colors[selectedIndex].withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$value/10',
              style: TextStyle(
                color: colors[selectedIndex],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSlider({
    required String label,
    required String emoji,
    required int value,
    required ValueChanged<int> onChanged,
    required Color color,
    bool isInverted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                onChanged(v.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Valió la pena el día?',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildWorthItOption(
                icon: Icons.thumb_up_rounded,
                label: 'Sí',
                isSelected: _worthIt == true,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _worthIt = true);
                },
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWorthItOption(
                icon: Icons.help_outline_rounded,
                label: 'No sé',
                isSelected: _worthIt == null,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _worthIt = null);
                },
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWorthItOption(
                icon: Icons.thumb_down_rounded,
                label: 'No',
                isSelected: _worthIt == false,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _worthIt = false);
                },
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorthItOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isSelected ? null : MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PAGE 3: PHYSICAL WELLBEING
  // ============================================================================
  Widget _buildPhysicalWellbeingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Sleep quality with visual
          _buildSleepCard(),
          const SizedBox(height: 20),

          // Quick metrics row
          Row(
            children: [
              Expanded(
                child: _buildCompactMetric(
                  icon: Icons.water_drop_rounded,
                  label: 'Agua',
                  value: '$_waterIntake',
                  unit: 'vasos',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _showNumberPicker(
                    title: 'Vasos de agua',
                    current: _waterIntake,
                    min: 0,
                    max: 15,
                    onChanged: (v) => setState(() => _waterIntake = v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactMetric(
                  icon: Icons.directions_run_rounded,
                  label: 'Ejercicio',
                  value: '$_exerciseMinutes',
                  unit: 'min',
                  color: const Color(0xFFEF4444),
                  onTap: () => _showNumberPicker(
                    title: 'Minutos de ejercicio',
                    current: _exerciseMinutes,
                    min: 0,
                    max: 180,
                    step: 5,
                    onChanged: (v) => setState(() => _exerciseMinutes = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sleep quality slider
          _buildQuickSlider(
            label: 'Calidad del sueño',
            emoji: '😴',
            value: _sleepQuality,
            onChanged: (v) => setState(() => _sleepQuality = v),
            color: const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withOpacity(0.15),
            const Color(0xFF7C3AED).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bedtime_rounded,
                  color: Color(0xFF7C3AED),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horas de sueño',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arrastra para ajustar',
                      style: TextStyle(
                        color: MinimalColors.textTertiary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_sleepHours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF7C3AED),
              inactiveTrackColor: const Color(0xFF7C3AED).withOpacity(0.2),
              thumbColor: const Color(0xFF7C3AED),
              overlayColor: const Color(0xFF7C3AED).withOpacity(0.1),
              trackHeight: 10,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _sleepHours,
              min: 0,
              max: 12,
              divisions: 24,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _sleepHours = v);
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0h', style: TextStyle(color: MinimalColors.textTertiary(context), fontSize: 12)),
              Text('6h', style: TextStyle(color: MinimalColors.textTertiary(context), fontSize: 12)),
              Text('12h', style: TextStyle(color: MinimalColors.textTertiary(context), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetric({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                color: MinimalColors.textTertiary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para editar',
              style: TextStyle(
                color: color.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberPicker({
    required String title,
    required int current,
    required int min,
    required int max,
    int step = 1,
    required ValueChanged<int> onChanged,
  }) {
    int tempValue = current;

    showModalBottomSheet(
      context: context,
      backgroundColor: MinimalColors.backgroundCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MinimalColors.shadow(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: tempValue > min
                        ? () {
                            HapticFeedback.selectionClick();
                            setModalState(() => tempValue = (tempValue - step).clamp(min, max));
                          }
                        : null,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.remove, color: Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '$tempValue',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: tempValue < max
                        ? () {
                            HapticFeedback.selectionClick();
                            setModalState(() => tempValue = (tempValue + step).clamp(min, max));
                          }
                        : null,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onChanged(tempValue);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // PAGE 4: EMOTIONAL WELLBEING
  // ============================================================================
  Widget _buildEmotionalWellbeingPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildQuickSlider(
            label: 'Nivel de ansiedad',
            emoji: '😰',
            value: _anxietyLevel,
            onChanged: (v) => setState(() => _anxietyLevel = v),
            color: const Color(0xFFEF4444),
            isInverted: true,
          ),
          const SizedBox(height: 16),

          _buildQuickSlider(
            label: 'Motivación',
            emoji: '🔥',
            value: _motivationLevel,
            onChanged: (v) => setState(() => _motivationLevel = v),
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),

          _buildQuickSlider(
            label: 'Interacción social',
            emoji: '👥',
            value: _socialInteraction,
            onChanged: (v) => setState(() => _socialInteraction = v),
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 16),

          _buildQuickSlider(
            label: 'Batería social',
            emoji: '🔋',
            value: _socialBattery,
            onChanged: (v) => setState(() => _socialBattery = v),
            color: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PAGE 5: SUMMARY
  // ============================================================================
  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Overall wellbeing card
          _buildOverallScoreCard(),
          const SizedBox(height: 20),

          // Quick stats grid
          _buildStatsGrid(),
          const SizedBox(height: 20),

          // Productivity section
          _buildProductivitySummary(),
          const SizedBox(height: 20),

          // Smart insights
          _buildSmartInsights(),
        ],
      ),
    );
  }

  Widget _buildOverallScoreCard() {
    final double physicalScore = (_sleepQuality + (_waterIntake / 1.5).clamp(0, 10)) / 2;
    final double emotionalScore = (_moodScore + _motivationLevel + (10 - _anxietyLevel)) / 3;
    final double productivityScore = (_workProductivity + _focusLevel + _energyLevel) / 3;
    final double overallScore = (physicalScore + emotionalScore + productivityScore) / 3;

    Color getScoreColor(double score) {
      if (score >= 8) return const Color(0xFF10B981);
      if (score >= 6) return const Color(0xFF34D399);
      if (score >= 4) return const Color(0xFFF59E0B);
      return const Color(0xFFEF4444);
    }

    String getScoreLabel(double score) {
      if (score >= 8) return 'Excelente';
      if (score >= 6) return 'Bien';
      if (score >= 4) return 'Regular';
      return 'Necesita atención';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getScoreColor(overallScore).withOpacity(0.2),
            getScoreColor(overallScore).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: getScoreColor(overallScore).withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.spa_rounded,
                color: getScoreColor(overallScore),
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Bienestar General',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            overallScore.toStringAsFixed(1),
            style: TextStyle(
              color: getScoreColor(overallScore),
              fontSize: 64,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            getScoreLabel(overallScore),
            style: TextStyle(
              color: getScoreColor(overallScore),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.mood_rounded,
            label: 'Ánimo',
            value: _moodScore.toString(),
            color: const Color(0xFF7C3AED),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.bolt_rounded,
            label: 'Energía',
            value: _energyLevel.toString(),
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStatCard(
            icon: Icons.bedtime_rounded,
            label: 'Sueño',
            value: '${_sleepHours.toStringAsFixed(1)}h',
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
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
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
              color: MinimalColors.textTertiary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivitySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF3B82F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Productividad',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProductivityRow('Trabajo', _workProductivity, const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildProductivityRow('Enfoque', _focusLevel, const Color(0xFF7C3AED)),
          const SizedBox(height: 12),
          _buildProductivityRow('Satisfacción', _lifeSatisfaction, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildProductivityRow(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 10,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartInsights() {
    final insights = _getInsights();

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withOpacity(0.1),
            const Color(0xFF7C3AED).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: Color(0xFF7C3AED),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Insights del día',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.take(3).map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFF7C3AED))),
                Expanded(
                  child: Text(
                    insight,
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getInsights() {
    final insights = <String>[];

    if (_moodScore <= 4 && _energyLevel >= 7) {
      insights.add('Tienes energía pero tu ánimo está bajo. Considera hacer algo que disfrutes.');
    }
    if (_stressLevel >= 7 && _sleepQuality <= 4) {
      insights.add('El estrés alto y sueño pobre están relacionados. Prioriza tu descanso.');
    }
    if (_moodScore >= 8 && _energyLevel >= 8) {
      insights.add('¡Excelente día! Anota qué hiciste diferente para replicarlo.');
    }
    if (_waterIntake <= 4 && _energyLevel <= 5) {
      insights.add('Poca hidratación puede afectar tu energía. Intenta beber más agua.');
    }
    if (_socialInteraction >= 8 && _socialBattery <= 3) {
      insights.add('Mucha interacción social ha drenado tu batería. Tómate tiempo para ti.');
    }

    if (insights.isEmpty) {
      insights.add('Sigue registrando tu día para obtener insights personalizados.');
    }

    return insights;
  }

  // ============================================================================
  // HELPERS
  // ============================================================================
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
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}

class _StepInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StepInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
