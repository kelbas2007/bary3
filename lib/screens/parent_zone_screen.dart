import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../theme/aurora_theme.dart';
import '../models/player_profile.dart';
import '../models/transaction.dart';
import '../services/money_ui.dart';
import 'parent_statistics_screen.dart';
import 'export_import_screen.dart';
import '../state/transactions_notifier.dart';
import '../state/piggy_banks_notifier.dart';
import '../state/providers.dart';
import '../l10n/app_localizations.dart';

class ParentZoneScreen extends ConsumerStatefulWidget {
  const ParentZoneScreen({super.key});

  @override
  ConsumerState<ParentZoneScreen> createState() => _ParentZoneScreenState();
}

class _ParentZoneScreenState extends ConsumerState<ParentZoneScreen> {
  final _pinController = TextEditingController();
  final _newPinController = TextEditingController();
  bool _isAuthenticated = false;
  PlayerProfile? _profile;

  @override
  void initState() {
    super.initState();
    _checkPin();
    _loadProfile();
  }

  Future<void> _checkPin() async {
    final hasPin = await StorageService.hasParentPin();
    setState(() {
      _isAuthenticated = !hasPin; // Если PIN не установлен, считаем авторизованным
    });
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.getPlayerProfile();
    setState(() {
      _profile = profile;
    });
  }

