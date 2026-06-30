// ============================================================================
// lib/presentation/screens/v2/analytics_v3_screen.dart
// ANALYTICS SCREEN - REBUILT V4
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../../providers/analytics_v3_provider.dart';
import '../../providers/optimized_providers.dart';
import 'components/minimal_colors.dart';

final _logger = Logger();

class AnalyticsV3Screen extends StatefulWidget {
  const AnalyticsV3Screen({super.key});

  @override
  State<AnalyticsV3Screen> createState() => _AnalyticsV3ScreenState();
}

class _AnalyticsV3ScreenState extends State<AnalyticsV3Screen>
    with TickerProviderStateMixin {
  int _selectedPeriod = 30;
  bool _isLoading = false;
  int _insightPage = 0;
  late PageController _insightPageController;

  late AnimationController _fadeController;
  late AnimationController _scoreController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _insightPageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _insightPageController.dispose();
    _fadeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final authProvider =
        Provider.of<OptimizedAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final provider =
          Provider.of<AnalyticsV3Provider>(context, listen: false);
      await provider.loadAnalytics(user.id, periodDays: _selectedPeriod);
      await provider.loadAllNewAnalytics(user.id, periodDays: _selectedPeriod);
      if (mounted) {
        _fadeController.forward(from: 0);
        _scoreController.forward(from: 0);
      }
    } catch (e) {
      if (kDebugMode) _logger.e('Analytics load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _changePeriod(int period) {
    if (_selectedPeriod == period) return;
    setState(() => _selectedPeriod = period);
    _scoreController.reset();
    _fadeController.reset();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: Consumer<AnalyticsV3Provider>(
        builder: (context, provider, _) {
          final isLoadingAny = _isLoading || provider.isLoading;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              if (isLoadingAny)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingSkeleton(),
                )
              else if (!provider.hasData)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onRetry: _loadData),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroSection(context, provider),
                            const SizedBox(height: 14),
                            _buildQuickStats(context, provider),
                            const SizedBox(height: 22),
                            _buildSectionTitle(
                                context, 'Bienestar', 'por componentes'),
                            const SizedBox(height: 12),
                            _buildWellnessBreakdown(context, provider),
                            const SizedBox(height: 22),
                            _buildSectionTitle(context, 'Métricas clave', null),
                            const SizedBox(height: 12),
                            _buildMetricGrid(context, provider),
                            if (provider.sleepPattern?.weeklyPattern.isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 22),
                              _buildSectionTitle(
                                  context, 'Sueño semanal', 'horas por día'),
                              const SizedBox(height: 12),
                              _buildSleepSection(context, provider),
                            ],
                            if (provider.activityCorrelations.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              _buildSectionTitle(context, 'Correlaciones',
                                  'actividades vs bienestar'),
                              const SizedBox(height: 12),
                              _buildCorrelationsSection(context, provider),
                            ],
                            if (provider.topInsights.isNotEmpty ||
                                provider.topRecommendations.isNotEmpty) ...[
                              const SizedBox(height: 22),
                              _buildSectionTitle(
                                  context,
                                  'Insights',
                                  '${_selectedPeriod}d analizados'),
                              const SizedBox(height: 12),
                              _buildInsightsSection(context, provider),
                            ],
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================================
  // SECTIONS
  // ============================================================================

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      backgroundColor: MinimalColors.backgroundPrimary(context),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 56,
      title: Text(
        'Analytics',
        style: TextStyle(
          color: MinimalColors.textPrimary(context),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _PeriodSelector(
            selected: _selectedPeriod,
            onChanged: _changePeriod,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, String? subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          title,
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: MinimalColors.textMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeroSection(
      BuildContext context, AnalyticsV3Provider provider) {
    final score = provider.wellnessScore?.overallScore ?? 0.0;
    final gradients = MinimalColors.primaryGradient(context);

    return Container(
      height: 210,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradients.first,
            gradients.length > 1 ? gradients.last : gradients.first,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradients.first.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: _GridPatternPainter(
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, _) {
                    final animated = score * _scoreAnimation.value;
                    return SizedBox(
                      width: 130,
                      height: 130,
                      child: CustomPaint(
                        painter: _WellnessArcPainter(
                          score: animated,
                          maxScore: 10,
                          trackColor: Colors.white.withValues(alpha: 0.15),
                          fillColor: Colors.white,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                animated.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                'de 10',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.65),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Score de\nBienestar',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getWellnessLabel(score),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Últimos $_selectedPeriod días',
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
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, AnalyticsV3Provider provider) {
    final sleep = provider.sleepPattern?.averageSleepHours;
    final stress = provider.stressManagement?.averageStressLevel;
    final goals = provider.goalAnalytics?.completionRate;

    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            label: 'Sueño',
            value: sleep != null ? '${sleep.toStringAsFixed(1)}h' : '—',
            icon: Icons.bedtime_rounded,
            subtitle: _getSleepLabel(provider.sleepPattern?.averageSleepQuality),
            gradientColors: MinimalColors.positiveGradient(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            label: 'Estrés',
            value: stress != null ? stress.toStringAsFixed(1) : '—',
            icon: Icons.monitor_heart_rounded,
            subtitle: _getStressLabel(stress),
            gradientColors: (stress != null && stress > 6)
                ? MinimalColors.negativeGradient(context)
                : MinimalColors.neutralGradient(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            label: 'Metas',
            value: goals != null ? '${(goals * 100).toInt()}%' : '—',
            icon: Icons.track_changes_rounded,
            subtitle: 'completadas',
            gradientColors: (goals != null && goals >= 0.7)
                ? MinimalColors.positiveGradient(context)
                : MinimalColors.neutralGradient(context),
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessBreakdown(
      BuildContext context, AnalyticsV3Provider provider) {
    final components = provider.wellnessScore?.componentScores ?? {};
    if (components.isEmpty) return const SizedBox.shrink();

    final order = [
      'mood', 'energy', 'sleep', 'motivation',
      'stress', 'anxiety', 'emotional_stability', 'life_satisfaction'
    ];
    final labels = {
      'mood': 'Ánimo',
      'energy': 'Energía',
      'sleep': 'Sueño',
      'motivation': 'Motivación',
      'stress': 'Estrés',
      'anxiety': 'Ansiedad',
      'emotional_stability': 'Estabilidad',
      'life_satisfaction': 'Satisfacción',
    };

    final sorted = [
      ...order.where(components.containsKey).map((k) => MapEntry(k, components[k]!)),
      ...components.entries.where((e) => !order.contains(e.key)),
    ].take(6).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: MinimalColors.backgroundSecondary(context), width: 1),
      ),
      child: Column(
        children: sorted.map((entry) {
          final k = entry.key;
          final raw = entry.value;
          final display = (k == 'stress' || k == 'anxiety')
              ? (11.0 - raw).clamp(0.0, 10.0)
              : raw.clamp(0.0, 10.0);
          return _WellnessBar(
            label: labels[k] ?? k,
            value: display,
            maxValue: 10.0,
            gradientColors: _barGradient(context, k, display),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricGrid(
      BuildContext context, AnalyticsV3Provider provider) {
    final moodStab =
        provider.moodStability?['stability_score'] as double?;
    final chronotype =
        provider.energyPatterns?['chronotype'] as String?;
    final socialScore =
        provider.socialWellness?['social_wellness_score'] as double?;
    final streak =
        provider.habitConsistency?['longest_streak'] as int?;
    final productivity =
        provider.productivityPatterns?['productivity_score'] as double?;
    final balance =
        provider.lifestyleBalance?['balance_score'] as double?;

    final cards = <_MetricCardData>[
      _MetricCardData(
        title: 'Estabilidad\nEmocional',
        value: moodStab != null
            ? '${(moodStab * 10).toStringAsFixed(0)}%'
            : '—',
        icon: Icons.psychology_alt_rounded,
        color: MinimalColors.primaryGradient(context).first,
        subtitle: _moodStabLabel(moodStab),
      ),
      _MetricCardData(
        title: 'Cronotipo',
        value: _chronotypeEmoji(chronotype),
        icon: Icons.wb_sunny_rounded,
        color: MinimalColors.neutralGradient(context).first,
        subtitle: _chronotypeLabel(chronotype),
        isEmoji: true,
      ),
      _MetricCardData(
        title: 'Bienestar\nSocial',
        value: socialScore != null ? socialScore.toStringAsFixed(1) : '—',
        icon: Icons.people_rounded,
        color: MinimalColors.positiveGradient(context).first,
        subtitle: 'de 10',
      ),
      _MetricCardData(
        title: 'Racha\nMáxima',
        value: streak != null ? '$streak d' : '—',
        icon: Icons.local_fire_department_rounded,
        color: MinimalColors.neutralGradient(context).last,
        subtitle: 'días seguidos',
      ),
      _MetricCardData(
        title: 'Productividad',
        value: productivity != null
            ? '${(productivity * 10).toStringAsFixed(0)}%'
            : '—',
        icon: Icons.bolt_rounded,
        color: MinimalColors.accentGradient(context).first,
        subtitle: _productivityLabel(productivity),
      ),
      _MetricCardData(
        title: 'Balance\nVital',
        value: balance != null ? balance.toStringAsFixed(1) : '—',
        icon: Icons.balance_rounded,
        color: MinimalColors.positiveGradient(context).last,
        subtitle: 'de 10',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) => _MetricCard(data: cards[i]),
    );
  }

  Widget _buildSleepSection(
      BuildContext context, AnalyticsV3Provider provider) {
    final pattern = provider.sleepPattern!.weeklyPattern;
    final optimal = provider.sleepPattern!.optimalSleepHours;
    final maxH = math.max(
        optimal, pattern.values.fold<double>(0, (a, b) => math.max(a, b)));

    final dayOrder = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final sorted = [
      ...dayOrder.where(pattern.containsKey).map((d) => MapEntry(d, pattern[d]!)),
      ...pattern.entries.where((e) => !dayOrder.contains(e.key)),
    ].take(7).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: MinimalColors.backgroundSecondary(context), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Promedio: ${provider.sleepPattern!.averageSleepHours.toStringAsFixed(1)}h',
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Óptimo: ${optimal.toStringAsFixed(1)}h',
                style: TextStyle(
                  color: MinimalColors.textMuted(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sorted.map((entry) {
                final ratio = maxH > 0 ? (entry.value / maxH) : 0.0;
                final isOptimal =
                    entry.value >= optimal - 0.5 && entry.value <= optimal + 1;
                final grad = isOptimal
                    ? MinimalColors.positiveGradient(context)
                    : MinimalColors.primaryGradient(context);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: math.max(4, 64 * ratio),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: grad,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: MinimalColors.textMuted(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationsSection(
      BuildContext context, AnalyticsV3Provider provider) {
    final correlations = provider.activityCorrelations.take(5).toList();
    final metricLabels = {
      'mood': 'Ánimo',
      'energy': 'Energía',
      'stress': 'Estrés',
      'sleep': 'Sueño',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: MinimalColors.backgroundSecondary(context), width: 1),
      ),
      child: Column(
        children: correlations.map((corr) {
          final strength = corr.correlationStrength.clamp(-1.0, 1.0);
          final isPositive = strength >= 0;
          final abs = strength.abs();
          final grad = isPositive
              ? MinimalColors.positiveGradient(context)
              : MinimalColors.negativeGradient(context);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        corr.activityName,
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      metricLabels[corr.targetMetric] ?? corr.targetMetric,
                      style: TextStyle(
                        color: MinimalColors.textMuted(context),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: grad.first.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${(strength * 100).toInt()}%',
                        style: TextStyle(
                          color: grad.first,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: MinimalColors.backgroundSecondary(context),
                      ),
                      FractionallySizedBox(
                        widthFactor: abs.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: grad),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightsSection(
      BuildContext context, AnalyticsV3Provider provider) {
    final allCards = [
      ...provider.topInsights
          .map((t) => _InsightCardData(text: t, isInsight: true)),
      ...provider.topRecommendations
          .map((t) => _InsightCardData(text: t, isInsight: false)),
    ];
    if (allCards.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 118,
          child: PageView.builder(
            controller: _insightPageController,
            onPageChanged: (i) => setState(() => _insightPage = i),
            itemCount: allCards.length,
            itemBuilder: (context, i) {
              final card = allCards[i];
              final grad = card.isInsight
                  ? MinimalColors.primaryGradient(context)
                  : MinimalColors.positiveGradient(context);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      grad.first.withValues(alpha: 0.15),
                      grad.last.withValues(alpha: 0.07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: grad.first.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: grad.first.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        card.isInsight
                            ? Icons.lightbulb_rounded
                            : Icons.tips_and_updates_rounded,
                        color: grad.first,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        card.text,
                        style: TextStyle(
                          color: MinimalColors.textSecondary(context),
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (allCards.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(allCards.length, (i) {
              final active = i == _insightPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? MinimalColors.primaryGradient(context).first
                      : MinimalColors.backgroundSecondary(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _getWellnessLabel(double score) {
    if (score >= 8.5) return 'Excelente bienestar';
    if (score >= 7.0) return 'Buen nivel de bienestar';
    if (score >= 5.5) return 'Bienestar moderado';
    if (score >= 4.0) return 'Área de mejora';
    return 'Necesita atención';
  }

  String _getSleepLabel(double? quality) {
    if (quality == null) return 'sin datos';
    if (quality >= 8) return 'excelente';
    if (quality >= 6) return 'bueno';
    if (quality >= 4) return 'regular';
    return 'mejorable';
  }

  String _getStressLabel(double? stress) {
    if (stress == null) return 'sin datos';
    if (stress <= 3) return 'bajo';
    if (stress <= 6) return 'moderado';
    return 'alto';
  }

  String _moodStabLabel(double? v) {
    if (v == null) return 'sin datos';
    if (v >= 8.0) return 'muy estable';
    if (v >= 6.0) return 'estable';
    if (v >= 4.0) return 'variable';
    return 'inestable';
  }

  String _productivityLabel(double? v) {
    if (v == null) return 'sin datos';
    if (v >= 8.0) return 'alta';
    if (v >= 6.0) return 'media-alta';
    if (v >= 4.0) return 'media';
    return 'baja';
  }

  String _chronotypeEmoji(String? c) {
    if (c == 'morning') return '🌅';
    if (c == 'evening') return '🌙';
    return '☀️';
  }

  String _chronotypeLabel(String? c) {
    if (c == 'morning') return 'madrugador';
    if (c == 'evening') return 'noctámbulo';
    return 'intermedio';
  }

  List<Color> _barGradient(BuildContext ctx, String key, double val) {
    if (key == 'stress' || key == 'anxiety') {
      return val < 5
          ? MinimalColors.positiveGradient(ctx)
          : MinimalColors.negativeGradient(ctx);
    }
    if (val >= 7) return MinimalColors.positiveGradient(ctx);
    if (val >= 5) return MinimalColors.primaryGradient(ctx);
    return MinimalColors.neutralGradient(ctx);
  }
}

// ============================================================================
// PAINTERS
// ============================================================================

class _WellnessArcPainter extends CustomPainter {
  final double score;
  final double maxScore;
  final Color trackColor;
  final Color fillColor;

  const _WellnessArcPainter({
    required this.score,
    required this.maxScore,
    required this.trackColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const startAngle = math.pi * 0.75;
    const totalSweep = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final progress = maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0.0;
    if (progress <= 0) return;

    final sweep = totalSweep * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = fillColor
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final endAngle = startAngle + sweep;
    canvas.drawCircle(
      Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      ),
      6,
      Paint()..color = fillColor,
    );
  }

  @override
  bool shouldRepaint(_WellnessArcPainter old) => old.score != score;
}

class _GridPatternPainter extends CustomPainter {
  final Color color;
  const _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPatternPainter old) => old.color != color;
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _PeriodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundSecondary(context),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [7, 30, 90].map((p) {
          final isSelected = selected == p;
          final label = p == 7 ? '7d' : p == 30 ? '30d' : '90d';
          return GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: MinimalColors.primaryGradient(context))
                    : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : MinimalColors.textMuted(context),
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String subtitle;
  final List<Color> gradientColors;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.subtitle,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: MinimalColors.backgroundSecondary(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: MinimalColors.textMuted(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: MinimalColors.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: MinimalColors.textMuted(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final List<Color> gradientColors;

  const _WellnessBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: MinimalColors.backgroundSecondary(context),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final bool isEmoji;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isEmoji = false,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;
  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: MinimalColors.backgroundSecondary(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 14),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.isEmoji)
                Text(data.value, style: const TextStyle(fontSize: 22))
              else
                Text(
                  data.value,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              if (data.subtitle != null)
                Text(
                  data.subtitle!,
                  style: TextStyle(
                    color: MinimalColors.textMuted(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              Text(
                data.title,
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCardData {
  final String text;
  final bool isInsight;
  const _InsightCardData({required this.text, required this.isInsight});
}

class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton();

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _Bone(height: 210, opacity: _anim.value),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _Bone(height: 84, opacity: _anim.value)),
              const SizedBox(width: 10),
              Expanded(child: _Bone(height: 84, opacity: _anim.value)),
              const SizedBox(width: 10),
              Expanded(child: _Bone(height: 84, opacity: _anim.value)),
            ]),
            const SizedBox(height: 14),
            _Bone(height: 180, opacity: _anim.value * 0.9),
            const SizedBox(height: 14),
            _Bone(height: 180, opacity: _anim.value * 0.7),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double height;
  final double opacity;
  const _Bone({required this.height, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: MinimalColors.backgroundSecondary(context),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: MinimalColors.textMuted(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sin datos suficientes',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Registra tu estado de ánimo, sueño y actividades durante al menos una semana para ver tu análisis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MinimalColors.textMuted(context),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.primaryGradient(context)
                          .first
                          .withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
