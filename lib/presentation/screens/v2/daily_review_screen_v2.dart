// ============================================================================
// daily_review_screen_v2.dart - NUEVA VERSIÓN GUIADA E INTERACTIVA
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers optimizados
import '../../../core/themes/app_theme.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/daily_activities_provider.dart';
import '../../../data/models/goal_model.dart';

// Pantallas relacionadas
import 'calendar_screen_v2.dart';

// Componentes
import 'components/minimal_colors.dart';
import 'analytics_v3_screen.dart';
import '../../widgets/voice_recording_widget.dart';
import '../../widgets/progress_entry_dialog.dart';
import '../../widgets/enhanced_goal_card.dart';

class DailyReviewScreenV2 extends StatefulWidget {
  const DailyReviewScreenV2({super.key});

  @override
  State<DailyReviewScreenV2> createState() => _DailyReviewScreenV2State();
}

class _DailyReviewScreenV2State extends State<DailyReviewScreenV2>
    with TickerProviderStateMixin {

  // ============================================================================
  // CONTROLADORES Y ESTADO
  // ============================================================================

  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _cardController;
  late AnimationController _pulseController;
  late AnimationController _pageTransitionController;
  late AnimationController _staggerController;
  
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final int _totalSteps = 5;

  // Estados del formulario
  final _reflectionController = TextEditingController();
  final _innerReflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _positiveTagsController = TextEditingController();
  final _negativeTagsController = TextEditingController();

  // Métricas principales
  int _moodScore = 5;
  int _energyLevel = 5;
  int _stressLevel = 5;
  bool? _worthIt;

  // Métricas de bienestar
  int _sleepQuality = 5;
  int _anxietyLevel = 5;
  int _motivationLevel = 5;
  int _socialInteraction = 5;
  int _physicalActivity = 5;
  int _workProductivity = 5;

  // Métricas numéricas
  double _sleepHours = 8.0;
  int _waterIntake = 8;
  int _meditationMinutes = 0;
  int _exerciseMinutes = 0;
  double _screenTimeHours = 4.0;

  // Métricas avanzadas
  int _socialBattery = 5;
  int _creativeEnergy = 5;
  int _emotionalStability = 5;
  int _focusLevel = 5;
  int _lifeSatisfaction = 5;
  int _weatherMoodImpact = 0;
  List<String> _completedActivitiesToday = [];
  List<String> _goalsSummary = [];

  // Controladores adicionales (nivel de clase para evitar memory leaks)
  late TextEditingController _goalsSummaryController;
  late TextEditingController _completedActivitiesController;

  // Voice recording state
  bool _isVoiceRecordingExpanded = false;
  String? _voiceRecordingPath;

  // Caché de análisis y sugerencias (evita recalcular en cada rebuild)
  Map<String, dynamic> _cachedAnalysis = {'emotions': [], 'sentiment': 0.0, 'wordCount': 0};
  List<String> _cachedSuggestions = [];

  @override
  void initState() {
    super.initState();
    // Hide system navigation buttons for more screen space (restored in dispose)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
    _goalsSummaryController = TextEditingController();
    _completedActivitiesController = TextEditingController();
    _cachedSuggestions = _getSmartSuggestions();
    _setupAnimations();
    _loadExistingEntry();
  }

  @override
  void dispose() {
    // Restore system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    
    _pageController.dispose();
    _progressController.dispose();
    _cardController.dispose();
    _pulseController.dispose();
    _pageTransitionController.dispose();
    _staggerController.dispose();
    _reflectionController.dispose();
    _innerReflectionController.dispose();
    _gratitudeController.dispose();
    _positiveTagsController.dispose();
    _negativeTagsController.dispose();
    _goalsSummaryController.dispose();
    _completedActivitiesController.dispose();
    super.dispose();
  }

  // ============================================================================
  // CONFIGURACIÓN
  // ============================================================================

  void _setupAnimations() {
    _pageController = PageController();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController, 
      curve: Curves.easeOutQuart
    ));


    // Start initial animations with enhanced staggering
    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pageTransitionController.forward();
        _updateProgress();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _staggerController.forward();
      }
    });
  }

  void _loadExistingEntry() {
    final entriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);
    final todayEntry = entriesProvider.todayEntry;

    if (todayEntry != null) {
      setState(() {
        _reflectionController.text = todayEntry.freeReflection;
        _innerReflectionController.text = todayEntry.innerReflection ?? '';
        _gratitudeController.text = todayEntry.gratitudeItems ?? '';
        _positiveTagsController.text = todayEntry.positiveTags.join(', ');
        _negativeTagsController.text = todayEntry.negativeTags.join(', ');
        _moodScore = todayEntry.moodScore ?? 5;
        _energyLevel = todayEntry.energyLevel ?? 5;
        _stressLevel = todayEntry.stressLevel ?? 5;
        _worthIt = todayEntry.worthIt;
        _sleepQuality = todayEntry.sleepQuality ?? 5;
        _anxietyLevel = todayEntry.anxietyLevel ?? 5;
        _motivationLevel = todayEntry.motivationLevel ?? 5;
        _socialInteraction = todayEntry.socialInteraction ?? 5;
        _physicalActivity = todayEntry.physicalActivity ?? 5;
        _workProductivity = todayEntry.workProductivity ?? 5;
        _sleepHours = todayEntry.sleepHours ?? 8.0;
        _waterIntake = todayEntry.waterIntake ?? 8;
        _meditationMinutes = todayEntry.meditationMinutes ?? 0;
        _exerciseMinutes = todayEntry.exerciseMinutes ?? 0;
        _screenTimeHours = todayEntry.screenTimeHours ?? 4.0;
        _socialBattery = todayEntry.socialBattery ?? 5;
        _creativeEnergy = todayEntry.creativeEnergy ?? 5;
        _emotionalStability = todayEntry.emotionalStability ?? 5;
        _focusLevel = todayEntry.focusLevel ?? 5;
        _lifeSatisfaction = todayEntry.lifeSatisfaction ?? 5;
        _weatherMoodImpact = todayEntry.weatherMoodImpact ?? 0;
        _completedActivitiesToday = List<String>.from(todayEntry.completedActivitiesToday);
        _goalsSummary = List<String>.from(todayEntry.goalsSummary);
        _goalsSummaryController.text = todayEntry.goalsSummary.join('\n');
        _completedActivitiesController.text = todayEntry.completedActivitiesToday.join('\n');
      });
    }
  }

  // ============================================================================
  // MÉTODOS SOFISTICADOS PARA EXPRESIÓN DEL USUARIO
  // ============================================================================

  // Palabras clave para análisis semántico
  static const Map<String, List<String>> _emotionKeywords = {
    'joy': ['feliz', 'alegre', 'contento', 'radiante', 'eufórico', 'dichoso'],
    'sadness': ['triste', 'melancólico', 'decaído', 'desanimado', 'sombrío'],
    'anger': ['enojado', 'furioso', 'irritado', 'molesto', 'rabioso'],
    'fear': ['miedo', 'nervioso', 'ansioso', 'preocupado', 'temeroso'],
    'surprise': ['sorprendido', 'asombrado', 'impactado', 'inesperado'],
    'disgust': ['asco', 'repulsión', 'disgusto', 'desagrado'],
    'calm': ['calmado', 'relajado', 'sereno', 'tranquilo', 'pacífico'],
    'excited': ['emocionado', 'entusiasmado', 'vibrante', 'energético'],
  };

  // Análisis inteligente del texto libre
  Map<String, dynamic> _analyzeReflectionText(String text) {
    if (text.isEmpty) return {'emotions': [], 'sentiment': 0.0, 'complexity': 0};

    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final detectedEmotions = <String>[];
    double sentimentScore = 0.0;
    int positiveWords = 0;
    int negativeWords = 0;

    for (final word in words) {
      for (final emotion in _emotionKeywords.keys) {
        if (_emotionKeywords[emotion]!.contains(word)) {
          detectedEmotions.add(emotion);
          
          // Calcular sentimiento
          if (['joy', 'calm', 'excited'].contains(emotion)) {
            positiveWords++;
          } else if (['sadness', 'anger', 'fear', 'disgust'].contains(emotion)) {
            negativeWords++;
          }
        }
      }
    }

    if (positiveWords + negativeWords > 0) {
      sentimentScore = (positiveWords - negativeWords) / (positiveWords + negativeWords);
    }

    return {
      'emotions': detectedEmotions.toSet().toList(),
      'sentiment': sentimentScore,
      'complexity': words.length,
      'wordCount': words.length,
    };
  }

  // Sugerencias inteligentes basadas en el estado actual
  List<String> _getSmartSuggestions() {
    final suggestions = <String>[];
    
    if (_moodScore <= 4) {
      suggestions.addAll([
        '¿Qué pequeña cosa podrías hacer ahora para sentirte un poco mejor?',
        '¿Hay alguien con quien te gustaría hablar?',
        'Describe un momento feliz de hoy, por pequeño que sea.',
      ]);
    }
    
    if (_stressLevel >= 7) {
      suggestions.addAll([
        '¿Qué está causando más estrés en este momento?',
        'Describe tu técnica favorita para relajarte.',
        '¿Qué harías si tuvieras una hora libre ahora mismo?',
      ]);
    }
    
    if (_energyLevel <= 3) {
      suggestions.addAll([
        '¿Qué actividad te da más energía normalmente?',
        'Describe cómo te sientes físicamente en este momento.',
        '¿Qué necesitas para recargar tu energía?',
      ]);
    }

    // Sugerencias generales si no hay específicas
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'Describe el mejor momento de tu día.',
        '¿Qué aprendiste sobre ti mismo hoy?',
        'Si tuvieras que darle un consejo a alguien que tuvo un día como el tuyo, ¿qué le dirías?',
        '¿Qué te gustaría recordar de este día en el futuro?',
      ]);
    }

    suggestions.shuffle();
    return suggestions;
  }

  // Obtener el emoji basado en múltiples métricas
  String _getSmartEmoji() {
    final avgMood = (_moodScore + (10 - _stressLevel) + _energyLevel) / 3;
    
    if (avgMood >= 8) return '😊';
    if (avgMood >= 7) return '🙂';
    if (avgMood >= 6) return '😐';
    if (avgMood >= 5) return '😕';
    if (avgMood >= 4) return '😔';
    return '😢';
  }

  // ============================================================================
  // NAVEGACIÓN
  // ============================================================================

  // Single source of truth for the current step: the PageController drives
  // _currentStep via _onPageChanged. Navigation helpers only request the page.
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentStep = index;
    });
    _updateProgress();
    HapticFeedback.mediumImpact();

    // Staggered entrance animations for the new step
    _pageTransitionController.reset();
    _staggerController.reset();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _pageTransitionController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _staggerController.forward();
    });
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _totalSteps);
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return true; // Reflexión opcional
      case 1:
        return _moodScore > 0;
      case 2:
        return true; // Métricas opcionales
      case 3:
        return true; // Metas + actividades opcionales
      case 4:
        return _worthIt != null;
      default:
        return false;
    }
  }

  // ============================================================================
  // UI PRINCIPAL
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedTheme(
          duration: const Duration(milliseconds: 300),
          data: themeProvider.currentThemeData,
          child: Scaffold(
            backgroundColor: MinimalColors.backgroundPrimary(context),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProgressSection(),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              MinimalColors.backgroundPrimary(context),
                              MinimalColors.backgroundSecondary(context).withValues(alpha: 0.8),
                              // En claro evitamos el "wash" morado del fondo.
                              Theme.of(context).extension<AppColors>()?.isDark == false
                                  ? MinimalColors.backgroundPrimary(context)
                                  : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _totalSteps,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            switch (index) {
                              case 0:
                                return _buildReflectionStep();
                              case 1:
                                return _buildMoodWellbeingStep();
                              case 2:
                                return _buildMetricsStep();
                              case 3:
                                return _buildGoalsActivitiesStep();
                              case 4:
                                return _buildReflectionFinalStep();
                              default:
                                return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                    _buildBottomNav(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Persistent step navigation so the wizard isn't swipe-only.
  Widget _buildBottomNav() {
    final isLast = _currentStep == _totalSteps - 1;
    final canContinue = _canContinue();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                label: const Text('Atrás'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: MinimalColors.textPrimary(context),
                  side: BorderSide(
                    color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0 && !isLast) const SizedBox(width: 12),
          // "Continuar" only while there are steps ahead; the final step has
          // its own save button inside the content.
          if (!isLast)
            Expanded(
              flex: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: canContinue
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: canContinue
                      ? null
                      : MinimalColors.textMuted(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: canContinue ? _nextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledForegroundColor:
                        MinimalColors.textMuted(context),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // HEADER Y PROGRESO
  // ============================================================================

  Widget _buildHeader() {
    return Container(
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
                      color: MinimalColors.gradientShadow(context, alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_note_outlined,
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
                        'Reflexión Diaria',
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
                      'Paso ${_currentStep + 1} de $_totalSteps · ${_stepMeta[_currentStep]['label']}',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button so the user can always exit the wizard
              Container(
                decoration: BoxDecoration(
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.close,
                    color: MinimalColors.textPrimary(context),
                    size: 22,
                  ),
                  tooltip: 'Cerrar',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: _buildStepProgress(),
    );
  }

  // ============================================================================
  // PASO 1: REFLEXIÓN LIBRE
  // ============================================================================

  Widget _buildReflectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            icon: '✍️',
            title: 'Reflexión Personal',
            subtitle: 'Comparte cómo ha sido tu día',
            child: Column(
              children: [
                _buildReflectionField(),
                const SizedBox(height: 16),
                _buildVoiceRecordingWidget(),
                const SizedBox(height: 16),
                _buildGratitudeField(),
                const SizedBox(height: 16),
                _buildTagsFields(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionField() {
    final analysis = _cachedAnalysis;
    final suggestions = _cachedSuggestions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto principal mejorado
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundSecondary(context),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.gradientShadow(context, alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.primaryGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: MinimalColors.textPrimary(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reflexión Libre',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_reflectionController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getSentimentGradient(analysis['sentiment']),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getSmartEmoji()} ${analysis['wordCount']} palabras',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              TextField(
                controller: _reflectionController,
                maxLines: 6,
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 16,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: _getPersonalizedHint(),
                  hintStyle: TextStyle(
                    color: MinimalColors.textMuted(context),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (text) => setState(() {
                  _cachedAnalysis = _analyzeReflectionText(text);
                }),
              ),
            ],
          ),
        ),
        
        // Análisis emocional en tiempo real
        if (_reflectionController.text.isNotEmpty && analysis['emotions'].isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.gradientShadow(context, alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emociones detectadas:',
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: (analysis['emotions'] as List<String>).map((emotion) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEmotionColor(emotion),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_getEmotionEmoji(emotion)} ${_translateEmotion(emotion)}',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

        // Sugerencias inteligentes
        if (_reflectionController.text.isEmpty || _reflectionController.text.length < 20)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MinimalColors.lightGradient(context)[0].withValues(alpha: 0.1),
                    MinimalColors.lightGradient(context)[1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: MinimalColors.lightGradient(context)[0],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sugerencias para reflexionar:',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...suggestions.take(2).map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        _reflectionController.text = '$suggestion\n\n';
                        _reflectionController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _reflectionController.text.length),
                        );
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MinimalColors.backgroundCard(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: MinimalColors.lightGradient(context)[0],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  color: MinimalColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Métodos auxiliares para el campo de reflexión mejorado
  String _getPersonalizedHint() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return '¿Cómo empezaste tu día? ¿Qué esperas que suceda hoy?';
    } else if (hour < 17) {
      return '¿Cómo va tu día hasta ahora? ¿Qué ha sido lo más destacado?';
    } else {
      return '¿Cómo ha sido tu día? ¿Qué has aprendido sobre ti mismo?';
    }
  }

  List<Color> _getSentimentGradient(double sentiment) {
    if (sentiment > 0.3) {
      return MinimalColors.positiveGradient(context);
    } else if (sentiment < -0.3) {
      return MinimalColors.negativeGradient(context);
    } else {
      return MinimalColors.neutralGradient(context);
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'joy': return Colors.amber;
      case 'calm': return Colors.purple;
      case 'excited': return Colors.orange;
      case 'sadness': return Colors.indigo;
      case 'anger': return Colors.red;
      case 'fear': return Colors.purple;
      case 'surprise': return Colors.teal;
      case 'disgust': return Colors.brown;
      default: return Colors.grey;
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case 'joy': return '😊';
      case 'calm': return '😌';
      case 'excited': return '🤩';
      case 'sadness': return '😢';
      case 'anger': return '😠';
      case 'fear': return '😨';
      case 'surprise': return '😲';
      case 'disgust': return '🤢';
      default: return '🙂';
    }
  }

  String _translateEmotion(String emotion) {
    switch (emotion) {
      case 'joy': return 'Alegría';
      case 'calm': return 'Calma';
      case 'excited': return 'Emoción';
      case 'sadness': return 'Tristeza';
      case 'anger': return 'Enojo';
      case 'fear': return 'Miedo';
      case 'surprise': return 'Sorpresa';
      case 'disgust': return 'Disgusto';
      default: return emotion;
    }
  }

  Widget _buildVoiceRecordingWidget() {
    return VoiceRecordingWidget(
      isExpanded: _isVoiceRecordingExpanded,
      existingRecordingPath: _voiceRecordingPath,
      onExpand: () {
        setState(() {
          _isVoiceRecordingExpanded = !_isVoiceRecordingExpanded;
        });
      },
      onRecordingComplete: (path) {
        setState(() {
          _voiceRecordingPath = path;
        });
        
        // Opcionalmente, mostrar un mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Grabación de voz guardada exitosamente'),
            backgroundColor: MinimalColors.positiveMain(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildGratitudeField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.positiveGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.coloredShadow(context, MinimalColors.positiveGradient(context)[1], alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.positiveGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: MinimalColors.textPrimary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gratitud y Apreciación',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_gratitudeController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: MinimalColors.positiveGradient(context),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '💚 Gratitud',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _gratitudeController,
            maxLines: 3,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '¿Por qué estás agradecido hoy? Menciona personas, momentos o experiencias...',
              hintStyle: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsFields() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.positiveMain(context).withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.gradientShadow(context, alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _positiveTagsController,
              style: TextStyle(color: MinimalColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: '✅ Aspectos positivos',
                labelStyle: TextStyle(color: MinimalColors.positiveMain(context)),
                hintText: 'ej: productivo, feliz',
                hintStyle: TextStyle(color: MinimalColors.textMuted(context)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MinimalColors.negativeMain(context).withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.gradientShadow(context, alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _negativeTagsController,
              style: TextStyle(color: MinimalColors.textPrimary(context)),
              decoration: InputDecoration(
                labelText: '❌ Aspectos a mejorar',
                labelStyle: TextStyle(color: MinimalColors.negativeMain(context)),
                hintText: 'ej: estresado, cansado',
                hintStyle: TextStyle(color: MinimalColors.textMuted(context)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // PASO 2 (CONSOLIDADO): MOOD + BIENESTAR
  // ============================================================================

  Widget _buildMoodWellbeingStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStepCard(
            icon: '😊',
            title: 'Estado de Ánimo',
            subtitle: 'Evalúa cómo te sientes hoy',
            child: Column(
              children: [
                _buildMoodSelector(),
                const SizedBox(height: 24),
                _buildMoodInsight(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            icon: '⚡',
            title: 'Energía y Estrés',
            subtitle: 'Evalúa tu nivel de energía y estrés',
            child: Column(
              children: [
                _buildInteractiveSlider(
                  title: 'Nivel de Energía',
                  value: _energyLevel,
                  emoji: '⚡',
                  gradientColors: MinimalColors.positiveGradient(context),
                  onChanged: (value) => setState(() => _energyLevel = value),
                ),
                const SizedBox(height: 24),
                _buildInteractiveSlider(
                  title: 'Nivel de Estrés',
                  value: _stressLevel,
                  emoji: '😰',
                  gradientColors: MinimalColors.negativeGradient(context),
                  onChanged: (value) => setState(() => _stressLevel = value),
                  isReversed: true,
                ),
                const SizedBox(height: 24),
                _buildEnergyStressBalance(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PASO 4 (CONSOLIDADO): METAS + ACTIVIDADES
  // ============================================================================

  Widget _buildGoalsActivitiesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepCard(
            icon: '🎯',
            title: 'Progreso de Metas',
            subtitle: 'Revisa y actualiza el progreso de tus metas personales',
            child: Column(
              children: [
                _buildGoalsProgressSection(),
                const SizedBox(height: 16),
                _buildGoalsSummaryField(),
                const SizedBox(height: 16),
                _buildDailyPhotosSection(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            icon: '✅',
            title: 'Actividades del Día',
            subtitle: 'Selecciona las actividades que completaste hoy',
            child: Column(
              children: [
                _buildActivitiesProgressHeader(),
                const SizedBox(height: 16),
                _buildInteractiveActivitiesGrid(),
                const SizedBox(height: 16),
                _buildCompletedActivitiesField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PASO 5 (CONSOLIDADO): REFLEXIÓN PROFUNDA + EVALUACIÓN FINAL
  // ============================================================================

  Widget _buildReflectionFinalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStepCard(
            icon: '🧘',
            title: 'Reflexión Profunda',
            subtitle: 'Conecta con tus sentimientos más profundos',
            child: _buildInnerReflectionField(),
          ),
          const SizedBox(height: 16),
          _buildStepCard(
            icon: '🎯',
            title: 'Reflexión Final',
            subtitle: 'Evalúa el valor general de tu día',
            child: Column(
              children: [
                _buildWorthItQuestion(),
                const SizedBox(height: 24),
                _buildDaySummary(),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 24),
                _buildNavigationOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moodEmojis = ['😢', '😟', '😐', '🙂', '😊', '😄', '😆', '🤩', '😍', '🥳'];
    final moodLabels = ['Muy mal', 'Mal', 'Regular-', 'Regular', 'Bien', 'Muy bien', 'Genial', 'Fantástico', 'Increíble', 'Perfecto'];

    return Column(
      children: [
        // Emoji grande actual — el círculo transiciona de color y el emoji
        // hace un "pop" al cambiar de valor.
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: _getMoodGradient(_moodScore)),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.coloredShadow(context, _getMoodColor(_moodScore), alpha: 0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                moodEmojis[(_moodScore - 1).clamp(0, 9)],
                key: ValueKey<int>(_moodScore),
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Label del estado
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            moodLabels[(_moodScore - 1).clamp(0, 9)],
            key: ValueKey<int>(_moodScore),
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Escala táctil del estado de ánimo (tap o desliza)
        _buildTapScale(
          value: _moodScore,
          gradientColors: _getMoodGradient(_moodScore),
          onChanged: (v) => setState(() => _moodScore = v),
        ),
      ],
    );
  }

  Widget _buildMoodInsight() {
    String insight = '';
    Color insightColor = MinimalColors.textSecondary(context);

    if (_moodScore <= 3) {
      insight = 'Parece que ha sido un día difícil. Recuerda que los días difíciles también forman parte del crecimiento.';
      insightColor = MinimalColors.negativeMain(context);
    } else if (_moodScore <= 6) {
      insight = 'Un día promedio. Pequeños cambios pueden hacer una gran diferencia mañana.';
      insightColor = MinimalColors.warningMain(context);
    } else {
      insight = '¡Qué buen día! Reflexiona sobre qué lo hizo especial para repetirlo.';
      insightColor = MinimalColors.positiveMain(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insightColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: insightColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                color: insightColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSlider({
    required String title,
    required int value,
    required String emoji,
    required List<Color> gradientColors,
    required Function(int) onChanged,
    bool isReversed = false,
  }) {
    // final effectiveValue = isReversed ? (11 - value) : value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withValues(alpha: 0.1),
            gradientColors[1].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradientColors[0].withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value/10',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildTapScale(
            value: value,
            gradientColors: gradientColors,
            onChanged: onChanged,
          ),

          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _getSliderLabel(title, value, isReversed),
              style: TextStyle(
                color: gradientColors[0],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSliderLabel(String title, int value, bool isReversed) {
    if (title.contains('Energía')) {
      if (value <= 3) return 'Muy baja energía';
      if (value <= 6) return 'Energía moderada';
      return 'Alta energía';
    } else if (title.contains('Estrés')) {
      if (value <= 3) return 'Muy relajado';
      if (value <= 6) return 'Algo de tensión';
      return 'Muy estresado';
    }
    return '';
  }

  Widget _buildEnergyStressBalance() {
    final balance = _energyLevel - _stressLevel;
    final balanceColor = balance > 2
        ? MinimalColors.positiveMain(context)
        : balance < -2
        ? MinimalColors.negativeMain(context)
        : MinimalColors.warningMain(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: balanceColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Balance Energía-Estrés',
            style: TextStyle(
              color: balanceColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (balance + 9) / 18, // Normalizar de -9 a 9 => 0 a 1
            backgroundColor: MinimalColors.textMuted(context).withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(balanceColor),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            _getBalanceMessage(balance),
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getBalanceMessage(int balance) {
    if (balance > 3) return 'Excelente balance: mucha energía, poco estrés';
    if (balance > 0) return 'Buen balance general';
    if (balance > -3) return 'Balance neutral: energía y estrés equilibrados';
    return 'Desequilibrio: alto estrés, poca energía';
  }

  // ============================================================================
  // PASO 4: MÉTRICAS DETALLADAS
  // ============================================================================

  Widget _buildMetricsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStepCard(
            icon: '📊',
            title: 'Métricas Detalladas',
            subtitle: 'Opcional: registra métricas específicas',
            child: Column(
              children: [
                _buildMetricsGrid(),
                const SizedBox(height: 20),
                _buildNumericMetrics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {'title': 'Calidad del Sueño', 'value': _sleepQuality, 'emoji': '😴', 'key': 'sleep'},
      {'title': 'Ansiedad', 'value': _anxietyLevel, 'emoji': '😰', 'key': 'anxiety'},
      {'title': 'Motivación', 'value': _motivationLevel, 'emoji': '🔥', 'key': 'motivation'},
      {'title': 'Interacción Social', 'value': _socialInteraction, 'emoji': '👥', 'key': 'social'},
      {'title': 'Actividad Física', 'value': _physicalActivity, 'emoji': '🏃', 'key': 'physical'},
      {'title': 'Productividad', 'value': _workProductivity, 'emoji': '💼', 'key': 'work'},
    ];

    return Column(
      children: metrics.map((metric) => Column(
        children: [
          _buildMetricSlider(metric),
          const SizedBox(height: 16),
        ],
      )).toList(),
    );
  }

  // Slider alargado para métricas del grid (similar al estilo numeric)
  Widget _buildMetricSlider(Map<String, dynamic> metric) {
    final title = metric['title'] as String;
    final value = metric['value'] as int;
    final emoji = metric['emoji'] as String;
    final key = metric['key'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.gradientShadow(context, alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.lightGradient(context)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$value/10',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Widget visual específico para cada métrica
          Container(
            height: 50,
            child: _buildGridMetricVisualization(key, value.toDouble()),
          ),
          const SizedBox(height: 12),
          _buildTapScale(
            value: value,
            gradientColors: MinimalColors.lightGradient(context),
            onChanged: (v) => setState(() => _updateMetricValue(key, v)),
          ),
        ],
      ),
    );
  }


  // Visualizaciones para métricas del grid
  Widget _buildGridMetricVisualization(String key, double value) {
    final Color baseColor = MinimalColors.primaryGradient(context)[0];
    
    switch (key) {
      case 'physical':
        return _buildPhysicalActivityVisualization(value, baseColor);
      case 'anxiety':
        return _buildAnxietyVisualization(value, baseColor);
      case 'motivation':
        return _buildMotivationVisualization(value, baseColor);
      case 'social':
        return _buildSocialVisualization(value, baseColor);
      case 'sleep':
        return _buildSleepQualityVisualization(value, baseColor);
      case 'work':
        return _buildProductivityVisualization(value, baseColor);
      default:
        return Container(
          height: 40,
          child: LinearProgressIndicator(
            value: value / 10,
            backgroundColor: baseColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(baseColor),
          ),
        );
    }
  }

  // Visualización para actividad física - figuras corriendo
  Widget _buildPhysicalActivityVisualization(double value, Color color) {
    int activeCount = (value / 2).ceil(); // 1-5 figuras activas
    
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          bool isActive = index < activeCount;
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 8,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ] : null,
            ),
            child: isActive ? Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ) : null,
          );
        }),
      ),
    );
  }

  // Visualización para ansiedad - ondas de estrés
  Widget _buildAnxietyVisualization(double value, Color color) {
    // Invertir valor: menos ansiedad = mejor
    double intensity = value / 10;
    
    return Container(
      height: 40,
      child: CustomPaint(
        painter: AnxietyWavesPainter(
          intensity: intensity,
          color: intensity > 0.6 ? Colors.red : (intensity > 0.3 ? Colors.orange : Colors.green),
        ),
        size: Size.infinite,
      ),
    );
  }

  // Visualización para motivación - llama de energía
  Widget _buildMotivationVisualization(double value, Color color) {
    double intensity = value / 10;
    
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          double height = 15 + (intensity * 15) + (index * 5);
          return AnimatedContainer(
            duration: Duration(milliseconds: 500 + (index * 100)),
            margin: EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.orange,
                  Colors.red,
                  Colors.yellow.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  // Visualización para interacción social - círculos conectados
  Widget _buildSocialVisualization(double value, Color color) {
    int connections = (value / 2).ceil();
    
    return Container(
      height: 40,
      child: CustomPaint(
        painter: SocialConnectionsPainter(
          connections: connections,
          color: color,
        ),
        size: Size.infinite,
      ),
    );
  }

  // Visualización para calidad del sueño - lunas
  Widget _buildSleepQualityVisualization(double value, Color color) {
    double quality = value / 10;
    
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          double opacity = (quality > (index * 0.33)) ? 1.0 : 0.3;
          return AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: opacity,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: opacity),
                shape: BoxShape.circle,
                boxShadow: opacity > 0.5 ? [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 4,
                  )
                ] : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // Visualización para productividad - barras de progreso
  Widget _buildProductivityVisualization(double value, Color color) {
    double progress = value / 10;
    
    return Container(
      height: 40,
      child: Column(
        children: List.generate(3, (index) {
          double barProgress = (progress > (index * 0.33)) ? (progress - (index * 0.33)) * 3 : 0;
          barProgress = barProgress.clamp(0.0, 1.0);
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1),
              child: LinearProgressIndicator(
                value: barProgress,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumericMetrics() {
    return Column(
      children: [
        _buildNumericSlider(
          title: 'Horas de sueño',
          value: _sleepHours,
          emoji: '🛏️',
          unit: 'horas',
          min: 0,
          max: 12,
          onChanged: (value) => setState(() => _sleepHours = value),
        ),
        const SizedBox(height: 16),
        _buildNumericSlider(
          title: 'Vasos de agua',
          value: _waterIntake.toDouble(),
          emoji: '💧',
          unit: 'vasos',
          min: 0,
          max: 15,
          isInteger: true,
          onChanged: (value) => setState(() => _waterIntake = value.round()),
        ),
        const SizedBox(height: 16),
        _buildNumericSlider(
          title: 'Tiempo de pantalla',
          value: _screenTimeHours,
          emoji: '📱',
          unit: 'horas',
          min: 0,
          max: 16,
          onChanged: (value) => setState(() => _screenTimeHours = value),
        ),
      ],
    );
  }

  Widget _buildNumericSlider({
    required String title,
    required double value,
    required String emoji,
    required String unit,
    required double min,
    required double max,
    required Function(double) onChanged,
    bool isInteger = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.gradientShadow(context, alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.lightGradient(context)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isInteger
                      ? '${value.round()} $unit'
                      : '${value.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Widget visual específico para cada métrica
          Container(
            height: 50,
            child: _buildMetricVisualizationV2(title, value, MinimalColors.lightGradient(context)[0]),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: MinimalColors.lightGradient(context)[0],
              inactiveTrackColor: MinimalColors.textMuted(context).withValues(alpha: 0.3),
              thumbColor: MinimalColors.lightGradient(context)[1],
              overlayColor: MinimalColors.lightGradient(context)[0].withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: isInteger ? (max - min).round() : null,
              onChanged: (newValue) {
                onChanged(newValue);
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgressSection() {
    return Consumer<GoalsProvider>(
      builder: (context, goalsProvider, child) {
        final activeGoals = goalsProvider.goals.where((goal) => goal.isActive).toList();

        if (activeGoals.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.flag_outlined, size: 48, color: Colors.orange),
                const SizedBox(height: 12),
                Text(
                  'No tienes metas activas',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea una meta para empezar a hacer seguimiento de tu progreso',
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Text(
              'Tus Metas Activas',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...activeGoals.map((goal) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EnhancedGoalCard(
                goal: goal,
                showFullDetails: false,
                onTap: () {
                  // Could navigate to goal details if needed
                },
                onProgressUpdate: () {
                  _showProgressUpdateDialog(goal);
                },
              ),
            )),
          ],
        );
      },
    );
  }


  Widget _buildGoalsSummaryField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.summarize_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resumen de Metas',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _goalsSummaryController,
            onChanged: (value) {
              setState(() {
                _goalsSummary = value.split('\n').where((line) => line.trim().isNotEmpty).toList();
              });
            },
            maxLines: 3,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Describe tu progreso en las metas de hoy...',
              hintStyle: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPhotosSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fotos del Día',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Próximamente podrás adjuntar fotos a tu reflexión',
                    style: TextStyle(
                      color: MinimalColors.textSecondary(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesProgressHeader() {
    return Consumer<DailyActivitiesProvider>(
      builder: (context, activitiesProvider, child) {
        final completionPercentage = activitiesProvider.completionPercentage;
        final completedCount = activitiesProvider.completedCount;
        final totalCount = activitiesProvider.totalActivities;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso de Actividades',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$completedCount/$totalCount',
                    style: TextStyle(
                      color: MinimalColors.primaryGradient(context)[0],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: completionPercentage / 100,
                backgroundColor: MinimalColors.textSecondary(context).withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(MinimalColors.primaryGradient(context)[0]),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${completionPercentage.toStringAsFixed(0)}% completado',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveActivitiesGrid() {
    return Consumer<DailyActivitiesProvider>(
      builder: (context, activitiesProvider, child) {
        final activities = activitiesProvider.activities;
        
        if (activities.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No hay actividades disponibles',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Las actividades se cargarán automáticamente',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildInteractiveActivityCard(activity, activitiesProvider);
          },
        );
      },
    );
  }

  Widget _buildInteractiveActivityCard(dynamic activity, DailyActivitiesProvider provider) {
    final isCompleted = activity.isCompleted;
    final completionColor = isCompleted ? Colors.green : MinimalColors.textSecondary(context);
    
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        
        if (isCompleted) {
          await provider.undoActivityCompletion(activity.id);
        } else {
          await provider.completeActivity(activity.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [Colors.green.shade400, Colors.green.shade600]
                : [
                    MinimalColors.backgroundCard(context),
                    MinimalColors.backgroundSecondary(context),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.6)
                : MinimalColors.textSecondary(context).withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isCompleted
                  ? MinimalColors.coloredShadow(context, Colors.green, alpha: 0.1)
                  : MinimalColors.gradientShadow(context, alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Completion status indicator
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : completionColor,
                  size: 20,
                ),
              ),
            ),
            
            // Activity content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity emoji
                  Text(
                    activity.emoji,
                    style: TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  
                  // Activity title
                  Text(
                    activity.title,
                    style: TextStyle(
                      color: isCompleted ? Colors.white : MinimalColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Activity duration
                  Text(
                    activity.durationText,
                    style: TextStyle(
                      color: isCompleted ? Colors.white.withValues(alpha: 0.85) : MinimalColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.white.withValues(alpha: 0.2)
                          : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.category,
                      style: TextStyle(
                        color: isCompleted ? Colors.white : MinimalColors.primaryGradient(context)[0],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedActivitiesField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.positiveGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Actividades Adicionales',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _completedActivitiesController,
            onChanged: (value) {
              setState(() {
                _completedActivitiesToday = value
                    .split('\n')
                    .where((line) => line.trim().isNotEmpty)
                    .toList();
              });
            },
            maxLines: 3,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Agrega otras actividades que completaste...',
              hintStyle: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerReflectionField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.backgroundCard(context),
            MinimalColors.backgroundSecondary(context),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.gradientShadow(context, alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.accentGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mi Reflexión Interior',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: _innerReflectionController,
            maxLines: 8,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '¿Qué sientes en este momento? ¿Qué pensamientos ocupan tu mente? No hay juicio, solo observación...',
              hintStyle: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _canContinue()
            ? LinearGradient(colors: MinimalColors.accentGradient(context))
            : null,
        color: !_canContinue() 
            ? MinimalColors.textMuted(context).withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _canContinue()
            ? [
                BoxShadow(
                  color: MinimalColors.gradientShadow(context, alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: _canContinue() ? _saveReflection : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.save_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Guardar Reflexión',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorthItQuestion() {
    return Column(
      children: [
        Text(
          '¿Ha valido la pena este día?',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _worthIt = true);
                  HapticFeedback.mediumImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _worthIt == true
                        ? LinearGradient(colors: MinimalColors.positiveGradient(context))
                        : null,
                    color: _worthIt == true ? null : MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _worthIt == true
                          ? Colors.green
                          : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      width: _worthIt == true ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '👍',
                        style: TextStyle(fontSize: _worthIt == true ? 40 : 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sí, ha valido la pena',
                        style: TextStyle(
                          color: _worthIt == true ? Colors.white : MinimalColors.textSecondary(context),
                          fontSize: 14,
                          fontWeight: _worthIt == true ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _worthIt = false);
                  HapticFeedback.mediumImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: _worthIt == false
                        ? LinearGradient(colors: MinimalColors.negativeGradient(context))
                        : null,
                    color: _worthIt == false ? null : MinimalColors.backgroundCard(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _worthIt == false
                          ? Colors.red
                          : MinimalColors.textMuted(context).withValues(alpha: 0.3),
                      width: _worthIt == false ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '👎',
                        style: TextStyle(fontSize: _worthIt == false ? 40 : 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No, podría mejorar',
                        style: TextStyle(
                          color: _worthIt == false ? Colors.white : MinimalColors.textSecondary(context),
                          fontSize: 14,
                          fontWeight: _worthIt == false ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDaySummary() {
    final overallScore = (_moodScore + _energyLevel + (11 - _stressLevel)) / 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _getMoodGradient(overallScore.round())),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.coloredShadow(context, _getMoodColor(overallScore.round()), alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Puntuación del Día',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${overallScore.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getDayMessage(overallScore),
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayMessage(double score) {
    if (score >= 8) return '¡Excelente día! Sigue así 🌟';
    if (score >= 6) return 'Buen día en general 👍';
    if (score >= 4) return 'Día promedio, hay espacio para mejorar 📈';
    return 'Día difícil, mañana será mejor 💪';
  }

  Widget _buildNavigationOptions() {
    return Column(
      children: [
        Text(
          'Después de guardar puedes:',
          style: TextStyle(
            color: MinimalColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          icon: Icons.calendar_month,
          title: 'Ver todas las reflexiones',
          subtitle: 'Navegar por el calendario del año',
          onTap: () {
            _saveReflection().then((success) {
              if (success) {
                _navigateToCalendar();
              }
            });
          },
        ),
        const SizedBox(height: 12),
        _buildNavigationButton(
          icon: Icons.analytics,
          title: 'Ver análisis y tendencias',
          subtitle: 'Explorar patrones en tus datos',
          onTap: () {
            _saveReflection().then((success) {
              if (success && mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsV3Screen(),
                  ),
                );
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MinimalColors.textMuted(context).withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: MinimalColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: MinimalColors.textMuted(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // WIDGETS HELPER
  // ============================================================================

  Widget _buildStepCard({
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final isLight = Theme.of(context).extension<AppColors>()?.isDark == false;
    final accent = MinimalColors.primaryGradient(context);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack)),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          // Claro: superficie blanca limpia. Oscuro: gradiente translúcido.
          color: isLight ? MinimalColors.backgroundCard(context) : null,
          gradient: isLight
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    MinimalColors.backgroundCard(context),
                    accent[0].withValues(alpha: 0.08),
                    accent[1].withValues(alpha: 0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLight
                ? MinimalColors.textMuted(context).withValues(alpha: 0.15)
                : accent[0].withValues(alpha: 0.3),
            width: isLight ? 1 : 1.5,
          ),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: MinimalColors.gradientShadow(context, alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: MinimalColors.gradientShadow(context, alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: isLight
                ? null
                : Border.all(
                    color: MinimalColors.textMuted(context).withValues(alpha: 0.12),
                    width: 1,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // Claro: tinte muy tenue del acento. Oscuro: gradiente actual.
                  color: isLight ? accent[0].withValues(alpha: 0.06) : null,
                  gradient: isLight
                      ? null
                      : LinearGradient(
                          colors: accent
                              .map((c) => c.withValues(alpha: 0.15))
                              .toList(),
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent[0].withValues(alpha: isLight ? 0.12 : 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: MinimalColors.primaryGradient(context),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: MinimalColors.textPrimary(context),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: MinimalColors.textSecondary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: MinimalColors.primaryGradient(context)[0],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }


  // ============================================================================
  // LÓGICA DE NEGOCIO
  // ============================================================================

  Future<bool> _saveReflection() async {
    final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
    final entriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      _showErrorSnackBar('Error: usuario no autenticado');
      return false;
    }

    try {
      _showLoadingDialog();

      final success = await entriesProvider.saveDailyEntry(
        userId: authProvider.currentUser!.id,
        freeReflection: _reflectionController.text.trim(),
        innerReflection: _innerReflectionController.text.trim().isEmpty
            ? null
            : _innerReflectionController.text.trim(),
        completedActivitiesToday: _completedActivitiesToday,
        goalsSummary: _goalsSummary,
        positiveTags: _positiveTagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        negativeTags: _negativeTagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        worthIt: _worthIt,
        moodScore: _moodScore,
        energyLevel: _energyLevel,
        stressLevel: _stressLevel,
        sleepQuality: _sleepQuality,
        anxietyLevel: _anxietyLevel,
        motivationLevel: _motivationLevel,
        socialInteraction: _socialInteraction,
        physicalActivity: _physicalActivity,
        workProductivity: _workProductivity,
        sleepHours: _sleepHours,
        waterIntake: _waterIntake,
        meditationMinutes: _meditationMinutes,
        exerciseMinutes: _exerciseMinutes,
        screenTimeHours: _screenTimeHours,
        gratitudeItems: _gratitudeController.text.trim().isEmpty ? null : _gratitudeController.text.trim(),
        weatherMoodImpact: _weatherMoodImpact,
        socialBattery: _socialBattery,
        creativeEnergy: _creativeEnergy,
        emotionalStability: _emotionalStability,
        focusLevel: _focusLevel,
        lifeSatisfaction: _lifeSatisfaction,
        voiceRecordingPath: _voiceRecordingPath,
      );

      if (mounted) Navigator.pop(context); // Cerrar loading

      if (success) {
        _showSuccessSnackBar('¡Reflexión guardada exitosamente!');
        return true;
      } else {
        _showErrorSnackBar('Error al guardar la reflexión');
        return false;
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Cerrar loading
      _showErrorSnackBar('Error inesperado al guardar');
      return false;
    }
  }

  void _navigateToCalendar() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CalendarScreenV2(),
      ),
    );
  }


  // ============================================================================
  // HELPERS
  // ============================================================================

  Color _getMoodColor(int score) {
    if (score <= 3) return MinimalColors.negativeMain(context);
    if (score <= 6) return MinimalColors.warningMain(context);
    return MinimalColors.positiveMain(context);
  }

  List<Color> _getMoodGradient(int score) {
    if (score <= 3) return MinimalColors.negativeGradient(context);
    if (score <= 6) return MinimalColors.neutralGradient(context);
    return MinimalColors.positiveGradient(context);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinimalColors.negativeMain(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MinimalColors.positiveMain(context),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateMetricValue(String key, int value) {
    switch (key) {
      case 'sleep':
        _sleepQuality = value;
        break;
      case 'anxiety':
        _anxietyLevel = value;
        break;
      case 'motivation':
        _motivationLevel = value;
        break;
      case 'social':
        _socialInteraction = value;
        break;
      case 'physical':
        _physicalActivity = value;
        break;
      case 'work':
        _workProductivity = value;
        break;
    }
  }

  void _showProgressUpdateDialog(GoalModel goal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressEntryDialog(
        goal: goal,
        onEntryCreated: (entry) async {
          try {
            // Here you would typically call a service to update the goal
            // For now, we'll just show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Progreso actualizado exitosamente'),
                backgroundColor: MinimalColors.positiveMain(context),
              ),
            );
            // Refresh the goals data
            setState(() {
              // Update would happen here
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error actualizando progreso: $e'),
                backgroundColor: MinimalColors.negativeMain(context),
              ),
            );
          }
        },
      ),
    );
  }

  // Metadata de cada paso (emoji + nombre corto) para el stepper y la cabecera.
  static const List<Map<String, String>> _stepMeta = [
    {'emoji': '✍️', 'label': 'Reflexión'},
    {'emoji': '😊', 'label': 'Ánimo'},
    {'emoji': '📊', 'label': 'Métricas'},
    {'emoji': '🎯', 'label': 'Metas'},
    {'emoji': '🧘', 'label': 'Final'},
  ];

  // Stepper segmentado: nodos navegables con estado hecho/activo/pendiente.
  Widget _buildStepProgress() {
    return SizedBox(
      height: 44,
      child: Row(
        children: List.generate(_totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final leftIndex = i ~/ 2;
            final done = leftIndex < _currentStep;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: done
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: done
                      ? null
                      : MinimalColors.textMuted(context).withValues(alpha: 0.18),
                ),
              ),
            );
          }
          return _buildStepNode(i ~/ 2);
        }),
      ),
    );
  }

  Widget _buildStepNode(int index) {
    final isActive = index == _currentStep;
    final isDone = index < _currentStep;
    final filled = isActive || isDone;
    final size = isActive ? 40.0 : 32.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: filled
              ? LinearGradient(colors: MinimalColors.primaryGradient(context))
              : null,
          color: filled ? null : MinimalColors.backgroundCard(context),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : MinimalColors.textMuted(context).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: MinimalColors.primaryGradient(context)[0]
                        .withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isDone
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(
                _stepMeta[index]['emoji']!,
                style: TextStyle(fontSize: isActive ? 18 : 13),
              ),
      ),
    );
  }

  // Escala táctil 1–N: tap o desliza para fijar el valor (reemplaza sliders).
  Widget _buildTapScale({
    required int value,
    required ValueChanged<int> onChanged,
    required List<Color> gradientColors,
    int max = 10,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 4.0;
        final segWidth = (constraints.maxWidth - gap * (max - 1)) / max;

        void handleAt(double dx) {
          final idx = (dx / (segWidth + gap)).floor().clamp(0, max - 1);
          final v = idx + 1;
          if (v != value) {
            onChanged(v);
            HapticFeedback.selectionClick();
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => handleAt(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => handleAt(d.localPosition.dx),
          child: Row(
            children: List.generate(max, (i) {
              final isFilled = i < value;
              final isCurrent = i == value - 1;
              return Container(
                width: segWidth,
                height: 34,
                margin: EdgeInsets.only(right: i == max - 1 ? 0 : gap),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: isFilled
                      ? LinearGradient(colors: gradientColors)
                      : null,
                  color: isFilled
                      ? null
                      : MinimalColors.textMuted(context).withValues(alpha: 0.12),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isFilled
                        ? Colors.white
                        : MinimalColors.textMuted(context),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ============================================================================
  // MÉTODOS DE VISUALIZACIÓN PARA MÉTRICAS V2
  // ============================================================================

  Widget _buildMetricVisualizationV2(String title, double value, Color color) {
    switch (title) {
      case 'Vasos de agua':
        return _buildWaterVisualizationV2(value.toInt(), color);
      case 'Horas de sueño':
        return _buildSleepVisualizationV2(value, color);
      case 'Tiempo de pantalla':
        return _buildScreenTimeVisualizationV2(value, color);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWaterVisualizationV2(int glasses, Color color) {
    final maxGlasses = 8;
    final glassesToShow = glasses > maxGlasses ? maxGlasses : glasses;
    final hasMore = glasses > maxGlasses;

    return Container(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vasos de agua
          ...List.generate(glassesToShow, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Container(
                width: 12,
                height: 18,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: color,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(2),
                            topRight: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.7),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(2),
                            bottomRight: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (hasMore) ...[
            const SizedBox(width: 4),
            Text(
              '+${glasses - maxGlasses}',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepVisualizationV2(double hours, Color color) {
    final totalHours = 12;
    final sleepHours = hours.clamp(0, totalHours.toDouble());
    final progress = sleepHours / totalHours;

    return Container(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reloj de sueño con arco
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              children: [
                // Círculo base
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                ),
                // Arco de progreso
                CustomPaint(
                  size: const Size(32, 32),
                  painter: SleepArcPainterV2(
                    progress: progress,
                    color: color,
                    strokeWidth: 3,
                  ),
                ),
                // Ícono de luna en el centro
                Center(
                  child: Icon(
                    Icons.bedtime,
                    size: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Barras de horas
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                final hourIndex = index + 1;
                final isActive = hourIndex <= sleepHours;
                return Expanded(
                  child: Container(
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isActive ? color : color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeVisualizationV2(double hours, Color color) {
    final maxHours = 12;
    final intensity = (hours / maxHours).clamp(0.0, 1.0);
    
    return Container(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Teléfono con pantalla que se va llenando
          Container(
            width: 18,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Parte superior (vacía)
                Expanded(
                  flex: (100 - (intensity * 100)).toInt().clamp(1, 100),
                  child: Container(),
                ),
                // Parte inferior (llena según uso)
                if (intensity > 0)
                  Expanded(
                    flex: (intensity * 100).toInt().clamp(1, 100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Ondas de radiación
          ...List.generate(3, (index) {
            final waveOpacity = (intensity * (1 - (index * 0.3))).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Container(
                width: 3,
                height: (8 + index * 3).toDouble(),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: waveOpacity),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTERS PARA VISUALIZACIONES V2
// ============================================================================

// Painter para ondas de ansiedad
class AnxietyWavesPainter extends CustomPainter {
  final double intensity;
  final Color color;

  AnxietyWavesPainter({required this.intensity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveHeight = size.height * 0.3 * intensity;
    final waveCount = 3 + (intensity * 2).round();
    
    for (int i = 0; i < waveCount; i++) {
      final x = (size.width / waveCount) * i;
      if (i == 0) {
        path.moveTo(x, size.height / 2);
      } else {
        path.lineTo(x, size.height / 2 + waveHeight * (i % 2 == 0 ? 1 : -1));
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter para conexiones sociales
class SocialConnectionsPainter extends CustomPainter {
  final int connections;
  final Color color;

  SocialConnectionsPainter({required this.connections, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Dibujar círculos conectados
    final radius = 4.0;
    final spacing = size.width / (connections + 1);
    
    for (int i = 0; i < connections; i++) {
      final x = spacing * (i + 1);
      final y = size.height / 2;
      
      // Dibujar círculo
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // Dibujar línea de conexión al siguiente
      if (i < connections - 1) {
        final nextX = spacing * (i + 2);
        canvas.drawLine(
          Offset(x + radius, y),
          Offset(nextX - radius, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SleepArcPainterV2 extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  SleepArcPainterV2({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final startAngle = -90 * (3.14159 / 180); // -90 grados en radianes
    final sweepAngle = 360 * progress * (3.14159 / 180); // Progreso en radianes

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}