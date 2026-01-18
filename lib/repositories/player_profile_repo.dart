import '../models/player_profile.dart';
import '../services/storage_service.dart';

class PlayerProfileRepository {
  const PlayerProfileRepository();

  Future<PlayerProfile> fetch({bool forceRefresh = false}) {
    return StorageService.getPlayerProfile(forceRefresh: forceRefresh);
  }

  Future<void> save(PlayerProfile profile) {
    return StorageService.savePlayerProfile(profile);
  }

  Future<void> addXp(int delta) async {
    final profile = await StorageService.getPlayerProfile();
    await StorageService.savePlayerProfile(profile.copyWith(xp: profile.xp + delta));
  }
}

