// lib/presentation/screens/components/modern_design_system.dart

import 'package:flutter/material.dart';

// ============================================================================
// 🎨 COLORES MODERNOS - VERSIÓN COMPLETA Y CORREGIDA
// ============================================================================
class ModernColors {
  // ✅ COLORES PRINCIPALES
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF764ba2);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentYellow = Color(0xFFF59E0B); // ✅ AÑADIDO

  // ✅ BACKGROUNDS
  static const Color darkPrimary = Color(0xFF0a0e27);
  static const Color darkSecondary = Color(0xFF2d1b69);
  static const Color darkAccent = Color(0xFF11998e);
  static const Color surfaceDark = Color(0xFF141B2D);

  // ✅ GLASS Y SURFACES
  static const Color glassPrimary = Color(0x1AFFFFFF);
  static const Color glassSecondary = Color(0x0DFFFFFF);
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color surface = surfaceDark; // ✅ AÑADIDO (alias)
  static const Color onSurface = Colors.white; // ✅ AÑADIDO (alias)

  // ✅ BORDERS
  static const Color borderPrimary = Color(0x33FFFFFF);
  static const Color borderSecondary = Color(0x1AFFFFFF);

  // ✅ TEXT COLORS
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textHint = Color(0x66FFFFFF);

  // ✅ STATUS COLORS
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color primary = accentBlue; // ✅ AÑADIDO (alias)

  // ✅ GRADIENTES PRINCIPALES
  static const List<Color> primaryGradient = [Color(0xFF667eea), Color(0xFF764ba2)];
  static const List<Color> positiveGradient = [Color(0xFF11998e), Color(0xFF38ef7d)];
  static const List<Color> negativeGradient = [Color(0xFFff6b6b), Color(0xFFfeca57)];
  static const List<Color> neutralGradient = [Color(0xFF2c3e50), Color(0xFF3498db)];
  static const List<Color> warningGradient = [Color(0xFFfeca57), Color(0xFFff9f43)];
  static const List<Color> errorGradient = [Color(0xFFff6b6b), Color(0xFFee5253)];

  // ✅ CATEGORÍAS
  static const Map<String, Color> categories = {
    'emocional': Color(0xFF667eea),
    'fisico': Color(0xFF11998e),
    'social': Color(0xFFff6b6b),
    'mental': Color(0xFF4ecdc4),
    'espiritual': Color(0xFF764ba2),
  };
}

// ============================================================================
// ♊️ GRADIENTES GEMINI
// ============================================================================
class GeminiGradients {
  static const List<Color> background = [Color(0xFF131314), Color(0xFF000000)];
  static const List<Color> header = [Color(0xFF4A4E69), Color(0xFF22223B)];
  static const List<Color> card = [Color(0xFF22223B), Color(0xFF131314)];
  static const List<Color> accent = [Color(0xFF8E9BFF), Color(0xFF5A67D8)];
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
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(colors: gradient!)
            : null,
        color: backgroundColor ?? (gradient == null ? ModernColors.glassPrimary : null),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(
          color: ModernColors.borderPrimary,
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
            // FIX: Arreglo completo - usar LinearGradient en lugar de List<Color>
            gradient: widget.isPrimary
                ? LinearGradient(
              colors: widget.gradient ?? ModernColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: widget.isPrimary ? null : ModernColors.glassPrimary,
            borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : ModernColors.borderPrimary,
            ),
            boxShadow: widget.isPrimary ? [
              BoxShadow(
                color: (widget.gradient ?? ModernColors.primaryGradient).first.withOpacity(0.3),
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
                color: ModernColors.textHint,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                widget.prefixIcon,
                color: _isFocused ? ModernColors.primaryGradient.first : ModernColors.textHint,
              )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                onTap: widget.onSuffixTap,
                child: Icon(
                  widget.suffixIcon,
                  color: ModernColors.textHint,
                ),
              )
                  : null,
              filled: true,
              fillColor: ModernColors.glassPrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: BorderSide(
                  color: ModernColors.primaryGradient.first,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
                borderSide: const BorderSide(
                  color: ModernColors.error,
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

class ModernMoodSelector extends StatefulWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodChanged;
  final bool animated;

  const ModernMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
    this.animated = true,
  });

  @override
  State<ModernMoodSelector> createState() => _ModernMoodSelectorState();
}

class _ModernMoodSelectorState extends State<ModernMoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'label': 'Muy mal', 'color': ModernColors.error},
    {'emoji': '😔', 'label': 'Mal', 'color': ModernColors.warning},
    {'emoji': '😐', 'label': 'Regular', 'color': ModernColors.info},
    {'emoji': '🙂', 'label': 'Bien', 'color': ModernColors.success},
    {'emoji': '😊', 'label': 'Muy bien', 'color': ModernColors.accentGreen},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ModernAnimations.medium,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo te sientes hoy?',
            style: ModernTypography.heading3,
          ),
          const SizedBox(height: ModernSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final mood = moods[index];
              final isSelected = widget.selectedMood == index + 1;

              return GestureDetector(
                onTap: () {
                  if (widget.animated) {
                    _controller.forward().then((_) {
                      _controller.reverse();
                    });
                  }
                  widget.onMoodChanged(index + 1);
                },
                child: AnimatedContainer(
                  duration: ModernAnimations.fast,
                  padding: const EdgeInsets.all(ModernSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood['color'].withOpacity(0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? mood['color']
                          : ModernColors.borderPrimary,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: ModernAnimations.fast,
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 24,
                        ),
                        child: Text(mood['emoji']),
                      ),
                      const SizedBox(height: ModernSpacing.xs),
                      Text(
                        mood['label'],
                        style: ModernTypography.bodySmall.copyWith(
                          color: isSelected ? mood['color'] : ModernColors.textHint,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ModernProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final IconData icon;
  final String? trailing;

  const ModernProgressCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.color,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ModernTypography.bodyLarge),
                    Text(subtitle, style: ModernTypography.bodySmall),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: ModernTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: ModernColors.borderSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🌈 TEMA GLOBAL
// ============================================================================

class ModernTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'System',
      scaffoldBackgroundColor: ModernColors.darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF667eea),
        secondary: Color(0xFF11998e),
        surface: Color(0xFF2d1b69),
        error: ModernColors.error,
      ),
      textTheme: const TextTheme(
        displayLarge: ModernTypography.heading1,
        displayMedium: ModernTypography.heading2,
        displaySmall: ModernTypography.heading3,
        bodyLarge: ModernTypography.bodyLarge,
        bodyMedium: ModernTypography.bodyMedium,
        bodySmall: ModernTypography.bodySmall,
        labelLarge: ModernTypography.button,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: ModernSpacing.lg,
            vertical: ModernSpacing.md,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ModernColors.glassPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ModernSpacing.md,
          vertical: ModernSpacing.md,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ModernColors.glassPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
        ),
      ),
    );
  }
}

