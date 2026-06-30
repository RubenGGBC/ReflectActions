// ============================================================================
// core/themes/app_theme.dart
// ============================================================================

import 'package:flutter/material.dart';

enum AppThemeType {
  deepOcean,
  electricDark,
  springLight,
  sunsetWarm,
}

class AppColors extends ThemeExtension<AppColors> {
  // Colores base
  final Color primaryBg;
  final Color secondaryBg;
  final Color surface;
  final Color surfaceVariant;

  // Acentos
  final Color accentPrimary;
  final Color accentSecondary;

  // Textos
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Estados
  final Color positiveMain;
  final Color positiveLight;
  final Color positiveGlow;
  final Color negativeMain;
  final Color negativeLight;
  final Color negativeGlow;
  final Color warningMain;
  final Color infoMain;

  // Efectos
  final Color shadowColor;
  final Color borderColor;
  final Color glassBg;

  // Gradientes
  final List<Color> gradientHeader;
  final List<Color> gradientButton;

  // Categorías
  final Map<String, Color> categories;

  // Metadatos
  final String name;
  final String displayName;
  final String icon;
  final String description;
  final bool isDark;

  const AppColors({
    required this.primaryBg,
    required this.secondaryBg,
    required this.surface,
    required this.surfaceVariant,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.positiveMain,
    required this.positiveLight,
    required this.positiveGlow,
    required this.negativeMain,
    required this.negativeLight,
    required this.negativeGlow,
    required this.warningMain,
    required this.infoMain,
    required this.shadowColor,
    required this.borderColor,
    required this.glassBg,
    required this.gradientHeader,
    required this.gradientButton,
    required this.categories,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.description,
    required this.isDark,
  });