  Future<void> _authenticate() async {
    final l10n = AppLocalizations.of(context)!;
    final hasPin = await StorageService.hasParentPin();
    if (!hasPin) {
      // PIN не установлен, создаём новый
      if (_pinController.text.length == 4) {
        await StorageService.setParentPin(_pinController.text);
        setState(() {
          _isAuthenticated = true;
        });
        _pinController.clear();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parentZone_pinMustBe4Digits)),
        );
      }
    } else {
      // Проверяем PIN
      final isValid = await StorageService.verifyParentPin(_pinController.text);
      if (isValid) {
        setState(() {
          _isAuthenticated = true;
        });
        _pinController.clear();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parentZone_wrongPin)),
        );
      }
    }
  }

  Future<void> _changePin() async {
    final l10n = AppLocalizations.of(context)!;
    if (_newPinController.text.length == 4) {
      await StorageService.setParentPin(_newPinController.text);
      _newPinController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parentZone_pinChanged)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.parentZone_pinMustBe4Digits)),
      );
    }
  }

  Future<void> _unlockPremium() async {
    final l10n = AppLocalizations.of(context)!;
    if (_profile != null) {
      await StorageService.savePlayerProfile(
        _profile!.copyWith(premiumUnlocked: true),
      );
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.parentZone_premiumUnlocked)),
        );
      }
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final pinController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.parentZone_resetData),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.parentZone_resetWarning,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(l10n.parentZone_enterPinToConfirm),
            const SizedBox(height: 8),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.parentZone_pin,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final isValid = await StorageService.verifyParentPin(pinController.text);
              if (!context.mounted) return;
              if (isValid) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.parentZone_wrongPin)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.parentZone_reset),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!context.mounted) return;
      await _resetAllData(context);
    }
  }

  Future<void> _resetAllData(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Удаляем все данные через StorageService
      await StorageService.resetAllData();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parentZone_allDataDeleted),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parentZone_resetError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.parentZone_title),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AuroraTheme.blueGradient,
          ),
          child: Center(
            child: AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<bool>(
                      future: StorageService.hasParentPin(),
                      builder: (context, snapshot) {
                        final hasPin = snapshot.data ?? false;
                        return Text(
                          hasPin ? 'Введите PIN' : 'Создайте PIN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'PIN (4 цифры)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _authenticate,
                      child: Text(l10n.parentZone_login),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final transactions = ref.watch(transactionsProvider).value ?? const <Transaction>[];
    final pendingApprovals = transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.source == TransactionSource.earningsLab &&
              !t.parentApproved,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.parentZone_title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Премиум',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile?.premiumUnlocked == true
                          ? 'Статус: Разблокирован'
                          : 'Статус: Заблокирован',
                      style: TextStyle(
                        color: _profile?.premiumUnlocked == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    if (_profile?.premiumUnlocked != true) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _unlockPremium,
                        child: Text(l10n.parentZone_unlockPremium),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AuroraTheme.glassCard(
              child: ListTile(
                title: const Text(
                  'Статистика',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Доходы, расходы, прогресс',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParentStatisticsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (pendingApprovals.isNotEmpty) ...[
              AuroraTheme.glassCard(
                child: ListTile(
                  title: Text(
                    'Ожидают одобрения (${pendingApprovals.length})',
                    style: const TextStyle(color: Colors.orange),
                  ),
                  subtitle: const Text(
                    'Заработки, требующие подтверждения',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPendingApprovals(context, pendingApprovals),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            AuroraTheme.glassCard(
              child: ListTile(
                title: const Text(
                  'Экспорт / Импорт',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Сохранить или загрузить данные',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExportImportScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AuroraTheme.glassCard(
              child: ListTile(
                title: const Text(
                  'Сброс данных',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text(
                  'Удалить все данные (требует PIN)',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.delete, color: Colors.red),
                onTap: () => _showResetDialog(context),
              ),
            ),
            const SizedBox(height: 16),
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Изменить PIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'Новый PIN (4 цифры)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _changePin,
                      child: Text(l10n.parentZone_edit),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPendingApprovals(
      BuildContext context, List<Transaction> pending) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AuroraTheme.blueGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ожидают одобрения (${pending.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final t = pending[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => _showApprovalDetail(context, t),
                        borderRadius: BorderRadius.circular(16),
                        child: AuroraTheme.glassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t.note ?? 'Заработок',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      formatAmountUi(context, t.amount),
                                      style: const TextStyle(
                                        color: AuroraTheme.neonYellow,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (t.childComment != null && t.childComment!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    t.childComment!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (t.photoPaths != null && t.photoPaths!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.image, color: Colors.white54, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${t.photoPaths!.length} фото',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _rejectTransaction(context, t),
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text('Отклонить'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _approveTransaction(context, t),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Одобрить'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.parentZone_close,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showApprovalDetail(
      BuildContext context, Transaction transaction) async {
    int? rating;
    final feedbackController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AuroraTheme.blueGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.note ?? 'Заработок',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Награда',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatAmountUi(context, transaction.amount),
                            style: const TextStyle(
                              color: AuroraTheme.neonYellow,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (transaction.childComment != null && transaction.childComment!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AuroraTheme.glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.comment, color: Colors.white70, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Комментарий ребёнка',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              transaction.childComment!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (transaction.photoPaths != null && transaction.photoPaths!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AuroraTheme.glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.image, color: Colors.white70, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Фото результата',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: transaction.photoPaths!.map((path) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(Icons.image, color: Colors.white54),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Оцени качество работы',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rating = index + 1;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.star,
                                    color: rating != null && index < rating!
                                        ? AuroraTheme.neonYellow
                                        : Colors.white38,
                                    size: 32,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: feedbackController,
                            decoration: InputDecoration(
                              hintText: 'Комментарий для ребёнка (необязательно)',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _rejectTransaction(context, transaction),
                        child: const Text('Отклонить', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _approveTransactionWithRating(
                            context,
                            transaction,
                            rating,
                            feedbackController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Одобрить'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _approveTransactionWithRating(
      BuildContext context,
      Transaction transaction,
      int? rating,
      String feedback) async {
    final l10n = AppLocalizations.of(context)!;
    final txRepo = ref.read(transactionsRepositoryProvider);
    final piggyRepo = ref.read(piggyBanksRepositoryProvider);
    final all = await txRepo.fetch();
    final index = all.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      final current = all[index];

      // Если это доход из Earnings Lab с назначением в копилку,
      // то при одобрении нужно зачислить деньги в копилку.
      if (!current.parentApproved &&
          current.type == TransactionType.income &&
          current.piggyBankId != null) {
        final banks = await piggyRepo.fetch();
        final bankIndex = banks.indexWhere((b) => b.id == current.piggyBankId);
        if (bankIndex >= 0) {
          final bank = banks[bankIndex];
          final updatedBank =
              bank.copyWith(currentAmount: bank.currentAmount + current.amount);
          await piggyRepo.upsert(updatedBank);
          ref.read(piggyBanksProvider.notifier).refresh();
        }
      }

      // Обновляем транзакцию с оценкой и комментарием
      final updated = current.copyWith(
        parentApproved: true,
        parentRating: rating,
        parentFeedback: feedback.isNotEmpty ? feedback : null,
      );
      
      // Сохраняем обновлённую транзакцию
      final updatedList = List<Transaction>.from(all);
      updatedList[index] = updated;
      await StorageService.saveTransactions(updatedList);
      
      ref.read(transactionsProvider.notifier).refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parentZone_earningsApproved),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Закрываем детальный диалог
      Navigator.pop(context); // Закрываем список одобрений
    }
  }

  Future<void> _approveTransaction(
      BuildContext context, Transaction transaction) async {
    // Используем упрощённое одобрение без оценки (для быстрого одобрения из списка)
    await _approveTransactionWithRating(context, transaction, null, '');
  }

  Future<void> _rejectTransaction(
      BuildContext context, Transaction transaction) async {
    final txRepo = ref.read(transactionsRepositoryProvider);
    await txRepo.removeById(transaction.id);
    ref.read(transactionsProvider.notifier).refresh();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.parentZone_earningsRejected),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context);
  }
}

