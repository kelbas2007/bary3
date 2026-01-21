import '../models/player_profile.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/bari_memory.dart';

/// Сервис для проверки повышения уровня и уведомлений
class LevelService {
  /// Проверяет, было ли повышение уровня, и отправляет уведомление
  /// 
  /// Возвращает true, если уровень повысился
  static Future<bool> checkLevelUp(
    PlayerProfile oldProfile,
    PlayerProfile newProfile,
  ) async {
    if (newProfile.level > oldProfile.level) {
      final newLevel = newProfile.level;
      
      // Проверяем, включены ли уведомления о повышении уровня
      final levelUpEnabled = await StorageService.getLevelUpNotificationsEnabled();
      if (levelUpEnabled) {
        // Показываем уведомление
        await NotificationService.scheduleLevelUpNotification(newLevel);
      }
      
      // Сохраняем в память Бари
      final memory = await StorageService.getBariMemory();
      memory.addAction(
        BariAction(
          type: BariActionType.levelUp,
          timestamp: DateTime.now(),
        ),
      );
      await StorageService.saveBariMemory(memory);
      
      return true;
    }
    
    return false;
  }
}
