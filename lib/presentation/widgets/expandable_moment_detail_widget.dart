// lib/presentation/widgets/expandable_moment_detail_widget.dart
// ============================================================================
// EXPANDABLE MOMENT DETAIL WIDGET - Enhanced photo display with glowing borders
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/optimized_models.dart';

class ExpandableMomentDetailWidget extends StatefulWidget {
  final String imagePath;
  final OptimizedInteractiveMomentModel moment;
  final VoidCallback? onClose;

  const ExpandableMomentDetailWidget({
    super.key,
    required this.imagePath,
    required this.moment,
    this.onClose,
  });

  @override
  State<ExpandableMomentDetailWidget> createState() => _ExpandableMomentDetailWidgetState();
}

class _ExpandableMomentDetailWidgetState extends State<ExpandableMomentDetailWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Set system UI for full screen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _fadeController.forward();
    _scaleController.forward();
    _glowController.repeat(reverse: true);
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _transformationController.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _fadeController.reverse();
    await _scaleController.reverse();
    if (mounted) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main photo display with zoom functionality and glowing border
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation, _glowAnimation]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        // Glowing border effect based on moment type
                        boxShadow: [
                          BoxShadow(
                            color: _getMomentGlowColor(widget.moment.type)
                                .withValues(alpha: _glowAnimation.value * 0.8),
                            blurRadius: 30,
                            spreadRadius: 8,
                            offset: Offset.zero,
                          ),
                          BoxShadow(
                            color: _getMomentGlowColor(widget.moment.type)
                                .withValues(alpha: _glowAnimation.value * 0.6),
                            blurRadius: 60,
                            spreadRadius: 15,
                            offset: Offset.zero,
                          ),
                          BoxShadow(
                            color: _getMomentGlowColor(widget.moment.type)
                                .withValues(alpha: _glowAnimation.value * 0.4),
                            blurRadius: 90,
                            spreadRadius: 25,
                            offset: Offset.zero,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getMomentGlowColor(widget.moment.type)
                                .withValues(alpha: _glowAnimation.value),
                            width: 3,
                          ),
                        ),
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top overlay with close button and moment info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 24,
                      right: 24,
                      bottom: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // Close button with glow effect
                        GestureDetector(
                          onTap: _handleClose,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: _getMomentGlowColor(widget.moment.type)
                                        .withValues(alpha: _glowAnimation.value * 0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getMomentGlowColor(widget.moment.type)
                                          .withValues(alpha: _glowAnimation.value * 0.3),
                                      blurRadius: 10,
                                      offset: Offset.zero,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Moment info with enhanced styling
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _getMomentTypeGradient(widget.moment.type),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _getMomentGlowColor(widget.moment.type)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.moment.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDateTime(widget.moment.createdAt),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          margin: const EdgeInsets.only(top: 4),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: _getMomentTypeGradient(widget.moment.type),
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _getMomentTypeLabel(widget.moment.type),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom overlay with enhanced moment details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full moment text if available with glowing border
                        if (widget.moment.text.isNotEmpty)
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getMomentGlowColor(widget.moment.type)
                                        .withValues(alpha: _glowAnimation.value * 0.6),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getMomentGlowColor(widget.moment.type)
                                          .withValues(alpha: _glowAnimation.value * 0.2),
                                      blurRadius: 15,
                                      offset: Offset.zero,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.moment.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              );
                            },
                          ),

                        if (widget.moment.text.isNotEmpty)
                          const SizedBox(height: 16),

                        // Enhanced moment info row
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getRelativeTime(widget.moment.createdAt),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (widget.moment.intensity > 0) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getIntensityColor(widget.moment.intensity),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Intensidad ${widget.moment.intensity}/10',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tap to close gesture detector
          GestureDetector(
            onTap: _handleClose,
            behavior: HitTestBehavior.translucent,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Color _getMomentGlowColor(String? type) {
    switch (type) {
      case 'positive':
        return const Color(0xFF10B981); // Green glow for positive moments
      case 'negative':
        return const Color(0xFFef4444); // Red glow for negative moments
      default:
        return const Color(0xFFf59e0b); // Orange glow for neutral moments
    }
  }

  List<Color> _getMomentTypeGradient(String? type) {
    switch (type) {
      case 'positive':
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
      case 'negative':
        return [const Color(0xFFb91c1c), const Color(0xFFef4444)];
      default:
        return [const Color(0xFFf59e0b), const Color(0xFFfbbf24)];
    }
  }

  String _getMomentTypeLabel(String? type) {
    switch (type) {
      case 'positive':
        return 'Momento Positivo';
      case 'negative':
        return 'Momento Negativo';
      default:
        return 'Momento Neutral';
    }
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return const Color(0xFF10B981);
    if (intensity <= 6) return const Color(0xFFf59e0b);
    return const Color(0xFFef4444);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final isToday = dateTime.day == now.day && 
                    dateTime.month == now.month && 
                    dateTime.year == now.year;
    
    if (isToday) {
      return 'Hoy, ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}