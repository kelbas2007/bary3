import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'providers.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    // Мост к legacy: любое изменение StorageService.transactionsVersion
    // перезагрузит список транзакций.
    ref.watch(transactionsVersionProvider);
    final repo = ref.read(transactionsRepositoryProvider);
    return repo.fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(transactionsRepositoryProvider).fetch(forceRefresh: true));
  }

  Future<void> add(Transaction transaction) async {
    await ref.read(transactionsRepositoryProvider).add(transaction);
    // Репозиторий/StorageService дернёт transactionsVersion, но обновим быстрее.
    await refresh();
  }
}

