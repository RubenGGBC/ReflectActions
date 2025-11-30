// ============================================================================
// add_activity_modal.dart - MODAL MEJORADO PARA AGREGAR ACTIVIDADES
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../../data/models/roadmap_activity_model.dart';
import '../../../providers/daily_roadmap_provider.dart';
import 'minimal_colors.dart';

class AddActivityModal extends StatefulWidget {
  final DailyRoadmapProvider provider;
  final int initialHour;
  final int initialMinute;

  const AddActivityModal({
    super.key,
    required this.provider,
    required this.initialHour,
    required this.initialMinute,
  });

  @override
  State<AddActivityModal> createState() => _AddActivityModalState();
}

class _AddActivityModalState extends State<AddActivityModal>
    with TickerProviderStateMixin {

  late AnimationController _slideController;
  late AnimationController _fadeController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedHour = 0;
  int _selectedMinute = 0;
  ActivityPriority _selectedPriority = ActivityPriority.medium;
  String? _selectedCategory;
  int _estimatedDuration = 60; // minutes
  ActivityMood? _plannedMood;
  bool _isLoading = false;
  bool _showAdvancedOptions = false;

  // Categories - Streamlined list
  final List<String> _categories = [
    'Trabajo',
    'Personal',
    'Ejercicio',
    'Salud',
    'Estudio',
    'Social',
  ];

  // Duration options (in minutes) - Simplified
  final List<int> _durationOptions = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;
    _setupAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Start animations with a slight delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "add_activity_modal",
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.shadow(context),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _buildForm(context),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: MinimalColors.primaryGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_task_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nueva Actividad',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Programa una nueva actividad',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _closeModal,
                icon: Icon(
                  Icons.close_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Quick action buttons
          _buildQuickActionButtons(context),
          const SizedBox(height: 24),

          // Essential fields
          _buildTitleField(context),
          const SizedBox(height: 20),
          _buildTimeSection(context),
          const SizedBox(height: 20),
          _buildQuickSettings(context),

          // Advanced options toggle
          const SizedBox(height: 24),
          _buildAdvancedToggle(context),

          // Advanced options (collapsible)
          if (_showAdvancedOptions) ...[
            const SizedBox(height: 20),
            _buildDescriptionField(context),
            const SizedBox(height: 20),
            _buildCategorySection(context),
            const SizedBox(height: 20),
            _buildMoodSection(context),
          ],

          const SizedBox(height: 32), // Extra space for better scrolling
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    final quickActions = [
      {'icon': Icons.fitness_center, 'title': 'Ejercicio', 'category': 'Ejercicio', 'duration': 60},
      {'icon': Icons.work_outline, 'title': 'Trabajo', 'category': 'Trabajo', 'duration': 120},
      {'icon': Icons.book_outlined, 'title': 'Estudio', 'category': 'Estudio', 'duration': 90},
      {'icon': Icons.restaurant, 'title': 'Comida', 'category': 'Personal', 'duration': 45},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Acciones rápidas',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: quickActions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _titleController.text = action['title'] as String;
                    _selectedCategory = action['category'] as String;
                    _estimatedDuration = action['duration'] as int;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                        MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: MinimalColors.primaryGradient(context)[0],
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action['title'] as String,
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.title_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Título de la actividad',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          autofocus: false,
          textInputAction: TextInputAction.next,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Ej: Reunión de equipo, Ejercicio...',
            hintStyle: TextStyle(
              color: MinimalColors.textSecondary(context).withValues(alpha: 0.6),
              fontSize: 16,
            ),
            filled: true,
            fillColor: MinimalColors.backgroundSecondary(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            prefixIcon: Icon(
              Icons.edit_note_rounded,
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.7),
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MinimalColors.primaryGradient(context)[0],
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El título es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Descripción (opcional)',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          style: TextStyle(color: MinimalColors.textPrimary(context)),
          maxLines: 3,
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Agrega detalles adicionales sobre esta actividad...',
            hintStyle: TextStyle(
              color: MinimalColors.textSecondary(context).withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: MinimalColors.backgroundSecondary(context),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: MinimalColors.primaryGradient(context)[0],
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(BuildContext context) {
    final now = DateTime.now();
    final isCurrentTime = _selectedHour == now.hour && _selectedMinute == now.minute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Hora programada',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Quick "Now" button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedHour = now.hour;
                  _selectedMinute = (now.minute ~/ 15) * 15; // Round to nearest 15 min
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrentTime
                      ? MinimalColors.primaryGradient(context)[0]
                      : MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isCurrentTime
                          ? Colors.white
                          : MinimalColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ahora',
                      style: TextStyle(
                        color: isCurrentTime
                            ? Colors.white
                            : MinimalColors.textSecondary(context),
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
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showTimePicker,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.15),
                  MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hora seleccionada',
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_calendar_rounded,
                    color: MinimalColors.primaryGradient(context)[0],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSettings(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPrioritySelector(context),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDurationSelector(context),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.priority_high_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Prioridad',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: ActivityPriority.values.map((priority) {
              final isSelected = priority == _selectedPriority;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedPriority = priority);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          priority.emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 20 : 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priority.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : MinimalColors.textSecondary(context),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Duración',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showDurationPicker(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.15),
                  MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: MinimalColors.primaryGradient(context)[0],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_estimatedDuration}m',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: MinimalColors.primaryGradient(context)[0],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedToggle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _showAdvancedOptions = !_showAdvancedOptions);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MinimalColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Opciones avanzadas',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedRotation(
              turns: _showAdvancedOptions ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: MinimalColors.textSecondary(context),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCategorySection(BuildContext context) {
    final categoryIcons = {
      'Trabajo': Icons.work_outline,
      'Personal': Icons.person_outline,
      'Ejercicio': Icons.fitness_center,
      'Salud': Icons.favorite_outline,
      'Estudio': Icons.school_outlined,
      'Social': Icons.people_outline,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Categoría',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _selectedCategory = isSelected ? null : category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                      : null,
                  color: !isSelected ? MinimalColors.backgroundSecondary(context) : null,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      categoryIcons[category],
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : MinimalColors.primaryGradient(context)[0],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : MinimalColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildMoodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.mood_rounded,
              color: MinimalColors.primaryGradient(context)[0],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Estado de ánimo esperado',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: ActivityMood.values.map((mood) {
              final isSelected = mood == _plannedMood;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _plannedMood = isSelected ? null : mood;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood.emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mood.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : MinimalColors.textSecondary(context),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        border: Border(
          top: BorderSide(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.shadow(context),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main action button
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? LinearGradient(
                          colors: MinimalColors.primaryGradient(context)
                              .map((c) => c.withValues(alpha: 0.7))
                              .toList(),
                        )
                      : LinearGradient(colors: MinimalColors.primaryGradient(context)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !_isLoading
                      ? [
                          BoxShadow(
                            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            key: ValueKey('text'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Crear Actividad',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : _closeModal,
                style: TextButton.styleFrom(
                  foregroundColor: MinimalColors.textSecondary(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: MinimalColors.textSecondary(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar Hora',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedHour,
                      ),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedHour = index);
                      },
                      children: List.generate(24, (index) {
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: MinimalColors.textPrimary(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      color: MinimalColors.textPrimary(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Minutes
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedMinute ~/ 15,
                      ),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedMinute = index * 15);
                      },
                      children: [0, 15, 30, 45].map((minute) {
                        return Center(
                          child: Text(
                            minute.toString().padLeft(2, '0'),
                            style: TextStyle(
                              color: MinimalColors.textPrimary(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: MinimalColors.primaryGradient(context)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Center(
                      child: Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: MinimalColors.backgroundCard(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: MinimalColors.textSecondary(context).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Duración Estimada',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _durationOptions.length,
                itemBuilder: (context, index) {
                  final duration = _durationOptions[index];
                  final isSelected = duration == _estimatedDuration;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _estimatedDuration = duration);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: MinimalColors.primaryGradient(context))
                            : null,
                        color: !isSelected ? MinimalColors.backgroundSecondary(context) : null,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : Border.all(
                          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${duration}m',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : MinimalColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await widget.provider.addActivity(
        title: _titleController.text.trim(),
        hour: _selectedHour,
        minute: _selectedMinute,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategory,
        estimatedDuration: _estimatedDuration,
      );

      if (success && mounted) {
        // Update planned mood if selected
        if (_plannedMood != null) {
          // Find the created activity and update its mood
          final activities = widget.provider.currentRoadmap?.getActivitiesInHour(_selectedHour) ?? [];
          final newActivity = activities.where((a) => a.title == _titleController.text.trim()).firstOrNull;
          if (newActivity != null) {
            await widget.provider.updateActivityMood(newActivity.id, _plannedMood!, isPlanned: true);
          }
        }

        _closeModal();
      } else {
        _showErrorSnackBar('Error al crear la actividad');
      }
    } catch (e) {
      _showErrorSnackBar('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _closeModal() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}

// Extension for null safety
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}