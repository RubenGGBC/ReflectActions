// lib/presentation/screens/v2/insights_screen.dart
// Pantalla principal de Insights Automáticos

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/insights_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/models/insights_models.dart';
import 'components/minimal_colors.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsights();
      _animController.forward();
    });
  }

  void _loadInsights() {
    final auth = context.read<OptimizedAuthProvider>();
    if (auth.currentUser != null) {
      context.read<InsightsProvider>().loadInsights(auth.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Consumer<InsightsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return _buildLoadingState();
              }
              if (provider.error != null) {
                return _buildErrorState(provider.error!);
              }
              if (provider.needsMoreData) {
                return _buildNeedsDataState();
              }
              return _buildInsightsContent(provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analizando tus datos...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar insights',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: MinimalColors.textSecondary(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadInsights,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedsDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights,
                size: 64,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Necesitamos más datos',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Registra al menos 7 días de reflexiones para que podamos generar insights personalizados sobre tus patrones.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade400),
                  const SizedBox(width: 12),
                  Text(
                    'Tip: Escribe una reflexión diaria',
                    style: TextStyle(color: MinimalColors.textPrimary(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsContent(InsightsProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        final auth = context.read<OptimizedAuthProvider>();
        if (auth.currentUser != null) {
          await provider.refreshInsights(auth.currentUser!.id);
        }
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader(provider)),
          
          // Resumen semanal
          if (provider.weeklySummary != null)
            SliverToBoxAdapter(
              child: _WeeklySummaryCard(summary: provider.weeklySummary!),
            ),
          
          // Patrones detectados
          if (provider.patterns.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionTitle('🔍 Patrones Detectados')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _PatternCard(pattern: provider.patterns[index]),
                childCount: provider.patterns.length,
              ),
            ),
          ],
          
          // Correlaciones
          if (provider.correlations.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionTitle('📈 Correlaciones')),
            SliverToBoxAdapter(
              child: _CorrelationsSection(correlations: provider.correlations),
            ),
          ],
          
          // Predicciones
          if (provider.predictions.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionTitle('🔮 Tendencias')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _TrendCard(prediction: provider.predictions[index]),
                childCount: provider.predictions.length,
              ),
            ),
          ],
          
          // Espaciado final
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(InsightsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tus Insights',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Análisis de ${provider.insights?.totalDaysAnalyzed ?? 0} días',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadInsights,
                icon: Icon(
                  Icons.refresh,
                  color: MinimalColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          color: MinimalColors.textPrimary(context),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================================
// WEEKLY SUMMARY CARD
// ============================================================================

class _WeeklySummaryCard extends StatelessWidget {
  final WeeklySummary summary;

  const _WeeklySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900.withOpacity(0.3),
            Colors.purple.shade900.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con emoji y título
          Row(
            children: [
              Text(summary.moodEmoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen Semanal',
                      style: TextStyle(
                        color: MinimalColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${summary.totalEntries} de 7 días registrados',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (summary.comparison != null)
                _buildComparisonBadge(context, summary.comparison!),
            ],
          ),
          const SizedBox(height: 20),
          
          // Métricas principales
          Row(
            children: [
              _buildMetricTile(
                context,
                'Ánimo',
                summary.averageMood.toStringAsFixed(1),
                Icons.mood,
                Colors.amber,
              ),
              _buildMetricTile(
                context,
                'Energía',
                summary.averageEnergy.toStringAsFixed(1),
                Icons.bolt,
                Colors.orange,
              ),
              _buildMetricTile(
                context,
                'Estrés',
                summary.averageStress.toStringAsFixed(1),
                Icons.psychology,
                Colors.red.shade300,
              ),
            ],
          ),
          
          // Mejor y peor día
          if (summary.bestDay != null || summary.worstDay != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (summary.bestDay != null)
                  Expanded(
                    child: _buildDayHighlight(
                      context,
                      '🌟 Mejor día',
                      summary.bestDay!.dayName,
                      summary.bestDay!.mood,
                      Colors.green,
                    ),
                  ),
                if (summary.bestDay != null && summary.worstDay != null)
                  const SizedBox(width: 12),
                if (summary.worstDay != null)
                  Expanded(
                    child: _buildDayHighlight(
                      context,
                      '💪 Día difícil',
                      summary.worstDay!.dayName,
                      summary.worstDay!.mood,
                      Colors.orange,
                    ),
                  ),
              ],
            ),
          ],

          // Tags frecuentes
          if (summary.topPositiveTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.topPositiveTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✨ $tag',
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 12,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonBadge(BuildContext context, WeekComparison comparison) {
    final isPositive = comparison.isMoodImproved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green.shade300 : Colors.red.shade300,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            comparison.moodChangeText,
            style: TextStyle(
              color: isPositive ? Colors.green.shade300 : Colors.red.shade300,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
                color: MinimalColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHighlight(
    BuildContext context,
    String label,
    String dayName,
    double mood,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayName,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Mood: ${mood.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PATTERN CARD
// ============================================================================

class _PatternCard extends StatelessWidget {
  final EmotionalPattern pattern;

  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pattern.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pattern.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(pattern.icon, color: pattern.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pattern.title,
                        style: TextStyle(
                          color: MinimalColors.textPrimary(context),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildConfidenceBadge(context),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pattern.description,
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade300,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pattern.suggestion,
                          style: TextStyle(
                            color: Colors.blue.shade200,
                            fontSize: 13,
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

  Widget _buildConfidenceBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pattern.isHighConfidence 
            ? Colors.green.withOpacity(0.2) 
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(pattern.confidence * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: pattern.isHighConfidence ? Colors.green.shade300 : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================================
// CORRELATIONS SECTION
// ============================================================================

class _CorrelationsSection extends StatelessWidget {
  final List<HabitCorrelation> correlations;

  const _CorrelationsSection({required this.correlations});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: correlations.map((corr) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCorrelationItem(context, corr),
        )).toList(),
      ),
    );
  }

  Widget _buildCorrelationItem(BuildContext context, HabitCorrelation corr) {
    return Row(
      children: [
        Icon(corr.icon, color: corr.strengthColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${corr.habit} → ${corr.outcome}',
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                corr.interpretation,
                style: TextStyle(
                  color: MinimalColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: corr.strengthColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                corr.strengthLabel,
                style: TextStyle(
                  color: corr.strengthColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'r=${corr.correlation.toStringAsFixed(2)}',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// TREND CARD
// ============================================================================

class _TrendCard extends StatelessWidget {
  final TrendPrediction prediction;

  const _TrendCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final isUp = prediction.direction == TrendDirection.up;
    final isStable = prediction.direction == TrendDirection.stable;
    
    final color = isUp ? Colors.green : (isStable ? Colors.blue : Colors.orange);
    final icon = isUp ? Icons.trending_up : (isStable ? Icons.trending_flat : Icons.trending_down);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.metric,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prediction.insight,
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prediction.currentValue.toStringAsFixed(1),
                style: TextStyle(
                  color: MinimalColors.textPrimary(context),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${prediction.changePercent >= 0 ? '+' : ''}${prediction.changePercent.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
