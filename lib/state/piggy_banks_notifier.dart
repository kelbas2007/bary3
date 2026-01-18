import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/piggy_bank.dart';
import 'providers.dart';

final piggyBanksProvider =
    AsyncNotifierProvider<PiggyBanksNotifier, List<PiggyBank>>(
  PiggyBanksNotifier.new,
);

class PiggyBanksNotifier extends AsyncNotifier<List<PiggyBank>> {
  @override
  Future<List<PiggyBank>> build() async {
    ref.watch(piggyBanksVersionProvider);
    final repo = ref.read(piggyBanksRepositoryProvider);
    return repo.fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(piggyBanksRepositoryProvider).fetch(forceRefresh: true));
  }
}

