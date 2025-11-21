// ============================================================================
// edit_activity_modal.dart - MODAL PARA EDITAR ACTIVIDADES DEL ROADMAP
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Models and providers
import '../../../../data/models/roadmap_activity_model.dart';
import '../../../providers/daily_roadmap_provider.dart';
import '../../../providers/theme_provider.dart';

class EditActivityModal extends StatefulWidget {
  final DailyRoadmapProvider provider;
  final RoadmapActivityModel activity;

  const EditActivityModal({
    super.key,
    required this.provider,
    required this.activity,
  });

  @override
  State<EditActivityModal> createState() => _EditActivityModalState();
}

class _EditActivityModalState extends State<EditActivityModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _feelingsController = TextEditingController();
  
  int _selectedHour = 0;
  int _selectedMinute = 0;
  String _selectedCategory = '';
  int? _estimatedDuration;
  bool _isCompleted = false;

  final List<String> _categories = [
    'Trabajo',
    'Personal',
    'Salud',
    'Ejercicio',
    'Estudio',
    'Descanso',
    'Social',
    'Comida',
    'Transporte',
    'Entretenimiento',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeFields();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _feelingsController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _initializeFields() {
    _titleController.text = widget.activity.title;
    _descriptionController.text = widget.activity.description ?? '';
    _notesController.text = widget.activity.notes ?? '';
    _feelingsController.text = widget.activity.feelingsNotes ?? '';
    
    _selectedHour = widget.activity.hour;
    _selectedMinute = widget.activity.minute;
    _selectedCategory = widget.activity.category ?? _categories.first;
    _estimatedDuration = widget.activity.estimatedDuration;
    _isCompleted = widget.activity.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHandle(theme),
                  _buildHeader(theme),
                  Expanded(
                    child: _buildForm(theme),
                  ),
                  _buildActions(theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle(ThemeProvider theme) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: theme.borderColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradientHeader,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit,
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
                  'Editar Actividad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Modifica los detalles de tu actividad',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ThemeProvider theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Título de la actividad',
            hint: 'Ej: Reunión con el equipo',
            icon: Icons.title,
            theme: theme,
            required: true,
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _descriptionController,
            label: 'Descripción',
            hint: 'Describe brevemente la actividad...',
            icon: Icons.description,
            theme: theme,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDurationField(theme),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildCategorySelector(theme),
          const SizedBox(height: 20),
          
          _buildCompletionToggle(theme),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _notesController,
            label: 'Notas adicionales',
            hint: 'Agrega cualquier información relevante...',
            icon: Icons.note,
            theme: theme,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _feelingsController,
            label: 'Sentimientos/Estado de ánimo',
            hint: 'Cómo te sentiste durante esta actividad...',
            icon: Icons.mood,
            theme: theme,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeProvider theme,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.accentPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: theme.negativeMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            filled: true,
            fillColor: theme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.accentPrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 20, color: theme.accentPrimary),
            const SizedBox(width: 8),
            Text(
              'Hora',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: theme.negativeMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTimePicker(theme),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationField(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timer, size: 20, color: theme.accentPrimary),
            const SizedBox(width: 8),
            Text(
              'Duración (min)',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _estimatedDuration?.toString() ?? '',
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 16,
          ),
          onChanged: (value) {
            _estimatedDuration = int.tryParse(value);
          },
          decoration: InputDecoration(
            hintText: 'Ej: 60',
            hintStyle: TextStyle(
              color: theme.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            filled: true,
            fillColor: theme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.accentPrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, size: 20, color: theme.accentPrimary),
            const SizedBox(width: 8),
            Text(
              'Categoría',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
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
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: theme.gradientHeader)
                      : null,
                  color: !isSelected ? theme.surfaceVariant : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : theme.borderColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.textPrimary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompletionToggle(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: _isCompleted ? theme.positiveMain : theme.accentPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado de la actividad',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isCompleted ? 'Completada' : 'Pendiente',
                  style: TextStyle(
                    color: _isCompleted ? theme.positiveMain : theme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCompleted,
            onChanged: (value) {
              setState(() {
                _isCompleted = value;
              });
              HapticFeedback.lightImpact();
            },
            activeColor: theme.positiveMain,
            inactiveThumbColor: theme.textSecondary,
            inactiveTrackColor: theme.borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          top: BorderSide(
            color: theme.borderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showDeleteDialog(theme),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.negativeMain,
                side: BorderSide(color: theme.negativeMain, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Eliminar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accentPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 16,
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

  void _showTimePicker(ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: theme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Seleccionar hora',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Hours
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index > 23) return null;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                        childCount: 24,
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Minutes
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index * 15;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          if (index < 0 || index > 3) return null;
                          final minute = index * 15;
                          return Center(
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                        childCount: 4,
                      ),
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
                    backgroundColor: theme.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Eliminar actividad',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar esta actividad? Esta acción no se puede deshacer.',
          style: TextStyle(
            color: theme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteActivity();
            },
            child: Text(
              'Eliminar',
              style: TextStyle(color: theme.negativeMain),
            ),
          ),
        ],
      ),
    );
  }

  void _saveActivity() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Por favor ingresa un título para la actividad', isError: true);
      return;
    }

    try {
      final updatedActivity = widget.activity.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        hour: _selectedHour,
        minute: _selectedMinute,
        category: _selectedCategory,
        estimatedDuration: _estimatedDuration,
        isCompleted: _isCompleted,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        feelingsNotes: _feelingsController.text.trim().isEmpty 
            ? null 
            : _feelingsController.text.trim(),
      );

      await widget.provider.updateActivity(updatedActivity);
      
      if (mounted) {
        _showSnackBar('Actividad actualizada correctamente');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error al actualizar la actividad: $e', isError: true);
    }
  }

  void _deleteActivity() async {
    try {
      await widget.provider.removeActivity(widget.activity.id);
      
      if (mounted) {
        _showSnackBar('Actividad eliminada correctamente');
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error al eliminar la actividad: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}