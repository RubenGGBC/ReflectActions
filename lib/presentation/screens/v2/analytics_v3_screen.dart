// ============================================================================
// lib/presentation/screens/v2/analytics_v3_screen.dart
// ANALYTICS V3 SCREEN - PROFESSIONAL CLEAN DESIGN
// 
// DATA REQUIREMENTS DOCUMENTATION:
// --------------------------------
// 1. WellnessScoreModel: 5+ daily entries for accurate calculation
// 2. SleepPatternModel: 7+ sleep records for pattern analysis  
// 3. StressManagementModel: 5+ stress ratings for trend analysis
// 4. ActivityCorrelationModel: 10+ activity entries for correlations
// 5. ProductivityPatterns: 7+ productivity entries for peak analysis
// 6. MoodStability: 7+ mood entries for variance calculation
// 7. LifestyleBalance: 10+ entries across different life areas
// 8. EnergyPatterns: 7+ energy level entries for chronotype detection
// 9. SocialWellness: 5+ social interaction entries
// 10. HabitConsistency: 14+ habit tracking entries for streak analysis
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Providers
import '../../providers/analytics_v3_provider.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/enhanced_goals_provider.dart';

// Modern Design System
import '../components/modern_design_system.dart';
import 'components/minimal_colors.dart';

class AnalyticsV3Screen extends StatefulWidget {
  const AnalyticsV3Screen({super.key});

  @override
  State<AnalyticsV3Screen> createState() => _AnalyticsV3ScreenState();
}

class _AnalyticsV3ScreenState extends State<AnalyticsV3Screen> with TickerProviderStateMixin {
  
  int _selectedPeriod = 30;
  final List<int> _periodOptions = [7, 30, 90];
  
