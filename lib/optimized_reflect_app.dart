// lib/optimized_reflect_app.dart
// Aplicación principal con navegación y providers

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'injection_container_clean.dart' as clean_di;

// Providers
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/extended_daily_entries_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/image_moments_provider.dart';
import 'presentation/providers/analytics_provider.dart';
import 'presentation/providers/analytics_v3_provider.dart';
import 'presentation/providers/advanced_emotion_analysis_provider.dart';
import 'presentation/providers/challenges_provider.dart';
import 'presentation/providers/streak_provider.dart';
import 'presentation/providers/recommended_activities_provider.dart';
import 'presentation/providers/daily_activities_provider.dart';
import 'presentation/providers/daily_roadmap_provider.dart';
import 'presentation/providers/enhanced_goals_provider.dart';
import 'presentation/providers/hopecore_quotes_provider.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/insights_provider.dart';

// Screens
import 'presentation/screens/v2/login_screen_v2.dart';
import 'presentation/screens/v2/main_navigation_screen_v2.dart';
import 'presentation/screens/v2/welcome_onboarding_screen.dart';

// Components
import 'presentation/screens/components/modern_design_system.dart';

class OptimizedReflectApp extends StatelessWidget {
  const OptimizedReflectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ============================================================================
        // CORE PROVIDERS
        // ============================================================================
        ChangeNotifierProvider<OptimizedAuthProvider>(
          create: (_) => clean_di.sl<OptimizedAuthProvider>()..initialize(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => clean_di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<GoalsProvider>(
          create: (_) => clean_di.sl<GoalsProvider>(),
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, EnhancedGoalsProvider>(
          create: (_) => clean_di.sl<EnhancedGoalsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadGoals(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProvider<ImageMomentsProvider>(
          create: (_) => clean_di.sl<ImageMomentsProvider>(),
        ),

        ChangeNotifierProvider<HopecoreQuotesProvider>(
          create: (_) => clean_di.sl<HopecoreQuotesProvider>(),
        ),

        ChangeNotifierProvider<OnboardingProvider>(
          create: (_) => clean_di.sl<OnboardingProvider>()..initialize(),
        ),

        // ============================================================================
        // DEPENDENT PROVIDERS
        // ============================================================================
        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedDailyEntriesProvider>(
          create: (_) => clean_di.sl<OptimizedDailyEntriesProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadEntries(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, ExtendedDailyEntriesProvider>(
          create: (_) => clean_di.sl<ExtendedDailyEntriesProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadEntries(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedMomentsProvider>(
          create: (_) => clean_di.sl<OptimizedMomentsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadMoments(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, OptimizedAnalyticsProvider>(
          create: (_) => clean_di.sl<OptimizedAnalyticsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadCompleteAnalytics(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, AnalyticsProvider>(
          create: (_) => clean_di.sl<AnalyticsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadCompleteAnalytics(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, AnalyticsV3Provider>(
          create: (_) => clean_di.sl<AnalyticsV3Provider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadAnalytics(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, AnalyticsProviderV4>(
          create: (_) => clean_di.sl<AnalyticsProviderV4>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadAllAnalytics(auth.currentUser!.id);
            }
            return previous!;
          },
        ),

        ChangeNotifierProvider<ChallengesProvider>(
          create: (_) => clean_di.sl<ChallengesProvider>(),
        ),

        ChangeNotifierProvider<StreakProvider>(
          create: (_) => clean_di.sl<StreakProvider>(),
        ),

        ChangeNotifierProvider<AdvancedEmotionAnalysisProvider>(
          create: (_) => clean_di.sl<AdvancedEmotionAnalysisProvider>(),
        ),

        ChangeNotifierProvider<RecommendedActivitiesProvider>(
          create: (_) => clean_di.sl<RecommendedActivitiesProvider>(),
        ),

        ChangeNotifierProvider<DailyActivitiesProvider>(
          create: (_) => clean_di.sl<DailyActivitiesProvider>(),
        ),

        ChangeNotifierProvider<DailyRoadmapProvider>(
          create: (_) => clean_di.sl<DailyRoadmapProvider>(),
        ),

        ChangeNotifierProxyProvider<OptimizedAuthProvider, InsightsProvider>(
          create: (_) => clean_di.sl<InsightsProvider>(),
          update: (context, auth, previous) {
            if (auth.isLoggedIn && auth.currentUser != null) {
              previous?.loadInsights(auth.currentUser!.id);
            }
            return previous!;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ReflectFlutter',
            debugShowCheckedModeBanner: false,
            theme: ModernTheme.darkTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/onboarding': (context) => const WelcomeOnboardingScreen(),
              '/login': (context) => const LoginScreenV2(),
              '/main': (context) => const MainNavigationScreenV2(),
            },
          );
        },
      ),
    );
  }
}

// Wrapper para decidir la pantalla inicial
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeUser();
    });
  }

  Future<void> _checkFirstTimeUser() async {
    final authProvider = context.read<OptimizedAuthProvider>();
    await authProvider.checkFirstTimeUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OptimizedAuthProvider>(
      builder: (context, auth, child) {
        // Loading state
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check for first time user
        if (auth.isFirstTimeUser) {
          return const WelcomeOnboardingScreen();
        }

        // Single profile per device - skip login screen
        if (auth.isLoggedIn) {
          return const MainNavigationScreenV2();
        } else {
          // This shouldn't happen with single profile per device
          // but fallback to onboarding if no user found
          return const WelcomeOnboardingScreen();
        }
      },
    );
  }
}

// ============================================================================
// HELPER PARA LOGGING
// ============================================================================

final Logger _logger = clean_di.sl<Logger>();

void logProvider(String providerName, String action) {
  _logger.d('🔄 Provider: $providerName - Action: $action');
}

// ============================================================================
// EJEMPLO DE USO DE LOGGING
// ============================================================================

void exampleUsage() {
  logProvider('OptimizedAuthProvider', 'Initializing...');
  // ...
  logProvider('OptimizedAuthProvider', 'User logged in');
}

// ============================================================================
// VERIFICACIÓN DE ESTADO DE PROVIDERS
// ============================================================================

void checkProviderStatus(BuildContext context) {
  final authProvider = Provider.of<OptimizedAuthProvider>(context, listen: false);
  final dailyEntriesProvider = Provider.of<OptimizedDailyEntriesProvider>(context, listen: false);

  _logger.i('Provider Status Check:');
  _logger.i('  - AuthProvider Logged In: ${authProvider.isLoggedIn}');
  _logger.i('  - DailyEntriesProvider Entries Loaded: ${dailyEntriesProvider.entries.isNotEmpty}');
}

// ============================================================================
// INICIALIZACIÓN DE SERVICIOS CRÍTICOS
// ============================================================================

Future<void> initializeCriticalServices() async {
  await clean_di.initCriticalServices();
}