import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../screens/balance_screen.dart';
import '../screens/piggy_banks_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/lessons_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/bari_chat_screen.dart';
import '../screens/bari_recommendations_screen.dart';
import '../screens/plan_event_screen.dart';
import '../widgets/bari_overlay.dart';
import '../services/storage_service.dart';
import '../models/bari_memory.dart';
import '../utils/page_transitions.dart';
import '../theme/aurora_theme.dart';
import '../state/planned_events_notifier.dart';
import '../models/transaction.dart';
import '../utils/money_input_validator.dart';
import '../services/auto_fill_service.dart';
import '../state/transactions_notifier.dart';
import '../state/piggy_banks_notifier.dart';
import '../state/player_profile_notifier.dart';
import '../state/providers.dart';
import '../bari_smart/bari_context_adapter.dart';
import '../bari_smart/providers/proactive_hints_provider.dart';
import '../bari_smart/bari_models.dart' as bari_models;
import '../utils/weekly_test_data_generator.dart';
import '../screens/calculators_list_screen.dart';
import '../screens/earnings_lab_screen.dart';
import '../screens/parent_statistics_screen.dart';
import 'dart:async';
import '../screens/notes_screen.dart';
import '../screens/tools_hub_screen.dart';
import '../screens/calendar_forecast_screen.dart';
import '../screens/achievements_screen.dart';
import '../services/deep_link_service.dart';
import '../screens/calculators/piggy_plan_calculator.dart';
import '../utils/haptic_feedback_util.dart';
import '../screens/calculators/goal_date_calculator.dart';
import '../screens/calculators/monthly_budget_calculator.dart';
import '../screens/calculators/subscriptions_calculator.dart';
import '../screens/calculators/can_i_buy_calculator.dart';
import '../screens/calculators/price_comparison_calculator.dart';
import '../screens/calculators/twenty_four_hour_rule_calculator.dart';
import '../screens/calculators/budget_50_30_20_calculator.dart';
import '../screens/calculators/calendar_forecast_calculator.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  BariMemory? _bariMemory;
  late final VoidCallback _tabListener;

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _isFabOpen = false;

  // Проактивные подсказки Бари
  bari_models.BariResponse? _proactiveHint;
  DateTime? _lastHintCheck;
  static const _hintCheckInterval = Duration(
    minutes: 5,
  ); // Проверять не чаще раза в 5 минут

  bool _isNavigating = false; // Защита от повторных навигаций
  StreamSubscription<DeepLink>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();

    // Слушаем deep links от системных ассистентов
    _deepLinkSubscription = DeepLinkService.instance.deepLinks.listen(
      _handleDeepLink,
      onError: (error) {
        debugPrint('[MainScreen] Deep link error: $error');
      },
    );

    // Обрабатываем начальный deep link (если приложение запущено через deep link)
    DeepLinkService.instance.handleInitialLink();
    // Откладываем загрузку данных, чтобы не блокировать UI при запуске
    // Выполняем после первого рендера с задержкой для полной загрузки UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Загружаем память Бари асинхронно
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _loadBariMemory();
        }
      });
      // Откладываем проверку подсказки еще больше, чтобы дать время загрузиться данным
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _checkProactiveHint();
        }
      });
    });

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    );

    _tabListener = () {
      final newIndex = MainScreen.tabNotifier.value;
      if (newIndex != _currentIndex &&
          newIndex >= 0 &&
          newIndex < _screens.length) {
        setState(() {
          _currentIndex = newIndex;
        });
        // Проверяем подсказку при смене вкладки (с debounce)
        _checkProactiveHintDebounced();
      }
    };
    MainScreen.tabNotifier.addListener(_tabListener);
  }

  @override
  void dispose() {
    MainScreen.tabNotifier.removeListener(_tabListener);
    _fabController.dispose();
    _deepLinkSubscription?.cancel();
    // Отменяем все таймеры
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Очищаем все отложенные задачи
    });
    super.dispose();
  }

  /// Обработка deep link от системного ассистента
  void _handleDeepLink(DeepLink link) {
    debugPrint(
      '[MainScreen] Handling deep link: ${link.scheme}://${link.host}${link.path}',
    );
    if (_isNavigating) return;
    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isNavigating = false;
        return;
      }

      try {
        // Обработка импорта тестовых данных (проверяем первым)
        if (link.isImportTestData) {
          debugPrint('[MainScreen] Import test data deep link detected');
          _importTestData();
        }
        // Обработка открытия экрана
        else if (link.screen != null) {
          _navigateToScreen(link.screen!);
        }
        // Обработка открытия калькулятора
        else if (link.calculator != null) {
          _navigateToCalculator(link.calculator!);
        }
        // Обработка запроса к Бари
        else if (link.isBariQuery && link.bariQuestion != null) {
          _navigateToBariChat(link.bariQuestion!);
        }
        // Обработка создания заметки
        else if (link.isCreateNote) {
          _navigateToCreateNote();
        }
        // Обработка создания события
        else if (link.isCreateEvent) {
          _navigateToCreateEvent();
        }
      } catch (e) {
        debugPrint('[MainScreen] Error handling deep link: $e');
      } finally {
        Future.delayed(const Duration(milliseconds: 500), () {
          _isNavigating = false;
        });
      }
    });
  }

  void _navigateToScreen(String screen) {
    switch (screen) {
      case 'balance':
        MainScreen.tabNotifier.value = 0;
        break;
      case 'piggy_banks':
      case 'piggies':
        MainScreen.tabNotifier.value = 1;
        break;
      case 'calendar':
        MainScreen.tabNotifier.value = 2;
        break;
      case 'lessons':
        MainScreen.tabNotifier.value = 3;
        break;
      case 'settings':
        MainScreen.tabNotifier.value = 4;
        break;
      case 'notes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotesScreen()),
        );
        break;
      case 'tools':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ToolsHubScreen()),
        );
        break;
      case 'earnings_lab':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EarningsLabScreen()),
        );
        break;
      case 'calendar_forecast':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CalendarForecastScreen(),
          ),
        );
        break;
      case 'achievements':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AchievementsScreen()),
        );
        break;
    }
  }

  void _navigateToCalculator(String calculator) {
    Widget? targetCalculator;

    // Определяем, какой калькулятор нужно открыть
    switch (calculator) {
      case 'piggy_plan':
        targetCalculator = const PiggyPlanCalculator();
        break;
      case 'goal_date':
        targetCalculator = const GoalDateCalculator();
        break;
      case 'monthly_budget':
        targetCalculator = const MonthlyBudgetCalculator();
        break;
      case 'subscriptions':
        targetCalculator = const SubscriptionsCalculator();
        break;
      case 'can_i_buy':
        targetCalculator = const CanIBuyCalculator();
        break;
      case 'price_comparison':
        targetCalculator = const PriceComparisonCalculator();
        break;
      case '24h_rule':
        targetCalculator = const Rule24HoursCalculator();
        break;
      case '50_30_20':
        targetCalculator = const Budget503020Calculator();
        break;
      case 'calendar_forecast':
        targetCalculator = const CalendarForecastCalculator();
        break;
    }

    // Если калькулятор найден, открываем его, иначе открываем список
    final screen = targetCalculator ?? const CalculatorsListScreen();
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _navigateToBariChat(String question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BariChatScreen(topicTitle: question),
      ),
    );
  }

  void _navigateToCreateNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotesScreen()),
    );
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PlanEventScreen()),
    );
  }

  /// Автоматический импорт тестовых данных
  Future<void> _importTestData() async {
    debugPrint('[MainScreen] Starting automatic test data import...');
    try {
      await WeeklyTestDataGenerator.generateWeeklyData();
      debugPrint('[MainScreen] Test data import completed successfully!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Тестовые данные успешно импортированы!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('[MainScreen] Error importing test data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка импорта: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  final List<Widget> _screens = [
    const BalanceScreen(),
    const PiggyBanksScreen(),
    const CalendarScreen(),
    const LessonsScreen(),
    const SettingsScreen(),
  ];

  Future<void> _loadBariMemory() async {
    final memory = await StorageService.getBariMemory();
    if (mounted) {
      setState(() {
        _bariMemory = memory;
      });
    }
  }

  /// Проверяет проактивную подсказку с debounce
  void _checkProactiveHintDebounced() {
    final now = DateTime.now();
    if (_lastHintCheck != null &&
        now.difference(_lastHintCheck!) < _hintCheckInterval) {
      return; // Слишком рано
    }
    _checkProactiveHint();
  }

  /// Проверяет и показывает проактивную подсказку Бари
  Future<void> _checkProactiveHint() async {
    if (!mounted) return;

    final now = DateTime.now();
    _lastHintCheck = now;

    try {
      final currentScreenId = _getCurrentScreenId();
      final ctx = await BariContextAdapter.build(
        currentScreenId: currentScreenId,
      );
      final hintsProvider = const ProactiveHintsProvider();
      final hint = await hintsProvider.getHint(ctx);

      if (mounted && hint != null) {
        // Сохраняем тип подсказки в память для избежания повторений
        final memory = await StorageService.getBariMemory();
        // Определяем тип подсказки по payload действия
        final hintType = hint.actions.isNotEmpty
            ? _extractHintType(hint.actions.first.payload ?? '')
            : 'general';
        memory.addTip('hint_type:$hintType');
        await StorageService.saveBariMemory(memory);

        setState(() {
          _proactiveHint = hint;
        });
      } else if (mounted) {
        // Если подсказки нет, очищаем предыдущую
        setState(() {
          _proactiveHint = null;
        });
      }
    } catch (e) {
      // Игнорируем ошибки при получении подсказок
      debugPrint('Error getting proactive hint: $e');
    }
  }

  /// Извлекает тип подсказки из payload
  String _extractHintType(String payload) {
    if (payload.contains('earnings_lab')) return 'earnings_lab';
    if (payload.contains('parent_stats')) return 'expenses';
    if (payload.contains('piggy_banks')) return 'piggy';
    if (payload.contains('lessons')) return 'lesson';
    if (payload.contains('monthly_budget')) return 'budget';
    if (payload.contains('plan')) return 'planning';
    return 'general';
  }

  String _getCurrentScreenId() {
    switch (_currentIndex) {
      case 0:
        return 'balance';
      case 1:
        return 'piggy_banks';
      case 2:
        return 'calendar';
      case 3:
        return 'lessons';
      case 4:
        return 'settings';
      default:
        return 'balance';
    }
  }

  /// Обработчик действий из проактивных подсказок
  void _handleProactiveAction(bari_models.BariAction action) {
    switch (action.type) {
      case bari_models.BariActionType.openScreen:
        if (_isNavigating) return; // Предотвращаем повторные вызовы
        _isNavigating = true;

        if (action.payload != null) {
          // Для открытия новых экранов не нужно popUntil - просто открываем экран
          // Для переключения вкладок используем tabNotifier без навигации
          switch (action.payload) {
            case 'balance':
            case 'piggy_banks':
            case 'piggies':
            case 'calendar':
            case 'lessons':
            case 'settings':
              // Для переключения вкладок сначала возвращаемся на главный экран
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  _isNavigating = false;
                  return;
                }
                try {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } catch (e) {
                  _isNavigating = false;
                  return;
                }
                // Переключаем вкладку после возврата на главный экран
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!mounted) {
                    _isNavigating = false;
                    return;
                  }
                  switch (action.payload) {
                    case 'balance':
                      MainScreen.tabNotifier.value = 0;
                      break;
                    case 'piggy_banks':
                    case 'piggies':
                      MainScreen.tabNotifier.value = 1;
                      break;
                    case 'calendar':
                      MainScreen.tabNotifier.value = 2;
                      break;
                    case 'lessons':
                      MainScreen.tabNotifier.value = 3;
                      break;
                    case 'settings':
                      MainScreen.tabNotifier.value = 4;
                      break;
                  }
                  _isNavigating = false;
                });
              });
              break;
            case 'earnings_lab':
            case 'calculators':
            case 'parent_stats':
              // Для открытия новых экранов просто открываем их без popUntil
              SchedulerBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                  _isNavigating = false;
                  return;
                }
                try {
                  Widget? targetScreen;
                  switch (action.payload) {
                    case 'earnings_lab':
                      targetScreen = const EarningsLabScreen();
                      break;
                    case 'calculators':
                      targetScreen = const CalculatorsListScreen();
                      break;
                    case 'parent_stats':
                      targetScreen = const ParentStatisticsScreen();
                      break;
                  }
                  if (targetScreen != null && mounted) {
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => targetScreen!,
                          ),
                        )
                        .then((_) => _isNavigating = false)
                        .catchError((_) => _isNavigating = false);
                  } else {
                    _isNavigating = false;
                  }
                } catch (e) {
                  _isNavigating = false;
                }
              });
              break;
            default:
              _isNavigating = false;
          }
        } else {
          // Если payload пустой, просто возвращаемся на главный экран
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              _isNavigating = false;
              return;
            }
            try {
              Navigator.of(context).popUntil((route) => route.isFirst);
              _isNavigating = false;
            } catch (e) {
              _isNavigating = false;
            }
          });
        }
        break;

      case bari_models.BariActionType.openCalculator:
        if (_isNavigating) return;
        _isNavigating = true;
        // Отложить навигацию для безопасности
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalculatorsListScreen(),
              ),
            ).then((_) => _isNavigating = false);
          } else {
            _isNavigating = false;
          }
        });
        // NOTE: В будущем можно добавить навигацию к конкретному калькулятору по payload
        // Например, если payload содержит 'calculator': 'budget_503020', открыть соответствующий калькулятор
        break;

      case bari_models.BariActionType.createPlan:
        if (_isNavigating) return;
        _isNavigating = true;
        // Отложить навигацию для безопасности
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanEventScreen()),
            ).then((_) => _isNavigating = false);
          } else {
            _isNavigating = false;
          }
        });
        break;

      default:
        break;
    }

    // Скрываем подсказку после действия
    setState(() {
      _proactiveHint = null;
    });
  }

  void _toggleFab() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Future<void> _handleIncome(Map<String, dynamic> result) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final amountMinor = MoneyInputValidator.validateAndShowError(
      context,
      result['amount'] as String,
    );
    if (amountMinor == null) return;
    final piggyBankId = result['piggyBankId'] as String?;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.income,
      amount: amountMinor,
      date: DateTime.now(),
      category: result['category'] as String?,
      note: result['note'] as String?,
      source: TransactionSource.manual,
    );

    await ref.read(transactionsProvider.notifier).add(transaction);

    if (piggyBankId != null) {
      final banks = await StorageService.getPiggyBanks();
      final bank = banks.firstWhere((b) => b.id == piggyBankId);

      final updatedBank = bank.copyWith(
        currentAmount: bank.currentAmount + amountMinor,
      );
      final bankIndex = banks.indexWhere((b) => b.id == piggyBankId);
      if (bankIndex >= 0) {
        banks[bankIndex] = updatedBank;
      }
      await StorageService.savePiggyBanks(banks);
      await ref.read(piggyBanksProvider.notifier).refresh();

      final transferTransaction = Transaction(
        id: '${DateTime.now().millisecondsSinceEpoch}_transfer',
        type: TransactionType.expense,
        amount: amountMinor,
        date: DateTime.now(),
        note: l10n.mainScreen_transferToPiggyBank(bank.name),
        piggyBankId: piggyBankId,
        source: TransactionSource.piggyBank,
      );
      await ref.read(transactionsProvider.notifier).add(transferTransaction);
    } else {
      await AutoFillService.processAutoFill(transaction);
    }

    await ref.read(playerProfileRepositoryProvider).addXp(10);
    _recordBariAction(BariActionType.income, transaction);
    _refreshAll();
  }

  Future<void> _handleExpense(Map<String, dynamic> result) async {
    if (!mounted) return;
    final amountMinor = MoneyInputValidator.validateAndShowError(
      context,
      result['amount'] as String,
    );
    if (amountMinor == null) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.expense,
      amount: amountMinor,
      date: DateTime.now(),
      category: result['category'] as String?,
      note: result['note'] as String?,
      piggyBankId: result['piggyBankId'] as String?,
      source: result['piggyBankId'] != null
          ? TransactionSource.piggyBank
          : TransactionSource.manual,
    );

    await ref.read(transactionsProvider.notifier).add(transaction);
    await ref.read(playerProfileRepositoryProvider).addXp(5);
    _recordBariAction(BariActionType.expense, transaction);
    _refreshAll();
  }

  Future<void> _recordBariAction(BariActionType type, Transaction tx) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final memory = await StorageService.getBariMemory();
    memory.addAction(
      BariAction(
        type: type,
        timestamp: DateTime.now(),
        transactionId: tx.id,
        amount: tx.amount,
      ),
    );

    final tip = switch (type) {
      BariActionType.income => l10n.bariTip_income,
      BariActionType.expense => l10n.bariTip_expense,
      BariActionType.planCreated => l10n.bariTip_planCreated,
      BariActionType.planCompleted => l10n.bariTip_planCompleted,
      BariActionType.piggyBankCreated => l10n.bariTip_piggyBankCreated,
      BariActionType.piggyBankCompleted => l10n.bariTip_piggyBankCompleted,
      BariActionType.lessonCompleted => l10n.bariTip_lessonCompleted,
      BariActionType.levelUp => l10n.bariTip_levelUp,
    };
    memory.addTip(tip);
    await StorageService.saveBariMemory(memory);
    if (mounted) {
      setState(() {
        _bariMemory = memory;
      });
    }
  }

  Future<void> _refreshAll() async {
    await ref.read(transactionsProvider.notifier).refresh();
    await ref.read(plannedEventsProvider.notifier).refresh();
    await ref.read(playerProfileProvider.notifier).refresh();
  }

  Future<void> _planEvent() async {
    Navigator.push(
      context,
      SlidePageRoute(page: const PlanEventScreen()),
    ).then((_) => ref.read(plannedEventsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Слушаем изменения транзакций для обновления подсказок
    // Проверяем, что данные загружены, прежде чем проверять подсказки
    ref.listen<AsyncValue<List<Transaction>>>(transactionsProvider, (
      previous,
      next,
    ) {
      // Проверяем подсказки только если данные успешно загружены
      if (next.hasValue && next.value != null && next.value!.isNotEmpty) {
        // Откладываем проверку, чтобы не блокировать UI
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _checkProactiveHintDebounced();
          }
        });
      }
    });

    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Stack(
        children: [
          if (!isTablet)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_currentIndex),
                child: _screens[_currentIndex.clamp(0, _screens.length - 1)],
              ),
            )
          else
            _screens[_currentIndex.clamp(0, _screens.length - 1)],
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedbackUtil.selection();
                    setState(() {
                      _currentIndex = 4; // Settings screen index
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _currentIndex == 4
                          ? AuroraTheme.neonYellow.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentIndex == 4
                            ? AuroraTheme.neonYellow
                            : Colors.white24,
                      ),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: _currentIndex == 4
                          ? AuroraTheme.neonYellow
                          : Colors.white70,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Builder(
            builder: (builderContext) {
              return BariOverlay(
                memory: _bariMemory ?? BariMemory(),
                proactiveHint: _proactiveHint,
                onChatTap: () {
                  if (!mounted) return;
                  Navigator.of(
                    builderContext,
                  ).push(SlidePageRoute(page: const BariChatScreen()));
                },
                onMoreTipsTap: () {
                  if (!mounted) return;
                  Navigator.of(builderContext).push(
                    SlidePageRoute(page: const BariRecommendationsScreen()),
                  );
                },
                onHintAction: _handleProactiveAction,
              );
            },
          ),
          if (_isFabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFabOption(
                        icon: Icons.calendar_today,
                        label: l10n.common_plan,
                        color: AuroraTheme.neonPurple,
                        onTap: () {
                          _toggleFab();
                          _planEvent();
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFabOption(
                        icon: Icons.remove,
                        label: l10n.common_expense,
                        color: Colors.redAccent,
                        onTap: () {
                          _toggleFab();
                          HapticFeedback.lightImpact();
                          showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddTransactionSheet(
                              type: TransactionType.expense,
                            ),
                          ).then((result) {
                            if (result != null) _handleExpense(result);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildFabOption(
                        icon: Icons.add,
                        label: l10n.common_income,
                        color: AuroraTheme.neonBlue,
                        onTap: () {
                          _toggleFab();
                          HapticFeedback.lightImpact();
                          showModalBottomSheet<Map<String, dynamic>>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddTransactionSheet(
                              type: TransactionType.income,
                            ),
                          ).then((result) {
                            if (result != null) _handleIncome(result);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFab,
        backgroundColor: _isFabOpen ? Colors.white : AuroraTheme.neonBlue,
        elevation: 4,
        shape: const CircleBorder(),
        child: AnimatedIcon(
          icon: AnimatedIcons.add_event,
          progress: _fabAnimation,
          color: _isFabOpen ? AuroraTheme.spaceBlue : Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isTablet
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex.clamp(0, 3),
              onDestinationSelected: (index) {
                if (_currentIndex != index) {
                  HapticFeedbackUtil.selection();
                }
                setState(() {
                  _currentIndex = index;
                });
                MainScreen.tabNotifier.value = index;
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet),
                  label: l10n.common_balance,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.savings_outlined),
                  selectedIcon: const Icon(Icons.savings),
                  label: l10n.common_piggyBanks,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_today_outlined),
                  selectedIcon: const Icon(Icons.calendar_today),
                  label: l10n.common_calendar,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.school_outlined),
                  selectedIcon: const Icon(Icons.school),
                  label: l10n.common_lessons,
                ),
              ],
            ),
      drawer: isTablet
          ? Drawer(
              child: NavigationRail(
                selectedIndex: _currentIndex.clamp(0, 3),
                onDestinationSelected: (index) {
                  if (_currentIndex != index) {
                    HapticFeedbackUtil.selection();
                  }
                  setState(() {
                    _currentIndex = index;
                  });
                  MainScreen.tabNotifier.value = index;
                  Navigator.pop(context);
                },
                labelType: NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: const Icon(Icons.account_balance_wallet),
                    label: Text(l10n.common_balance),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.savings_outlined),
                    selectedIcon: const Icon(Icons.savings),
                    label: Text(l10n.common_piggyBanks),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.calendar_today_outlined),
                    selectedIcon: const Icon(Icons.calendar_today),
                    label: Text(l10n.common_calendar),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.school_outlined),
                    selectedIcon: const Icon(Icons.school),
                    label: Text(l10n.common_lessons),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              HapticFeedbackUtil.mediumImpact();
              onTap();
            },
            backgroundColor: color,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// AddTransactionSheet импортируется из balance_screen.dart