  bool _isLoading = false;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations after data loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }


  void _loadAnalyticsData() async {
    // Prevent multiple simultaneous loads
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    // Start fade animation for loading state
    _fadeController.forward();
    
    try {
      final userProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        print('🔍 Analytics Screen: Loading analytics for user ${currentUser.id}');
        final analyticsProvider = Provider.of<AnalyticsV3Provider>(context, listen: false);
        print('📊 Analytics Screen: Provider obtained, calling loadAnalytics...');
        await analyticsProvider.loadAnalytics(currentUser.id, periodDays: _selectedPeriod);
        print('✨ Analytics Screen: loadAnalytics completed');
        // Load new analytics methods
        print('🔧 Analytics Screen: Loading new analytics methods...');
        await analyticsProvider.loadAllNewAnalytics(currentUser.id, periodDays: _selectedPeriod);
        print('🎯 Analytics Screen: All new analytics loaded');
        print('📊 Checking loaded data:');
        print('   - Productivity: ${analyticsProvider.productivityPatterns != null ? "✅" : "❌"}');
        print('   - Mood Stability: ${analyticsProvider.moodStability != null ? "✅" : "❌"}');
        print('   - Lifestyle Balance: ${analyticsProvider.lifestyleBalance != null ? "✅" : "❌"}');
        
        // Start animations after data loads successfully
        if (mounted) {
          _startAnimations();
        }
      } else {
        print('❌ Analytics Screen: No current user');
      }
    } catch (e) {
      print('❌ Analytics Screen Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startAnimations() {
    // Reset all animations
    _fadeController.reset();
    _slideController.reset();
    _staggerController.reset();
    
    // Start animations with staggered timing
    _fadeController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: MinimalColors.backgroundPrimary(context),
          body: Container(
                  decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MinimalColors.backgroundPrimary(context),
                  MinimalColors.backgroundSecondary(context),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: SafeArea(
                    child: Column(
                children: [
                  _buildProfessionalHeader(themeProvider),
                  _buildCompactPeriodSelector(themeProvider),
                  Expanded(
                    child: _isLoading
                        ? _buildMinimalLoadingState(themeProvider)
                        : _buildProfessionalAnalyticsContent(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // PROFESSIONAL HEADER WIDGET WITH MODERN EFFECTS
  // ============================================================================
  // DATA SOURCE: Static UI elements + period selection state
  // REQUIRED DATA: None (pure UI component)
  // PURPOSE: Clean, minimal header with modern visual effects
  // ============================================================================
  Widget _buildProfessionalHeader(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  Icons.insights,
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
                      'Insights de bienestar',
                      style: TextStyle(
                        color: MinimalColors.textSecondary(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: MinimalColors.accentGradient(context)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ============================================================================
  // DATA REQUIREMENT BADGE HELPER
  // ============================================================================
  Widget _buildDataBadge(int requiredEntries, String type, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
        color: (color ?? ModernColors.info).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? ModernColors.info).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$requiredEntries+ $type',
        style: TextStyle(
          color: color ?? ModernColors.info,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================================
  // COMPACT PERIOD SELECTOR WITH GLASS EFFECT
  // ============================================================================
  // DATA SOURCE: _selectedPeriod state variable
  // REQUIRED DATA: _periodOptions list [7, 30, 90]
  // PURPOSE: Glassmorphic period selection interface
  // ============================================================================
  Widget _buildCompactPeriodSelector(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
        border: Border.all(
          color: MinimalColors.textMuted(context).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _periodOptions.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => _updatePeriod(period),
              child: AnimatedContainer(
                duration: ModernAnimations.medium,
                padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: MinimalColors.primaryGradient(context),
                  ) : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: MinimalColors.gradientShadow(context, alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  _getPeriodLabel(period),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white 
                      : MinimalColors.textSecondary(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================================
  // MINIMAL LOADING STATE WIDGET
  // ============================================================================
  // DATA SOURCE: _isLoading state variable
  // REQUIRED DATA: None (pure UI component)
  // PURPOSE: Clean, professional loading indicator
  // ============================================================================
  Widget _buildMinimalLoadingState(ThemeProvider themeProvider) {
    return Center(
            child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minimal loading spinner
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                themeProvider.accentPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Loading text
          Text(
            'Analizando datos...',
            style: TextStyle(
              color: MinimalColors.textSecondary(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto puede tomar unos momentos',
            style: TextStyle(
              color: MinimalColors.textMuted(context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PROFESSIONAL ANALYTICS CONTENT WIDGET
  // ============================================================================
  // DATA SOURCE: AnalyticsV3Provider (all analytics data)
  // REQUIRED DATA: Minimum data requirements documented per card
  // PURPOSE: Main analytics dashboard with professional layout
  // ============================================================================
  Widget _buildProfessionalAnalyticsContent() {
    return Consumer<AnalyticsV3Provider>(
      builder: (context, provider, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            if (provider.error != null) {
              return _buildCleanErrorState(provider.error!, themeProvider);
            }

            if (!provider.hasData) {
              return _buildCleanEmptyState(themeProvider);
            }

            return CustomScrollView(
              slivers: [
                // Data status banner if insufficient data
                if (!provider.hasSufficientData)
                  SliverToBoxAdapter(
                    child: _buildDataStatusBanner(provider, themeProvider),
                  ),
                
                // Primary metrics section
                SliverToBoxAdapter(
                  child: _buildPrimaryMetricsSection(provider, themeProvider),
                ),
                
                // Secondary analytics grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildListDelegate([
                      _buildCleanSleepCard(provider, themeProvider),
                      _buildCleanStressCard(provider, themeProvider), 
                      _buildCleanProductivityCard(provider, themeProvider),
                      _buildCleanMoodCard(provider, themeProvider),
                      _buildCleanEnergyCard(provider, themeProvider),
                      _buildCleanSocialCard(provider, themeProvider),
                    ]),
                  ),
                ),
                
                // Full width cards section
                SliverToBoxAdapter(
                  child: _buildFullWidthCardsSection(provider, themeProvider),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================================
  // DATA STATUS BANNER WIDGET
  // ============================================================================
  // DATA SOURCE: provider.hasSufficientData, provider.motivationalMessage
  // REQUIRED DATA: Boolean flag indicating data sufficiency
  // PURPOSE: Inform users about data limitations with encouragement
  // ============================================================================
  Widget _buildDataStatusBanner(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datos limitados disponibles',
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Continúa registrando para insights más precisos',
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PRIMARY METRICS SECTION WIDGET
  // ============================================================================
  // DATA SOURCE: provider.wellnessScore + Quick stats from multiple providers
  // REQUIRED DATA: WellnessScoreModel (5+ entries), Sleep/Stress/Goals data
  // PURPOSE: Main dashboard showing key wellness metrics at a glance
  // ============================================================================
  Widget _buildPrimaryMetricsSection(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
        children: [
          // Wellness score card (hero metric)
          if (provider.wellnessScore != null)
            _buildHeroWellnessCard(provider, themeProvider),
          if (provider.wellnessScore != null)
            const SizedBox(height: 20),
          // Quick stats row
          _buildCleanQuickStatsRow(provider, themeProvider),
        ],
      ),
    );
  }

  // ============================================================================
  // HERO WELLNESS CARD WITH MODERN EFFECTS
  // ============================================================================
  // DATA SOURCE: provider.wellnessScore (WellnessScoreModel)
  // REQUIRED DATA: 5+ daily entries for accurate wellness calculation
  // PURPOSE: Primary wellness score display with modern glass effects
  // ============================================================================
  Widget _buildHeroWellnessCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final wellness = provider.wellnessScore;
    if (wellness == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(-5, 5),
          ),
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
            child: Column(
        children: [
          // Header with badge
          Row(
            children: [
              Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Score de Bienestar',
                          style: ModernTypography.heading4.copyWith(
                            color: MinimalColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildDataBadge(5, 'entradas', color: ModernColors.success),
                      ],
                    ),
                  ],
                ),
              ),
              // Wellness level indicator with enhanced effects
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.positiveGradient(context),
                  ),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusRound),
                  boxShadow: [
                    BoxShadow(
                      color: MinimalColors.coloredShadow(context, MinimalColors.success, alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _getWellnessLevel(wellness.overallScore),
                  style: TextStyle(
                    color: _getWellnessColor(wellness.overallScore),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Score display
          Row(
            children: [
              Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${wellness.overallScore.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: MinimalColors.textPrimary(context),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '/10',
                          style: TextStyle(
                            color: MinimalColors.textSecondary(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Wellness level indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                  color: _getWellnessColor(wellness.overallScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getWellnessColor(wellness.overallScore).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getWellnessLevel(wellness.overallScore),
                  style: TextStyle(
                    color: _getWellnessColor(wellness.overallScore),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Component bars
          ...wellness.componentScores.entries.map((entry) => 
            _buildCleanComponentBar(entry.key, entry.value, themeProvider),
          ).toList(),
            ],
          ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // CLEAN COMPONENT BAR WIDGET (Helper)
  // ============================================================================
  Widget _buildCleanComponentBar(String key, double value, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _translateComponent(key),
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 6,
                    decoration: BoxDecoration(
                color: MinimalColors.backgroundSecondary(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 10.0).clamp(0.0, 1.0),
                child: Container(
                        decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: MinimalColors.primaryGradient(context),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CLEAN QUICK STATS ROW WIDGET
  // ============================================================================
  // DATA SOURCE: provider.sleepPattern, provider.stressManagement, Goals data
  // REQUIRED DATA: 7+ sleep records, 5+ stress ratings, Goals from EnhancedGoalsProvider
  // PURPOSE: Quick overview of key metrics in compact format
  // ============================================================================
  Widget _buildCleanQuickStatsRow(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildCompactMetricCard(
            'Sueño',
            '${provider.sleepPattern?.averageSleepHours.toStringAsFixed(1) ?? '--'}h',
            Icons.bedtime_outlined,
            themeProvider,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompactMetricCard(
            'Estrés',
            '${provider.stressManagement?.averageStressLevel.toStringAsFixed(1) ?? '--'}/10',
            Icons.psychology_outlined,
            themeProvider,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer<EnhancedGoalsProvider>(
            builder: (context, goalsProvider, _) {
              final stats = goalsProvider.goalStatistics;
              final completionRate = stats['completionRate'] ?? 0.0;
              return _buildCompactMetricCard(
                'Metas',
                '${(completionRate * 100).toStringAsFixed(0)}%',
                Icons.flag_outlined,
                themeProvider,
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // COMPACT METRIC CARD WITH MODERN EFFECTS
  // ============================================================================
  Widget _buildCompactMetricCard(String title, String value, IconData icon, ThemeProvider themeProvider) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_staggerAnimation.value * 0.02),
          child: Container(
            padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: themeProvider.accentPrimary,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: MinimalColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: MinimalColors.textSecondary(context),
                    fontSize: 12,
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

  // ============================================================================
  // GRID CARD WIDGETS (For 2-column layout)
  // ============================================================================

  // CLEAN SLEEP CARD - DATA: provider.sleepPattern (7+ sleep records)
  Widget _buildCleanSleepCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final sleep = provider.sleepPattern;
    return _buildGridCard(
      title: 'Sueño',
      value: sleep != null ? '${sleep.averageSleepHours.toStringAsFixed(1)}h' : '--',
      subtitle: sleep != null ? 'Promedio' : 'Sin datos',
      icon: Icons.bedtime,
      color: ModernColors.accentBlue,
      themeProvider: themeProvider,
      requiredData: 7,
      dataType: 'registros',
    );
  }

  // CLEAN STRESS CARD - DATA: provider.stressManagement (5+ stress ratings)
  Widget _buildCleanStressCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final stress = provider.stressManagement;
    return _buildGridCard(
      title: 'Estrés',
      value: stress != null ? '${stress.averageStressLevel.toStringAsFixed(1)}/10' : '--',
      subtitle: stress != null ? 'Promedio' : 'Sin datos',
      icon: Icons.psychology,
      color: ModernColors.accentOrange,
      themeProvider: themeProvider,
      requiredData: 5,
      dataType: 'ratings',
    );
  }

  // CLEAN PRODUCTIVITY CARD - DATA: provider.productivityPatterns (7+ productivity entries)
  Widget _buildCleanProductivityCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final productivity = provider.productivityPatterns;
    String value = '--';
    String subtitle = 'Sin datos';
    
    if (productivity != null && productivity['status'] != 'insufficient_data') {
      if (productivity['productivity_score'] != null) {
        value = '${productivity['productivity_score']?.toStringAsFixed(1)}/10';
        subtitle = 'Score';
      }
    }
    
    return _buildGridCard(
      title: 'Productividad',
      value: value,
      subtitle: subtitle,
      icon: Icons.trending_up,
      color: ModernColors.accentGreen,
      themeProvider: themeProvider,
      requiredData: 7,
      dataType: 'entradas',
    );
  }

  // CLEAN MOOD CARD - DATA: provider.moodStability (7+ mood entries)
  Widget _buildCleanMoodCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final mood = provider.moodStability;
    String value = '--';
    String subtitle = 'Sin datos';
    
    if (mood != null && mood['status'] != 'insufficient_data') {
      if (mood['stability_score'] != null) {
        value = '${mood['stability_score']?.toStringAsFixed(1)}/10';
        subtitle = 'Estabilidad';
      }
    }
    
    return _buildGridCard(
      title: 'Ánimo',
      value: value,
      subtitle: subtitle,
      icon: Icons.mood,
      color: ModernColors.accentPurple,
      themeProvider: themeProvider,
      requiredData: 7,
      dataType: 'entradas',
    );
  }

  // CLEAN ENERGY CARD - DATA: provider.energyPatterns (7+ energy entries)
  Widget _buildCleanEnergyCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final energy = provider.energyPatterns;
    String value = '--';
    String subtitle = 'Sin datos';
    
    if (energy != null && energy['status'] != 'insufficient_data') {
      if (energy['chronotype'] != null) {
        value = energy['chronotype'].toString();
        subtitle = 'Cronotipo';
      }
    }
    
    return _buildGridCard(
      title: 'Energía',
      value: value,
      subtitle: subtitle,
      icon: Icons.battery_charging_full,
      color: ModernColors.accentYellow,
      themeProvider: themeProvider,
      requiredData: 7,
      dataType: 'niveles',
    );
  }

  // CLEAN SOCIAL CARD - DATA: provider.socialWellness (5+ social interactions)
  Widget _buildCleanSocialCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final social = provider.socialWellness;
    String value = '--';
    String subtitle = 'Sin datos';
    
    if (social != null && social['status'] != 'insufficient_data') {
      if (social['social_wellness_score'] != null) {
        value = '${social['social_wellness_score']?.toStringAsFixed(1)}/10';
        subtitle = 'Score Social';
      }
    }
    
    return _buildGridCard(
      title: 'Social',
      value: value,
      subtitle: subtitle,
      icon: Icons.people,
      color: Color(0xFFE91E63), // Pink
      themeProvider: themeProvider,
      requiredData: 5,
      dataType: 'interacciones',
    );
  }

  // ============================================================================
  // GRID CARD HELPER WIDGET WITH MODERN EFFECTS AND DATA BADGES
  // ============================================================================
  Widget _buildGridCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required ThemeProvider themeProvider,
    required int requiredData,
    required String dataType,
  }) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_staggerAnimation.value * 0.01),
          child: Container(
            padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: MinimalColors.primaryGradient(context).map((c) => c.withOpacity(0.1)).toList(),
                  ),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              _buildDataBadge(requiredData, dataType, color: color),
            ],
          ),
          const SizedBox(height: ModernSpacing.md),
          Text(
            value,
            style: ModernTypography.heading2.copyWith(
              color: MinimalColors.textPrimary(context),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: ModernTypography.bodySmall.copyWith(
              color: MinimalColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            title,
            style: ModernTypography.bodyMedium.copyWith(
              color: MinimalColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // FULL WIDTH CARDS SECTION WIDGET
  // ============================================================================
  // DATA SOURCE: Various provider methods for lifestyle, habits, correlations
  // REQUIRED DATA: Variable per card type (documented individually)
  // PURPOSE: Detailed analytics cards that need full width for charts/lists
  // ============================================================================
  Widget _buildFullWidthCardsSection(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
        children: [
          // Correlations card
          if (provider.activityCorrelations.isNotEmpty)
            _buildCleanCorrelationsCard(provider, themeProvider),
          if (provider.activityCorrelations.isNotEmpty)
            const SizedBox(height: 20),
          
          // Lifestyle balance card  
          if (provider.lifestyleBalance != null && provider.lifestyleBalance!['status'] != 'insufficient_data')
            _buildCleanLifestyleCard(provider, themeProvider),
          if (provider.lifestyleBalance != null && provider.lifestyleBalance!['status'] != 'insufficient_data')
            const SizedBox(height: 20),
          
          // Habits consistency card
          if (provider.habitConsistency != null && provider.habitConsistency!['status'] != 'insufficient_data')
            _buildCleanHabitsCard(provider, themeProvider),
          if (provider.habitConsistency != null && provider.habitConsistency!['status'] != 'insufficient_data')
            const SizedBox(height: 20),
          
          // Insights card
          if (provider.topInsights.isNotEmpty || provider.topRecommendations.isNotEmpty)
            _buildCleanInsightsCard(provider, themeProvider),
        ],
      ),
    );
  }

  // ============================================================================
  // CLEAN FULL-WIDTH CARD IMPLEMENTATIONS
  // ============================================================================

  // CORRELATIONS CARD - DATA: provider.activityCorrelations (10+ activity entries)
  Widget _buildCleanCorrelationsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final correlations = provider.activityCorrelations;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
              color: MinimalColors.backgroundCard(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(-5, 5),
                ),
                BoxShadow(
                  color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.accentGreen.withOpacity(0.2),
                      ModernColors.accentGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.accentGreen.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.trending_up,
                  color: ModernColors.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Correlaciones Clave',
                  style: ModernTypography.heading4.copyWith(
                    color: themeProvider.textPrimary,
                  ),
                ),
              ),
              _buildDataBadge(10, 'actividades', color: ModernColors.accentGreen),
            ],
          ),
          const SizedBox(height: ModernSpacing.lg),
          ...correlations.take(3).map((correlation) => Padding(
            padding: const EdgeInsets.symmetric(vertical: ModernSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${correlation.activityName} → ${correlation.targetMetric}',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: themeProvider.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCorrelationColorClean(correlation.correlationStrength),
                        _getCorrelationColorClean(correlation.correlationStrength).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: _getCorrelationColorClean(correlation.correlationStrength).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${(correlation.correlationStrength * 100).toStringAsFixed(0)}%',
                    style: ModernTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
        ),
          ),
        );
      },
    );
  }

  // LIFESTYLE CARD - DATA: provider.lifestyleBalance (10+ entries across life areas)
  Widget _buildCleanLifestyleCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final lifestyle = provider.lifestyleBalance;
    if (lifestyle == null) return const SizedBox();
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 50, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(-5, 5),
          ),
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.accentPurple.withOpacity(0.2),
                      ModernColors.accentPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.accentPurple.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.balance,
                  color: ModernColors.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Balance de Vida',
                  style: ModernTypography.heading4.copyWith(
                    color: themeProvider.textPrimary,
                  ),
                ),
              ),
              _buildDataBadge(10, 'áreas', color: ModernColors.accentPurple),
              const SizedBox(width: 12),
              if (lifestyle['balance_score'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ModernColors.positiveGradient,
                    ),
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusRound),
                    boxShadow: ModernShadows.card,
                  ),
                  child: Text(
                    '${lifestyle['balance_score']?.toStringAsFixed(1)}/10',
                    style: ModernTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (lifestyle['life_areas'] != null) ...[
            const SizedBox(height: ModernSpacing.lg),
            ...lifestyle['life_areas'].entries.take(4).map<Widget>((entry) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        entry.key.toString().replaceAll('_', ' ').toUpperCase(),
                        style: ModernTypography.caption.copyWith(
                          color: themeProvider.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 8,
                              decoration: BoxDecoration(
                          color: ModernColors.borderSecondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (entry.value as num).toDouble() / 10,
                          child: Container(
                                  decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: ModernColors.positiveGradient,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: ModernColors.accentGreen.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(entry.value as num).toStringAsFixed(1)}',
                      style: ModernTypography.bodySmall.copyWith(
                        color: themeProvider.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ],
        ],
        ),
          ),
        );
      },
    );
  }

  // HABITS CARD - DATA: provider.habitConsistency (14+ habit tracking entries)
  Widget _buildCleanHabitsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final habits = provider.habitConsistency;
    if (habits == null) return const SizedBox();
    
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_staggerAnimation.value * 0.01),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(-5, 5),
          ),
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.info.withOpacity(0.2),
                      ModernColors.info.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.info.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.track_changes,
                  color: ModernColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Consistencia de Hábitos',
                  style: ModernTypography.heading4.copyWith(
                    color: themeProvider.textPrimary,
                  ),
                ),
              ),
              _buildDataBadge(14, 'seguimientos', color: ModernColors.info),
            ],
          ),
          const SizedBox(height: ModernSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(ModernSpacing.md),
                        decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernColors.success.withOpacity(0.1),
                        ModernColors.success.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
                    border: Border.all(
                      color: ModernColors.success.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score',
                        style: ModernTypography.caption.copyWith(
                          color: themeProvider.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habits['consistency_score'] != null 
                          ? '${habits['consistency_score']?.toStringAsFixed(1)}/10'
                          : '--',
                        style: ModernTypography.heading3.copyWith(
                          color: themeProvider.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(ModernSpacing.md),
                        decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernColors.warning.withOpacity(0.1),
                        ModernColors.warning.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ModernSpacing.radiusMedium),
                    border: Border.all(
                      color: ModernColors.warning.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Racha Máxima',
                        style: ModernTypography.caption.copyWith(
                          color: themeProvider.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habits['longest_streak'] != null 
                          ? '${habits['longest_streak']} días'
                          : '--',
                        style: ModernTypography.heading3.copyWith(
                          color: themeProvider.textPrimary,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
          ),
        );
      },
    );
  }

  // INSIGHTS CARD - DATA: provider.topInsights, provider.topRecommendations
  Widget _buildCleanInsightsCard(AnalyticsV3Provider provider, ThemeProvider themeProvider) {
    final insights = provider.topInsights;
    final recommendations = provider.topRecommendations;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fadeAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
        color: MinimalColors.backgroundCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[0].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(-5, 5),
          ),
          BoxShadow(
            color: MinimalColors.primaryGradient(context)[1].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
        ],
      ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                      decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernColors.accentYellow.withOpacity(0.2),
                      ModernColors.accentYellow.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: ModernColors.accentYellow.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: ModernColors.accentYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Insights y Recomendaciones',
                  style: ModernTypography.heading4.copyWith(
                    color: themeProvider.textPrimary,
                  ),
                ),
              ),
              _buildDataBadge(3, 'análisis', color: ModernColors.accentYellow),
            ],
          ),
          if (insights.isNotEmpty) ...[
            const SizedBox(height: ModernSpacing.lg),
            ...insights.take(2).map((insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: ModernSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                          decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ModernColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.accentBlue.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: ModernTypography.bodyMedium.copyWith(
                        color: themeProvider.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: ModernSpacing.md),
            ...recommendations.take(2).map((rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: ModernSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ModernColors.positiveGradient,
                      ),
                      borderRadius: BorderRadius.circular(ModernSpacing.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.accentGreen.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rec,
                      style: ModernTypography.bodyMedium.copyWith(
                        color: themeProvider.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
        ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // CLEAN ERROR AND EMPTY STATES
  // ============================================================================

  Widget _buildCleanErrorState(String error, ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: themeProvider.negativeMain,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAnalyticsData,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.accentPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              color: themeProvider.textHint,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Sin datos disponibles',
              style: TextStyle(
                color: MinimalColors.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza a registrar tus actividades diarias para ver análisis detallados de tu bienestar.',
              style: TextStyle(
                color: MinimalColors.textSecondary(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER FUNCTIONS FOR NEW DESIGN
  // ============================================================================

  Color _getWellnessColor(double score) {
    if (score >= 8.0) return Colors.green;
    if (score >= 6.0) return Colors.lime;
    if (score >= 4.0) return Colors.orange;
    return Colors.red;
  }

  String _getWellnessLevel(double score) {
    if (score >= 8.0) return 'Excelente';
    if (score >= 6.0) return 'Bueno';
    if (score >= 4.0) return 'Regular';
    return 'Necesita Atención';
  }

  Color _getCorrelationColorClean(double strength) {
    final absStrength = strength.abs();
    if (absStrength >= 0.7) {
      return strength > 0 ? Colors.green : Colors.red;
    } else if (absStrength >= 0.3) {
      return strength > 0 ? Colors.lightGreen : Colors.deepOrange;
    } else {
      return Colors.grey;
    }
  }

  // ============================================================================
  // EXISTING HELPER METHODS (Updated to support new design)
  // ============================================================================

  void _updatePeriod(int newPeriod) {
    if (_selectedPeriod == newPeriod || _isLoading) return;
    
    setState(() => _selectedPeriod = newPeriod);
    
    final provider = Provider.of<AnalyticsV3Provider>(context, listen: false);
    provider.setPeriodDays(newPeriod);
    
    // Reset animations before loading new data
    _fadeController.reset();
    _slideController.reset();
    _staggerController.reset();
    
    _loadAnalyticsData();
  }

  String _getPeriodLabel(int days) {
    switch (days) {
      case 7: return '7 días';
      case 30: return '30 días';
      case 90: return '90 días';
      default: return '$days días';
    }
  }

  String _translateComponent(String component) {
    final translations = {
      'mood': 'Estado de Ánimo',
      'energy': 'Energía',
      'stress': 'Estrés',
      'sleep': 'Sueño',
      'anxiety': 'Ansiedad',
      'motivation': 'Motivación',
      'emotional_stability': 'Estabilidad Emocional',
      'life_satisfaction': 'Satisfacción',
    };
    return translations[component] ?? component;
  }

}