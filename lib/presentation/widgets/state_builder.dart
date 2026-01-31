// lib/presentation/widgets/state_builder.dart
// Widget unificado para manejar estados de loading, empty, error y contenido

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/components/modern_design_system.dart';

/// Configuración para el estado vacío
class EmptyStateConfig {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Color>? iconGradient;

  const EmptyStateConfig({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconGradient,
  });

  /// Configuraciones predefinidas comunes
  static EmptyStateConfig entries({VoidCallback? onAction}) => EmptyStateConfig(
        icon: Icons.book_outlined,
        title: 'Sin entradas',
        subtitle: 'Comienza registrando tu día',
        actionLabel: 'Crear entrada',
        onAction: onAction,
        iconGradient: ModernColors.primaryGradient,
      );

  static EmptyStateConfig goals({VoidCallback? onAction}) => EmptyStateConfig(
        icon: Icons.flag_outlined,
        title: 'Sin objetivos',
        subtitle: 'Define tus metas para comenzar',
        actionLabel: 'Crear objetivo',
        onAction: onAction,
        iconGradient: ModernColors.positiveGradient,
      );

  static EmptyStateConfig activities({VoidCallback? onAction}) => EmptyStateConfig(
        icon: Icons.check_circle_outline,
        title: 'Sin actividades',
        subtitle: 'Planifica tu día',
        actionLabel: 'Agregar actividad',
        onAction: onAction,
        iconGradient: ModernColors.neutralGradient,
      );

  static EmptyStateConfig analytics() => const EmptyStateConfig(
        icon: Icons.analytics_outlined,
        title: 'Sin datos suficientes',
        subtitle: 'Registra más entradas para ver análisis',
        iconGradient: ModernColors.primaryGradient,
      );

  static EmptyStateConfig search() => const EmptyStateConfig(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle: 'Intenta con otros términos',
      );
}

/// Widget principal para manejar estados de UI
class StateBuilder extends StatefulWidget {
  /// Si está cargando datos
  final bool isLoading;

  /// Si los datos están vacíos
  final bool isEmpty;

  /// Error actual (null si no hay error)
  final String? error;

  /// Configuración del estado vacío
  final EmptyStateConfig? emptyConfig;

  /// Callback para reintentar en caso de error
  final VoidCallback? onRetry;

  /// Builder del contenido cuando hay datos
  final WidgetBuilder builder;

  /// Mensaje de carga personalizado
  final String? loadingMessage;

  /// Si debe animar las transiciones
  final bool animate;

  /// Duración de las animaciones
  final Duration animationDuration;

  const StateBuilder({
    super.key,
    required this.isLoading,
    required this.isEmpty,
    required this.builder,
    this.error,
    this.emptyConfig,
    this.onRetry,
    this.loadingMessage,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<StateBuilder> createState() => _StateBuilderState();
}

class _StateBuilderState extends State<StateBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prioridad: Error > Loading > Empty > Content
    if (widget.error != null) {
      return _buildAnimatedChild(_ErrorState(
        error: widget.error!,
        onRetry: widget.onRetry,
      ));
    }

    if (widget.isLoading) {
      return _LoadingState(message: widget.loadingMessage);
    }

    if (widget.isEmpty) {
      return _buildAnimatedChild(_EmptyState(
        config: widget.emptyConfig ?? const EmptyStateConfig(
          icon: Icons.inbox_outlined,
          title: 'Sin datos',
        ),
      ));
    }

    return _buildAnimatedChild(widget.builder(context));
  }

  Widget _buildAnimatedChild(Widget child) {
    if (!widget.animate) return child;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: child,
      ),
    );
  }
}

/// Estado de carga con indicador animado
class _LoadingState extends StatefulWidget {
  final String? message;

  const _LoadingState({this.message});

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: ModernColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.primaryGradient.first
                          .withOpacity(0.3 + (_pulseController.value * 0.2)),
                      blurRadius: 20 + (_pulseController.value * 10),
                      spreadRadius: _pulseController.value * 5,
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: ModernColors.primaryGradient,
              ).createShader(bounds),
              child: Text(
                widget.message!,
                style: ModernTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Estado vacío con icono, mensaje y CTA opcional
class _EmptyState extends StatelessWidget {
  final EmptyStateConfig config;

  const _EmptyState({required this.config});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con gradiente
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: config.iconGradient ?? ModernColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (config.iconGradient ?? ModernColors.primaryGradient)
                        .first
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                config.icon,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              config.title,
              style: ModernTypography.heading2,
              textAlign: TextAlign.center,
            ),

            // Subtítulo
            if (config.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                config.subtitle!,
                style: ModernTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],

            // Botón de acción
            if (config.actionLabel != null && config.onAction != null) ...[
              const SizedBox(height: 32),
              ModernButton(
                text: config.actionLabel!,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  config.onAction!();
                },
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error con mensaje y botón de reintentar
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de error
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: ModernColors.errorGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ModernColors.error.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              'Algo salió mal',
              style: ModernTypography.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Mensaje de error
            Text(
              error,
              style: ModernTypography.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Botón de reintentar
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ModernButton(
                text: 'Reintentar',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onRetry!();
                },
                icon: Icons.refresh,
                gradient: ModernColors.errorGradient,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget auxiliar para construir con animaciones
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
