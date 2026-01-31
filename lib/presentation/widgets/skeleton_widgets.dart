// lib/presentation/widgets/skeleton_widgets.dart
// Widgets de skeleton/shimmer para estados de carga

import 'package:flutter/material.dart';
import '../screens/components/modern_design_system.dart';

/// Efecto shimmer base reutilizable
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color>? gradientColors;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.gradientColors,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ?? [
      ModernColors.glassPrimary,
      ModernColors.borderPrimary.withOpacity(0.3),
      ModernColors.glassPrimary,
    ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
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

/// Box rectangular con shimmer
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ModernColors.glassPrimary,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Círculo con shimmer
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ModernColors.glassPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton de una card estándar
class CardSkeleton extends StatelessWidget {
  final double? height;
  final bool showAvatar;
  final int textLines;

  const CardSkeleton({
    super.key,
    this.height,
    this.showAvatar = true,
    this.textLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(ModernSpacing.md),
        decoration: BoxDecoration(
          color: ModernColors.glassPrimary,
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
          border: Border.all(color: ModernColors.borderSecondary),
        ),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ModernColors.glassSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ModernColors.glassSecondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  ...List.generate(textLines - 1, (index) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      height: 12,
                      width: index == textLines - 2 ? 100 : double.infinity,
                      decoration: BoxDecoration(
                        color: ModernColors.glassSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton de una lista de cards
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final bool showAvatar;
  final EdgeInsets? padding;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.showAvatar = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(ModernSpacing.md),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: ModernSpacing.sm),
      itemBuilder: (context, index) {
        return CardSkeleton(
          height: itemHeight,
          showAvatar: showAvatar,
        );
      },
    );
  }
}

/// Skeleton de un gráfico/chart
class ChartSkeleton extends StatelessWidget {
  final double height;
  final ChartSkeletonType type;

  const ChartSkeleton({
    super.key,
    this.height = 200,
    this.type = ChartSkeletonType.bar,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(ModernSpacing.md),
        decoration: BoxDecoration(
          color: ModernColors.glassPrimary,
          borderRadius: BorderRadius.circular(ModernSpacing.radiusLarge),
          border: Border.all(color: ModernColors.borderSecondary),
        ),
        child: type == ChartSkeletonType.bar
            ? _buildBarChart()
            : _buildLineChart(),
      ),
    );
  }

  Widget _buildBarChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final heights = [0.6, 0.8, 0.4, 0.9, 0.5, 0.7, 0.3];
        return Container(
          width: 24,
          height: (height - 40) * heights[index],
          decoration: BoxDecoration(
            color: ModernColors.glassSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildLineChart() {
    return CustomPaint(
      size: Size.infinite,
      painter: _LineChartSkeletonPainter(),
    );
  }
}

enum ChartSkeletonType { bar, line }

class _LineChartSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ModernColors.glassSecondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [0.5, 0.3, 0.6, 0.2, 0.7, 0.4, 0.5];
    
    for (int i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final y = size.height * (1 - points[i]);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Skeleton de métricas/stats grid
class StatsGridSkeleton extends StatelessWidget {
  final int columns;
  final int rows;
  final double itemHeight;

  const StatsGridSkeleton({
    super.key,
    this.columns = 2,
    this.rows = 2,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ModernSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: ModernSpacing.sm,
          mainAxisSpacing: ModernSpacing.sm,
          childAspectRatio: 1.5,
        ),
        itemCount: columns * rows,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: ModernColors.glassPrimary,
              borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
              border: Border.all(color: ModernColors.borderSecondary),
            ),
            padding: const EdgeInsets.all(ModernSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ModernColors.glassSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ModernColors.glassSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: ModernColors.glassSecondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton de perfil/header
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: ModernColors.glassPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: ModernSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ModernColors.glassPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: ModernColors.glassPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
