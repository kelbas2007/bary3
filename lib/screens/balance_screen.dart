import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/transaction.dart';
import '../models/planned_event.dart';
import '../models/piggy_bank.dart';
import '../models/bari_memory.dart';
import '../theme/aurora_theme.dart';
import '../widgets/async_error_widget.dart';
import '../services/money_formatter.dart';
import '../services/currency_scope.dart';
import '../domain/ux_detail_level.dart';
import '../state/transactions_notifier.dart';
import '../state/planned_events_notifier.dart';
import '../state/player_profile_notifier.dart';
import '../state/piggy_banks_notifier.dart';
import '../widgets/bari_reaction.dart';
import '../widgets/aurora_bottom_sheet.dart';
import '../widgets/aurora_text_field.dart';
import '../widgets/aurora_button.dart';
import '../l10n/app_localizations.dart';
import '../utils/haptic_feedback_util.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/swipeable_list_item.dart';
import '../widgets/animated_list_view.dart';
import '../widgets/accessibility_wrapper.dart';
import '../widgets/quick_tools_grid.dart';
import '../widgets/transaction_item.dart';

class BalanceScreen extends ConsumerStatefulWidget {
  const BalanceScreen({super.key});

  @override
  ConsumerState<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends ConsumerState<BalanceScreen>
    with WidgetsBindingObserver {
  String _filter = 'all'; // day, week, month, all
  String _searchQuery = ''; // поисковый запрос
  bool _showReaction = false;
  BariActionType? _lastAction;
  bool _showForecast = false; // переключатель прогноза
  final TextEditingController _searchController = TextEditingController();
  UxDetailLevel _uxDetailLevel = UxDetailLevel.simple;
  
  // Кэш для оптимизации вычислений
  int? _cachedBalance;
  List<Transaction>? _cachedFilteredTransactions;
  String? _lastFilterCache;
  String? _lastSearchCache;
  bool? _lastForecastCache;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Загружаем уровень подробности (simple/pro)
    StorageService.getUxDetailLevel().then((raw) {
      if (!mounted) return;
      setState(() {
        _uxDetailLevel = UxDetailLevelX.fromStorage(raw);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Перезагружаем данные при возврате приложения в foreground
      ref.read(transactionsProvider.notifier).refresh();
      ref.read(plannedEventsProvider.notifier).refresh();
      ref.read(playerProfileProvider.notifier).refresh();
    }
  }

  int _calculateBalance(
    List<Transaction> transactions,
    List<PlannedEvent> plannedEvents,
  ) {
    // Используем кэш, если параметры не изменились
    if (_cachedBalance != null &&
        _lastFilterCache == _filter &&
        _lastForecastCache == _showForecast) {
      return _cachedBalance!;
    }
    
    // Оптимизированное вычисление баланса с использованием fold
    int balance = transactions
        .where((t) => t.parentApproved == true && t.affectsWallet == true)
        .fold<int>(
          0,
          (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount),
        );

    // Если включён прогноз, добавляем запланированные события
    if (_showForecast) {
      final now = DateTime.now();
      final periodEnd = now.add(
        Duration(
          days: _filter == 'day'
              ? 1
              : _filter == 'week'
              ? 7
              : _filter == 'month'
              ? 30
              : 90,
        ),
      );

      // Оптимизированное вычисление с использованием fold
      final forecastAmount = plannedEvents
          .where((e) =>
              e.status != PlannedEventStatus.canceled &&
              e.status == PlannedEventStatus.planned &&
              e.dateTime.isAfter(now) &&
              e.dateTime.isBefore(periodEnd) &&
              e.affectsWallet)
          .fold<int>(
            0,
            (sum, e) => sum + (e.type == TransactionType.income ? e.amount : -e.amount),
          );
      
      balance += forecastAmount;
    }

    // Сохраняем в кэш
    _cachedBalance = balance;
    _lastFilterCache = _filter;
    _lastForecastCache = _showForecast;
    
    return balance;
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    // Используем кэш, если параметры не изменились
    if (_cachedFilteredTransactions != null &&
        _lastFilterCache == _filter &&
        _lastSearchCache == _searchQuery) {
      return _cachedFilteredTransactions!;
    }
    
    final now = DateTime.now();
    final filtered = <Transaction>[];
    
    // Оптимизированная фильтрация - сначала по времени, потом по поиску
    for (final t in transactions) {
      // Фильтр по времени
      bool timeMatch = true;
      switch (_filter) {
        case 'day':
          timeMatch =
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
          break;
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          timeMatch = t.date.isAfter(
            weekStart.subtract(const Duration(days: 1)),
          );
          break;
        case 'month':
          timeMatch = t.date.year == now.year && t.date.month == now.month;
          break;
        default:
          timeMatch = true;
      }
      
      if (!timeMatch) continue;

      // Поиск по тексту
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final noteMatch = t.note?.toLowerCase().contains(query) ?? false;
        final categoryMatch = t.category?.toLowerCase().contains(query) ?? false;
        if (!noteMatch && !categoryMatch) continue;
      }

      filtered.add(t);
    }
    
    // Сортируем и ограничиваем результат
    filtered.sort((a, b) => b.date.compareTo(a.date));
    final result = filtered.take(20).toList();
    
    // Сохраняем в кэш
    _cachedFilteredTransactions = result;
    _lastFilterCache = _filter;
    _lastSearchCache = _searchQuery;
    
    return result;
  }

  Future<void> _handleRefresh() async {
    // Используем refresh для NotifierProvider
    await ref.read(transactionsProvider.notifier).refresh();
    await ref.read(piggyBanksProvider.notifier).refresh();
    await ref.read(plannedEventsProvider.notifier).refresh();
    await ref.read(playerProfileProvider.notifier).refresh();

    // Симуляция реакции Бари на обновление
    if (mounted) {
      setState(() {
        _showReaction = true;
        _lastAction = null; // Просто обновление
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showReaction = false;
          });
        }
      });
    }
  }

  String _formatAmount(int cents) {
    final locale = Localizations.localeOf(context).toString();
    final currencyCode = CurrencyScope.of(context).currencyCode;
    return formatMoney(
      amountMinor: cents,
      currencyCode: currencyCode,
      locale: locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final plannedEventsAsync = ref.watch(plannedEventsProvider);
    final profileAsync = ref.watch(playerProfileProvider);

    // Обработка ошибок загрузки
    if (transactionsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.balance)),
        body: AsyncErrorWidget(
          error: transactionsAsync.error!,
          stackTrace: transactionsAsync.stackTrace,
          onRetry: () => ref.read(transactionsProvider.notifier).refresh(),
        ),
      );
    }

    // Показываем skeleton screen при загрузке
    if (transactionsAsync.isLoading && !transactionsAsync.hasValue) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.balance)),
        body: Container(
          decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
          child: const ListSkeleton(),
        ),
      );
    }

    final transactions = transactionsAsync.value ?? [];
    final plannedEvents = plannedEventsAsync.value ?? [];
    final profile = profileAsync.value;

    // Инвалидируем кэш при изменении данных
    if (transactionsAsync.isRefreshing || transactionsAsync.isReloading) {
      _cachedBalance = null;
      _cachedFilteredTransactions = null;
    }

    final balance = _calculateBalance(transactions, plannedEvents);
    final filteredTransactions = _getFilteredTransactions(transactions);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.balance),
        actions: [
          // Кнопка поиска
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AuroraTheme.spaceBlue,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.search,
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AuroraTheme.neonBlue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.2),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                                Navigator.pop(context);
                              },
                              child: Text(AppLocalizations.of(context)!.reset),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)!.done),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bari Reaction / Status
                    if (_showReaction && _lastAction != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        width: double.infinity,
                        child: BariReaction(
                          actionType: _lastAction!,
                          mood: BariMood.happy,
                        ),
                      ),

                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AuroraTheme.neonBlue,
                            AuroraTheme.neonPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AuroraTheme.neonBlue.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.balance_currentBalance,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _showForecast
                                        ? AppLocalizations.of(context)!.balance_forecast
                                        : AppLocalizations.of(context)!.balance_fact,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: _showForecast,
                                    onChanged: (value) {
                                      HapticFeedbackUtil.selection();
                                      setState(() {
                                        _showForecast = value;
                                      });
                                    },
                                    activeThumbColor: AuroraTheme.neonYellow,
                                    activeTrackColor: Colors.white24,
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AccessibilityWrapper(
                            label: _formatAmount(balance),
                            value: _formatAmount(balance),
                            liveRegion: true,
                            child: ScalableText(
                              _formatAmount(balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_showForecast) ...[
                            const SizedBox(height: 8),
                            Text(
                              _uxDetailLevel == UxDetailLevel.simple
                                  ? AppLocalizations.of(context)!.balance_withPlannedExpenses
                                  : _filter == 'day'
                                      ? AppLocalizations.of(context)!.balance_forecastForDay
                                      : _filter == 'week'
                                          ? AppLocalizations.of(context)!.balance_forecastForWeek
                                          : _filter == 'month'
                                              ? AppLocalizations.of(context)!.balance_forecastForMonth
                                              : AppLocalizations.of(context)!.balance_forecastFor3Months,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (profile != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.balance_level(profile.level),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${profile.xpProgress}/${profile.xpForNextLevel} XP',
                                        style: const TextStyle(
                                          color: AuroraTheme.neonYellow,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: profile.xpProgressPercent,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AuroraTheme.neonYellow,
                                    ),
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Быстрые инструменты (замена большой кнопки)
                    const QuickToolsGrid(),
                    const SizedBox(height: 24),
                    // Фильтры
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: AppLocalizations.of(context)!.balance_filterDay,
                            selected: _filter == 'day',
                            onTap: () {
                            HapticFeedbackUtil.selection();
                            setState(() => _filter = 'day');
                          },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: AppLocalizations.of(context)!.balance_filterWeek,
                            selected: _filter == 'week',
                            onTap: () {
                            HapticFeedbackUtil.selection();
                            setState(() => _filter = 'week');
                          },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: AppLocalizations.of(context)!.balance_filterMonth,
                            selected: _filter == 'month',
                            onTap: () {
                            HapticFeedbackUtil.selection();
                            setState(() => _filter = 'month');
                          },
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Все',
                            selected: _filter == 'all',
                            onTap: () {
                            HapticFeedbackUtil.selection();
                            setState(() => _filter = 'all');
                          },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Список транзакций
                    if (filteredTransactions.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.receipt_long,
                        title: _uxDetailLevel == UxDetailLevel.simple
                            ? AppLocalizations.of(context)!.balance_emptyStateIncome
                            : AppLocalizations.of(context)!.balance_emptyStateNoTransactions,
                        subtitle: '',
                        actionLabel: AppLocalizations.of(context)!.balance_addIncome,
                        onAction: () {
                          HapticFeedbackUtil.lightImpact();
                          // Открываем диалог добавления транзакции
                        },
                      )
                    else
                      RepaintBoundary(
                        child: AnimatedListView<Transaction>(
                          items: filteredTransactions,
                          itemBuilder: (context, tx, index) {
                            return RepaintBoundary(
                              child: SwipeableListItem(
                                key: ValueKey(tx.id),
                                onSwipeLeft: () {
                                  // Можно добавить действие при свайпе влево
                                },
                                rightActionColor: Colors.red,
                                rightActionIcon: Icons.delete,
                                rightActionLabel: 'Удалить',
                                child: TransactionItem(
                                  key: ValueKey(tx.id),
                                  transaction: tx,
                                ),
                              ),
                            );
                          },
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AuroraTheme.neonBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class AddTransactionSheet extends StatefulWidget {
  final TransactionType type;

  const AddTransactionSheet({super.key, required this.type});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  String? _selectedPiggyBankId;

  // Примерные категории
  List<String> _getExpenseCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.balance_categories_food,
      l10n.balance_categories_transport,
      l10n.balance_categories_games,
      l10n.balance_categories_clothing,
      l10n.balance_categories_entertainment,
      l10n.balance_categories_other,
    ];
  }

  List<String> _getIncomeCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.balance_categories_pocketMoney,
      l10n.balance_categories_gift,
      l10n.balance_categories_sideJob,
      l10n.balance_categories_other,
    ];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == TransactionType.income;
    final categories = isIncome ? _getIncomeCategories(context) : _getExpenseCategories(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AuroraBottomSheet(
        title: isIncome
            ? AppLocalizations.of(context)!.balance_addIncome
            : AppLocalizations.of(context)!.balance_addExpense,
        titleIcon: isIncome ? Icons.add_circle : Icons.remove_circle,
        titleIconColor: isIncome ? Colors.greenAccent : Colors.redAccent,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Сумма
              AuroraTextField(
                label: AppLocalizations.of(context)!.balance_amount,
                controller: _amountController,
                icon: Icons.attach_money,
                iconColor: isIncome ? Colors.greenAccent : Colors.redAccent,
                hintText: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 20),
              // Категория
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.balance_category,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    dropdownColor: AuroraTheme.spaceBlue,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.balance_selectCategory,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: (isIncome
                              ? Colors.greenAccent
                              : Colors.redAccent),
                          width: 2,
                        ),
                      ),
                    ),
                    items: categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Выбор копилки (для расхода - как источник, для дохода - как цель)
              FutureBuilder<List<PiggyBank>>(
                future: StorageService.getPiggyBanks(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final banks = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIncome
                            ? AppLocalizations.of(context)!.balance_toPiggyBank
                            : AppLocalizations.of(context)!.balance_fromPiggyBank,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPiggyBankId,
                        dropdownColor: AuroraTheme.spaceBlue,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Выберите копилку',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AuroraTheme.neonYellow,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.savings,
                            color: AuroraTheme.neonYellow,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            child: Text(
                              'Основной кошелёк',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          ...banks.map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text(b.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPiggyBankId = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Заметка
              AuroraTextField(
                label: 'Заметка (необязательно)',
                controller: _noteController,
                icon: Icons.note,
                iconColor: AuroraTheme.neonBlue,
                hintText: 'Добавьте описание...',
              ),
              const SizedBox(height: 24),
              // Кнопка Сохранить
              SizedBox(
                width: double.infinity,
                child: AuroraButton(
                  text: AppLocalizations.of(context)!.balance_save,
                  icon: Icons.check,
                  customColor: isIncome ? Colors.greenAccent : Colors.redAccent,
                  onPressed: () {
                    final amount = _amountController.text;
                    if (amount.isEmpty) return;

                    Navigator.pop(context, {
                      'amount': amount,
                      'category': _selectedCategory ?? 'Без категории',
                      'note': _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                      'piggyBankId': _selectedPiggyBankId,
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
