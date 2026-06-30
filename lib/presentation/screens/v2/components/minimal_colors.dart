// ============================================================================
// minimal_colors.dart - PROXY to unified AppColors
// DEPRECATED: Use AppColors via Theme.of(context).extension<AppColors>()
// ============================================================================

import 'package:flutter/material.dart';
import 'package:untitled3/core/themes/app_theme.dart';

class MinimalColors {
  // Backgrounds
  static Color backgroundPrimary(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.primaryBg;

  static Color backgroundCard(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.surface;

  static Color backgroundSecondary(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.secondaryBg;

  // Textos
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.textPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.textSecondary;

  static Color textTertiary(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.textSecondary;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.textHint;

  // Estados semánticos (theme-aware)
  static Color positiveMain(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.positiveMain;

  static Color negativeMain(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.negativeMain;

  static Color warningMain(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.warningMain;

  static Color infoMain(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.infoMain;

  // Sombras
  static Color shadow(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.textHint.withValues(alpha: 0.4);

  static Color gradientShadow(BuildContext context, {double alpha = 0.2}) =>
      Theme.of(context).extension<AppColors>()!.textHint.withValues(alpha: alpha);

  static Color coloredShadow(BuildContext context, Color baseColor, {double alpha = 0.2}) =>
      baseColor.withValues(alpha: alpha);

  // Gradientes
  static List<Color> primaryGradient(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.gradientHeader;

  static List<Color> accentGradient(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.gradientHeader;

  static List<Color> lightGradient(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!.gradientHeader;

  static List<Color> positiveGradient(BuildContext context) => [
        Theme.of(context).extension<AppColors>()!.positiveMain,
        const Color(0xFF34d399),
      ];

  static List<Color> neutralGradient(BuildContext context) => [
        Theme.of(context).extension<AppColors>()!.warningMain,
        const Color(0xFFfbbf24),
      ];

  static List<Color> negativeGradient(BuildContext context) => [
        Theme.of(context).extension<AppColors>()!.negativeMain,
        const Color(0xFFfca5a5),
      ];

  // Estáticos - paleta morado-azul
  static Color get background => const Color(0xFF080B18);
  static Color get surface => const Color(0xFF0F1528);
  static Color get surfaceVariant => const Color(0xFF1A2240);
  static Color get border => const Color(0xFF2D3A6B);

  static Color get primary => const Color(0xFF7C3AED);
  static Color get accent => const Color(0xFF4F46E5);
  static Color get secondary => const Color(0xFF3B82F6);

  static Color get textPrimaryStatic => const Color(0xFFE8EAF0);
  static Color get textSecondaryStatic => const Color(0xFFB3B8C8);
  static Color get textTertiaryStatic => const Color(0xFFB3B8C8);
  static Color get textMutedStatic => const Color(0xFF8691A8);

  static Color get success => const Color(0xFF10B981);
  static Color get warning => const Color(0xFFF59E0B);
  static Color get error => const Color(0xFFEF4444);
  static Color get info => const Color(0xFF7C3AED);

  static Color get shadowStatic => const Color(0x4D3B0FBF);

  static Color get backgroundPrimaryStatic => background;
  static Color get backgroundCardStatic => surface;
  static Color get backgroundSecondaryStatic => surfaceVariant;

  static List<Color> get primaryGradientStatic => const [
        Color(0xFF7C3AED),
        Color(0xFF2563EB),
      ];

  static List<Color> get accentGradientStatic => const [
        Color(0xFF6D28D9),
        Color(0xFF4F46E5),
      ];

  static List<Color> get lightGradientStatic => const [
        Color(0xFFA78BFA),
        Color(0xFF60A5FA),
      ];

  static List<Color> get positiveGradientStatic => const [
        Color(0xFF10B981),
        Color(0xFF34d399),
      ];

  static List<Color> get neutralGradientStatic => const [
        Color(0xFFf59e0b),
        Color(0xFFfbbf24),
      ];

  static List<Color> get negativeGradientStatic => const [
        Color(0xFFEF4444),
        Color(0xFFfca5a5),
      ];

  // Métodos de utilidad
  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);

  static List<Color> gradientWithOpacity(List<Color> gradient, double opacity) =>
      gradient.map((color) => color.withValues(alpha: opacity)).toList();
}
