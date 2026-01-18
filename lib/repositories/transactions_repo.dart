import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionsRepository {
  const TransactionsRepository();

  Future<List<Transaction>> fetch({bool forceRefresh = false}) {
    return StorageService.getTransactions(forceRefresh: forceRefresh);
  }

  /// Идемпотентное добавление: если транзакция привязана к plannedEventId,
  /// не создаём дубль.
  Future<void> add(Transaction transaction) async {
    final plannedEventId = transaction.plannedEventId;
    if (plannedEventId != null && plannedEventId.isNotEmpty) {
      final existing = await findByPlannedEventId(plannedEventId);
      if (existing != null) return;
    }
    await StorageService.addTransaction(transaction);
  }

  Future<Transaction?> findByPlannedEventId(String plannedEventId) async {
    final tx = await StorageService.getTransactions();
    for (final t in tx) {
      if (t.plannedEventId == plannedEventId) return t;
    }
    return null;
  }

  Future<void> setParentApproved(String id, bool approved) async {
    final tx = await StorageService.getTransactions();
    final idx = tx.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    tx[idx] = tx[idx].copyWith(parentApproved: approved);
    await StorageService.saveTransactions(tx);
  }

  Future<void> removeById(String id) async {
    final tx = await StorageService.getTransactions();
    tx.removeWhere((t) => t.id == id);
    await StorageService.saveTransactions(tx);
  }
}

