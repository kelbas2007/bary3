import '../models/player_profile.dart';
import '../services/storage_service.dart';
import '../services/level_service.dart';

class PlayerProfileRepository {
  const PlayerProfileRepository();

  Future<PlayerProfile> fetch({bool forceRefresh = false}) {
    return StorageService.getPlayerProfile(forceRefresh: forceRefresh);
  }

  Future<void> save(PlayerProfile profile) {
    return StorageService.savePlayerProfile(profile);
  }

  Future<void> addXp(int delta) async {
    final oldProfile = await StorageService.getPlayerProfile();
    final newProfile = oldProfile.copyWith(xp: oldProfile.xp + delta);
    await StorageService.savePlayerProfile(newProfile);
    await LevelService.checkLevelUp(oldProfile, newProfile);
  }
}

