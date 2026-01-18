import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_profile.dart';
import 'providers.dart';

final playerProfileProvider =
    AsyncNotifierProvider<PlayerProfileNotifier, PlayerProfile>(
  PlayerProfileNotifier.new,
);

class PlayerProfileNotifier extends AsyncNotifier<PlayerProfile> {
  @override
  Future<PlayerProfile> build() async {
    ref.watch(playerProfileVersionProvider);
    final repo = ref.read(playerProfileRepositoryProvider);
    return repo.fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(playerProfileRepositoryProvider).fetch(forceRefresh: true));
  }
}

