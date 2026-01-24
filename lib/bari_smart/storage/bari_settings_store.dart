import '../../services/storage_service.dart';

// BariMode удален, так как онлайн режим удален
enum BariMode {
  offline,
}

class BariSettingsStore {
  // Всегда offline
  BariMode mode = BariMode.offline;
  bool showSources = false; // Источники не показываем, так как нет онлайн поиска
  bool smallTalkEnabled = true;
  bool useSystemAssistant = true;

  Future<void> load() async {
    // Режим всегда офлайн
    mode = BariMode.offline;
    // Источники отключены
    showSources = false;
    smallTalkEnabled = await StorageService.getBariSmallTalkEnabled();
    useSystemAssistant = await StorageService.getBariUseSystemAssistant();
  }

  // Метод setMode удален
  // Метод setShowSources удален

  Future<void> setSmallTalkEnabled(bool v) async {
    smallTalkEnabled = v;
    await StorageService.setBariSmallTalkEnabled(v);
  }

  Future<void> setUseSystemAssistant(bool v) async {
    useSystemAssistant = v;
    await StorageService.setBariUseSystemAssistant(v);
  }

  // Для совместимости оставляем геттеры, но они всегда возвращают false
  bool get onlineEnabled => false;
  bool get manualOnly => true;
}
