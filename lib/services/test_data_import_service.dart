import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../utils/weekly_test_data_generator.dart';

/// Сервис для автоматического импорта тестовых данных через Method Channel
class TestDataImportService {
  static const MethodChannel _channel = MethodChannel('com.bary3/test_data_import');

  /// Импортирует недельные тестовые данные
  static Future<bool> importWeeklyData() async {
    try {
      if (kDebugMode) {
        // В debug режиме вызываем генератор напрямую
        await WeeklyTestDataGenerator.generateWeeklyData();
        return true;
      } else {
        // В release режиме используем method channel
        final result = await _channel.invokeMethod('importWeeklyData');
        return result as bool? ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TestDataImportService] Error importing data: $e');
      }
      return false;
    }
  }
}
