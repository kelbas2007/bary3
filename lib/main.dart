import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/bari_chat_screen.dart';
import 'screens/parent_zone_screen.dart';
import 'screens/tools_hub_screen.dart';
import 'screens/piggy_banks_screen.dart';
import 'screens/calculators/budget_50_30_20_calculator.dart';
import 'screens/calculators/twenty_four_hour_rule_calculator.dart';
import 'screens/calculators/can_i_buy_calculator.dart';
import 'screens/calculators/subscriptions_calculator.dart';
import 'screens/calculators/goal_date_calculator.dart';
import 'screens/calculators/monthly_budget_calculator.dart';
import 'screens/calculators/price_comparison_calculator.dart';
import 'screens/calculators/piggy_plan_calculator.dart';
import 'screens/calculators/calendar_forecast_calculator.dart';
import 'theme/aurora_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/currency_controller.dart';
import 'services/currency_scope.dart';
import 'services/deep_link_service.dart';
import 'l10n/app_localizations.dart';
import 'services/performance_monitor.dart';
import 'services/app_shortcuts_service.dart';
import 'services/live_activities_service.dart';

final GlobalKey<Bary3AppState> appKey = GlobalKey<Bary3AppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Предзагружаем SharedPreferences, чтобы первый доступ был быстрее
  // Это предотвращает блокировку UI при первом обращении к провайдерам
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('[main] Error initializing SharedPreferences: $e');
  }
  
  // Инициализируем сервисы с обработкой ошибок
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('[main] Error initializing NotificationService: $e');
  }
  
  try {
    // Run migration to fix old piggy bank transaction types
    await StorageService.migratePiggyLedgerIfNeeded();
  } catch (e) {
    debugPrint('[main] Error running migration: $e');
  }
  
  try {
    // Инициализируем сервис deep links
    DeepLinkService.instance.initialize();
  } catch (e) {
    debugPrint('[main] Error initializing DeepLinkService: $e');
  }
  
  // Регистрируем App Shortcuts для Google Assistant
  try {
    await AppShortcutsService.registerShortcuts();
  } catch (e) {
    debugPrint('[main] Error registering App Shortcuts: $e');
  }
  
  // Инициализируем Live Activities Service
  try {
    await LiveActivitiesService.initialize();
  } catch (e) {
    debugPrint('[main] Error initializing Live Activities Service: $e');
  }
  
  // Запускаем мониторинг производительности в debug режиме
  if (kDebugMode) {
    try {
      PerformanceMonitor().startFpsMonitoring();
    } catch (e) {
      debugPrint('[main] Error starting PerformanceMonitor: $e');
    }
  }
  
  runApp(Bary3App(key: appKey));
}

class Bary3App extends StatefulWidget {
  const Bary3App({super.key});

  @override
  State<Bary3App> createState() => Bary3AppState();
}

class Bary3AppState extends State<Bary3App> {
  String _theme = 'blue';
  String _language = 'ru';
  late final CurrencyController _currencyController;

  @override
  void initState() {
    super.initState();
    _currencyController = CurrencyController();
    // Загружаем валюту асинхронно, не блокируя UI
    _currencyController.load();
    // Загружаем настройки асинхронно
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await StorageService.getTheme();
    final language = await StorageService.getLanguage();
    if (mounted) {
      setState(() {
        _theme = theme;
        _language = language;
      });
    }
  }

  void setLanguage(String language) {
    if (!mounted) return;
    setState(() {
      _language = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CurrencyScope(
      controller: _currencyController,
      child: ProviderScope(
        child: MaterialApp(
          key: const Key('bary3_app'),
          title: 'BargeldKids Solo',
          theme: AuroraTheme.getTheme(themeColor: _theme),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru', ''),
            Locale('de', ''),
            Locale('en', ''),
          ],
          locale: Locale(_language),
          home: const MainScreen(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/chat': (context) => const BariChatScreen(),
            '/parent-zone': (context) => const ParentZoneScreen(),
            '/tools': (context) => const ToolsHubScreen(),
            '/piggy-banks': (context) => const PiggyBanksScreen(),
            '/calculator-50-30-20': (context) => const Budget503020Calculator(),
            '/calculator-24h': (context) => const Rule24HoursCalculator(),
            '/calculator-can-i-buy': (context) => const CanIBuyCalculator(),
            '/calculator-subscriptions': (context) => const SubscriptionsCalculator(),
            '/calculator-goal-date': (context) => const GoalDateCalculator(),
            '/calculator-monthly-budget': (context) => const MonthlyBudgetCalculator(),
            '/calculator-price-comparison': (context) => const PriceComparisonCalculator(),
            '/calculator-piggy-plan': (context) => const PiggyPlanCalculator(),
            '/calculator-calendar-forecast': (context) => const CalendarForecastCalculator(),
          },
        ),
      ),
    );
  }
}
