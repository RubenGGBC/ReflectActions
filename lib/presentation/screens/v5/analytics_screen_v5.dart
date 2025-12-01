// ============================================================================
// ANALYTICS SCREEN V5 - MODERN WELLNESS ANALYTICS
// ============================================================================
// Diseño minimalista premium con animaciones y efectos visuales

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/analytics_provider_v4.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../v2/components/minimal_colors.dart';
import '../../../data/services/analytics_database_extension_v4_simple.dart';

class AnalyticsScreenV5 extends StatefulWidget {
  const AnalyticsScreenV5({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreenV5> createState() => _AnalyticsScreenV5State();
}

class _AnalyticsScreenV5State extends State<AnalyticsScreenV5>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadAnalytics() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (authProvider.currentUser == null) return;

    final userId = authProvider.currentUser!.id;
    final provider = context.read<AnalyticsProviderV4>();
    await provider.loadAllAnalytics(userId);

    if (mounted) {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: Consumer<AnalyticsProviderV4>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null || !provider.hasAnyData) {
            return _buildEmptyState();
          }

          return _buildAnalyticsContent(provider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.gradientShadow(context, alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: MinimalColors.accentGradient(context),
            ).createShader(bounds),
            child: const Text(
              'Analizando tu progreso...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.gradientShadow(context, alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Comienza tu viaje',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Registra tus entradas diarias para\nver tu progreso aquí',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: MinimalColors.primaryGradient(context),
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: MinimalColors.gradientShadow(context, alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _loadAnalytics,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Actualizar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(AnalyticsProviderV4 provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                child: _buildHeader(provider),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTimeframeSelector(provider),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildHeroScoreCard(provider),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuickStatsGrid(provider),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildWellbeingSection(provider),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGoalsSection(provider),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMomentsSection(provider),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildInsightsSection(provider),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AnalyticsProviderV4 provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.accentGradient(context)[0].withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: MinimalColors.accentGradient(context),
                      ).createShader(bounds),
                      child: Text(
                        'Analytics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analiza tu progreso y tendencias',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.gradientShadow(context, alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _loadAnalytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(AnalyticsProviderV4 provider) {
    final timeframes = provider.availableTimeframes;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 50,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: timeframes.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final timeframe = timeframes[index];
            final isSelected = provider.selectedTimeframe.label == timeframe.label;

              return GestureDetector(
              onTap: () async {
                final authProvider = context.read<OptimizedAuthProvider>();
                if (authProvider.currentUser != null) {
                  await provider.changeTimeframe(
                    timeframe,
                    authProvider.currentUser!.id,
                  );
                }
              },
                child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: MinimalColors.primaryGradient(context),
                        )
                      : null,
                  color: isSelected ? null : MinimalColors.backgroundCard(context),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : MinimalColors.shadow(context),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: MinimalColors.gradientShadow(context, alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    timeframe.label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : MinimalColors.textPrimary(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroScoreCard(AnalyticsProviderV4 provider) {
    final motivation = provider.motivationInsights;
    final score = motivation?.motivationScore ?? 0.0;

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: MinimalColors.primaryGradient(context),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.gradientShadow(context, alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Score de Bienestar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        height: 0.9,
                        letterSpacing: -2,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        '/10',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: score / 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getScoreMessage(score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getScoreMessage(double score) {
    if (score >= 8.5) return '¡Excelente progreso! 🌟';
    if (score >= 7) return '¡Muy bien! Sigue así 💪';
    if (score >= 5.5) return 'Buen avance 👍';
    if (score >= 4) return 'En progreso 🌱';
    return '¡Puedes mejorar! 💙';
  }

  Widget _buildQuickStatsGrid(AnalyticsProviderV4 provider) {
    final goals = provider.goalAnalytics;
    final moments = provider.momentsAnalytics;
    final trends = provider.wellbeingTrends;

    final improving = trends.where((t) => t.trendDirection == 'improving').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            label: 'Metas',
            value: '${goals?.completionRate.toStringAsFixed(0) ?? '0'}%',
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Mejoras',
            value: '$improving',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_emotions_rounded,
            label: 'Momentos',
            value: '${moments?.totalMoments ?? 0}',
            color: const Color(0xFFFFA726),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textTertiary(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellbeingSection(AnalyticsProviderV4 provider) {
    final trends = provider.wellbeingTrends;

    if (trends.isEmpty) {
      return _buildEmptySectionCard('No hay datos de tendencias', Icons.show_chart);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tendencias de Bienestar', Icons.analytics_outlined),
        const SizedBox(height: 16),
        ...trends.take(5).map((trend) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showTrendDetailDialog(trend),
            child: _buildTrendCard(trend),
          ),
        )),
      ],
    );
  }

  void _showTrendDetailDialog(SimpleWellbeingTrend trend) {
    final isImproving = trend.trendDirection == 'improving';
    final isStable = trend.trendDirection == 'stable';

    final color = isImproving
        ? const Color(0xFF4ECDC4)
        : isStable
            ? const Color(0xFFFFA726)
            : const Color(0xFFFF6B6B);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MinimalColors.backgroundCard(context),
                MinimalColors.backgroundPrimary(context),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      isImproving
                          ? Icons.trending_up_rounded
                          : isStable
                              ? Icons.trending_flat_rounded
                              : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trend.metric,
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTrendStatusText(trend.trendDirection),
                          style: TextStyle(
                            color: color,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: MinimalColors.textSecondary(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Metrics row
              Row(
                children: [
                  Expanded(
                    child: _buildDetailMetric(
                      'Promedio',
                      trend.averageValue.toStringAsFixed(1),
                      Icons.analytics_outlined,
                      color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailMetric(
                      'Cambio',
                      '${trend.improvementPercentage > 0 ? '+' : ''}${trend.improvementPercentage.toStringAsFixed(0)}%',
                      isImproving ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Large chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: trend.dataPoints.isNotEmpty
                    ? CustomPaint(
                        painter: _SparklinePainter(
                          dataPoints: trend.dataPoints,
                          color: color,
                        ),
                        size: Size.infinite,
                      )
                    : Center(
                        child: Text(
                          'No hay datos suficientes',
                          style: TextStyle(
                            color: MinimalColors.textTertiary(context),
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Data points count
              Center(
                child: Text(
                  '${trend.dataPoints.length} puntos de datos',
                  style: TextStyle(
                    color: MinimalColors.textTertiary(context),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textTertiary(context),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTrendStatusText(String direction) {
    switch (direction) {
      case 'improving':
        return 'Mejorando';
      case 'declining':
        return 'Declinando';
      case 'stable':
        return 'Estable';
      default:
        return direction;
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: MinimalColors.primaryGradient(context),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(SimpleWellbeingTrend trend) {
    final isImproving = trend.trendDirection == 'improving';
    final isStable = trend.trendDirection == 'stable';

    final color = isImproving
        ? const Color(0xFF4ECDC4)
        : isStable
            ? const Color(0xFFFFA726)
            : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.shadow(context),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isImproving
                      ? Icons.trending_up_rounded
                      : isStable
                          ? Icons.trending_flat_rounded
                          : Icons.trending_down_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trend.metric,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend.improvementPercentage > 0
                      ? '+${trend.improvementPercentage.toStringAsFixed(0)}%'
                      : '${trend.improvementPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Promedio: ',
                style: TextStyle(
                  color: MinimalColors.textTertiary(context),
                  fontSize: 14,
                ),
              ),
              Text(
                trend.averageValue.toStringAsFixed(1),
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (trend.dataPoints.isNotEmpty)
                SizedBox(
                  width: 100,
                  height: 40,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      dataPoints: trend.dataPoints,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(AnalyticsProviderV4 provider) {
    final goals = provider.goalAnalytics;

    if (goals == null || goals.totalGoals == 0) {
      return _buildEmptySectionCard('No hay metas registradas', Icons.flag_outlined);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Progreso de Metas', Icons.flag_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MinimalColors.backgroundCard(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MinimalColors.shadow(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MinimalColors.shadow(context),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildGoalMetric(
                      'Total',
                      goals.totalGoals.toString(),
                      Icons.format_list_bulleted_rounded,
                      const Color(0xFF8B7EFF),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: MinimalColors.shadow(context),
                  ),
                  Expanded(
                    child: _buildGoalMetric(
                      'Completadas',
                      goals.completedGoals.toString(),
                      Icons.check_circle_rounded,
                      const Color(0xFF4ECDC4),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: MinimalColors.shadow(context),
                  ),
                  Expanded(
                    child: _buildGoalMetric(
                      'Tasa',
                      '${goals.completionRate.toStringAsFixed(0)}%',
                      Icons.trending_up_rounded,
                      const Color(0xFFFFA726),
                    ),
                  ),
                ],
              ),
              if (goals.goalsByCategory.isNotEmpty) ...[
                const SizedBox(height: 24),
                Divider(color: MinimalColors.shadow(context)),
                const SizedBox(height: 20),
                ...goals.goalsByCategory.entries.take(4).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryBar(
                      _getCategoryDisplayName(entry.key),
                      entry.value,
                      goals.totalGoals,
                      _getCategoryColor(entry.key),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: MinimalColors.textTertiary(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar(String name, int count, int total, Color color) {
    final progress = count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: MinimalColors.backgroundSecondary(context),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(String category) {
    const categoryNames = {
      'mindfulness': 'Mindfulness',
      'stress': 'Estrés',
      'sleep': 'Sueño',
      'social': 'Social',
      'physical': 'Físico',
      'emotional': 'Emocional',
      'productivity': 'Productividad',
      'habits': 'Hábitos',
    };
    return categoryNames[category.toLowerCase()] ?? category;
  }

  Color _getCategoryColor(String category) {
    const categoryColors = {
      'mindfulness': Color(0xFF8B7EFF),
      'stress': Color(0xFFFF6B6B),
      'sleep': Color(0xFF4ECDC4),
      'social': Color(0xFFFFA726),
      'physical': Color(0xFF66D9EF),
      'emotional': Color(0xFFFF6B9D),
      'productivity': Color(0xFF95E1D3),
      'habits': Color(0xFFFFBE76),
    };
    return categoryColors[category.toLowerCase()] ?? const Color(0xFF8B7EFF);
  }

  Widget _buildMomentsSection(AnalyticsProviderV4 provider) {
    final moments = provider.momentsAnalytics;

    if (moments == null || moments.totalMoments == 0) {
      return _buildEmptySectionCard('No hay momentos registrados', Icons.emoji_emotions_outlined);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Momentos Destacados', Icons.star_rounded),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFA726).withValues(alpha: 0.1),
                const Color(0xFFFF6B6B).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFA726).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMomentStat('⚡', 'Total', moments.totalMoments.toString()),
                  Container(width: 1, height: 60, color: MinimalColors.shadow(context)),
                  _buildMomentStat('😊', 'Positivos', '${moments.positivityRatio.toStringAsFixed(0)}%'),
                  Container(width: 1, height: 60, color: MinimalColors.shadow(context)),
                  _buildMomentStat('📅', 'Diario', '${(moments.totalMoments / 30).toStringAsFixed(1)}'),
                ],
              ),
              if (moments.momentsByType.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...moments.momentsByType.entries.map((entry) {
                  final percentage = (entry.value / moments.totalMoments * 100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMomentTypeBar(
                      _getMomentTypeLabel(entry.key),
                      percentage,
                      _getMomentTypeColor(entry.key),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMomentStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: MinimalColors.textTertiary(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMomentTypeBar(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: MinimalColors.backgroundSecondary(context),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  String _getMomentTypeLabel(String type) {
    const labels = {
      'positive': 'Positivos',
      'negative': 'Negativos',
      'neutral': 'Neutrales',
    };
    return labels[type.toLowerCase()] ?? type;
  }

  Color _getMomentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'positive':
        return const Color(0xFF4ECDC4);
      case 'negative':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFFFA726);
    }
  }

  Widget _buildInsightsSection(AnalyticsProviderV4 provider) {
    final motivation = provider.motivationInsights;
    final insights = motivation?.improvements ?? [];
    final recommendations = motivation?.recommendations ?? [];
    final achievements = motivation?.achievements ?? [];

    if (insights.isEmpty && recommendations.isEmpty && achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Insights Personalizados', Icons.lightbulb_rounded),
        const SizedBox(height: 16),

        if (achievements.isNotEmpty) ...[
          ...achievements.take(2).map((achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInsightCard(
              icon: Icons.emoji_events_rounded,
              text: achievement,
              gradient: [const Color(0xFFFFA726), const Color(0xFFFF6B6B)],
            ),
          )),
        ],

        if (insights.isNotEmpty) ...[
          ...insights.take(2).map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInsightCard(
              icon: Icons.trending_up_rounded,
              text: insight,
              gradient: [const Color(0xFF4ECDC4), const Color(0xFF66D9EF)],
            ),
          )),
        ],

        if (recommendations.isNotEmpty) ...[
          ...recommendations.take(2).map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInsightCard(
              icon: Icons.tips_and_updates_rounded,
              text: rec,
              gradient: [const Color(0xFF8B7EFF), const Color(0xFFB197FC)],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String text,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient[0].withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySectionCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.shadow(context),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              color: MinimalColors.textTertiary(context),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: MinimalColors.textTertiary(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM PAINTER FOR SPARKLINE CHARTS
// ============================================================================

class _SparklinePainter extends CustomPainter {
  final List<SimpleDataPoint> dataPoints;
  final Color color;

  _SparklinePainter({
    required this.dataPoints,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    for (final point in dataPoints) {
      if (point.value < minValue) minValue = point.value;
      if (point.value > maxValue) maxValue = point.value;
    }

    final range = maxValue - minValue;
    if (range == 0) {
      minValue -= 1;
      maxValue += 1;
    }

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < dataPoints.length; i++) {
      final value = dataPoints[i].value;
      final x = (i / (dataPoints.length - 1)) * size.width;
      final y = size.height - ((value - minValue) / (maxValue - minValue)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
