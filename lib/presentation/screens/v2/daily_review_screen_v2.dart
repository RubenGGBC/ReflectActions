// ============================================================================
// DAILY REVIEW SCREEN V2 - REDESIGNED WITH ALL FEATURES
// ============================================================================
// Versión reorganizada manteniendo TODAS las funcionalidades originales

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/daily_activities_provider.dart';
import '../../../data/models/optimized_models.dart';
import '../../../data/models/goal_model.dart';
import 'components/minimal_colors.dart';
import '../../widgets/voice_recording_widget.dart';
import '../../widgets/enhanced_goal_card.dart';
import '../../widgets/progress_entry_dialog.dart';
import 'calendar_screen_v2.dart';
import 'activities_screen.dart';
import '../v5/analytics_screen_v5.dart';
import 'package:image_picker/image_picker.dart';

class DailyReviewScreenV2 extends StatefulWidget {
  const DailyReviewScreenV2({super.key});

  @override
  State<DailyReviewScreenV2> createState() => _DailyReviewScreenV2State();
}

class _DailyReviewScreenV2State extends State<DailyReviewScreenV2>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Form controllers
  final _reflectionController = TextEditingController();
  final _innerReflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _positiveTagsController = TextEditingController();
  final _negativeTagsController = TextEditingController();
  final _scrollController = ScrollController();

  // Core metrics
  int _moodScore = 7;
  int _energyLevel = 7;
  int _stressLevel = 3;
  bool? _worthIt = true;

  // Wellbeing metrics - Physical
  int _sleepQuality = 7;
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _exerciseMinutes = 0;
  int _meditationMinutes = 0;
  double _screenTimeHours = 4.0;
  int _physicalActivity = 7;

  // Wellbeing metrics - Emotional
  int _anxietyLevel = 3;
  int _motivationLevel = 7;
  int _socialInteraction = 7;
  int _emotionalStability = 7;
  int _socialBattery = 7;
  int _creativeEnergy = 7;
  int _weatherMoodImpact = 0;

  // Productivity metrics
  int _workProductivity = 7;
  int _focusLevel = 7;
  int _lifeSatisfaction = 7;

  // Activities & Goals
  List<String> _completedActivitiesToday = [];
  List<String> _goalsSummary = [];

  // Voice recording
  String? _voiceRecordingPath;

  // Daily photos
  List<String> _dailyPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Expansion states
  bool _isSaving = false;
  bool _showInnerReflection = false;
  bool _showGratitude = false;
  bool _showTags = false;
  bool _showPhysicalWellbeing = false;
  bool _showEmotionalWellbeing = false;
  bool _showProductivity = false;
  bool _showActivitiesGoals = false;
  bool _showVoiceRecording = false;
  bool _showDailyPhotos = false;
  bool _showSmartSuggestions = false;

  @override
  void initState() {
    super.initState();
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
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
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
          _innerReflectionController.text = todayEntry.innerReflection ?? '';
          _gratitudeController.text = todayEntry.gratitudeItems ?? '';
          _positiveTagsController.text = todayEntry.positiveTags.join(', ');
          _negativeTagsController.text = todayEntry.negativeTags.join(', ');

          _moodScore = todayEntry.moodScore ?? 7;
          _energyLevel = todayEntry.energyLevel ?? 7;
          _stressLevel = todayEntry.stressLevel ?? 3;
          _worthIt = todayEntry.worthIt;

          _sleepQuality = todayEntry.sleepQuality ?? 7;
          _sleepHours = todayEntry.sleepHours ?? 8.0;
          _waterIntake = todayEntry.waterIntake ?? 8;
          _exerciseMinutes = todayEntry.exerciseMinutes ?? 0;
          _meditationMinutes = todayEntry.meditationMinutes ?? 0;
          _screenTimeHours = todayEntry.screenTimeHours ?? 4.0;
          _physicalActivity = todayEntry.physicalActivity ?? 7;

          _anxietyLevel = todayEntry.anxietyLevel ?? 3;
          _motivationLevel = todayEntry.motivationLevel ?? 7;
          _socialInteraction = todayEntry.socialInteraction ?? 7;
          _emotionalStability = todayEntry.emotionalStability ?? 7;
          _socialBattery = todayEntry.socialBattery ?? 7;
          _creativeEnergy = todayEntry.creativeEnergy ?? 7;
          _weatherMoodImpact = todayEntry.weatherMoodImpact ?? 0;

          _workProductivity = todayEntry.workProductivity ?? 7;
          _focusLevel = todayEntry.focusLevel ?? 7;
          _lifeSatisfaction = todayEntry.lifeSatisfaction ?? 7;

          _voiceRecordingPath = todayEntry.voiceRecordingPath;
        });
      }
    }
  }

  Future<void> _saveEntry() async {
    if (_reflectionController.text.trim().isEmpty) {
      _showSnackBar('Escribe algo sobre tu día', isError: true);
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
        positiveTags: _positiveTagsController.text.trim().isNotEmpty
            ? _positiveTagsController.text.split(',').map((t) => t.trim()).toList()
            : [],
        negativeTags: _negativeTagsController.text.trim().isNotEmpty
            ? _negativeTagsController.text.split(',').map((t) => t.trim()).toList()
            : [],
        worthIt: _worthIt,
        moodScore: _moodScore,
        energyLevel: _energyLevel,
        stressLevel: _stressLevel,
        sleepQuality: _sleepQuality,
        sleepHours: _sleepHours,
        waterIntake: _waterIntake,
        exerciseMinutes: _exerciseMinutes,
        meditationMinutes: _meditationMinutes,
        screenTimeHours: _screenTimeHours,
        physicalActivity: _physicalActivity,
        anxietyLevel: _anxietyLevel,
        motivationLevel: _motivationLevel,
        socialInteraction: _socialInteraction,
        emotionalStability: _emotionalStability,
        socialBattery: _socialBattery,
        creativeEnergy: _creativeEnergy,
        weatherMoodImpact: _weatherMoodImpact,
        workProductivity: _workProductivity,
        focusLevel: _focusLevel,
        lifeSatisfaction: _lifeSatisfaction,
        voiceRecordingPath: _voiceRecordingPath,
      );

      if (success) {
        HapticFeedback.heavyImpact();
        _showSnackBar('✨ Entrada guardada exitosamente');

        // Optional: Clear form or keep data
        // Future.delayed(const Duration(seconds: 1), _clearForm);
      } else {
        _showSnackBar('Error al guardar la entrada', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _clearForm() {
    if (!mounted) return;
    setState(() {
      _reflectionController.clear();
      _innerReflectionController.clear();
      _gratitudeController.clear();
      _positiveTagsController.clear();
      _negativeTagsController.clear();
      _moodScore = 7;
      _energyLevel = 7;
      _stressLevel = 3;
      _worthIt = true;
      _sleepQuality = 7;
      _sleepHours = 8.0;
      _waterIntake = 8;
      _exerciseMinutes = 0;
      _meditationMinutes = 0;
      _screenTimeHours = 4.0;
      _physicalActivity = 7;
      _anxietyLevel = 3;
      _motivationLevel = 7;
      _socialInteraction = 7;
      _emotionalStability = 7;
      _socialBattery = 7;
      _creativeEnergy = 7;
      _weatherMoodImpact = 0;
      _workProductivity = 7;
      _focusLevel = 7;
      _lifeSatisfaction = 7;
      _completedActivitiesToday = [];
      _goalsSummary = [];
      _voiceRecordingPath = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFFF6B6B)
            : const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _reflectionController.dispose();
    _innerReflectionController.dispose();
    _gratitudeController.dispose();
    _positiveTagsController.dispose();
    _negativeTagsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDateCard(),
                    const SizedBox(height: 24),

                    // Main reflection with smart analysis
                    _buildReflectionSection(),
                    const SizedBox(height: 16),

                    // Optional sections (collapsible)
                    _buildExpandableSection(
                      isExpanded: _showInnerReflection,
                      onToggle: () => setState(() => _showInnerReflection = !_showInnerReflection),
                      icon: Icons.self_improvement_rounded,
                      title: 'Reflexión Interna',
                      subtitle: 'Profundiza en tus pensamientos',
                      child: _buildInnerReflection(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showGratitude,
                      onToggle: () => setState(() => _showGratitude = !_showGratitude),
                      icon: Icons.favorite_rounded,
                      title: 'Gratitud',
                      subtitle: '¿Por qué estás agradecido?',
                      child: _buildGratitude(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showTags,
                      onToggle: () => setState(() => _showTags = !_showTags),
                      icon: Icons.tag_rounded,
                      title: 'Tags Emocionales',
                      subtitle: 'Identifica tus emociones',
                      child: _buildTagsSection(),
                    ),
                    const SizedBox(height: 20),

                    // Core metrics (always visible)
                    _buildCoreMetricsSection(),
                    const SizedBox(height: 20),

                    // Wellbeing summary visualization
                    _buildWellbeingSummaryCard(),
                    const SizedBox(height: 20),

                    _buildWorthItSection(),
                    const SizedBox(height: 16),

                    // Advanced collapsible sections
                    _buildExpandableSection(
                      isExpanded: _showPhysicalWellbeing,
                      onToggle: () => setState(() => _showPhysicalWellbeing = !_showPhysicalWellbeing),
                      icon: Icons.fitness_center_rounded,
                      title: 'Bienestar Físico',
                      subtitle: 'Sueño, ejercicio, hidratación',
                      child: _buildPhysicalWellbeingSection(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showEmotionalWellbeing,
                      onToggle: () => setState(() => _showEmotionalWellbeing = !_showEmotionalWellbeing),
                      icon: Icons.psychology_rounded,
                      title: 'Bienestar Emocional',
                      subtitle: 'Ansiedad, motivación, social',
                      child: _buildEmotionalWellbeingSection(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showProductivity,
                      onToggle: () => setState(() => _showProductivity = !_showProductivity),
                      icon: Icons.work_rounded,
                      title: 'Productividad & Enfoque',
                      subtitle: 'Trabajo, concentración, satisfacción',
                      child: _buildProductivitySection(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showActivitiesGoals,
                      onToggle: () => setState(() => _showActivitiesGoals = !_showActivitiesGoals),
                      icon: Icons.check_circle_rounded,
                      title: 'Actividades & Metas',
                      subtitle: 'Lo que lograste hoy',
                      child: _buildActivitiesGoalsSection(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showDailyPhotos,
                      onToggle: () => setState(() => _showDailyPhotos = !_showDailyPhotos),
                      icon: Icons.photo_camera_rounded,
                      title: 'Fotos del Día',
                      subtitle: 'Captura momentos especiales',
                      child: _buildDailyPhotosSection(),
                    ),
                    const SizedBox(height: 16),

                    _buildExpandableSection(
                      isExpanded: _showVoiceRecording,
                      onToggle: () => setState(() => _showVoiceRecording = !_showVoiceRecording),
                      icon: Icons.mic_rounded,
                      title: 'Nota de Voz',
                      subtitle: 'Graba tus pensamientos',
                      child: _buildVoiceRecordingSection(),
                    ),
                    const SizedBox(height: 24),

                    // Smart suggestions (collapsible)
                    _buildSmartSuggestionsCard(),
                    const SizedBox(height: 24),

                    // Analytics navigation button
                    _buildAnalyticsButton(),
                    const SizedBox(height: 24),

                    _buildSaveButton(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: MinimalColors.primaryGradient(context),
          ).createShader(bounds),
          child: const Text(
            'Mi Día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.calendar_today_rounded,
            color: MinimalColors.textSecondary(context),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarScreenV2()),
          ),
        ),
        const SizedBox(width: 8),
      ],
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
          colors: MinimalColors.primaryGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.gradientShadow(context, alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$month ${now.day}, ${now.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection() {
    final analysis = _analyzeReflectionText(_reflectionController.text);
    final wordCount = analysis['wordCount'] as int;
    final sentiment = analysis['sentiment'] as double;

    return _buildSection(
      icon: Icons.edit_note_rounded,
      title: '¿Cómo estuvo tu día?',
      badge: wordCount > 0 ? '$wordCount palabras' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MinimalColors.shadow(context),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _reflectionController,
              maxLines: 6,
              onChanged: (value) => setState(() {}), // Trigger rebuild for analysis
              decoration: InputDecoration(
                hintText: 'Cuéntame sobre tu día... ¿Qué pasó? ¿Cómo te sentiste?',
                hintStyle: TextStyle(
                  color: MinimalColors.textTertiary(context),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          if (wordCount > 0) ...[
            const SizedBox(height: 12),
            _buildSentimentIndicator(sentiment),
          ],
        ],
      ),
    );
  }

  Widget _buildSentimentIndicator(double sentiment) {
    String emoji;
    String label;
    Color color;

    if (sentiment > 0.3) {
      emoji = '😊';
      label = 'Sentimiento positivo';
      color = const Color(0xFF4ECDC4);
    } else if (sentiment < -0.3) {
      emoji = '😔';
      label = 'Sentimiento negativo';
      color = const Color(0xFFFF6B6B);
    } else {
      emoji = '😐';
      label = 'Sentimiento neutral';
      color = const Color(0xFFFFA726);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerReflection() {
    return Container(
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B7EFF).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _innerReflectionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Reflexiona más profundamente... ¿Qué descubriste sobre ti?',
          hintStyle: TextStyle(
            color: MinimalColors.textTertiary(context),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: TextStyle(
          color: MinimalColors.textPrimary(context),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildGratitude() {
    return Container(
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _gratitudeController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Algo por lo que me siento agradecido es...',
          hintStyle: TextStyle(
            color: MinimalColors.textTertiary(context),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: TextStyle(
          color: MinimalColors.textPrimary(context),
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _positiveTagsController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Tags Positivos',
              labelStyle: TextStyle(
                color: const Color(0xFF4ECDC4),
                fontWeight: FontWeight.w600,
              ),
              hintText: 'feliz, motivado, productivo...',
              hintStyle: TextStyle(
                color: MinimalColors.textTertiary(context),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: _negativeTagsController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Tags Negativos',
              labelStyle: TextStyle(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
              hintText: 'cansado, estresado, frustrado...',
              hintStyle: TextStyle(
                color: MinimalColors.textTertiary(context),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoreMetricsSection() {
    return _buildSection(
      icon: Icons.analytics_rounded,
      title: 'Métricas del Día',
      child: Column(
        children: [
          _buildMetricSlider(
            label: 'Estado de ánimo',
            emoji: _getMoodEmoji(_moodScore),
            value: _moodScore.toDouble(),
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _moodScore = v.round());
            },
            color: const Color(0xFF8B7EFF),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            label: 'Nivel de energía',
            emoji: _getEnergyEmoji(_energyLevel),
            value: _energyLevel.toDouble(),
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _energyLevel = v.round());
            },
            color: const Color(0xFFFFA726),
          ),
          const SizedBox(height: 20),
          _buildMetricSlider(
            label: 'Nivel de estrés',
            emoji: _getStressEmoji(_stressLevel),
            value: _stressLevel.toDouble(),
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _stressLevel = v.round());
            },
            color: const Color(0xFFFF6B6B),
            isInverted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingSummaryCard() {
    // Calculate overall wellbeing score
    final double physicalScore = (
      _sleepQuality + _physicalActivity + (_waterIntake / 1.5)
    ) / 3;
    final double emotionalScore = (
      _moodScore + _motivationLevel + (10 - _anxietyLevel) + _emotionalStability
    ) / 4;
    final double productivityScore = (
      _workProductivity + _focusLevel + _energyLevel
    ) / 3;
    final double overallScore = (physicalScore + emotionalScore + productivityScore) / 3;

    String getScoreLabel(double score) {
      if (score >= 8) return 'Excelente';
      if (score >= 6.5) return 'Bien';
      if (score >= 5) return 'Regular';
      if (score >= 3.5) return 'Bajo';
      return 'Crítico';
    }

    Color getScoreColor(double score) {
      if (score >= 8) return const Color(0xFF4ECDC4);
      if (score >= 6.5) return const Color(0xFF95E1D3);
      if (score >= 5) return const Color(0xFFFFA726);
      if (score >= 3.5) return const Color(0xFFFF9A76);
      return const Color(0xFFFF6B6B);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getScoreColor(overallScore).withValues(alpha: 0.15),
            getScoreColor(overallScore).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getScoreColor(overallScore).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getScoreColor(overallScore).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.spa_rounded,
                  color: getScoreColor(overallScore),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienestar General',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      getScoreLabel(overallScore),
                      style: TextStyle(
                        color: getScoreColor(overallScore),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${overallScore.toStringAsFixed(1)}/10',
                style: TextStyle(
                  color: getScoreColor(overallScore),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniMetricCard(
                  'Físico',
                  physicalScore,
                  Icons.fitness_center_rounded,
                  const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniMetricCard(
                  'Emocional',
                  emotionalScore,
                  Icons.favorite_rounded,
                  const Color(0xFF8B7EFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniMetricCard(
                  'Productividad',
                  productivityScore,
                  Icons.trending_up_rounded,
                  const Color(0xFFFFA726),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricCard(String label, double score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalWellbeingSection() {
    return Column(
      children: [
        _buildMetricSlider(
          label: 'Calidad del sueño',
          emoji: '😴',
          value: _sleepQuality.toDouble(),
          onChanged: (v) => setState(() => _sleepQuality = v.round()),
          color: const Color(0xFF4ECDC4),
        ),
        const SizedBox(height: 16),
        _buildNumericMetric(
          label: 'Horas de sueño',
          emoji: '🌙',
          value: _sleepHours,
          unit: 'hrs',
          onChanged: (v) => setState(() => _sleepHours = v),
          min: 0,
          max: 12,
          color: const Color(0xFF8B7EFF),
        ),
        const SizedBox(height: 16),
        _buildNumericMetric(
          label: 'Vasos de agua',
          emoji: '💧',
          value: _waterIntake.toDouble(),
          unit: 'vasos',
          onChanged: (v) => setState(() => _waterIntake = v.round()),
          min: 0,
          max: 15,
          color: const Color(0xFF66D9EF),
        ),
        const SizedBox(height: 16),
        _buildNumericMetric(
          label: 'Ejercicio',
          emoji: '🏃',
          value: _exerciseMinutes.toDouble(),
          unit: 'min',
          onChanged: (v) => setState(() => _exerciseMinutes = v.round()),
          min: 0,
          max: 180,
          color: const Color(0xFFFF6B6B),
        ),
        const SizedBox(height: 16),
        _buildNumericMetric(
          label: 'Meditación',
          emoji: '🧘',
          value: _meditationMinutes.toDouble(),
          unit: 'min',
          onChanged: (v) => setState(() => _meditationMinutes = v.round()),
          min: 0,
          max: 120,
          color: const Color(0xFF95E1D3),
        ),
        const SizedBox(height: 16),
        _buildNumericMetric(
          label: 'Tiempo de pantalla',
          emoji: '📱',
          value: _screenTimeHours,
          unit: 'hrs',
          onChanged: (v) => setState(() => _screenTimeHours = v),
          min: 0,
          max: 18,
          color: const Color(0xFFFFA726),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Actividad física',
          emoji: '💪',
          value: _physicalActivity.toDouble(),
          onChanged: (v) => setState(() => _physicalActivity = v.round()),
          color: const Color(0xFFFF6B9D),
        ),
      ],
    );
  }

  Widget _buildEmotionalWellbeingSection() {
    return Column(
      children: [
        _buildMetricSlider(
          label: 'Nivel de ansiedad',
          emoji: '😰',
          value: _anxietyLevel.toDouble(),
          onChanged: (v) => setState(() => _anxietyLevel = v.round()),
          color: const Color(0xFFFF6B6B),
          isInverted: true,
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Nivel de motivación',
          emoji: '🔥',
          value: _motivationLevel.toDouble(),
          onChanged: (v) => setState(() => _motivationLevel = v.round()),
          color: const Color(0xFFFFA726),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Interacción social',
          emoji: '👥',
          value: _socialInteraction.toDouble(),
          onChanged: (v) => setState(() => _socialInteraction = v.round()),
          color: const Color(0xFF4ECDC4),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Batería social',
          emoji: '🔋',
          value: _socialBattery.toDouble(),
          onChanged: (v) => setState(() => _socialBattery = v.round()),
          color: const Color(0xFF66D9EF),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Estabilidad emocional',
          emoji: '🧘‍♀️',
          value: _emotionalStability.toDouble(),
          onChanged: (v) => setState(() => _emotionalStability = v.round()),
          color: const Color(0xFF8B7EFF),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Energía creativa',
          emoji: '🎨',
          value: _creativeEnergy.toDouble(),
          onChanged: (v) => setState(() => _creativeEnergy = v.round()),
          color: const Color(0xFFFF6B9D),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Impacto del clima',
          emoji: '🌤️',
          value: _weatherMoodImpact.toDouble(),
          onChanged: (v) => setState(() => _weatherMoodImpact = v.round()),
          color: const Color(0xFF95E1D3),
          min: -5,
          max: 5,
        ),
      ],
    );
  }

  Widget _buildProductivitySection() {
    return Column(
      children: [
        _buildMetricSlider(
          label: 'Productividad laboral',
          emoji: '💼',
          value: _workProductivity.toDouble(),
          onChanged: (v) => setState(() => _workProductivity = v.round()),
          color: const Color(0xFF4ECDC4),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Nivel de enfoque',
          emoji: '🎯',
          value: _focusLevel.toDouble(),
          onChanged: (v) => setState(() => _focusLevel = v.round()),
          color: const Color(0xFF8B7EFF),
        ),
        const SizedBox(height: 16),
        _buildMetricSlider(
          label: 'Satisfacción de vida',
          emoji: '✨',
          value: _lifeSatisfaction.toDouble(),
          onChanged: (v) => setState(() => _lifeSatisfaction = v.round()),
          color: const Color(0xFFFFA726),
        ),
      ],
    );
  }

  Widget _buildActivitiesGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Activities section
        Text(
          'Actividades Completadas',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
            );
            if (result != null && result is List<String>) {
              setState(() => _completedActivitiesToday = result);
            }
          },
          icon: const Icon(Icons.check_circle_outline),
          label: Text(_completedActivitiesToday.isEmpty
              ? 'Seleccionar Actividades'
              : '${_completedActivitiesToday.length} actividades'),
          style: ElevatedButton.styleFrom(
            backgroundColor: MinimalColors.backgroundCard(context),
            foregroundColor: const Color(0xFF4ECDC4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_completedActivitiesToday.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _completedActivitiesToday.map((activity) => Chip(
              label: Text(activity),
              backgroundColor: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
              labelStyle: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )).toList(),
          ),
        ],

        // Goals section
        const SizedBox(height: 24),
        Text(
          'Progreso de Metas',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildGoalsList(),
      ],
    );
  }

  Widget _buildGoalsList() {
    final authProvider = context.watch<OptimizedAuthProvider>();
    final goalsProvider = context.watch<GoalsProvider>();

    if (authProvider.currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MinimalColors.shadow(context),
            width: 1,
          ),
        ),
        child: Text(
          'Inicia sesión para ver tus metas',
          style: TextStyle(
            color: MinimalColors.textTertiary(context),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final activeGoals = goalsProvider.activeGoals;

    if (activeGoals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MinimalColors.shadow(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flag_rounded,
              color: MinimalColors.textTertiary(context),
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No tienes metas activas. Crea una meta para empezar a trackear tu progreso.',
                style: TextStyle(
                  color: MinimalColors.textTertiary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: activeGoals.take(3).map((goal) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: EnhancedGoalCard(
          goal: goal,
          showFullDetails: false,
          onProgressUpdate: () => _showProgressUpdateDialog(goal),
          onAddNote: () => _showAddNoteDialog(goal),
          onTap: () => _showGoalDetails(goal),
        ),
      )).toList(),
    );
  }

  void _showProgressUpdateDialog(GoalModel goal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressEntryDialog(
        goal: goal,
        onEntryCreated: (entry) async {
          final goalsProvider = context.read<GoalsProvider>();

          // Actualizar progreso con todas las métricas y notas
          await goalsProvider.addProgressEntry(entry);
          await goalsProvider.updateGoalProgress(
            goal.id!,
            entry.primaryValue,
            notes: entry.notes,
            metrics: entry.metrics,
          );

          HapticFeedback.mediumImpact();
          _showSnackBar('Progreso actualizado');
        },
      ),
    );
  }

  void _showAddNoteDialog(GoalModel goal) {
    // Por ahora, usar el diálogo de progreso que incluye notas
    _showProgressUpdateDialog(goal);
  }

  void _showGoalDetails(GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                goal.description ?? 'Sin descripción',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: MinimalColors.shadow(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}% completado',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showProgressUpdateDialog(goal);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                    ),
                    child: const Text('Actualizar Progreso'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceRecordingSection() {
    return VoiceRecordingWidget(
      existingRecordingPath: _voiceRecordingPath,
      onRecordingComplete: (path) => setState(() => _voiceRecordingPath = path),
    );
  }

  Widget _buildDailyPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add photo button
        ElevatedButton.icon(
          onPressed: _addPhoto,
          icon: const Icon(Icons.add_photo_alternate_rounded),
          label: const Text('Agregar Foto'),
          style: ElevatedButton.styleFrom(
            backgroundColor: MinimalColors.backgroundCard(context),
            foregroundColor: const Color(0xFF8B7EFF),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: const Color(0xFF8B7EFF).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_dailyPhotos.isNotEmpty) ...[
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _dailyPhotos.length,
            itemBuilder: (context, index) => _buildPhotoThumbnail(_dailyPhotos[index], index),
          ),
        ],
        if (_dailyPhotos.isEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.shadow(context),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.photo_camera_rounded,
                  color: MinimalColors.textTertiary(context),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'No hay fotos todavía. Agrega fotos para capturar momentos especiales de tu día.',
                    style: TextStyle(
                      color: MinimalColors.textTertiary(context),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoThumbnail(String photoPath, int index) {
    return GestureDetector(
      onTap: () => _viewPhoto(photoPath),
      onLongPress: () => _deletePhoto(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B7EFF).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B7EFF).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(photoPath),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _dailyPhotos.add(photo.path);
        });
        HapticFeedback.mediumImpact();
        _showSnackBar('Foto agregada');
      }
    } catch (e) {
      _showSnackBar('Error al agregar foto: $e', isError: true);
    }
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

  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MinimalColors.backgroundCard(context),
        title: Text(
          '¿Eliminar foto?',
          style: TextStyle(color: MinimalColors.textPrimary(context)),
        ),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: MinimalColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _dailyPhotos.removeAt(index);
              });
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              _showSnackBar('Foto eliminada');
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSuggestionsCard() {
    final suggestions = _getSmartSuggestions();

    return GestureDetector(
      onTap: () => setState(() => _showSmartSuggestions = !_showSmartSuggestions),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B7EFF).withValues(alpha: 0.1),
              const Color(0xFFB197FC).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF8B7EFF).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded,
                  color: Color(0xFF8B7EFF), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sugerencias Inteligentes',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _showSmartSuggestions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF8B7EFF),
                ),
              ],
            ),
            if (_showSmartSuggestions && suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...suggestions.take(3).map((suggestion) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF8B7EFF))),
                    Expanded(
                      child: Text(
                        suggestion,
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
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyticsScreenV5()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4ECDC4).withValues(alpha: 0.15),
              const Color(0xFF66D9EF).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF66D9EF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
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
                    'Ver análisis y tendencias',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explora tus patrones y progreso',
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: const Color(0xFF4ECDC4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorthItSection() {
    return _buildSection(
      icon: Icons.star_rounded,
      title: '¿Valió la pena?',
      child: Row(
        children: [
          Expanded(
            child: _buildWorthItButton(
              label: 'Sí',
              icon: Icons.check_circle_rounded,
              isSelected: _worthIt == true,
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _worthIt = true);
              },
              color: const Color(0xFF4ECDC4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildWorthItButton(
              label: 'No estoy seguro',
              icon: Icons.help_rounded,
              isSelected: _worthIt == null,
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _worthIt = null);
              },
              color: const Color(0xFFFFA726),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildWorthItButton(
              label: 'No',
              icon: Icons.cancel_rounded,
              isSelected: _worthIt == false,
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _worthIt = false);
              },
              color: const Color(0xFFFF6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorthItButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
              : null,
          color: isSelected ? null : MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
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
                color: isSelected
                    ? Colors.white
                    : MinimalColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required bool isExpanded,
    required VoidCallback onToggle,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: MinimalColors.textTertiary(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: MinimalColors.textSecondary(context),
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: child,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Continue with remaining widget builders...
  // Due to length, splitting into multiple parts

  Widget _buildMetricSlider({
    required String label,
    required String emoji,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
    bool isInverted = false,
    double min = 0,
    double max = 10,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
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
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}/${max.round()}',
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
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericMetric({
    required String label,
    required String emoji,
    required double value,
    required String unit,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
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
                  color: color.withValues(alpha: 0.15),
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
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 2).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSaving ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context),
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.gradientShadow(context, alpha: 0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.5,
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
                            letterSpacing: 0.5,
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? badge,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MinimalColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: MinimalColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // Smart analysis & suggestions
  Map<String, dynamic> _analyzeReflectionText(String text) {
    if (text.isEmpty) return {'emotions': [], 'sentiment': 0.0, 'complexity': 0, 'wordCount': 0};

    final words = text.toLowerCase().split(RegExp(r'\W+'));
    int positiveWords = 0;
    int negativeWords = 0;

    // Simple sentiment analysis
    const positiveKeywords = ['feliz', 'alegre', 'contento', 'bien', 'genial', 'excelente', 'amor'];
    const negativeKeywords = ['triste', 'mal', 'horrible', 'terrible', 'enojado', 'frustrado'];

    for (final word in words) {
      if (positiveKeywords.contains(word)) positiveWords++;
      if (negativeKeywords.contains(word)) negativeWords++;
    }

    double sentimentScore = 0.0;
    if (positiveWords + negativeWords > 0) {
      sentimentScore = (positiveWords - negativeWords) / (positiveWords + negativeWords);
    }

    return {
      'sentiment': sentimentScore,
      'wordCount': words.length,
    };
  }

  List<String> _getSmartSuggestions() {
    final suggestions = <String>[];
    final insights = <String>[];

    // Análisis de mood vs energy
    if (_moodScore <= 4 && _energyLevel >= 7) {
      insights.add('Tienes energía pero tu ánimo está bajo. Considera hacer algo que disfrutes.');
    } else if (_moodScore >= 8 && _energyLevel <= 3) {
      insights.add('Estás de buen ánimo pero con poca energía. Tal vez necesites descansar.');
    }

    // Análisis de estrés y sueño
    if (_stressLevel >= 7 && _sleepQuality <= 4) {
      insights.add('El estrés alto y sueño pobre están relacionados. Prioriza tu descanso.');
    }

    // Análisis de productividad y enfoque
    if (_workProductivity <= 4 && _focusLevel <= 4) {
      insights.add('Baja productividad y enfoque. ¿Qué distracciones puedes eliminar mañana?');
    } else if (_workProductivity >= 8 && _focusLevel >= 8) {
      insights.add('¡Excelente día productivo! ¿Qué hiciste diferente hoy?');
    }

    // Análisis de balance social
    if (_socialInteraction >= 8 && _socialBattery <= 3) {
      insights.add('Mucha interacción social ha drenado tu batería. Tómate tiempo para ti.');
    }

    // Análisis de bienestar físico
    if (_waterIntake <= 4 && _energyLevel <= 4) {
      insights.add('Poca hidratación puede afectar tu energía. Intenta beber más agua.');
    }

    // Análisis de mindfulness
    if (_anxietyLevel >= 7 && _meditationMinutes == 0) {
      insights.add('Ansiedad alta sin meditación. Incluso 5 minutos pueden ayudar.');
    }

    // Análisis de balance vida-trabajo
    if (_screenTimeHours >= 10 && _lifeSatisfaction <= 5) {
      insights.add('Mucho tiempo de pantalla puede afectar tu satisfacción. Considera desconectar.');
    }

    // Sugerencias específicas basadas en métricas
    if (_moodScore <= 4) {
      suggestions.addAll([
        '¿Qué pequeña cosa podrías hacer ahora para sentirte un poco mejor?',
        'Describe un momento feliz de hoy, por pequeño que sea.',
      ]);
    }

    if (_stressLevel >= 7) {
      suggestions.addAll([
        '¿Qué está causando más estrés en este momento?',
        '¿Qué harías si tuvieras una hora libre ahora mismo?',
        'Intenta respirar profundamente 5 veces. ¿Cómo te sientes ahora?',
      ]);
    }

    if (_energyLevel <= 3) {
      suggestions.addAll([
        '¿Qué actividad te da más energía normalmente?',
        '¿Qué necesitas para recargar tu energía?',
        '¿Has tomado suficiente agua y comido bien hoy?',
      ]);
    }

    if (_anxietyLevel >= 7) {
      suggestions.addAll([
        '¿Qué te está preocupando más en este momento?',
        'Nombra 3 cosas que puedes controlar ahora mismo.',
      ]);
    }

    if (_motivationLevel <= 4) {
      suggestions.addAll([
        '¿Qué te motivaba antes? ¿Puedes reconectar con eso?',
        '¿Qué pequeño logro puedes celebrar de hoy?',
      ]);
    }

    // Sugerencias de celebración
    if (_moodScore >= 8 && _energyLevel >= 8 && _stressLevel <= 3) {
      suggestions.addAll([
        '¡Qué día excelente! ¿Qué hiciste diferente?',
        'Celebra este buen momento. ¿Cómo vas a recompensarte?',
      ]);
    }

    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Describe el mejor momento de tu día.',
        '¿Qué aprendiste sobre ti mismo hoy?',
        '¿Qué te gustaría recordar de este día en el futuro?',
        '¿Qué podrías hacer mañana para mejorar tu día?',
      ]);
    }

    // Combinar insights y sugerencias
    final combined = [...insights, ...suggestions];
    return combined..shuffle();
  }

  // Emoji helpers
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
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}
