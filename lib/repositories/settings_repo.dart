import '../domain/ux_detail_level.dart';
import '../services/storage_service.dart';

class SettingsRepository {
  const SettingsRepository();

  Future<String> getLanguage() => StorageService.getLanguage();
  Future<void> setLanguage(String v) => StorageService.setLanguage(v);

  Future<String> getTheme() => StorageService.getTheme();
  Future<void> setTheme(String v) => StorageService.setTheme(v);

  Future<bool> getNotificationsEnabled() => StorageService.getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool v) => StorageService.setNotificationsEnabled(v);

  Future<String> getBariMode() => StorageService.getBariMode();
  Future<void> setBariMode(String v) => StorageService.setBariMode(v);

  Future<bool> getBariShowSources() => StorageService.getBariShowSources();
  Future<void> setBariShowSources(bool v) => StorageService.setBariShowSources(v);

  Future<bool> getBariSmallTalkEnabled() => StorageService.getBariSmallTalkEnabled();
  Future<void> setBariSmallTalkEnabled(bool v) => StorageService.setBariSmallTalkEnabled(v);

  Future<UxDetailLevel> getUxDetailLevel() async {
    final raw = await StorageService.getUxDetailLevel();
    return UxDetailLevelX.fromStorage(raw);
  }

  Future<void> setUxDetailLevel(UxDetailLevel v) {
    return StorageService.setUxDetailLevel(v.storageValue);
  }
}

