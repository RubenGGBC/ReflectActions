// ============================================================================
// V4 SEEDER RUNNER - EASY WAY TO SEED V4 ANALYTICS DATA
// ============================================================================

import 'package:flutter/foundation.dart';
import '../data/services/optimized_database_service.dart';
import 'v4_analytics_test_data_seeder.dart';

class V4SeederRunner {
  static Future<void> seedDataForCurrentUser(int userId) async {
    if (!kDebugMode) {
      debugPrint('⚠️ V4 seeder only runs in debug mode');
      return;
    }
    
    try {
      debugPrint('🚀 Starting V4 Analytics data seeding...');
      
      final databaseService = OptimizedDatabaseService();
      final seeder = V4AnalyticsTestDataSeeder(databaseService);
      
      await seeder.seedV4AnalyticsData(userId);
      
      debugPrint('🎉 V4 Analytics data seeding completed successfully!');
      debugPrint('📱 You can now navigate to the Analytics V4 screen to see the data');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error seeding V4 analytics data: $e');
      debugPrint('📋 Stack trace: $stackTrace');
    }
  }
  
  static Future<void> clearAnalyticsData(int userId) async {
    if (!kDebugMode) {
      debugPrint('⚠️ Data clearing only available in debug mode');
      return;
    }
    
    try {
      debugPrint('🧹 Clearing analytics data for user $userId...');
      
      final databaseService = OptimizedDatabaseService();
      final db = await databaseService.database;
      
      // Clear test data
      await db.delete('daily_entries', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('interactive_moments', where: 'user_id = ?', whereArgs: [userId]);
      await db.delete('user_goals', where: 'user_id = ?', whereArgs: [userId]);
      
      debugPrint('✅ Analytics data cleared successfully');
      
    } catch (e) {
      debugPrint('❌ Error clearing analytics data: $e');
    }
  }
  
  static Future<void> seedAndRefresh(int userId) async {
    await clearAnalyticsData(userId);
    await Future.delayed(const Duration(milliseconds: 500)); // Small delay
    await seedDataForCurrentUser(userId);
  }
  
  static void printSeedingInstructions() {
    if (!kDebugMode) return;
    
    debugPrint('');
    debugPrint('📊 V4 ANALYTICS DATA SEEDING INSTRUCTIONS');
    debugPrint('=' * 50);
    debugPrint('To seed test data for V4 Analytics:');
    debugPrint('');
    debugPrint('1. From your app code:');
    debugPrint('   await V4SeederRunner.seedDataForCurrentUser(userId);');
    debugPrint('');
    debugPrint('2. To clear and reseed:');
    debugPrint('   await V4SeederRunner.seedAndRefresh(userId);');
    debugPrint('');
    debugPrint('3. To clear data only:');
    debugPrint('   await V4SeederRunner.clearAnalyticsData(userId);');
    debugPrint('');
    debugPrint('Generated data includes:');
    debugPrint('• 60 days of detailed wellbeing entries with trends');
    debugPrint('• 12 diverse goals (4 completed, 8 active)');
    debugPrint('• 150+ interactive moments with emotional variety');
    debugPrint('• Realistic patterns for analytics visualization');
    debugPrint('=' * 50);
    debugPrint('');
  }
}