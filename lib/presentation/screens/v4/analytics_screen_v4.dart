// ============================================================================
// presentation/screens/v4/analytics_screen_v4.dart
// V4 ANALYTICS SCREEN - ADVANCED MOTIVATIONAL ANALYTICS
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../providers/analytics_provider_v4.dart';
import '../../providers/optimized_providers.dart';
import '../../../data/services/analytics_database_extension_v4_simple.dart';
import '../../../data/models/goal_model.dart';

class AnalyticsScreenV4 extends StatefulWidget {
  const AnalyticsScreenV4({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreenV4> createState() => _AnalyticsScreenV4State();
}

class _AnalyticsScreenV4State extends State<AnalyticsScreenV4>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _celebrationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Load analytics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  Future<void> _loadAnalytics() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    if (authProvider.currentUser == null) return;
    
    final userId = authProvider.currentUser!.id;
    final provider = context.read<AnalyticsProviderV4>();
    await provider.loadAllAnalytics(userId);
    _animationController.forward();
    
    if (provider.hasRecentAchievements) {
      _celebrationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Consumer<AnalyticsProviderV4>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return _buildAnalyticsContent(provider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8b5cf6)),
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing your progress...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load analytics',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadAnalytics,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8b5cf6),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(AnalyticsProviderV4 provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(provider),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTimeframeSelector(provider),
                  const SizedBox(height: 20),
                  _buildMotivationHeader(provider),
                  const SizedBox(height: 20),
                  _buildAchievementsSection(provider),
                  const SizedBox(height: 20),
                  _buildWellbeingTrendsSection(provider),
                  const SizedBox(height: 20),
                  _buildGoalsSection(provider),
                  const SizedBox(height: 20),
                  _buildMomentsSection(provider),
                  const SizedBox(height: 20),
                  _buildInsightsSection(provider),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AnalyticsProviderV4 provider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF000000),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Your Journey',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1e3a8a),
                Color(0xFF581c87),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _loadAnalytics(),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector(AnalyticsProviderV4 provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: provider.availableTimeframes.map((timeframe) {
          final isSelected = provider.selectedTimeframe.label == timeframe.label;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final authProvider = context.read<OptimizedAuthProvider>();
                if (authProvider.currentUser == null) return;
                provider.changeTimeframe(timeframe, authProvider.currentUser!.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8b5cf6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeframe.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMotivationHeader(AnalyticsProviderV4 provider) {
    final insights = provider.motivationInsights;
    if (insights == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motivation Score',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${insights.motivationScore.toStringAsFixed(1)}/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMotivationScoreIndicator(insights.motivationScore),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Primary Factor: ${insights.primaryMotivationFactor}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationScoreIndicator(double score) {
    final percentage = (score / 10.0).clamp(0.0, 1.0);
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.2)),
          ),
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 6,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Center(
            child: Text(
              score.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(AnalyticsProviderV4 provider) {
    final insights = provider.motivationInsights;
    if (insights == null || insights.achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 Recent Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.achievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(String achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF10b981), width: 1),
      ),
      child: Text(
        achievement,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildWellbeingTrendsSection(AnalyticsProviderV4 provider) {
    if (provider.wellbeingTrends.isEmpty) {
      return _buildEmptySection('📈 Wellbeing Trends', 'No data available yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📈 Wellbeing Trends',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.wellbeingTrends.map((trend) => _buildTrendCard(trend)),
      ],
    );
  }

  Widget _buildTrendCard(SimpleWellbeingTrend trend) {
    final isImproving = trend.trendDirection == 'improving';
    final isStable = trend.trendDirection == 'stable';
    
    Color cardColor = const Color(0xFF1A1A1A);
    Color accentColor = Colors.white70;
    IconData trendIcon = Icons.trending_flat;
    
    if (isImproving) {
      cardColor = const Color(0xFF10b981).withOpacity(0.1);
      accentColor = const Color(0xFF10b981);
      trendIcon = Icons.trending_up;
    } else if (!isStable) {
      cardColor = const Color(0xFFf59e0b).withOpacity(0.1);
      accentColor = const Color(0xFFf59e0b);
      trendIcon = Icons.trending_down;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(trendIcon, color: accentColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trend.metric,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                trend.averageValue.toStringAsFixed(1),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                trend.trendDirection.toUpperCase(),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isImproving && trend.improvementPercentage > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '+${trend.improvementPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _buildMiniChart(trend.dataPoints, accentColor),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<SimpleDataPoint> dataPoints, Color color) {
    if (dataPoints.length < 2) {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Insufficient data',
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      child: CustomPaint(
        painter: MiniChartPainter(dataPoints, color),
        size: const Size(double.infinity, 40),
      ),
    );
  }

  Widget _buildGoalsSection(AnalyticsProviderV4 provider) {
    final goalAnalytics = provider.goalAnalytics;
    if (goalAnalytics == null) {
      return _buildEmptySection('🎯 Goals Progress', 'No goals data available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Goals Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildGoalsOverviewCard(goalAnalytics),
        const SizedBox(height: 12),
        _buildGoalsCategoryBreakdown(goalAnalytics),
      ],
    );
  }

  Widget _buildGoalsOverviewCard(SimpleGoalAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildGoalStat('Total Goals', analytics.totalGoals.toString()),
          ),
          Expanded(
            child: _buildGoalStat('Completed', analytics.completedGoals.toString()),
          ),
          Expanded(
            child: _buildGoalStat('Success Rate', '${analytics.completionRate.toStringAsFixed(0)}%'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoalsCategoryBreakdown(SimpleGoalAnalytics analytics) {
    if (analytics.goalsByCategory.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goals by Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...analytics.goalsByCategory.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    _getCategoryEmojiFromString(entry.key),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getCategoryNameFromString(entry.key),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8b5cf6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        color: Color(0xFF8b5cf6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }


  Widget _buildMomentsSection(AnalyticsProviderV4 provider) {
    final momentsAnalytics = provider.momentsAnalytics;
    if (momentsAnalytics == null) {
      return _buildEmptySection('⚡ Quick Moments', 'No moments data available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚡ Quick Moments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMomentsStatsCard(momentsAnalytics),
      ],
    );
  }

  Widget _buildMomentsStatsCard(SimpleQuickMomentsAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGoalStat('Total Moments', analytics.totalMoments.toString()),
              ),
              Expanded(
                child: _buildGoalStat('Positivity', '${analytics.positivityRatio.toStringAsFixed(0)}%'),
              ),
              Expanded(
                child: _buildGoalStat('Positive', '${analytics.momentsByType['positive'] ?? 0}'),
              ),
            ],
          ),
          if (analytics.positivityRatio > 60) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10b981).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sentiment_very_satisfied, color: Color(0xFF10b981), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Great positivity ratio! Keep it up! 😊',
                    style: TextStyle(
                      color: Color(0xFF10b981),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightsSection(AnalyticsProviderV4 provider) {
    final insights = provider.motivationInsights;
    if (insights == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Insights & Recommendations',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (insights.improvements.isNotEmpty) ...[
          ...insights.improvements.map((improvement) => _buildInsightCard(
            improvement,
            const Color(0xFF10b981),
            Icons.trending_up,
          )),
        ],
        if (insights.recommendations.isNotEmpty) ...[
          ...insights.recommendations.map((recommendation) => _buildInsightCard(
            recommendation,
            const Color(0xFF3b82f6),
            Icons.lightbulb_outline,
          )),
        ],
      ],
    );
  }

  Widget _buildInsightCard(String text, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white30,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCategoryEmoji(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness:
        return '🧘';
      case GoalCategory.stress:
        return '😌';
      case GoalCategory.sleep:
        return '😴';
      case GoalCategory.social:
        return '👥';
      case GoalCategory.physical:
        return '💪';
      case GoalCategory.emotional:
        return '❤️';
      case GoalCategory.productivity:
        return '⚡';
      case GoalCategory.habits:
        return '🔄';
    }
  }

  String _getCategoryName(GoalCategory category) {
    switch (category) {
      case GoalCategory.mindfulness:
        return 'Mindfulness';
      case GoalCategory.stress:
        return 'Stress Management';
      case GoalCategory.sleep:
        return 'Sleep Quality';
      case GoalCategory.social:
        return 'Social Connection';
      case GoalCategory.physical:
        return 'Physical Health';
      case GoalCategory.emotional:
        return 'Emotional Wellbeing';
      case GoalCategory.productivity:
        return 'Productivity';
      case GoalCategory.habits:
        return 'Habit Formation';
    }
  }

  String _getCategoryEmojiFromString(String category) {
    switch (category.toLowerCase()) {
      case 'mindfulness':
        return '🧘';
      case 'stress':
        return '😌';
      case 'sleep':
        return '😴';
      case 'social':
        return '👥';
      case 'physical':
        return '💪';
      case 'emotional':
        return '❤️';
      case 'productivity':
        return '⚡';
      case 'habits':
        return '🔄';
      default:
        return '🎯';
    }
  }

  String _getCategoryNameFromString(String category) {
    switch (category.toLowerCase()) {
      case 'mindfulness':
        return 'Mindfulness';
      case 'stress':
        return 'Stress Management';
      case 'sleep':
        return 'Sleep Quality';
      case 'social':
        return 'Social Connection';
      case 'physical':
        return 'Physical Health';
      case 'emotional':
        return 'Emotional Wellbeing';
      case 'productivity':
        return 'Productivity';
      case 'habits':
        return 'Habit Formation';
      default:
        return category.substring(0, 1).toUpperCase() + category.substring(1);
    }
  }
}

// ============================================================================
// MINI CHART PAINTER
// ============================================================================

class MiniChartPainter extends CustomPainter {
  final List<SimpleDataPoint> dataPoints;
  final Color color;

  MiniChartPainter(this.dataPoints, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    final maxValue = dataPoints.map((p) => p.value).reduce(math.max);
    final minValue = dataPoints.map((p) => p.value).reduce(math.min);
    final valueRange = maxValue - minValue;
    
    if (valueRange == 0) return;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = (dataPoints[i].value - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = (i / (dataPoints.length - 1)) * size.width;
      final normalizedValue = (dataPoints[i].value - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height);
      
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}