  @override
  AppColors copyWith({
    Color? primaryBg,
    Color? secondaryBg,
    Color? surface,
    Color? surfaceVariant,
    Color? accentPrimary,
    Color? accentSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? positiveMain,
    Color? positiveLight,
    Color? positiveGlow,
    Color? negativeMain,
    Color? negativeLight,
    Color? negativeGlow,
    Color? warningMain,
    Color? infoMain,
    Color? shadowColor,
    Color? borderColor,
    Color? glassBg,
    List<Color>? gradientHeader,
    List<Color>? gradientButton,
    Map<String, Color>? categories,
    String? name,
    String? displayName,
    String? icon,
    String? description,
    bool? isDark,
  }) {
    return AppColors(
      primaryBg: primaryBg ?? this.primaryBg,
      secondaryBg: secondaryBg ?? this.secondaryBg,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      positiveMain: positiveMain ?? this.positiveMain,
      positiveLight: positiveLight ?? this.positiveLight,
      positiveGlow: positiveGlow ?? this.positiveGlow,
      negativeMain: negativeMain ?? this.negativeMain,
      negativeLight: negativeLight ?? this.negativeLight,
      negativeGlow: negativeGlow ?? this.negativeGlow,
      warningMain: warningMain ?? this.warningMain,
      infoMain: infoMain ?? this.infoMain,
      shadowColor: shadowColor ?? this.shadowColor,
      borderColor: borderColor ?? this.borderColor,
      glassBg: glassBg ?? this.glassBg,
      gradientHeader: gradientHeader ?? this.gradientHeader,
      gradientButton: gradientButton ?? this.gradientButton,
      categories: categories ?? this.categories,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryBg: Color.lerp(primaryBg, other.primaryBg, t)!,
      secondaryBg: Color.lerp(secondaryBg, other.secondaryBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      positiveMain: Color.lerp(positiveMain, other.positiveMain, t)!,
      positiveLight: Color.lerp(positiveLight, other.positiveLight, t)!,
      positiveGlow: Color.lerp(positiveGlow, other.positiveGlow, t)!,
      negativeMain: Color.lerp(negativeMain, other.negativeMain, t)!,
      negativeLight: Color.lerp(negativeLight, other.negativeLight, t)!,
      negativeGlow: Color.lerp(negativeGlow, other.negativeGlow, t)!,
      warningMain: Color.lerp(warningMain, other.warningMain, t)!,
      infoMain: Color.lerp(infoMain, other.infoMain, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      gradientHeader: gradientHeader,
      gradientButton: gradientButton,
      categories: categories,
      name: name,
      displayName: displayName,
      icon: icon,
      description: description,
      isDark: isDark,
    );
  }
}

// ============================================================================
// core/themes/theme_definitions.dart
// ============================================================================

class ThemeDefinitions {
  static const AppColors deepOcean = AppColors(
    // Metadatos
    name: "deep_ocean",
    displayName: "🌊 Deep Ocean",
    icon: "🌊",
    description: "Tranquilo y minimalista",
    isDark: true,

    // Fondos
    primaryBg: Color(0xFF080B18),
    secondaryBg: Color(0xFF0F1528),
    surface: Color(0xFF0F1528),
    surfaceVariant: Color(0xFF1A2240),

    // Acentos morado-azul
    accentPrimary: Color(0xFF7C3AED),
    accentSecondary: Color(0xFF3B82F6),

    // Textos
    textPrimary: Color(0xFFE8EAF0),
    textSecondary: Color(0xFFB3B8C8),
    textHint: Color(0xFF8691A8),

    // Estados
    positiveMain: Color(0xFF10B981),
    positiveLight: Color(0x3310B981),
    positiveGlow: Color(0x6610B981),
    negativeMain: Color(0xFFEF4444),
    negativeLight: Color(0x33EF4444),
    negativeGlow: Color(0x66EF4444),
    warningMain: Color(0xFFF59E0B),
    infoMain: Color(0xFF7C3AED),

    // Efectos
    shadowColor: Color(0x4D7C3AED),
    borderColor: Color(0xFF4F46E5),
    glassBg: Color(0x337C3AED),

    // Gradientes morado → azul
    gradientHeader: [Color(0xFF7C3AED), Color(0xFF2563EB)],
    gradientButton: [Color(0xFF6D28D9), Color(0xFF1D4ED8)],

    // Categorías
    categories: {
      'emocional': Color(0xFF9333EA),
      'fisico': Color(0xFF3B82F6),
      'social': Color(0xFF8B5CF6),
      'mental': Color(0xFF60A5FA),
      'espiritual': Color(0xFF6D28D9),
    },
  );

  static const AppColors electricDark = AppColors(
    // Metadatos
    name: "electric_dark",
    displayName: "⚡ Electric Dark",
    icon: "⚡",
    description: "Futurista y moderno",
    isDark: true,

    // Fondos oscuros
    primaryBg: Color(0xFF060810),
    secondaryBg: Color(0xFF0E1225),
    surface: Color(0xFF0E1225),
    surfaceVariant: Color(0xFF182040),

    // Acentos morado-azul vibrante
    accentPrimary: Color(0xFF8B5CF6),
    accentSecondary: Color(0xFF2563EB),

    // Textos brillantes
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF94A3B8),

    // Estados
    positiveMain: Color(0xFF10B981),
    positiveLight: Color(0x3310B981),
    positiveGlow: Color(0x6610B981),
    negativeMain: Color(0xFFEF4444),
    negativeLight: Color(0x33EF4444),
    negativeGlow: Color(0x66EF4444),
    warningMain: Color(0xFFF59E0B),
    infoMain: Color(0xFF8B5CF6),

    // Efectos neón morado-azul
    shadowColor: Color(0x4D8B5CF6),
    borderColor: Color(0xFF5B21B6),
    glassBg: Color(0x338B5CF6),

    // Gradientes morado → azul eléctrico
    gradientHeader: [Color(0xFF8B5CF6), Color(0xFF2563EB)],
    gradientButton: [Color(0xFF7C3AED), Color(0xFF1D4ED8)],

    // Categorías
    categories: {
      'emocional': Color(0xFFA78BFA),
      'fisico': Color(0xFF60A5FA),
      'social': Color(0xFF8B5CF6),
      'mental': Color(0xFF93C5FD),
      'espiritual': Color(0xFF6D28D9),
    },
  );

  static const AppColors springLight = AppColors(
    // Metadatos
    name: "spring_light",
    displayName: "🌸 Spring Light",
    icon: "🌸",
    description: "Fresco y luminoso",
    isDark: false,

    // Fondos claros con tinte suave
    primaryBg: Color(0xFFF5F3FF),
    secondaryBg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEDE9FE),

    // Acentos morado-azul
    accentPrimary: Color(0xFF7C3AED),
    accentSecondary: Color(0xFF3B82F6),

    // Textos oscuros para contraste
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF4338CA),
    textHint: Color(0xFF9CA3AF),

    // Estados
    positiveMain: Color(0xFF059669),
    positiveLight: Color(0xFFECFDF5),
    positiveGlow: Color(0xFFA7F3D0),
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    negativeGlow: Color(0xFFFECACA),
    warningMain: Color(0xFFF59E0B),
    infoMain: Color(0xFF7C3AED),

    // Efectos suaves morado
    shadowColor: Color(0x337C3AED),
    borderColor: Color(0xFFDDD6FE),
    glassBg: Color(0x1A7C3AED),

    // Gradientes morado → azul claro
    gradientHeader: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
    gradientButton: [Color(0xFF6D28D9), Color(0xFF2563EB)],