// ============================================================================
// 🪟 GLASS CARD - Efecto vidrio con blur
// ============================================================================

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double blur;
  final double opacity;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blur = 10,
    this.opacity = 0.1,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: borderRadius ?? BorderRadius.circular(ModernSpacing.radiusLarge),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            offset: const Offset(0, 4),
          ),
        ],
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

// ============================================================================
// 🌈 GRADIENT CARD - Card con fondo gradiente
// ============================================================================

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient = ModernColors.primaryGradient,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius,
    this.boxShadow,
  });

  /// Presets de gradientes comunes
  factory GradientCard.positive({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GradientCard(
      gradient: ModernColors.positiveGradient,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

  factory GradientCard.warning({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GradientCard(
      gradient: ModernColors.warningGradient,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

  factory GradientCard.error({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return GradientCard(
      gradient: ModernColors.errorGradient,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShadow = boxShadow ?? [
      BoxShadow(
        color: gradient.first.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ];

    final container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: gradientBegin,
          end: gradientEnd,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(ModernSpacing.radiusLarge),
        boxShadow: effectiveShadow,
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

// ============================================================================
// 👆 ACTION CARD - Card interactiva con chevron
// ============================================================================

class ActionCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool enableHaptic;
  final List<Color>? gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.enableHaptic = true,
    this.gradient,
    this.padding,
    this.margin,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      // HapticFeedback.lightImpact(); // Descomentar si se importa services
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        onTap: widget.onTap != null ? _handleTap : null,
        child: Container(
          margin: widget.margin,
          padding: widget.padding ?? const EdgeInsets.all(ModernSpacing.md),
          decoration: BoxDecoration(
            gradient: widget.gradient != null
                ? LinearGradient(
                    colors: widget.gradient!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.gradient == null ? ModernColors.glassPrimary : null,
            borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
            border: Border.all(
              color: ModernColors.borderPrimary,
              width: 1,
            ),
            boxShadow: widget.gradient != null
                ? [
                    BoxShadow(
                      color: widget.gradient!.first.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : ModernShadows.glass,
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: ModernSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: ModernTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: ModernTypography.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null)
                widget.trailing!
              else if (widget.showChevron && widget.onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: ModernColors.textSecondary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 📊 STAT CARD - Card para métricas y estadísticas
// ============================================================================

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final List<Color>? gradient;
  final String? trend;
  final bool trendPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.gradient,
    this.trend,
    this.trendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? ModernColors.primaryGradient.first;
    final effectiveGradient = gradient ?? [effectiveColor, effectiveColor.withOpacity(0.7)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ModernSpacing.md),
        decoration: BoxDecoration(
          color: ModernColors.glassPrimary,
          borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
          border: Border.all(color: ModernColors.borderSecondary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: effectiveGradient),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (trendPositive ? ModernColors.success : ModernColors.error)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendPositive ? Icons.trending_up : Icons.trending_down,
                          color: trendPositive ? ModernColors.success : ModernColors.error,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend!,
                          style: ModernTypography.bodySmall.copyWith(
                            color: trendPositive ? ModernColors.success : ModernColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: ModernTypography.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: ModernTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}