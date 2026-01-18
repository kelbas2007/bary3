// Helper script for automated data import
// Run with: flutter run -d <device> lib/main_import_helper.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'utils/weekly_test_data_generator.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('=== Automated Data Import ===');
  debugPrint('');
  
  try {
    // Initialize services
    await SharedPreferences.getInstance();
    await StorageService.migratePiggyLedgerIfNeeded();
    
    debugPrint('Generating weekly test data...');
    await WeeklyTestDataGenerator.generateWeeklyData();
    
    debugPrint('');
    debugPrint('✅ Data import completed successfully!');
    debugPrint('');
    debugPrint('Imported:');
    debugPrint('  - Transactions: 13');
    debugPrint('  - Piggy Banks: 3');
    debugPrint('  - Planned Events: 4');
    debugPrint('  - Lesson Progress: 5');
    debugPrint('  - Player Profile: Level 2, 350 XP');
    debugPrint('');
    
    // Verify data
    final transactions = await StorageService.getTransactions();
    final piggyBanks = await StorageService.getPiggyBanks();
    final events = await StorageService.getPlannedEvents();
    final progress = await StorageService.getLessonProgress();
    final profile = await StorageService.getPlayerProfile();
    
    debugPrint('Verification:');
    debugPrint('  - Transactions: ${transactions.length}');
    debugPrint('  - Piggy Banks: ${piggyBanks.length}');
    debugPrint('  - Events: ${events.length}');
    debugPrint('  - Lesson Progress: ${progress.length}');
    debugPrint('  - Player Level: ${profile.level}, XP: ${profile.xp}');
    debugPrint('');
    
    if (transactions.length >= 10 && 
        piggyBanks.length >= 3 && 
        events.length >= 4 && 
        progress.length >= 5) {
      debugPrint('✅ All data imported successfully!');
      exit(0);
    } else {
      debugPrint('⚠️ Some data may be missing');
      exit(1);
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error during import: $e');
    debugPrint('Stack trace: $stackTrace');
    exit(1);
  }
}
