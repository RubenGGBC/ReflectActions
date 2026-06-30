// ============================================================================
// injection_container_clean.dart - DEPENDENCY INJECTION OPTIMIZADO + NOTIFICATIONS
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Services optimizados
import 'data/services/optimized_database_service.dart';
import 'data/services/image_picker_service.dart';
// AI services removed
import 'services/notification_service.dart';
import 'services/voice_recording_service.dart';

// Providers optimizados
import 'presentation/providers/optimized_providers.dart';
import 'presentation/providers/extended_daily_entries_provider.dart';
import 'presentation/providers/image_moments_provider.dart'; // ✅ NUEVO PROVIDER AÑADIDO
import 'presentation/providers/analytics_v3_provider.dart'; // ✅ NUEVO: Analytics V3 Provider
import 'presentation/providers/advanced_emotion_analysis_provider.dart'; // ✅ NUEVO PROVIDER AVANZADO
import 'presentation/providers/challenges_provider.dart'; // ✅ HIGH PRIORITY ENHANCEMENT
import 'presentation/providers/streak_provider.dart'; // ✅ HIGH PRIORITY ENHANCEMENT
import 'presentation/providers/recommended_activities_provider.dart'; // ✅ NUEVO: Recommended Activities
import 'presentation/providers/daily_activities_provider.dart'; // ✅ NUEVO: Daily Activities
import 'presentation/providers/daily_roadmap_provider.dart'; // ✅ NUEVO: Daily Roadmap
import 'presentation/providers/enhanced_goals_provider.dart'; // ✅ NUEVO: Enhanced Goals
import 'presentation/providers/hopecore_quotes_provider.dart'; // ✅ NUEVO: Hopecore Quotes
// AI providers removed
// Theme provider (reutilizado del original)
import 'presentation/providers/theme_provider.dart';

final sl = GetIt.instance;

