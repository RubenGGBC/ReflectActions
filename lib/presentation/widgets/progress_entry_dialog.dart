// lib/presentation/widgets/progress_entry_dialog.dart
// ============================================================================
// MODERN PROGRESS ENTRY DIALOG - ENHANCED UX
// ============================================================================

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../../data/models/goal_model.dart';
import '../../data/services/image_picker_service.dart';
import '../../injection_container_clean.dart' as clean_di;
import '../screens/v2/components/minimal_colors.dart';

class ProgressEntryDialog extends StatefulWidget {
  final GoalModel goal;
  final Future<void> Function(ProgressEntry) onEntryCreated;

  const ProgressEntryDialog({
    super.key,
    required this.goal,
    required this.onEntryCreated,
  });

  @override
  State<ProgressEntryDialog> createState() => _ProgressEntryDialogState();
}

class _ProgressEntryDialogState extends State<ProgressEntryDialog>
    with TickerProviderStateMixin {

  final _logger = Logger();

  late AnimationController _slideController;
  late AnimationController _progressAnimController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Form controllers
  final _notesController = TextEditingController();

  // Progress value
  late double _newValue;
  late double _originalValue;

  // Metrics (simplified)
  int _qualityRating = 3;
  int _moodRating = 3;

  // Extras
  final List<String> _photoUrls = [];
  final List<String> _tags = [];
  final List<String> _quickNotes = [
    '¡Me sentí genial!',
    'Fue desafiante pero lo logré',
    'Tuve algunas dificultades',
    'No pude completar todo hoy',
    'Superé mis expectativas',
  ];

  bool _isLoading = false;
  bool _showExtras = false;

  @override
  void initState() {
    super.initState();
    _originalValue = widget.goal.currentValue.toDouble();
    _newValue = _originalValue;
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _slideController.forward();
    _progressAnimController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressAnimController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildProgressSection(context),
                        const SizedBox(height: 24),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),
                        _buildNotesSection(context),
                        if (_showExtras) ...[
                          const SizedBox(height: 24),
                          _buildExtrasSection(context),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
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
                      'Actualizar Progreso',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.goal.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final increment = _newValue - _originalValue;
    final newProgress = (_newValue / widget.goal.targetValue).clamp(0.0, 1.0);
    final willComplete = _newValue >= widget.goal.targetValue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.08),
            MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Current vs New Progress
          Row(
            children: [
              Expanded(
                child: _buildProgressIndicator(
                  'Actual',
                  _originalValue,
                  widget.goal.targetValue.toDouble(),
                  MinimalColors.textMuted(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: MinimalColors.primaryGradient(context)[0],
                  size: 24,
                ),
              ),
              Expanded(
                child: _buildProgressIndicator(
                  'Nuevo',
                  _newValue,
                  widget.goal.targetValue.toDouble(),
                  willComplete ? MinimalColors.success : MinimalColors.primaryGradient(context)[0],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Large slider
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nuevo valor: ${_newValue.toInt()} ${widget.goal.suggestedUnit}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                  if (increment > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: MinimalColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MinimalColors.success.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 14,
                            color: MinimalColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${increment.toInt()}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: MinimalColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
                  activeTrackColor: willComplete ? MinimalColors.success : MinimalColors.primaryGradient(context)[0],
                  inactiveTrackColor: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                  thumbColor: willComplete ? MinimalColors.success : MinimalColors.primaryGradient(context)[0],
                  overlayColor: (willComplete ? MinimalColors.success : MinimalColors.primaryGradient(context)[0]).withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: _newValue.clamp(_originalValue, widget.goal.targetValue.toDouble() * 1.2),
                  min: _originalValue,
                  max: math.max(widget.goal.targetValue.toDouble() * 1.2, _originalValue + 10),
                  divisions: ((math.max(widget.goal.targetValue.toDouble() * 1.2, _originalValue + 10) - _originalValue) ~/ 1).clamp(1, 100),
                  onChanged: (value) {
                    setState(() {
                      _newValue = value.clamp(_originalValue, widget.goal.targetValue.toDouble() * 1.2);
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_originalValue.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Meta: ${widget.goal.targetValue}',
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick increment buttons
          Row(
            children: [
              Expanded(
                child: _buildIncrementButton('+1', 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIncrementButton('+5', 5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIncrementButton('+10', 10),
              ),
            ],
          ),

          if (willComplete) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MinimalColors.success.withValues(alpha: 0.15),
                    MinimalColors.success.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MinimalColors.success.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MinimalColors.success,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Completarás este objetivo!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: MinimalColors.success,
                          ),
                        ),
                        Text(
                          'Excelente trabajo, sigue así',
                          style: TextStyle(
                            fontSize: 12,
                            color: MinimalColors.textSecondary(context),
                          ),
                        ),
                      ],
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

  Widget _buildProgressIndicator(String label, double value, double max, Color color) {
    final progress = (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: MinimalColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${value.toInt()}/${max.toInt()}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIncrementButton(String label, int amount) {
    final maxValue = widget.goal.targetValue.toDouble() * 1.2; // Máximo 120% del objetivo

    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.accentGradient(context),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.accentGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final newValue = _newValue + amount;
            if (newValue > maxValue) {
              // Si se pasa del límite, mostrar feedback
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No puedes exceder el 120% del objetivo (${maxValue.toInt()} ${widget.goal.suggestedUnit})'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: MinimalColors.warning,
                ),
              );
              setState(() {
                _newValue = maxValue; // Establecer al máximo permitido
              });
            } else {
              setState(() {
                _newValue = newValue;
              });
              HapticFeedback.mediumImpact();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final remaining = widget.goal.targetValue - _originalValue.toInt();
    final isAlreadyCompleted = _originalValue >= widget.goal.targetValue;

    return Row(
      children: [
        if (remaining > 0 && !isAlreadyCompleted)
          Expanded(
            child: _buildQuickActionButton(
              'Completar',
              Icons.check_circle_rounded,
              MinimalColors.success,
              () {
                setState(() {
                  _newValue = widget.goal.targetValue.toDouble();
                });
                HapticFeedback.heavyImpact();
              },
            ),
          ),
        if (remaining > 0 && !isAlreadyCompleted) const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            'Saltear hoy',
            Icons.skip_next_rounded,
            MinimalColors.warning,
            () {
              setState(() {
                _newValue = _originalValue;
                _notesController.text = 'Día saltado - continuaré mañana';
              });
              HapticFeedback.mediumImpact();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo te sentiste?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),

        // Quick notes
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickNotes.map((note) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _notesController.text = note;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  note,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Custom notes
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'O escribe tu propia nota...',
              hintStyle: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: MinimalColors.primaryGradient(context)[0],
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: MinimalColors.backgroundSecondary(context),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Toggle extras
        GestureDetector(
          onTap: () {
            setState(() {
              _showExtras = !_showExtras;
            });
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showExtras ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20,
                  color: MinimalColors.textSecondary(context),
                ),
                const SizedBox(width: 8),
                Text(
                  _showExtras ? 'Ocultar opciones extras' : 'Agregar fotos y calificación',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: MinimalColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtrasSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mood rating
        _buildMoodRating(context),

        const SizedBox(height: 20),

        // Photo section
        _buildPhotoSection(context),
      ],
    );
  }

  Widget _buildMoodRating(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Califica tu experiencia',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MinimalColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final moodIcons = [
              Icons.sentiment_very_dissatisfied,
              Icons.sentiment_dissatisfied,
              Icons.sentiment_neutral,
              Icons.sentiment_satisfied,
              Icons.sentiment_very_satisfied,
            ];
            final isSelected = _moodRating == index + 1;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _moodRating = index + 1;
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.15)
                      : MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? MinimalColors.primaryGradient(context)[0]
                        : MinimalColors.textMuted(context).withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Icon(
                  moodIcons[index],
                  size: isSelected ? 32 : 28,
                  color: isSelected
                      ? MinimalColors.primaryGradient(context)[0]
                      : MinimalColors.textSecondary(context),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos del progreso',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: MinimalColors.textPrimary(context),
              ),
            ),
            TextButton.icon(
              onPressed: _addPhoto,
              icon: Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: Text('Agregar'),
              style: TextButton.styleFrom(
                foregroundColor: MinimalColors.primaryGradient(context)[0],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photoUrls.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_photoUrls[index]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: MinimalColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: MinimalColors.backgroundSecondary(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MinimalColors.textMuted(context).withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_rounded,
                    size: 32,
                    color: MinimalColors.textMuted(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sin fotos aún',
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: MinimalColors.textMuted(context).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: MinimalColors.textMuted(context).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Guardar Progreso',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final imageService = clean_di.sl<ImagePickerService>();
      final imagePath = await imageService.pickFromGallery();
      if (imagePath != null) {
        setState(() {
          _photoUrls.add(imagePath);
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error agregando foto: $e'),
          backgroundColor: MinimalColors.error,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
    });
    HapticFeedback.lightImpact();
  }

  void _submitEntry() async {
    if (_newValue == _originalValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No has actualizado el valor del progreso'),
          backgroundColor: MinimalColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validar y ajustar el valor final
      final maxValue = widget.goal.targetValue.toDouble() * 1.2;
      final validatedValue = _newValue.clamp(_originalValue, maxValue);

      if (validatedValue != _newValue) {
        _logger.w('⚠️ Valor ajustado de $_newValue a $validatedValue (máximo permitido: $maxValue)');
      }

      final entry = ProgressEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: widget.goal.id.toString(),
        timestamp: DateTime.now(),
        primaryValue: validatedValue.toInt(),
        metrics: {
          'quality': _qualityRating,
          'mood': _moodRating,
        },
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        photoUrls: _photoUrls,
        tags: _tags,
      );

      HapticFeedback.mediumImpact();

      // Esperar a que se complete la actualización ANTES de cerrar
      await widget.onEntryCreated(entry);

      // Solo cerrar después de que todo esté actualizado
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error guardando entrada: $e'),
            backgroundColor: MinimalColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
