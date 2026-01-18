import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/piggy_banks_repo.dart';
import '../repositories/planned_events_repo.dart';
import '../repositories/player_profile_repo.dart';
import '../repositories/settings_repo.dart';
import '../repositories/transactions_repo.dart';
import '../services/storage_service.dart';

// --- Repositories ---

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return const SettingsRepository();
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return const TransactionsRepository();
});

final piggyBanksRepositoryProvider = Provider<PiggyBanksRepository>((ref) {
  return const PiggyBanksRepository();
});

final plannedEventsRepositoryProvider = Provider<PlannedEventsRepository>((
  ref,
) {
  return const PlannedEventsRepository();
});

final playerProfileRepositoryProvider = Provider<PlayerProfileRepository>((
  ref,
) {
  return const PlayerProfileRepository();
});

// --- Legacy bridges (пока не мигрированы все экраны) ---

/// Мосты к `StorageService.*Version`.
///
/// Важно: ValueNotifier'ы в StorageService - глобальные, их нельзя dispose'ить.
/// Поэтому мы НЕ используем ChangeNotifierProvider (он вызовет dispose),
/// а подписываемся вручную и снимаем подписку на dispose провайдера.
final transactionsVersionProvider = Provider<int>((ref) {
  final n = StorageService.transactionsVersion;
  void listener() => ref.invalidateSelf();
  n.addListener(listener);
  ref.onDispose(() => n.removeListener(listener));
  return n.value;
});

final piggyBanksVersionProvider = Provider<int>((ref) {
  final n = StorageService.piggyBanksVersion;
  void listener() => ref.invalidateSelf();
  n.addListener(listener);
  ref.onDispose(() => n.removeListener(listener));
  return n.value;
});

final plannedEventsVersionProvider = Provider<int>((ref) {
  final n = StorageService.plannedEventsVersion;
  void listener() => ref.invalidateSelf();
  n.addListener(listener);
  ref.onDispose(() => n.removeListener(listener));
  return n.value;
});

final playerProfileVersionProvider = Provider<int>((ref) {
  final n = StorageService.playerProfileVersion;
  void listener() => ref.invalidateSelf();
  n.addListener(listener);
  ref.onDispose(() => n.removeListener(listener));
  return n.value;
});