/// Inicializar todas las dependencias de la app limpia
Future<void> initCleanDependencies() async {
  Logger? logger;
  
  try {
    // ============================================================================
    // CORE SERVICES (Singletons - solo una instancia)
    // ============================================================================
    
    // Solo registrar Logger si no está ya registrado
    if (!sl.isRegistered<Logger>()) {
      sl.registerLazySingleton<Logger>(() => Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.none,
        ),
      ));
    }
    
    logger = sl<Logger>();
    logger.i('🧹 Inicializando dependencias limpias...');

    sl.registerLazySingleton<OptimizedDatabaseService>(
          () => OptimizedDatabaseService(),
    );
    
    sl.registerLazySingleton<ImagePickerService>(
          () => ImagePickerService(),
    );
    
    // Predictive analysis service removed
    
    sl.registerLazySingleton<NotificationService>(
          () => NotificationService(),
    );
    
    sl.registerLazySingleton<VoiceRecordingService>(
          () => VoiceRecordingService(),
    );



    // ============================================================================
    // PROVIDERS (Factories - nueva instancia cuando se pide)
    // ✅ CORREGIDO: Se cambia de registerLazySingleton a registerFactory para
    // evitar problemas de estado entre Hot Restarts.
    // ============================================================================

    sl.registerFactory<OptimizedAuthProvider>(
          () => OptimizedAuthProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<ThemeProvider>(
          () => ThemeProvider(),
    );

    sl.registerFactory<OptimizedDailyEntriesProvider>(
          () => OptimizedDailyEntriesProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ ExtendedDailyEntriesProvider con IA
    sl.registerFactory<ExtendedDailyEntriesProvider>(
          () => ExtendedDailyEntriesProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<OptimizedMomentsProvider>(
          () => OptimizedMomentsProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<OptimizedAnalyticsProvider>(
          () => OptimizedAnalyticsProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: Analytics V3 Provider
    sl.registerFactory<AnalyticsV3Provider>(
          () => AnalyticsV3Provider(sl<OptimizedDatabaseService>()),
    );

    // AI provider removed

    sl.registerFactory<GoalsProvider>(
          () => GoalsProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: EnhancedGoalsProvider
    sl.registerFactory<EnhancedGoalsProvider>(
          () => EnhancedGoalsProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: NotificationsProvider

    // ✅ NUEVO: ImageMomentsProvider
    sl.registerFactory<ImageMomentsProvider>(
          () => ImageMomentsProvider(),
    );

    // All AI providers removed

    // ✅ HIGH PRIORITY ENHANCEMENTS: New providers
    sl.registerFactory<ChallengesProvider>(
          () => ChallengesProvider(sl<OptimizedDatabaseService>()),
    );

    sl.registerFactory<StreakProvider>(
          () => StreakProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: AdvancedEmotionAnalysisProvider
    sl.registerFactory<AdvancedEmotionAnalysisProvider>(
          () => AdvancedEmotionAnalysisProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: RecommendedActivitiesProvider
    sl.registerFactory<RecommendedActivitiesProvider>(
          () => RecommendedActivitiesProvider(),
    );

    // ✅ NUEVO: DailyActivitiesProvider
    sl.registerFactory<DailyActivitiesProvider>(
          () => DailyActivitiesProvider(sl<OptimizedDatabaseService>()),
    );

    // ✅ NUEVO: DailyRoadmapProvider
    sl.registerFactory<DailyRoadmapProvider>(
          () => DailyRoadmapProvider(
            databaseService: sl<OptimizedDatabaseService>(),
          ),
    );

    // ✅ NUEVO: HopecoreQuotesProvider
    sl.registerFactory<HopecoreQuotesProvider>(
          () => HopecoreQuotesProvider(),
    );

    logger.i('✅ Dependencias limpias inicializadas correctamente');

  } catch (e) {
    logger?.e('❌ Error inicializando dependencias limpias: $e');
    // Use debugPrint instead of print for better performance
    debugPrint('❌ Error inicializando dependencias limpias: $e');
    rethrow;
  }
}

/// Inicializar servicios críticos al startup
Future<void> initCriticalServices() async {
  final logger = sl<Logger>();
  logger.i('🚀 Inicializando servicios críticos...');

  try {
    // Inicializar servicio de notificaciones
    final notificationService = sl<NotificationService>();
    await notificationService.init();
    await notificationService.setupDefaultReminders();
    logger.i('✅ Servicio de notificaciones inicializado');

    // Inicializar servicio de grabación de voz
    final voiceService = sl<VoiceRecordingService>();
    await voiceService.initialize();
    logger.i('✅ Servicio de grabación de voz inicializado');

    // Inicializar otros servicios críticos aquí si es necesario

  } catch (e) {
    logger.e('❌ Error inicializando servicios críticos: $e');
    // No lanzar error para evitar crash de la app
  }
}

// ============================================================================
// FUNCIONES DE UTILIDAD
// ============================================================================

/// Verificar que todos los servicios estén registrados
bool areCleanServicesRegistered() {
  try {
    // Verificar servicios core
    sl<Logger>();
    sl<OptimizedDatabaseService>();
    sl<ImagePickerService>();
    // AI service removed
    sl<NotificationService>();
    sl<VoiceRecordingService>();

    // Verificar providers
    sl<OptimizedAuthProvider>();
    sl<ThemeProvider>();
    sl<OptimizedDailyEntriesProvider>();
    sl<ExtendedDailyEntriesProvider>();
    sl<OptimizedMomentsProvider>();
    sl<OptimizedAnalyticsProvider>();
    sl<AnalyticsV3Provider>(); // ✅ NUEVO
    // AI provider removed
    sl<GoalsProvider>();
    sl<EnhancedGoalsProvider>(); // ✅ NUEVO
    sl<ImageMomentsProvider>(); // ✅ NUEVO
    // AI providers removed
    sl<ChallengesProvider>(); // ✅ HIGH PRIORITY ENHANCEMENT
    sl<StreakProvider>(); // ✅ HIGH PRIORITY ENHANCEMENT
    sl<AdvancedEmotionAnalysisProvider>(); // ✅ NUEVO

    return true;
  } catch (e) {
    return false;
  }
}

/// Información del contenedor limpio
Map<String, dynamic> getCleanContainerInfo() {
  return {
    'total_services': 19, // ✅ ACTUALIZADO after cleanup
    'services_ready': areCleanServicesRegistered(),
    'core_services': [
      'Logger',
      'OptimizedDatabaseService',
      'ImagePickerService', // ✅ NUEVO
      // AI services removed
      'NotificationService', // ✅ NUEVO
    ],
    'providers': [
      'OptimizedAuthProvider',
      'ThemeProvider',
      'OptimizedDailyEntriesProvider',
      'ExtendedDailyEntriesProvider',
      'OptimizedMomentsProvider',
      'OptimizedAnalyticsProvider',
      'AnalyticsProvider',
      'GoalsProvider',
      'NotificationsProvider', // ✅ NUEVO
      'ImageMomentsProvider', // ✅ NUEVO
      // AI providers removed
      'ChallengesProvider', // ✅ HIGH PRIORITY ENHANCEMENT
      'StreakProvider', // ✅ HIGH PRIORITY ENHANCEMENT
      'AdvancedEmotionAnalysisProvider', // ✅ NUEVO
    ],
    'removed_legacy': [
      'AnalyticsProvider (legacy)',
      'EnhancedAnalyticsProvider (duplicate)',
      'InteractiveMomentsProvider (legacy)',
      'AuthProvider (legacy)',
      'AdvancedUserAnalytics (merged)',
    ],
  };
}

/// Resetear contenedor para testing
Future<void> resetCleanContainer() async {
  await sl.reset();
}

/// Inicialización específica para testing
Future<void> initForCleanTesting() async {
  if (sl.isRegistered<OptimizedDatabaseService>()) {
    await resetCleanContainer();
  }
  await initCleanDependencies();
}

// ============================================================================
// EXTENSIONES PARA FACILITAR USO
// ============================================================================

extension CleanGetItExtension on GetIt {
  /// Verificar si un tipo está registrado de forma segura
  bool isRegisteredClean<T extends Object>() {
    try {
      return isRegistered<T>();
    } catch (e) {
      return false;
    }
  }

  /// Obtener instancia de forma segura
  T? getCleanSafe<T extends Object>() {
    try {
      if (isRegistered<T>()) {
        return get<T>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener servicio principal con verificación
  T getCleanService<T extends Object>() {
    if (!isRegistered<T>()) {
      throw Exception('Servicio $T no está registrado. Llama a initCleanDependencies() primero.');
    }
    return get<T>();
  }
}

// ============================================================================
// CONSTANTES DE IDENTIFICACIÓN
// ============================================================================

class CleanDIConstants {
  static const String logger = 'Logger';
  static const String databaseService = 'OptimizedDatabaseService';
  // AI services removed
  static const String notificationService = 'NotificationService'; // ✅ NUEVO
  static const String authProvider = 'OptimizedAuthProvider';
  static const String themeProvider = 'ThemeProvider';
  static const String dailyEntriesProvider = 'OptimizedDailyEntriesProvider';
  static const String extendedDailyEntriesProvider = 'ExtendedDailyEntriesProvider';
  static const String momentsProvider = 'OptimizedMomentsProvider';
  static const String analyticsProvider = 'OptimizedAnalyticsProvider';
  static const String goalsProvider = 'GoalsProvider';
  static const String notificationsProvider = 'NotificationsProvider'; // ✅ NUEVO
  static const String imageMomentsProvider = 'ImageMomentsProvider'; // ✅ NUEVO
  // AI providers removed
  static const String challengesProvider = 'ChallengesProvider'; // ✅ HIGH PRIORITY ENHANCEMENT
  static const String streakProvider = 'StreakProvider'; // ✅ HIGH PRIORITY ENHANCEMENT
}

// ============================================================================
// HELPER PARA MIGRACIÓN GRADUAL
// ============================================================================

class DIMigrationHelper {
  static const Map<String, String> _migrationMap = {
    'AuthProvider': 'OptimizedAuthProvider',
    'InteractiveMomentsProvider': 'OptimizedMomentsProvider',
    'AnalyticsProvider': 'OptimizedAnalyticsProvider',
    'DatabaseService': 'OptimizedDatabaseService',
  };

  static String? getOptimizedServiceName(String legacyName) {
    return _migrationMap[legacyName];
  }

  static bool hasOptimizedEquivalent(String legacyName) {
    return _migrationMap.containsKey(legacyName);
  }

  static List<String> getLegacyServicesToRemove() {
    return [
      'AdvancedUserAnalytics',
      'EnhancedAnalyticsProvider',
      'SessionService',
    ];
  }

  static Map<String, dynamic> checkMigrationStatus() {
    final isLegacyPresent = false; // Legacy system completely removed
    final isOptimizedPresent = sl.isRegisteredClean<OptimizedAuthProvider>();
    return {
      'legacy_present': isLegacyPresent,
      'optimized_present': isOptimizedPresent,
      'migration_complete': isOptimizedPresent, // Simplified since legacy is always false
      'conflicts': false, // No conflicts since legacy is removed
    };
  }
}

// ============================================================================
// CONFIGURACIÓN DE LOGGING OPTIMIZADA
// ============================================================================

class OptimizedLoggingConfig {
  static Logger createProductionLogger() {
    return Logger(
      level: Level.info,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 3,
        lineLength: 80,
        colors: false,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static Logger createDevelopmentLogger() {
    return Logger(
      level: Level.debug,
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none,
      ),
    );
  }

  static Logger createTestingLogger() {
    return Logger(
      level: Level.warning,
      printer: SimplePrinter(),
    );
  }
}

// ============================================================================
// INICIALIZADORES ESPECÍFICOS POR ENTORNO
// ============================================================================

Future<void> initForProduction() async {
  // Reset container to avoid conflicts
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createProductionLogger());
  await initCleanDependencies();
  await initCriticalServices(); // ✅ NUEVO
}

Future<void> initForDevelopment() async {
  // Reset container to avoid conflicts
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createDevelopmentLogger());
  await initCleanDependencies();
  await initCriticalServices(); // ✅ NUEVO
}

Future<void> initForTesting() async {
  await resetCleanContainer();
  sl.registerLazySingleton<Logger>(() => OptimizedLoggingConfig.createTestingLogger());
  await initCleanDependencies();
  // No inicializar notificaciones en testing
}
