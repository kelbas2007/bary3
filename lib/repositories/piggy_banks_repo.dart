import '../models/piggy_bank.dart';
import '../services/storage_service.dart';

class PiggyBanksRepository {
  const PiggyBanksRepository();

  Future<List<PiggyBank>> fetch({bool forceRefresh = false}) {
    return StorageService.getPiggyBanks(forceRefresh: forceRefresh);
  }

  Future<void> saveAll(List<PiggyBank> banks) {
    return StorageService.savePiggyBanks(banks);
  }

  Future<void> upsert(PiggyBank bank) async {
    final banks = await StorageService.getPiggyBanks();
    final idx = banks.indexWhere((b) => b.id == bank.id);
    if (idx >= 0) {
      banks[idx] = bank;
    } else {
      banks.add(bank);
    }
    await StorageService.savePiggyBanks(banks);
  }

  Future<void> delete(String bankId) async {
    final banks = await StorageService.getPiggyBanks();
    banks.removeWhere((b) => b.id == bankId);
    await StorageService.savePiggyBanks(banks);
  }
}