    // Categorías
    categories: {
      'emocional': Color(0xFF7C3AED),
      'fisico': Color(0xFF2563EB),
      'social': Color(0xFF8B5CF6),
      'mental': Color(0xFF3B82F6),
      'espiritual': Color(0xFF5B21B6),
    },
  );

  static const AppColors sunsetWarm = AppColors(
    // Metadatos
    name: "sunset_warm",
    displayName: "🌅 Sunset Warm",
    icon: "🌅",
    description: "Profundo y sereno",
    isDark: false,

    // Fondos con tinte azulado suave
    primaryBg: Color(0xFFEFF6FF),
    secondaryBg: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFDBEAFE),

    // Acentos morado-azul
    accentPrimary: Color(0xFF4F46E5),
    accentSecondary: Color(0xFF7C3AED),

    // Textos oscuros para contraste
    textPrimary: Color(0xFF1E1B4B),
    textSecondary: Color(0xFF312E81),
    textHint: Color(0xFF9CA3AF),

    // Estados
    positiveMain: Color(0xFF059669),
    positiveLight: Color(0xFFF0FDF4),
    positiveGlow: Color(0xFFBBF7D0),
    negativeMain: Color(0xFFDC2626),
    negativeLight: Color(0xFFFEF2F2),
    negativeGlow: Color(0xFFFECACA),
    warningMain: Color(0xFFF59E0B),
    infoMain: Color(0xFF4F46E5),

    // Efectos azul-morado
    shadowColor: Color(0x334F46E5),
    borderColor: Color(0xFFBFDBFE),
    glassBg: Color(0x1A4F46E5),

    // Gradientes azul → morado
    gradientHeader: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    gradientButton: [Color(0xFF3730A3), Color(0xFF6D28D9)],

    // Categorías
    categories: {
      'emocional': Color(0xFF4F46E5),
      'fisico': Color(0xFF2563EB),
      'social': Color(0xFF7C3AED),
      'mental': Color(0xFF60A5FA),
      'espiritual': Color(0xFF5B21B6),
    },
  );

  static Map<AppThemeType, AppColors> get themes => {
    AppThemeType.deepOcean: deepOcean,
    AppThemeType.electricDark: electricDark,
    AppThemeType.springLight: springLight,
    AppThemeType.sunsetWarm: sunsetWarm,
  };
}

// ============================================================================
// core/themes/app_theme_data.dart
// ============================================================================

class AppThemeData {
  static ThemeData buildTheme(AppColors appColors) {
    return ThemeData(
      useMaterial3: true,
      brightness: appColors.isDark ? Brightness.dark : Brightness.light,

      // Esquema de colores principal
      colorScheme: ColorScheme(
        brightness: appColors.isDark ? Brightness.dark : Brightness.light,
        primary: appColors.accentPrimary,
        onPrimary: Colors.white,
        secondary: appColors.accentSecondary,
        onSecondary: Colors.white,
        tertiary: appColors.positiveMain,
        onTertiary: Colors.white,
        error: appColors.negativeMain,
        onError: Colors.white,
        surface: appColors.surface,
        onSurface: appColors.textPrimary,
        surfaceContainerHighest: appColors.surfaceVariant,
        onSurfaceVariant: appColors.textSecondary,
        outline: appColors.borderColor,
        outlineVariant: appColors.borderColor.withValues(alpha: 0.5),
        shadow: appColors.shadowColor,
        scrim: Colors.black54,
        inverseSurface: appColors.textPrimary,
        onInverseSurface: appColors.primaryBg,
        inversePrimary: appColors.accentSecondary,
      ),

      // Tipografía personalizada
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: appColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: appColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: appColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: appColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: appColors.textHint,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: appColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: appColors.textHint,
        ),
      ),

      // AppBar personalizada
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.accentPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Botones personalizados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.accentPrimary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: appColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: appColors.accentPrimary,
          side: BorderSide(color: appColors.accentPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColors.accentPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Cards y contenedores
      cardTheme: CardThemeData(
        color: appColors.surface,
        shadowColor: appColors.shadowColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.accentPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appColors.negativeMain),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: appColors.textHint),
        labelStyle: TextStyle(color: appColors.textSecondary),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appColors.surface,
        selectedItemColor: appColors.accentPrimary,
        unselectedItemColor: appColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: appColors.accentPrimary,
        inactiveTrackColor: appColors.borderColor,
        thumbColor: appColors.accentPrimary,
        overlayColor: appColors.accentPrimary.withValues(alpha: 0.2),
        trackHeight: 4,
      ),

      // Checkbox y Switch
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: appColors.borderColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary;
          }
          return appColors.borderColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return appColors.accentPrimary.withValues(alpha: 0.5);
          }
          return appColors.borderColor.withValues(alpha: 0.3);
        }),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors.surface,
        contentTextStyle: TextStyle(color: appColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Extensiones de tema personalizadas
      extensions: <ThemeExtension<dynamic>>[appColors],
    );
  }
}