// lib/presentation/screens/components/modern_design_system.dart

import 'package:flutter/material.dart';
import 'package:untitled3/core/themes/app_theme.dart';

/// Colores modernos para las pantallas de analytics
/// DEPRECATED: Usa AppColors via Theme.of(context).extension<AppColors>()
class ModernColors {
  // --------------------------------------------------------------------------
  // Colores de gráficos (específicos de analytics, se mantienen estáticos)
  // --------------------------------------------------------------------------
  static const Color accentPurple = Color(0xFF9333EA);
  static const Color accentViolet = Color(0xFF6C63FF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentYellow = Color(0xFFFFD600);

  static const List<Color> chartColors = [
    accentPurple,
    accentViolet,
    accentOrange,
    accentGreen,
    accentYellow,
  ];

  // --------------------------------------------------------------------------
  // Colores semánticos - alineados con AppColors (deepOcean) para unificación
  // --------------------------------------------------------------------------
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFFA78BFA);

  // --------------------------------------------------------------------------
  // Gradientes principales (mantenidos estáticos para compatibilidad)
  // --------------------------------------------------------------------------
  static const List<Color> primaryGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF764ba2),
  ];
  static const List<Color> positiveGradient = [
    Color(0xFF11998e),
    Color(0xFF38ef7d),
  ];
  static const List<Color> negativeGradient = [
    Color(0xFFff6b6b),
    Color(0xFFfeca57),
  ];

  static const Color borderSecondary = Color(0x33FFFFFF);
  static const Color divider = Color(0x1AFFFFFF);
  static const Color shimmerBase = Color(0xFF1E293B);
  static const Color shimmerHighlight = Color(0xFF334155);

  // --------------------------------------------------------------------------
  // Colores de texto (mantenidos estáticos para compatibilidad con const)
  // --------------------------------------------------------------------------
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textHint = Color(0x66FFFFFF);

  // --------------------------------------------------------------------------
  // Backgrounds y surfaces (mantenidos estáticos para compatibilidad)
  // --------------------------------------------------------------------------
  static const Color darkPrimary = Color(0xFF0a0e27);
  static const Color darkSecondary = Color(0xFF2d1b69);
  static const Color surfaceDark = Color(0xFF141B2D);

  // --------------------------------------------------------------------------
  // Glass y bordes (mantenidos estáticos para compatibilidad)
  // --------------------------------------------------------------------------
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassSecondary = Color(0x0DFFFFFF);
  static const Color borderPrimary = Color(0x33FFFFFF);

  // --------------------------------------------------------------------------
  // Gradientes adicionales
  // --------------------------------------------------------------------------
  static const List<Color> neutralGradient = [
    Color(0xFF2c3e50),
    Color(0xFF9B59B6),
  ];
  static const List<Color> warningGradient = [
    Color(0xFFfeca57),
    Color(0xFFff9f43),
  ];
  static const List<Color> errorGradient = [
    Color(0xFFff6b6b),
    Color(0xFFee5253),
  ];

  // --------------------------------------------------------------------------
  // Categorías
  // --------------------------------------------------------------------------
  static const Map<String, Color> categories = {
    'emocional': Color(0xFF8B5CF6),
    'fisico': Color(0xFF11998e),
    'social': Color(0xFFff6b6b),
    'mental': Color(0xFF4ecdc4),
    'espiritual': Color(0xFF764ba2),
  };

}

// ============================================================================
// 📏 SPACING Y RADIOS
// ============================================================================
class ModernSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 25.0;
}

// ============================================================================
// 🎭 SOMBRAS MODERNAS
// ============================================================================
class ModernShadows {
  static const List<BoxShadow> glass = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 5)),
  ];
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x33000000), blurRadius: 25, offset: Offset(0, 15)),
  ];
  static const List<BoxShadow> inner = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2), spreadRadius: -2),
  ];
}

// ============================================================================
// 📝 TIPOGRAFÍA MODERNA - CORREGIDA Y EXPANDIDA
// ============================================================================
class ModernTypography {
  static const TextStyle heading1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ModernColors.textPrimary, height: 1.2);
  static const TextStyle heading2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: ModernColors.textPrimary, height: 1.3);
  static const TextStyle heading3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: ModernColors.textPrimary, height: 1.4);
  static const TextStyle heading4 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ModernColors.textPrimary, height: 1.4);

  // ✅ AÑADIDOS PARA COMPATIBILIDAD
  static const TextStyle headlineLarge = heading1;
  static const TextStyle headlineMedium = heading2;
  static const TextStyle headlineSmall = heading3;
  static const TextStyle titleMedium = heading4;
  static const TextStyle labelMedium = bodyMedium;


  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ModernColors.textPrimary, height: 1.5);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ModernColors.textSecondary, height: 1.4);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: ModernColors.textHint, height: 1.3);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ModernColors.textPrimary);
  static const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: ModernColors.textSecondary);
}
// ============================================================================
// 🎬 ANIMACIONES COMPLETAS
// ============================================================================

class ModernAnimations {
  // ✅ DURACIONES
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration ultraSlow = Duration(milliseconds: 800);

  // ✅ CURVAS
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve smoothOut = Curves.easeOutCubic;
  static const Curve smoothIn = Curves.easeInCubic;
  static const Curve spring = Curves.elasticOut;

  // ✅ TRANSICIONES PREDEFINIDAS
  static SlideTransition slideFromBottom(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: smoothOut)),
      child: child,
    );
  }

  static SlideTransition slideFromRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: smoothOut)),
      child: child,
    );
  }

  static FadeTransition fadeIn(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: easeInOut),
      child: child,
    );
  }
}

// ============================================================================
// 🎭 COMPONENTES MODERNOS REUTILIZABLES
// ============================================================================

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<Color>? gradient;
  final bool blur;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.gradient,
    this.blur = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(colors: gradient!)
            : null,
        color: backgroundColor ?? (gradient == null ? appColors.glassBg : null),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(
          color: appColors.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: blur ? ModernShadows.glass : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final List<Color>? gradient;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.width,
    this.padding,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ModernAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: ModernAnimations.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final defaultGradient = appColors.gradientHeader;
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width,
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: ModernSpacing.lg,
            vertical: ModernSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
              colors: widget.gradient ?? defaultGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: widget.isPrimary ? null : appColors.glassBg,
            borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : appColors.borderColor.withValues(alpha: 0.2),
            ),
            boxShadow: widget.isPrimary ? [
              BoxShadow(
                color: (widget.gradient ?? defaultGradient).first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ] else ...[
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                ],
                Text(
                  widget.text,
                  style: ModernTypography.button,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ModernTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  const ModernTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: ModernTypography.bodyMedium,
          ),
          const SizedBox(height: ModernSpacing.sm),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            style: ModernTypography.bodyLarge,
            decoration: InputDecoration(
              counterText: "",
              hintText: widget.hintText,
              hintStyle: ModernTypography.bodyMedium.copyWith(
                color: appColors.textHint,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                color: _isFocused ? appColors.gradientHeader.first : appColors.textHint,
              )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                onTap: widget.onSuffixTap,
                child: Icon(
                  widget.suffixIcon,
                  color: appColors.textHint,
                ),
              )
                  : null,
              filled: true,
              fillColor: appColors.glassBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide(
                  color: appColors.gradientHeader.first,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide(
                  color: appColors.negativeMain,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ModernSpacing.md,
                vertical: ModernSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
