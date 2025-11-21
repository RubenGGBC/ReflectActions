// ============================================================================
// SEED TEST DATA SCRIPT - EASY TO USE DATA SEEDING UTILITY
// ============================================================================

import 'package:flutter/foundation.dart';
import '../data/services/optimized_database_service.dart';
import 'enhanced_test_data_seeder.dart';

/// Simple script to seed comprehensive test data for a user
/// 
/// Usage:
/// ```dart
/// await seedTestDataForUser(userId: 1);
/// ```
class SeedTestDataScript {
  static Future<void> seedTestDataForUser({
    required int userId,
    bool clearExistingData = false,
  }) async {
    if (kDebugMode) {
      debugPrint('🚀 Starting comprehensive test data seeding for user $userId...');
    }

    try {
      // Initialize database service
      final databaseService = OptimizedDatabaseService();
      await databaseService.database; // This initializes the database

      // Initialize enhanced test data seeder
      final seeder = EnhancedTestDataSeeder(databaseService);

      // Clear existing data if requested
      if (clearExistingData) {
        if (kDebugMode) {
          debugPrint('🧹 Clearing existing test data...');
        }
        await seeder.clearEnhancedTestData(userId);
      }

      // Seed comprehensive test data
      await seeder.seedEnhancedTestData(userId);

      if (kDebugMode) {
        debugPrint('✅ Test data seeding completed successfully!');
        debugPrint('📊 Data seeded includes:');
        debugPrint('   • Enhanced user profile information');
        debugPrint('   • 45+ days of quick moments (2-5 per day)');
        debugPrint('   • 60 days of detailed daily reviews');
        debugPrint('   • 5 comprehensive goals with milestones and metrics');
        debugPrint('   • 14 days of structured daily roadmaps');
        debugPrint('   • Realistic activity completion patterns');
        debugPrint('   • Varied emotional data and reflections');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during test data seeding: $e');
      }
      rethrow;
    }
  }

  /// Seed only specific data types
  static Future<void> seedSpecificDataTypes({
    required int userId,
    bool seedUserInfo = true,
    bool seedQuickMoments = true,
    bool seedDailyReviews = true,
    bool seedGoals = true,
    bool seedRoadmaps = true,
  }) async {
    if (kDebugMode) {
      debugPrint('🎯 Seeding specific data types for user $userId...');
    }

    try {
      final databaseService = OptimizedDatabaseService();
      await databaseService.database;
      final seeder = EnhancedTestDataSeeder(databaseService);

      if (seedUserInfo) {
        await seeder.seedUserInfo(userId);
        if (kDebugMode) debugPrint('✅ User info seeded');
      }

      if (seedQuickMoments) {
        await seeder.seedQuickMoments(userId);
        if (kDebugMode) debugPrint('✅ Quick moments seeded');
      }

      if (seedDailyReviews) {
        await seeder.seedDailyReviews(userId);
        if (kDebugMode) debugPrint('✅ Daily reviews seeded');
      }

      if (seedGoals) {
        await seeder.seedEnhancedGoals(userId);
        if (kDebugMode) debugPrint('✅ Enhanced goals seeded');
      }

      if (seedRoadmaps) {
        await seeder.seedDailyRoadmaps(userId);
        if (kDebugMode) debugPrint('✅ Daily roadmaps seeded');
      }

      if (kDebugMode) {
        debugPrint('🎉 Specific data seeding completed!');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error during specific data seeding: $e');
      }
      rethrow;
    }
  }

  /// Clear all test data for a user
  static Future<void> clearTestDataForUser({required int userId}) async {
    if (kDebugMode) {
      debugPrint('🧹 Clearing all test data for user $userId...');
    }

    try {
      final databaseService = OptimizedDatabaseService();
      await databaseService.database;
      final seeder = EnhancedTestDataSeeder(databaseService);

      await seeder.clearEnhancedTestData(userId);

      if (kDebugMode) {
        debugPrint('✅ All test data cleared successfully!');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error clearing test data: $e');
      }
      rethrow;
    }
  }

  /// Quick setup for development and testing
  static Future<void> quickDevelopmentSetup({int userId = 1}) async {
    if (kDebugMode) {
      debugPrint('⚡ Quick development setup starting...');
      debugPrint('   This will seed comprehensive test data for user $userId');
    }

    await seedTestDataForUser(
      userId: userId,
      clearExistingData: true,
    );

    if (kDebugMode) {
      debugPrint('⚡ Quick development setup completed!');
      debugPrint('   Your app now has rich test data to work with.');
      debugPrint('   User ID: $userId');
    }
  }

  /// Demo data for showcasing app features
  static Future<void> createDemoData({int userId = 999}) async {
    if (kDebugMode) {
      debugPrint('🎪 Creating demo data for user $userId...');
    }

    await seedTestDataForUser(
      userId: userId,
      clearExistingData: true,
    );

    if (kDebugMode) {
      debugPrint('🎪 Demo data created successfully!');
      debugPrint('   Perfect for showcasing app features and capabilities.');
      debugPrint('   Demo User ID: $userId');
    }
  }
}

/// Convenience functions for common operations

/// Seed comprehensive test data for the default user (ID: 1)
Future<void> seedDefaultUserTestData() async {
  await SeedTestDataScript.seedTestDataForUser(userId: 1);
}

/// Quick setup for development
Future<void> quickDevSetup() async {
  await SeedTestDataScript.quickDevelopmentSetup();
}

/// Create demo data
Future<void> createDemoData() async {
  await SeedTestDataScript.createDemoData();
}

/// Clear test data for default user
Future<void> clearDefaultUserTestData() async {
  await SeedTestDataScript.clearTestDataForUser(userId: 1);
}

/// Example usage in main.dart or during app initialization:
/// 
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // For development builds, seed test data
///   if (kDebugMode) {
///     try {
///       await quickDevSetup();
///     } catch (e) {
///       debugPrint('Failed to seed test data: $e');
///     }
///   }
///   
///   runApp(MyApp());
/// }
/// ```
///
/// Or call specific functions when needed:
/// 
/// ```dart
/// // In a development screen or debug menu
/// ElevatedButton(
///   onPressed: () async {
///     await seedDefaultUserTestData();
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text('Test data seeded successfully!')),
///     );
///   },
///   child: Text('Seed Test Data'),
/// )
/// ```