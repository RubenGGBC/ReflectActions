// lib/presentation/mixins/animated_screen_mixin.dart
// Mixin para compartir animaciones comunes entre pantallas

import 'package:flutter/material.dart';
import '../screens/components/modern_design_system.dart';

/// Mixin que proporciona animaciones estándar para pantallas
/// 
/// Uso:
/// ```dart
/// class _MyScreenState extends State<MyScreen> 
///     with TickerProviderStateMixin, AnimatedScreenMixin {
///   
///   @override
///   void initState() {
///     super.initState();
///     initAnimations();
///   }
///   
///   @override
///   void dispose() {
///     disposeAnimations();
///     super.dispose();
///   }
/// }
/// ```
mixin AnimatedScreenMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  // ============================================================================
  // CONTROLLERS
  // ============================================================================
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  
  bool _animationsInitialized = false;

  // ============================================================================
  // ANIMATIONS (Getters)
  // ============================================================================
  
  /// Animación de fade in (0.0 -> 1.0)
  Animation<double> get fadeAnimation => CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOut,
  );
  
  /// Animación de slide desde abajo
  Animation<Offset> get slideFromBottomAnimation => Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));
  
  /// Animación de slide desde la derecha
  Animation<Offset> get slideFromRightAnimation => Tween<Offset>(
    begin: const Offset(0.3, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeOutCubic,
  ));
  
  /// Animación de pulso (para destacar elementos)
  Animation<double> get pulseAnimation => Tween<double>(
    begin: 1.0,
    end: 1.05,
  ).animate(CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  ));
  
  /// Animación de shimmer (-1.0 -> 2.0 para efecto de brillo)
  Animation<double> get shimmerAnimation => Tween<double>(
    begin: -1.0,
    end: 2.0,
  ).animate(CurvedAnimation(
    parent: _shimmerController,
    curve: Curves.linear,
  ));
  
  /// Animación de escala para entradas
  Animation<double> get scaleAnimation => Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOutBack,
  ));

  // ============================================================================
  // STAGGERED ANIMATIONS
  // ============================================================================
  
  /// Genera animación escalonada para listas
  /// [index] - índice del elemento
  /// [totalItems] - total de elementos (máx 10 para performance)
  Animation<double> staggeredFadeAnimation(int index, {int totalItems = 10}) {
    final itemsToAnimate = totalItems.clamp(1, 10);
    final start = (index / itemsToAnimate).clamp(0.0, 0.8);
    final end = ((index + 1) / itemsToAnimate).clamp(0.2, 1.0);
    
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }
  
  /// Genera animación de slide escalonada
  Animation<Offset> staggeredSlideAnimation(int index, {int totalItems = 10}) {
    final itemsToAnimate = totalItems.clamp(1, 10);
    final start = (index / itemsToAnimate).clamp(0.0, 0.8);
    final end = ((index + 1) / itemsToAnimate).clamp(0.2, 1.0);
    
    return Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  // ============================================================================
  // LIFECYCLE
  // ============================================================================
  
  /// Inicializa todos los controllers de animación
  /// Llamar en initState() después de super.initState()
  void initAnimations({
    Duration fadeDuration = const Duration(milliseconds: 600),
    Duration slideDuration = const Duration(milliseconds: 800),
    Duration pulseDuration = const Duration(milliseconds: 1500),
    Duration shimmerDuration = const Duration(milliseconds: 2000),
    bool autoStart = true,
    bool repeatPulse = true,
    bool repeatShimmer = true,
  }) {
    _fadeController = AnimationController(
      duration: fadeDuration,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: slideDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: pulseDuration,
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: shimmerDuration,
      vsync: this,
    );
    
    _animationsInitialized = true;
    
    if (autoStart) {
      startEntryAnimations();
    }
    
    if (repeatPulse) {
      _pulseController.repeat(reverse: true);
    }
    
    if (repeatShimmer) {
      _shimmerController.repeat();
    }
  }
  
  /// Inicia las animaciones de entrada (fade + slide)
  void startEntryAnimations() {
    if (!_animationsInitialized) return;
    _fadeController.forward();
    _slideController.forward();
  }
  
  /// Reinicia las animaciones de entrada
  void resetEntryAnimations() {
    if (!_animationsInitialized) return;
    _fadeController.reset();
    _slideController.reset();
  }
  
  /// Reproduce las animaciones de entrada desde el inicio
  void replayEntryAnimations() {
    resetEntryAnimations();
    startEntryAnimations();
  }
  
  /// Dispone todos los controllers
  /// Llamar en dispose() antes de super.dispose()
  void disposeAnimations() {
    if (!_animationsInitialized) return;
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
  }

  // ============================================================================
  // UTILITY WIDGETS
  // ============================================================================
  
  /// Envuelve un widget con animación de fade + slide
  Widget animatedEntry({
    required Widget child,
    bool fromBottom = true,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: fromBottom ? slideFromBottomAnimation : slideFromRightAnimation,
        child: child,
      ),
    );
  }
  
  /// Envuelve un widget con animación escalonada (para listas)
  Widget staggeredEntry({
    required Widget child,
    required int index,
    int totalItems = 10,
  }) {
    return FadeTransition(
      opacity: staggeredFadeAnimation(index, totalItems: totalItems),
      child: SlideTransition(
        position: staggeredSlideAnimation(index, totalItems: totalItems),
        child: child,
      ),
    );
  }
  
  /// Crea un widget con efecto de pulso
  Widget pulsingWidget({required Widget child}) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: child,
    );
  }
  
  /// Builder para lista animada con items escalonados
  Widget buildAnimatedList<I>({
    required List<I> items,
    required Widget Function(BuildContext context, I item, int index) itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return staggeredEntry(
          index: index,
          totalItems: items.length,
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

// ============================================================================
// ANIMATION WRAPPER WIDGETS (Para uso sin mixin)
// ============================================================================

/// Widget que aplica animación de entrada fade + slide
class AnimatedEntryWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool fromBottom;

  const AnimatedEntryWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.fromBottom = true,
  });

  @override
  State<AnimatedEntryWidget> createState() => _AnimatedEntryWidgetState();
}

class _AnimatedEntryWidgetState extends State<AnimatedEntryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.fromBottom ? const Offset(0, 0.2) : const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget que aplica animación escalonada a una lista de children
class StaggeredAnimationList extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: List.generate(widget.children.length, (index) {
        return AnimatedEntryWidget(
          duration: widget.itemDuration,
          delay: widget.staggerDelay * index,
          child: widget.children[index],
        );
      }),
    );
  }
}
