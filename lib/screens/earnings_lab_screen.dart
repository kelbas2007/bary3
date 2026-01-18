import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../models/player_profile.dart';
import '../models/custom_task.dart';
import '../models/piggy_bank.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/aurora_theme.dart';
import '../services/currency_scope.dart';
import '../services/money_formatter.dart';
import '../services/money_ui.dart';
import '../domain/finance_rules.dart';
import '../domain/ux_detail_level.dart';
import '../state/player_profile_notifier.dart';
import '../state/planned_events_notifier.dart';
import '../state/transactions_notifier.dart';
import 'earnings_history_screen.dart';
import 'bari_chat_screen.dart';
import '../l10n/app_localizations.dart';

class EarningsLabScreen extends StatefulWidget {
  const EarningsLabScreen({super.key});

  @override
  State<EarningsLabScreen> createState() => _EarningsLabScreenState();
}

class _EarningsLabScreenState extends State<EarningsLabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CustomTask> _customTasks = [];
  UxDetailLevel _uxDetailLevel = UxDetailLevel.simple;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCustomTasks();
    // Загружаем уровень подробности (simple/pro)
    StorageService.getUxDetailLevel().then((raw) {
      if (!mounted) return;
      setState(() {
        _uxDetailLevel = UxDetailLevelX.fromStorage(raw);
      });
    });
  }

  String _getEarningsLabExplanation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_uxDetailLevel == UxDetailLevel.simple) {
      return l10n.earningsLab_explanationSimple;
    } else {
      return l10n.earningsLab_explanationPro;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomTasks() async {
    final tasks = await StorageService.getCustomTasks();
    if (mounted) {
      setState(() {
        _customTasks = tasks;
      });
    }
  }

  Future<void> _saveCustomTasks() async {
    await StorageService.saveCustomTasks(_customTasks);
  }

  Map<String, dynamic> _customTaskToMap(CustomTask task) {
    return {
      'id': task.id,
      'title': task.title,
      'category': task.category,
      'recommendedMoney': task.rewardAmountMinor,
      'description': task.description ?? '',
      'reward': '${task.rewardAmountMinor ~/ 100}',
      'type': 'custom',
      'repeatType': task.repeatType,
      'cooldownHours': task.cooldownHours,
      'lastCompletedAt': task.lastCompletedAt,
      'time': '—',
      'difficulty': 1,
      'level': 'novice',
    };
  }

  Future<void> _showNewTaskBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<CustomTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewTaskBottomSheet(
        onSaved: (task) {
          Navigator.pop(context, task);
        },
      ),
    );

    if (result != null && context.mounted) {
      setState(() {
        _customTasks.add(result);
      });
      await _saveCustomTasks();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.earningsLab_taskAdded)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.earningsLab_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EarningsHistoryScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.earningsLab_tabQuick),
            Tab(text: AppLocalizations.of(context)!.earningsLab_tabHome),
            Tab(text: AppLocalizations.of(context)!.earningsLab_tabProjects),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Статистика
              _StatisticsPanel(explanation: _getEarningsLabExplanation(context)),
              // Список заданий
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _EarningsList(
                      category: 'quick',
                      tasks: [
                        ..._quickTasks,
                        ..._customTasks.map((t) => _customTaskToMap(t)),
                      ],
                      customTasks: _customTasks,
                      onTaskUpdated: _loadCustomTasks,
                    ),
                    _EarningsList(category: 'home', tasks: _homeTasks),
                    _EarningsList(category: 'project', tasks: _projectTasks),
                  ],
                ),
              ),
              // Кнопка "Новое задание"
              Padding(
                padding: const EdgeInsets.all(16),
                child: _NewTaskButton(
                  onPressed: () => _showNewTaskBottomSheet(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _quickTasks = [
    {
      'title': 'Помочь по дому',
      'time': '15 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '10 XP',
      'money': 0,
      'description':
          'Выбери одно дело: посуда / мусор / пыль / пол / стол. Сделай 10–15 минут и доведи до результата.',
    },
    {
      'title': 'Выучить стих',
      'time': '30 мин',
      'difficulty': 2,
      'level': 'novice',
      'reward': '20 XP',
      'money': 0,
      'description':
          'Прочитай 3 раза, выучи по строчкам, потом расскажи без подсказок.',
    },
    {
      'title': 'Убрать комнату',
      'time': '20 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '15 XP',
      'money': 0,
      'description':
          'Наведи порядок 10–15 минут: игрушки на место, стол чистый, мусор выброшен.',
    },
    {
      'title': 'Помыть посуду',
      'time': '20 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '15 XP',
      'money': 0,
      'description': 'Вымыть всю посуду после еды и убрать на место.',
    },
    {
      'title': 'Вынести мусор',
      'time': '5 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '10 XP',
      'money': 0,
      'description': 'Вынести мусор и завязать новый пакет.',
    },
    {
      'title': 'Пропылесосить',
      'time': '15 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '15 XP',
      'money': 0,
      'description': 'Пропылесосить свою комнату или гостиную.',
    },
    {
      'title': 'Полить цветы',
      'time': '10 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '10 XP',
      'money': 0,
      'description': 'Проверить и полить все комнатные растения.',
    },
    {
      'title': 'Покормить питомца',
      'time': '5 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '10 XP',
      'money': 0,
      'description': 'Покормить домашнего питомца и налить свежую воду.',
    },
    {
      'title': 'Застелить кровать',
      'time': '5 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '10 XP',
      'money': 0,
      'description': 'Аккуратно застелить свою кровать.',
    },
    {
      'title': 'Собрать портфель',
      'time': '10 мин',
      'difficulty': 1,
      'level': 'novice',
      'reward': '10 XP',
      'money': 0,
      'description': 'Проверить расписание и собрать всё необходимое на завтра.',
    },
  ];

  final List<Map<String, dynamic>> _homeTasks = [
    {
      'id': 'home_1',
      'title': 'Прочитать книгу',
      'description':
          'Прочитай главу из интересной книги. Чтение развивает воображение и словарный запас.',
      'time': '1 час',
      'timeMinutes': 60,
      'difficulty': 2,
      'level': 'experienced',
      'reward': '30 XP',
      'recommendedMoney': 200,
      'money': 0,
      'type': 'home',
      'tags': ['обучение'],
      'icon': 'menu_book',
      'color': 0xFF3F51B5,
      'steps': [
        'Выбери книгу',
        'Найди тихое место',
        'Прочитай главу',
        'Расскажи о прочитанном',
      ],
      'needs': ['Книга', 'Тихое место'],
      'bariTip': 'Читай по 10-15 минут с перерывами — так легче!',
      'canRepeat': true,
      'cooldownHours': 24, // 1 раз в день
      'requiresParent': false,
    },
    {
      'id': 'home_2',
      'title': 'Помочь с готовкой',
      'description':
          'Помоги родителям приготовить обед или ужин. Научишься готовить простые блюда!',
      'time': '45 мин',
      'timeMinutes': 45,
      'difficulty': 2,
      'level': 'experienced',
      'reward': '25 XP',
      'recommendedMoney': 150,
      'money': 0,
      'type': 'home',
      'tags': ['помощь', 'творчество'],
      'icon': 'restaurant_menu',
      'color': 0xFFE91E63,
      'steps': [
        'Выбери блюдо',
        'Помоги нарезать овощи',
        'Помешай на плите',
        'Помоги накрыть стол',
      ],
      'needs': ['Ингредиенты', 'Время'],
      'bariTip': 'Сначала спроси, что нужно сделать — так безопаснее!',
      'canRepeat': true,
      'cooldownHours': 24,
      'requiresParent': true, // нужен родитель для безопасности
    },
    {
      'id': 'home_3',
      'title': 'Выполнить домашнее задание',
      'description':
          'Сделай все домашние задания аккуратно и вовремя. Это твоя главная работа!',
      'time': '1 час',
      'timeMinutes': 60,
      'difficulty': 3,
      'level': 'experienced',
      'reward': '40 XP',
      'recommendedMoney': 300,
      'money': 0,
      'type': 'home',
      'tags': ['обучение'],
      'icon': 'school',
      'color': 0xFF00BCD4,
      'steps': [
        'Посмотри, что задано',
        'Выполни по порядку',
        'Проверь ошибки',
        'Собери портфель',
      ],
      'needs': ['Тетради', 'Ручки', 'Время'],
      'bariTip': 'Начни с самого сложного — потом будет легче!',
      'canRepeat': true,
      'cooldownHours': 24,
      'requiresParent': false,
    },
    {
      'id': 'home_4',
      'title': 'Помочь с покупками',
      'description':
          'Сходи с родителями в магазин и помоги нести покупки. Учишься планировать расходы!',
      'time': '1 час',
      'timeMinutes': 60,
      'difficulty': 2,
      'level': 'experienced',
      'reward': '30 XP',
      'recommendedMoney': 200,
      'money': 0,
      'type': 'home',
      'tags': ['помощь'],
      'icon': 'shopping_cart',
      'color': 0xFF795548,
      'steps': [
        'Составь список покупок',
        'Сходи в магазин',
        'Помоги нести сумки',
        'Разложи покупки',
      ],
      'needs': ['Список', 'Время'],
      'bariTip': 'Считай сдачу вместе с родителями — это полезно!',
      'canRepeat': true,
      'cooldownHours': 24,
      'requiresParent': true,
    },
    {
      'id': 'home_5',
      'title': 'Помыть машину',
      'description': 'Помыть семейную машину снаружи и внутри. Учишься ответственности!',
      'time': '1.5 часа',
      'timeMinutes': 90,
      'difficulty': 2,
      'level': 'experienced',
      'reward': '35 XP',
      'recommendedMoney': 300,
      'money': 0,
      'type': 'home',
      'tags': ['помощь'],
      'icon': 'directions_car',
      'color': 0xFF607D8B,
      'steps': [
        'Подготовь ведро и губку',
        'Помой машину снаружи',
        'Пропылесось салон',
        'Протри панель',
      ],
      'needs': ['Вода', 'Губка', 'Время'],
      'bariTip': 'Начни с крыши и двигайся вниз — так эффективнее!',
      'canRepeat': true,
      'cooldownHours': 168, // раз в неделю
      'requiresParent': true,
    },
    {
      'id': 'home_6',
      'title': 'Погулять с собакой',
      'description': 'Выгулять собаку утром или вечером. Ответственность за питомца!',
      'time': '30 мин',
      'timeMinutes': 30,
      'difficulty': 1,
      'level': 'experienced',
      'reward': '20 XP',
      'recommendedMoney': 100,
      'money': 0,
      'type': 'home',
      'tags': ['помощь'],
      'icon': 'pets',
      'color': 0xFF9C27B0,
      'steps': [
        'Возьми поводок',
        'Выведи собаку на прогулку',
        'Убери за собакой',
        'Вернись домой',
      ],
      'needs': ['Поводок', 'Время'],
      'bariTip': 'Соблюдай правила выгула — это важно для безопасности!',
      'canRepeat': true,
      'cooldownHours': 6,
      'requiresParent': false,
    },
    {
      'id': 'home_7',
      'title': 'Помочь с уборкой',
      'description': 'Помочь родителям с генеральной уборкой: вымыть окна, протереть пыль, убрать шкафы.',
      'time': '2 часа',
      'timeMinutes': 120,
      'difficulty': 3,
      'level': 'experienced',
      'reward': '45 XP',
      'recommendedMoney': 400,
      'money': 0,
      'type': 'home',
      'tags': ['помощь'],
      'icon': 'cleaning_services',
      'color': 0xFF4CAF50,
      'steps': [
        'Выбери комнату',
        'Протри пыль',
        'Вымой окна',
        'Убери вещи на место',
      ],
      'needs': ['Тряпки', 'Время', 'Энтузиазм'],
      'bariTip': 'Работай по одной комнате — так не устанешь!',
      'canRepeat': true,
      'cooldownHours': 168, // раз в неделю
      'requiresParent': true,
    },
    {
      'id': 'home_8',
      'title': 'Изучить новую тему',
      'description': 'Самостоятельно изучить новую тему по школьному предмету и сделать конспект.',
      'time': '1.5 часа',
      'timeMinutes': 90,
      'difficulty': 3,
      'level': 'experienced',
      'reward': '40 XP',
      'recommendedMoney': 350,
      'money': 0,
      'type': 'home',
      'tags': ['обучение'],
      'icon': 'menu_book',
      'color': 0xFF2196F3,
      'steps': [
        'Выбери тему',
        'Найди материалы',
        'Изучи и сделай конспект',
        'Проверь понимание',
      ],
      'needs': ['Учебники', 'Тетрадь', 'Время'],
      'bariTip': 'Делай перерывы каждые 25 минут — так лучше запомнишь!',
      'canRepeat': true,
      'cooldownHours': 24,
      'requiresParent': false,
    },
    {
      'id': 'home_9',
      'title': 'Помочь с ремонтом',
      'description': 'Помочь родителям с мелким ремонтом: покрасить, прикрутить, собрать мебель.',
      'time': '2 часа',
      'timeMinutes': 120,
      'difficulty': 3,
      'level': 'master',
      'reward': '50 XP',
      'recommendedMoney': 500,
      'money': 0,
      'type': 'home',
      'tags': ['помощь', 'творчество'],
      'icon': 'build',
      'color': 0xFFFF9800,
      'steps': [
        'Узнай задачу',
        'Подготовь инструменты',
        'Выполни работу',
        'Убери за собой',
      ],
      'needs': ['Инструменты', 'Время', 'Внимательность'],
      'bariTip': 'Следуй инструкциям родителей — безопасность важнее всего!',
      'canRepeat': true,
      'cooldownHours': 168,
      'requiresParent': true,
    },
    {
      'id': 'home_10',
      'title': 'Приготовить завтрак/ужин',
      'description': 'Самостоятельно приготовить завтрак или ужин для семьи. Учишься готовить!',
      'time': '1 час',
      'timeMinutes': 60,
      'difficulty': 2,
      'level': 'experienced',
      'reward': '35 XP',
      'recommendedMoney': 300,
      'money': 0,
      'type': 'home',
      'tags': ['помощь', 'творчество'],
      'icon': 'restaurant',
      'color': 0xFFE91E63,
      'steps': [
        'Выбери блюдо',
        'Подготовь ингредиенты',
        'Приготовь еду',
        'Накрой стол',
      ],
      'needs': ['Ингредиенты', 'Время', 'Рецепт'],
      'bariTip': 'Начни с простых блюд — постепенно научишься готовить сложнее!',
      'canRepeat': true,
      'cooldownHours': 24,
      'requiresParent': true,
    },
  ];

  final List<Map<String, dynamic>> _projectTasks = [
    {
      'id': 'project_1',
      'title': 'Создать поделку',
      'description':
          'Создай красивую поделку своими руками: рисунок, аппликацию, фигурку из пластилина.',
      'time': '2-3 дня',
      'timeMinutes': 180, // примерно
      'difficulty': 3,
      'level': 'master',
      'reward': '50 XP',
      'recommendedMoney': 500,
      'money': 0,
      'type': 'project',
      'tags': ['творчество'],
      'icon': 'palette',
      'color': 0xFFFF5722,
      'steps': [
        'Придумай идею',
        'Подготовь материалы',
        'Создай поделку',
        'Покажи результат',
      ],
      'needs': ['Материалы', 'Время', 'Вдохновение'],
      'bariTip': 'Не торопись — хорошая поделка требует времени!',
      'canRepeat': false, // пока не завершишь, второй не создаётся
      'cooldownHours': 0,
      'requiresParent': false,
    },
    {
      'id': 'project_2',
      'title': 'Выучить новое хобби',
      'description':
          'Начни изучать что-то новое: игру на инструменте, спорт, программирование, языки.',
      'time': 'Неделя',
      'timeMinutes': 420,
      'difficulty': 3,
      'level': 'master',
      'reward': '60 XP',
      'recommendedMoney': 600,
      'money': 0,
      'type': 'project',
      'tags': ['обучение', 'творчество'],
      'icon': 'sports_esports',
      'color': 0xFF009688,
      'steps': [
        'Выбери хобби',
        'Найди материалы/уроки',
        'Занимайся каждый день',
        'Покажи прогресс',
      ],
      'needs': ['Материалы', 'Время', 'Терпение'],
      'bariTip': 'Занимайся понемногу каждый день — так лучше!',
      'canRepeat': false,
      'cooldownHours': 0,
      'requiresParent': false,
    },
    {
      'id': 'project_3',
      'title': 'Организовать семейный праздник',
      'description':
          'Помоги организовать день рождения или другой праздник: укрась комнату, придумай игры.',
      'time': '3-5 дней',
      'timeMinutes': 300,
      'difficulty': 3,
      'level': 'master',
      'reward': '55 XP',
      'recommendedMoney': 550,
      'money': 0,
      'type': 'project',
      'tags': ['творчество', 'помощь'],
      'icon': 'celebration',
      'color': 0xFFFFC107,
      'steps': [
        'Придумай тему',
        'Сделай украшения',
        'Подготовь игры',
        'Проведи праздник',
      ],
      'needs': ['Материалы', 'Время', 'Идеи'],
      'bariTip': 'Начни с плана — так ничего не забудешь!',
      'canRepeat': false,
      'cooldownHours': 0,
      'requiresParent': true,
    },
    {
      'id': 'project_4',
      'title': 'Создать видео/блог',
      'description': 'Создать видео или написать блог-пост на интересную тему. Развиваешь творческие навыки!',
      'time': 'Неделя',
      'timeMinutes': 420,
      'difficulty': 3,
      'level': 'master',
      'reward': '60 XP',
      'recommendedMoney': 600,
      'money': 0,
      'type': 'project',
      'tags': ['творчество', 'обучение'],
      'icon': 'videocam',
      'color': 0xFF9C27B0,
      'steps': [
        'Выбери тему',
        'Напиши сценарий',
        'Сними/напиши контент',
        'Опубликуй результат',
      ],
      'needs': ['Камера/Компьютер', 'Время', 'Идеи'],
      'bariTip': 'Будь собой и рассказывай о том, что тебе интересно!',
      'canRepeat': false,
      'cooldownHours': 0,
      'requiresParent': false,
    },
    {
      'id': 'project_5',
      'title': 'Организовать семейный поход',
      'description': 'Спланировать и организовать семейный поход или пикник: маршрут, еда, игры.',
      'time': 'Неделя',
      'timeMinutes': 420,
      'difficulty': 3,
      'level': 'master',
      'reward': '55 XP',
      'recommendedMoney': 550,
      'money': 0,
      'type': 'project',
      'tags': ['помощь', 'творчество'],
      'icon': 'hiking',
      'color': 0xFF4CAF50,
      'steps': [
        'Выбери место',
        'Составь план',
        'Подготовь еду и игры',
        'Проведи поход',
      ],
      'needs': ['Время', 'План', 'Энтузиазм'],
      'bariTip': 'Учитывай погоду и интересы всех участников!',
      'canRepeat': false,
      'cooldownHours': 0,
      'requiresParent': true,
    },
    {
      'id': 'project_6',
      'title': 'Научиться программировать',
      'description': 'Изучить основы программирования: создать простую игру или сайт.',
      'time': '2 недели',
      'timeMinutes': 840,
      'difficulty': 4,
      'level': 'master',
      'reward': '70 XP',
      'recommendedMoney': 700,
      'money': 0,
      'type': 'project',
      'tags': ['обучение'],
      'icon': 'code',
      'color': 0xFF2196F3,
      'steps': [
        'Выбери язык/платформу',
        'Пройди базовые уроки',
        'Создай первый проект',
        'Покажи результат',
      ],
      'needs': ['Компьютер', 'Время', 'Терпение'],
      'bariTip': 'Начни с простых проектов — постепенно усложняй!',
      'canRepeat': false,
      'cooldownHours': 0,
      'requiresParent': false,
    },
  ];
}

// Панель статистики
class _StatisticsPanel extends StatefulWidget {
  final String explanation;

  const _StatisticsPanel({required this.explanation});

  @override
  State<_StatisticsPanel> createState() => _StatisticsPanelState();
}

class _StatisticsPanelState extends State<_StatisticsPanel> {
  int _todayCount = 0;
  int _weekEarnings = 0;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final transactions = await StorageService.getTransactions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    // Считаем выполненные сегодня
    final todayTasks = transactions
        .where(
          (t) =>
              t.source == TransactionSource.earningsLab &&
              t.parentApproved &&
              t.date.isAfter(today),
        )
        .length;

    // Считаем заработок за неделю
    final weekEarnings = transactions
        .where(
          (t) =>
              t.source == TransactionSource.earningsLab &&
              t.parentApproved &&
              t.date.isAfter(weekAgo) &&
              t.type == TransactionType.income,
        )
        .fold<int>(0, (sum, t) => sum + t.amount);

    // Считаем streak из StorageService
    final streak = await StorageService.getEarningsStreak();

    if (mounted) {
      setState(() {
        _todayCount = todayTasks;
        _weekEarnings = weekEarnings;
        _streakDays = streak;
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AuroraTheme.glassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.explanation,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.today,
                      label: 'Сделано сегодня',
                      value: _todayCount.toString(),
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.attach_money,
                      label: 'За неделю',
                      value: _formatAmount(_weekEarnings),
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.local_fire_department,
                      label: 'Серия',
                      value: '$_streakDays дней',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AuroraTheme.neonYellow, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EarningsList extends ConsumerStatefulWidget {
  final String category;
  final List<Map<String, dynamic>> tasks;
  final List<CustomTask>? customTasks;
  final VoidCallback? onTaskUpdated;

  const _EarningsList({
    required this.category,
    required this.tasks,
    this.customTasks,
    this.onTaskUpdated,
  });

  @override
  ConsumerState<_EarningsList> createState() => _EarningsListState();
}

class _EarningsListState extends ConsumerState<_EarningsList> {
  bool _isTaskUnlocked(
    Map<String, dynamic> task,
    PlayerProfile? profile,
    int completedCount,
  ) {
    if (profile == null) return true;
    final level = task['level'] as String;
    final playerLevel = profile.level;

    switch (level) {
      case 'novice':
        return true;
      case 'experienced':
        return playerLevel >= 3 || completedCount >= 5;
      case 'master':
        return playerLevel >= 5 || completedCount >= 10;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider).value;
    final plannedEvents = ref.watch(plannedEventsProvider).value ?? const <PlannedEvent>[];
    final transactions = ref.watch(transactionsProvider).value ?? const <Transaction>[];

    final plannedMap = <String, PlannedEvent>{};
    for (final event in plannedEvents) {
      if (event.source == EventSource.earningsLab &&
          event.status == PlannedEventStatus.planned &&
          event.name != null) {
        final n = event.name!;
        final key = n.startsWith('Earnings: ') ? n.substring(10) : n;
        plannedMap[key] = event;
      }
    }

    // Оптимизированная обработка транзакций - один проход
    final earningsTx = <Transaction>[];
    final lastByNote = <String, Transaction>{};
    int completedCount = 0;
    
    for (final t in transactions) {
      if (t.source == TransactionSource.earningsLab) {
        earningsTx.add(t);
        if (t.parentApproved) completedCount++;
        final note = t.note;
        if (note != null && note.isNotEmpty) {
          lastByNote.putIfAbsent(note, () => t);
        }
      }
    }
    
    // Сортируем один раз
    earningsTx.sort((a, b) => b.date.compareTo(a.date));

    final filteredTasks = widget.tasks.where((task) {
      return _isTaskUnlocked(task, profile, completedCount);
    }).toList();

    if (filteredTasks.isEmpty) {
      final isCustomTab =
          widget.category == 'quick' && widget.customTasks != null;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                isCustomTab
                    ? 'Заданий нет. Сделай первое!'
                    : 'Пока нет доступных заданий',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (isCustomTab) ...[
                const SizedBox(height: 8),
                const Text(
                  'Давай придумаем лёгкое задание на сегодня 🙂',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const SizedBox(height: 8),
                const Text(
                  'Выполни задания из других категорий, чтобы открыть новые!',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ), // Bottom padding для кнопки
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        final taskTitle = task['title'] as String;
        final isUnlocked = _isTaskUnlocked(task, profile, completedCount);
        final plannedEvent = plannedMap[taskTitle];
        final lastCompletion = lastByNote[taskTitle];

        // Проверяем cooldown для кастомных заданий
        bool isOnCooldown = false;
        String? cooldownText;
        if (task['type'] == 'custom' && widget.customTasks != null) {
          final taskId = task['id'] as String;
          final customTask = widget.customTasks!.firstWhere(
            (t) => t.id == taskId,
            orElse: () => CustomTask(
              id: '',
              title: '',
              category: '',
              rewardAmountMinor: 0,
              repeatType: RepeatType.none,
              cooldownHours: 0,
              createdAt: DateTime.now(),
            ),
          );
          if (customTask.cooldownHours > 0 &&
              customTask.lastCompletedAt != null) {
            final now = DateTime.now();
            final hoursSince = now
                .difference(customTask.lastCompletedAt!)
                .inHours;
            if (hoursSince < customTask.cooldownHours) {
              isOnCooldown = true;
              final remainingHours = customTask.cooldownHours - hoursSince;
              final remainingMinutes =
                  (customTask.cooldownHours * 60 -
                      now.difference(customTask.lastCompletedAt!).inMinutes) %
                  60;
              if (remainingHours > 0) {
                cooldownText =
                    'Доступно через: $remainingHours ч ${remainingMinutes > 0 ? '$remainingMinutes мин' : ''}';
              } else {
                cooldownText = 'Доступно через: $remainingMinutes мин';
              }
            }
          }
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.5,
            child: InkWell(
              onTap: isUnlocked
                  ? () {
                      HapticFeedback.selectionClick();
                      _showTaskActions(context, task, plannedEvent);
                    }
                  : null,
              borderRadius: BorderRadius.circular(24),
              child: AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      taskTitle,
                                      style: TextStyle(
                                        color: isUnlocked
                                            ? Colors.white
                                            : Colors.white54,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!isUnlocked) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: Colors.white54,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _DifficultyChip(
                                      difficulty: task['difficulty'] as int,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.timer,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task['time'] as String,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Статусные чипы
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (plannedEvent != null)
                                      _StatusChip(
                                        label: 'Запланировано',
                                        dateTime: plannedEvent.dateTime,
                                        color: Colors.teal,
                                      ),
                                    if (lastCompletion != null &&
                                        !lastCompletion.parentApproved)
                                      const _StatusChip(
                                        label: 'Ожидает одобрения',
                                        color: Colors.grey,
                                      ),
                                    if (lastCompletion != null &&
                                        lastCompletion.parentApproved &&
                                        lastCompletion.date.year ==
                                            DateTime.now().year &&
                                        lastCompletion.date.month ==
                                            DateTime.now().month &&
                                        lastCompletion.date.day ==
                                            DateTime.now().day)
                                      const _StatusChip(
                                        label: 'Сделано сегодня',
                                        color: Colors.green,
                                      ),
                                    if (isOnCooldown && cooldownText != null)
                                      _StatusChip(
                                        label: cooldownText,
                                        color: Colors.orange,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AuroraTheme.neonYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Builder(
                            builder: (context) {
                              if (task['type'] == 'custom' &&
                                  widget.customTasks != null) {
                                final rewardCents =
                                    task['recommendedMoney'] as int? ?? 0;
                                return Text(
                                  formatAmountUi(context, rewardCents),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                );
                              }
                              return Text(
                                task['reward'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: isUnlocked && plannedEvent == null
                                  ? () => _planTask(context, task)
                                  : null,
                              icon: const Icon(Icons.calendar_today),
                              label: const Text(
                                'Запланировать',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isUnlocked
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              _TaskDetailScreen(
                                                task: task,
                                                onComplete: () => _completeTask(
                                                  context,
                                                  task,
                                                ),
                                                onPlan: () =>
                                                    _planTask(context, task),
                                              ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                'Подробнее',
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
      },
    );
  }

  /// Создаёт все повторяющиеся события на год вперёд
  List<PlannedEvent> _createRepeatEvents(PlannedEvent baseEvent) {
    final List<PlannedEvent> repeatEvents = [baseEvent];
    
    if (baseEvent.repeat == RepeatType.none) {
      return repeatEvents;
    }

    final DateTime endDate = DateTime.now().add(const Duration(days: 365));
    DateTime currentDate = baseEvent.dateTime;

    while (currentDate.isBefore(endDate)) {
      DateTime nextDate;
      switch (baseEvent.repeat) {
        case RepeatType.daily:
          nextDate = currentDate.add(const Duration(days: 1));
          break;
        case RepeatType.weekly:
          nextDate = currentDate.add(const Duration(days: 7));
          break;
        case RepeatType.monthly:
          nextDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        case RepeatType.yearly:
          nextDate = DateTime(
            currentDate.year + 1,
            currentDate.month,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        default:
          return repeatEvents;
      }

      if (nextDate.isAfter(endDate)) break;

      final event = PlannedEvent(
        id: '${baseEvent.id}_${nextDate.millisecondsSinceEpoch}',
        type: baseEvent.type,
        amount: baseEvent.amount,
        name: baseEvent.name,
        category: baseEvent.category,
        dateTime: nextDate,
        repeat: baseEvent.repeat,
        notificationEnabled: baseEvent.notificationEnabled,
        notificationMinutesBefore: baseEvent.notificationMinutesBefore,
        source: baseEvent.source,
        payoutPiggyBankId: baseEvent.payoutPiggyBankId,
        affectsWallet: baseEvent.affectsWallet,
      );

      repeatEvents.add(event);
      currentDate = nextDate;
    }

    return repeatEvents;
  }

  Future<void> _planTask(
    BuildContext context,
    Map<String, dynamic> task,
  ) async {
    if (!mounted) return;

    // Выбираем дату (по умолчанию завтра)
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !context.mounted) return;

    // Выбираем время (по умолчанию 18:00)
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );

    if (pickedTime == null || !context.mounted) return;

    // Объединяем дату и время
    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Запрашиваем награду (можно изменить, но с ограничениями)
    final rewardResult = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PlanRewardDialog(
        recommendedMoney: (task['recommendedMoney'] as int?) ?? 0,
        taskTitle: task['title'] as String,
      ),
    );

    if (rewardResult == null || !context.mounted) return;

    final rewardAmount = rewardResult['amount'] as int;
    final repeatType = rewardResult['repeat'] as RepeatType;
    final notificationEnabled = rewardResult['notification'] as bool;
    final payoutDestination = rewardResult['payoutDestination'] as String? ?? 'wallet';
    final payoutPiggyBankId = rewardResult['payoutPiggyBankId'] as String?;
    final affectsWallet = payoutDestination == 'wallet';

    final baseEvent = PlannedEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.income,
      amount: rewardAmount,
      name: 'Earnings: ${task['title'] as String}',
      dateTime: dateTime,
      repeat: repeatType,
      notificationEnabled: notificationEnabled,
      notificationMinutesBefore: 30,
      source: EventSource.earningsLab,
      category: 'Заработок',
      payoutPiggyBankId: payoutPiggyBankId,
      affectsWallet: affectsWallet,
    );

    // Создаём все повторяющиеся события
    final repeatEvents = _createRepeatEvents(baseEvent);
    final events = await StorageService.getPlannedEvents();
    events.addAll(repeatEvents);
    await StorageService.savePlannedEvents(events);

    // Планируем уведомления для всех событий
    for (var event in repeatEvents) {
      if (event.notificationEnabled) {
        await NotificationService.scheduleEventNotification(event);
      }
    }

    if (!context.mounted) return;
    final dateStr = '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
    final count = repeatEvents.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 1
              ? 'Создано $count повторяющихся заработков в календаре'
              : 'Заработок добавлен в календарь на $dateStr $timeStr',
        ),
      ),
    );
    await ref.read(plannedEventsProvider.notifier).refresh(); // Обновляем статусы
  }

  Future<void> _completeTask(
    BuildContext context,
    Map<String, dynamic> task,
  ) async {
    if (!mounted) return;

    // Проверяем cooldown для кастомных заданий
    if (task['type'] == 'custom' && widget.customTasks != null) {
      final taskId = task['id'] as String;
      final customTask = widget.customTasks!.firstWhere(
        (t) => t.id == taskId,
        orElse: () => CustomTask(
          id: '',
          title: '',
          category: '',
          rewardAmountMinor: 0,
          repeatType: RepeatType.none,
          cooldownHours: 0,
          createdAt: DateTime.now(),
        ),
      );
      if (customTask.cooldownHours > 0 && customTask.lastCompletedAt != null) {
        final now = DateTime.now();
        final hoursSince = now.difference(customTask.lastCompletedAt!).inHours;
        if (hoursSince < customTask.cooldownHours) {
          if (!context.mounted) return;
          final remainingHours = customTask.cooldownHours - hoursSince;
          final remainingMinutes =
              (customTask.cooldownHours * 60 -
                  now.difference(customTask.lastCompletedAt!).inMinutes) %
              60;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                remainingHours > 0
                    ? 'Доступно через: $remainingHours ч ${remainingMinutes > 0 ? '$remainingMinutes мин' : ''}'
                    : 'Доступно через: $remainingMinutes мин',
              ),
            ),
          );
          return;
        }
      }
    }

    // Для кастомных заданий используем фиксированную награду
    double money = 0;
    String? childComment;
    List<String>? photoPaths;
    
    if (task['type'] == 'custom' && widget.customTasks != null) {
      final taskId = task['id'] as String;
      final customTask = widget.customTasks!.firstWhere(
        (t) => t.id == taskId,
        orElse: () => CustomTask(
          id: '',
          title: '',
          category: '',
          rewardAmountMinor: 0,
          repeatType: RepeatType.none,
          cooldownHours: 0,
          createdAt: DateTime.now(),
        ),
      );
      money = customTask.rewardAmountMinor / 100.0;
    } else {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _CompleteTaskDialog(task: task),
      );
      if (result == null) return;
      money = result['money'] as double? ?? 0;
      childComment = result['comment'] as String?;
      final photos = result['photoPaths'] as List<dynamic>?;
      if (photos != null && photos.isNotEmpty) {
        photoPaths = photos.cast<String>();
      }
    }

    final xp =
        int.tryParse(
          (task['reward'] as String? ?? '10').replaceAll(' XP', ''),
        ) ??
        10;

    // Проверяем, нужно ли одобрение родителя
    final requiresParent = task['requiresParent'] as bool? ?? false;
    if (requiresParent) {
      // Запрашиваем PIN родителя
      final hasPin = await StorageService.hasParentPin();
      if (!context.mounted) return;
      if (hasPin) {
        final enteredPin = await showDialog<String>(
          context: context,
          builder: (context) => _ParentPinDialog(),
        );
        if (enteredPin == null || enteredPin.isEmpty) {
          return; // Отменено
        }
        final isValid = await StorageService.verifyParentPin(enteredPin);
        if (!context.mounted) return;
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.earningsLab_wrongPin),
            ),
          );
          return;
        }
      }
    }

    // Создаём транзакцию если есть деньги
    if (money > 0) {
      // Проверяем ограничение награды (+50% от рекомендованной)
      final recommendedMoneyCents = (task['recommendedMoney'] as int?) ?? 0;
      final maxMoneyCents = (recommendedMoneyCents * 1.5).round();
      final moneyCents = (money * 100).toInt();
      if (maxMoneyCents > 0 && moneyCents > maxMoneyCents) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Максимальная награда: ${formatAmountUi(context, maxMoneyCents)}',
            ),
          ),
        );
        return;
      }

      // Спрашиваем, куда добавить деньги
      if (!context.mounted) return;
      final destination = await showDialog<String>(
        context: context,
        builder: (context) => _EarningsDestinationDialog(amount: moneyCents),
      );
      if (destination == null) return; // Отменено

      String? piggyBankId;
      if (destination == 'piggy') {
        // Выбираем копилку
        final banks = await StorageService.getPiggyBanks();
        if (banks.isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.earningsLab_noPiggyBanks),
            ),
          );
          return;
        }
        if (!context.mounted) return;
        final selectedBank = await showDialog<PiggyBank>(
          context: context,
          builder: (context) => _PiggyBankPickerDialog(banks: banks),
        );
        if (selectedBank == null) return; // Отменено
        piggyBankId = selectedBank.id;
      }

      // Проверяем, требуется ли одобрение родителя (по сумме)
      final requiresApproval = FinanceRules.requiresParentApproval(moneyCents);

      final bool goesToPiggy = piggyBankId != null;
      final bool affectsWallet = !goesToPiggy;

      // Создаём транзакцию дохода (одну, без перевода)
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.income,
        amount: moneyCents,
        date: DateTime.now(),
        note: task['title'] as String,
        source: TransactionSource.earningsLab,
        parentApproved: !requiresApproval, // если требуется одобрение, то false
        affectsWallet:
            affectsWallet, // награда в кошелёк влияет на баланс, в копилку — нет
        piggyBankId: piggyBankId,
        childComment: childComment?.isNotEmpty == true ? childComment : null,
        photoPaths: photoPaths?.isNotEmpty == true ? photoPaths : null,
      );

      // Сохраняем транзакцию дохода
      await StorageService.addTransaction(transaction);

      // Если деньги идут в копилку и одобрение не требуется — сразу увеличиваем копилку
      if (piggyBankId != null && !requiresApproval) {
        final banks = await StorageService.getPiggyBanks();
        final bankIndex = banks.indexWhere((b) => b.id == piggyBankId);
        if (bankIndex >= 0) {
          final bank = banks[bankIndex];
          final updatedBank = bank.copyWith(
            currentAmount: bank.currentAmount + moneyCents,
          );
          banks[bankIndex] = updatedBank;
          await StorageService.savePiggyBanks(banks);
        }
      }

      // Отмечаем соответствующее запланированное событие как выполненное
      final events = await StorageService.getPlannedEvents();
      final today = DateTime.now();
      for (var i = 0; i < events.length; i++) {
        final event = events[i];
        if (event.source == EventSource.earningsLab &&
            event.name == 'Earnings: ${task['title'] as String}' &&
            event.status == PlannedEventStatus.planned &&
            event.dateTime.year == today.year &&
            event.dateTime.month == today.month &&
            event.dateTime.day == today.day) {
          events[i] = event.copyWith(status: PlannedEventStatus.completed);
          break;
        }
      }
      await StorageService.savePlannedEvents(events);

      if (requiresApproval) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.earningsLab_sentForApproval),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        if (!context.mounted) return;
        final locale = Localizations.localeOf(context).toString();
        final currencyCode = CurrencyScope.of(context).currencyCode;
        final text = formatMoney(
          amountMinor: moneyCents,
          currencyCode: currencyCode,
          locale: locale,
        );
        String message;
        if (piggyBankId != null) {
          // Используем уже загруженные данные копилки
          final banks = await StorageService.getPiggyBanks();
          final bank = banks.firstWhere((b) => b.id == piggyBankId);
          message = '$text добавлено в копилку "${bank.name}"';
        } else {
          message = '$text добавлено в кошелёк';
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }

    // Начисляем XP
    final profile = await StorageService.getPlayerProfile();
    await StorageService.savePlayerProfile(
      profile.copyWith(xp: profile.xp + xp),
    );

    // Обновляем кастомное задание, если это оно
    if (task['type'] == 'custom' && widget.customTasks != null) {
      final taskId = task['id'] as String;
      final customTasks = await StorageService.getCustomTasks();
      final taskIndex = customTasks.indexWhere((t) => t.id == taskId);
      if (taskIndex >= 0) {
        customTasks[taskIndex] = customTasks[taskIndex].copyWith(
          lastCompletedAt: DateTime.now(),
        );
        await StorageService.saveCustomTasks(customTasks);
        if (widget.onTaskUpdated != null) {
          widget.onTaskUpdated!();
        }
      }
    }

    // Обновляем streak
    await _updateEarningsStreak();

    // Обновляем данные для отображения статусов
    await ref.read(transactionsProvider.notifier).refresh();
    await ref.read(plannedEventsProvider.notifier).refresh();
    await ref.read(playerProfileProvider.notifier).refresh();

    if (!context.mounted) return;
    String suffix = '';
    if (money > 0) {
      final locale = Localizations.localeOf(context).toString();
      final currencyCode = CurrencyScope.of(context).currencyCode;
      final text = formatMoney(
        amountMinor: (money * 100).toInt(),
        currencyCode: currencyCode,
        locale: locale,
      );
      suffix = ' + $text';
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('+$xp XP$suffix')));
  }

  Future<void> _updateEarningsStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStreakDate = await StorageService.getLastStreakDate();
    final currentStreak = await StorageService.getEarningsStreak();

    if (lastStreakDate == null) {
      // Первый раз
      await StorageService.setEarningsStreak(1);
      await StorageService.setLastStreakDate(today);
    } else {
      final lastDate = DateTime(
        lastStreakDate.year,
        lastStreakDate.month,
        lastStreakDate.day,
      );
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Уже выполнили сегодня - не обновляем
        return;
      } else if (daysDiff == 1) {
        // Продолжаем серию
        await StorageService.setEarningsStreak(currentStreak + 1);
        await StorageService.setLastStreakDate(today);
      } else {
        // Пропуск - сбрасываем
        await StorageService.setEarningsStreak(1);
        await StorageService.setLastStreakDate(today);
      }
    }
  }

  Future<void> _showTaskActions(
    BuildContext context,
    Map<String, dynamic> task,
    PlannedEvent? plannedEvent,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AuroraTheme.spaceBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text(
                'Запланировать',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context, 'plan'),
            ),
            if (plannedEvent != null)
              ListTile(
                leading: const Icon(Icons.edit_calendar, color: Colors.white),
                title: const Text(
                  'Перенести',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, 'reschedule'),
              ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.more_vert, color: Colors.white54),
              title: const Text(
                'Выполнить сейчас',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () => Navigator.pop(context, 'complete'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;
    if (action == 'complete') {
      _completeTask(context, task);
    } else if (action == 'plan') {
      _planTask(context, task);
    } else if (action == 'reschedule' && plannedEvent != null) {
      _planTask(context, task); // Перепланируем
    }
  }
}

class _DifficultyChip extends StatelessWidget {
  final int difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.green, Colors.orange, Colors.red];
    final labels = ['Легко', 'Средне', 'Сложно'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors[difficulty - 1].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[difficulty - 1],
        style: TextStyle(
          color: colors[difficulty - 1],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CompleteTaskDialog extends StatefulWidget {
  final Map<String, dynamic> task;

  const _CompleteTaskDialog({required this.task});

  @override
  State<_CompleteTaskDialog> createState() => _CompleteTaskDialogState();
}

class _CompleteTaskDialogState extends State<_CompleteTaskDialog> {
  final _moneyController = TextEditingController();
  final _commentController = TextEditingController();
  final List<String> _photoPaths = [];

  @override
  void dispose() {
    _moneyController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // NOTE: Для добавления фото требуется пакет image_picker.
    // Установите его в pubspec.yaml: image_picker: ^latest
    // Затем раскомментируйте код выбора изображения.
    // Пока просто показываем сообщение.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция фото будет доступна после установки image_picker'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendedMoney = (widget.task['recommendedMoney'] as int?) ?? 0;
    final recommendedMoneyText = recommendedMoney > 0
        ? formatAmountUi(context, recommendedMoney)
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AuroraTheme.blueGradient,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Задание выполнено! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
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
              const SizedBox(height: 8),
              Text(
                widget.task['title'] as String,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.earningsLab_howMuchEarned,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _moneyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: recommendedMoneyText ?? '0.00',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (recommendedMoneyText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Рекомендуемая награда: $recommendedMoneyText',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.comment, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Комментарий (необязательно)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Что было сложно? Что понравилось? Расскажи о выполненном задании...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_photoPaths.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoPaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              child: const Icon(Icons.image, color: Colors.white54),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photoPaths.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_photoPaths.length < 3)
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Добавить фото (до 3)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final money = double.tryParse(_moneyController.text) ?? 0;
                      if (money < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.earningsLab_amountCannotBeNegative),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context, {
                        'money': money,
                        'comment': _commentController.text.trim(),
                        'photoPaths': _photoPaths,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuroraTheme.neonBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)!.common_done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final Color color;

  const _StatusChip({required this.label, this.dateTime, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (dateTime != null) ...[
              const SizedBox(width: 4),
              Text(
                DateFormat('dd.MM HH:mm').format(dateTime!),
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Диалог планирования с наградой и повторениями
class _PlanRewardDialog extends StatefulWidget {
  final int recommendedMoney;
  final String taskTitle;

  const _PlanRewardDialog({
    required this.recommendedMoney,
    required this.taskTitle,
  });

  @override
  State<_PlanRewardDialog> createState() => _PlanRewardDialogState();
}

class _PlanRewardDialogState extends State<_PlanRewardDialog> {
  final _moneyController = TextEditingController();
  RepeatType _repeatType = RepeatType.none;
  bool _notificationEnabled = true;
  String _payoutDestination = 'wallet'; // 'wallet' or 'piggy'
  String? _selectedPiggyBankId;

  @override
  void initState() {
    super.initState();
    _moneyController.text = (widget.recommendedMoney / 100).toStringAsFixed(0);
  }

  @override
  void dispose() {
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxMoneyCents = (widget.recommendedMoney * 1.5).round();
    final recommendedMoneyCents = widget.recommendedMoney;

    return AlertDialog(
      title: Text('Планирование: ${widget.taskTitle}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _moneyController,
              keyboardType: const TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                labelText: 'Награда',
                helperText: recommendedMoneyCents > 0
                    ? 'Рекомендуется: ${formatAmountUi(context, recommendedMoneyCents)}\nМаксимум: ${formatAmountUi(context, maxMoneyCents)}'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Куда зачислить награду?', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _payoutDestination,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _payoutDestination = value;
                  if (value == 'wallet') {
                    _selectedPiggyBankId = null;
                  }
                });
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(AppLocalizations.of(context)!.earningsLab_wallet),
                    value: 'wallet',
                  ),
                  RadioListTile<String>(
                    title: Text(AppLocalizations.of(context)!.earningsLab_piggyBank),
                    value: 'piggy',
                  ),
                ],
              ),
            ),
            if (_payoutDestination == 'piggy') ...[
              const SizedBox(height: 8),
              FutureBuilder<List<PiggyBank>>(
                future: StorageService.getPiggyBanks(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                      'Нет копилок. Сначала создай копилку.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    );
                  }
                  final banks = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedPiggyBankId,
                    decoration: const InputDecoration(
                      labelText: 'Выбери копилку',
                    ),
                    items: banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank.id,
                        child: Text(bank.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPiggyBankId = value;
                      });
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.earningsLab_repeat, style: const TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<RepeatType>(
              groupValue: _repeatType,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _repeatType = value);
              },
              child: Column(
                children: [
                  RadioListTile<RepeatType>(
                    title: Text(AppLocalizations.of(context)!.earningsLab_no),
                    value: RepeatType.none,
                  ),
                  RadioListTile<RepeatType>(
                    title: Text(AppLocalizations.of(context)!.earningsLab_daily),
                    value: RepeatType.daily,
                  ),
                  RadioListTile<RepeatType>(
                    title: Text(AppLocalizations.of(context)!.earningsLab_weekly),
                    value: RepeatType.weekly,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.earningsLab_reminder),
              value: _notificationEnabled,
              onChanged: (value) =>
                  setState(() => _notificationEnabled = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final money = double.tryParse(_moneyController.text) ?? 0;
            if (money < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.earningsLab_amountCannotBeNegative),
                ),
              );
              return;
            }
            final moneyCents = (money * 100).toInt();
            if (maxMoneyCents > 0 && moneyCents > maxMoneyCents) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Максимальная награда: ${formatAmountUi(context, maxMoneyCents)}',
                  ),
                ),
              );
              return;
            }
            // Проверяем что выбрана копилка если нужно
            if (_payoutDestination == 'piggy' && _selectedPiggyBankId == null) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.earningsLab_selectPiggyForReward),
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'amount': moneyCents,
              'repeat': _repeatType,
              'notification': _notificationEnabled,
              'payoutDestination': _payoutDestination,
              'payoutPiggyBankId': _selectedPiggyBankId,
            });
          },
          child: Text(AppLocalizations.of(context)!.earningsLab_createPlan),
        ),
      ],
    );
  }
}

// Экран деталей задания
class _TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onComplete;
  final VoidCallback? onPlan;

  const _TaskDetailScreen({required this.task, this.onComplete, this.onPlan});

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String;
    final description = task['description'] as String? ?? '';
    final steps = (task['steps'] as List<dynamic>?) ?? [];
    final needs = (task['needs'] as List<dynamic>?) ?? [];
    final bariTip = task['bariTip'] as String? ?? '';
    final recommendedMoney = (task['recommendedMoney'] as int?) ?? 0;
    final canRepeat = task['canRepeat'] as bool? ?? true;
    final requiresParent = task['requiresParent'] as bool? ?? false;
    final icon = task['icon'] as String? ?? 'star';
    final color = task['color'] as int? ?? 0xFF4CAF50;
    final time = task['time'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(color).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(icon),
                    size: 64,
                    color: Color(color),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.earningsLab_description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final hasDescription = description.trim().isNotEmpty;
                          return Text(
                            hasDescription ? description : AppLocalizations.of(context)!.earningsLab_taskDescription,
                            style: TextStyle(
                              color: hasDescription
                                  ? Colors.white70
                                  : Colors.white38,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (steps.isNotEmpty) ...[
                const SizedBox(height: 16),
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Шаги выполнения',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...steps.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AuroraTheme.neonBlue.withValues(
                                      alpha: 0.3,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value as String,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (needs.isNotEmpty) ...[
                const SizedBox(height: 16),
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Что нужно',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: needs
                              .map(
                                (need) => Chip(
                                  label: Text(
                                    need as String,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (bariTip.isNotEmpty) ...[
                const SizedBox(height: 16),
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: AuroraTheme.neonYellow,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Совет Бари',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bariTip,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
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
                        'Информация',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: 'Рекомендуемая награда',
                        value: (recommendedMoney > 0)
                            ? (recommendedMoney / 100).toStringAsFixed(0)
                            : '—',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.timer, label: AppLocalizations.of(context)!.earningsLab_time, value: time),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.repeat,
                        label: 'Можно повторять',
                        value: canRepeat ? 'Да' : 'Нет',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.family_restroom,
                        label: 'Нужен родитель',
                        value: requiresParent ? 'Да' : 'Нет',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Главная кнопка - Запланировать
              ElevatedButton.icon(
                onPressed: onPlan,
                icon: const Icon(Icons.calendar_today),
                label: const Text(
                  'Запланировать',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              // Вторичная кнопка - Выполнено
              OutlinedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check),
                label: const Text(
                  'Выполнено',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  final detailsBuffer = StringBuffer();
                  if (recommendedMoney > 0) {
                    detailsBuffer.writeln(
                      'Рекомендуемая награда: ${(recommendedMoney / 100).toStringAsFixed(0)}.',
                    );
                  }
                  if (time.isNotEmpty) {
                    detailsBuffer.writeln('Примерное время: $time.');
                  }
                  detailsBuffer.writeln(
                    'Можно повторять: ${canRepeat ? 'да' : 'нет'}.',
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BariChatScreen(
                        contextType: 'earningsTask',
                        topicTitle: title,
                        topicDescription: description,
                        topicDetails: detailsBuffer.toString(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(AppLocalizations.of(context)!.earningsLab_discussWithBari),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'book':
        return Icons.book;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'restaurant':
        return Icons.restaurant;
      case 'menu_book':
        return Icons.menu_book;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'school':
        return Icons.school;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'palette':
        return Icons.palette;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'celebration':
        return Icons.celebration;
      default:
        return Icons.star;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Диалог ввода PIN родителя
class _ParentPinDialog extends StatefulWidget {
  @override
  State<_ParentPinDialog> createState() => _ParentPinDialogState();
}

class _ParentPinDialogState extends State<_ParentPinDialog> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.earningsLab_parentApprovalRequired),
      content: TextField(
        controller: _pinController,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        decoration: const InputDecoration(
          labelText: 'PIN родителя',
          hintText: 'Введите PIN',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _pinController.text),
          child: Text(AppLocalizations.of(context)!.common_confirm),
        ),
      ],
    );
  }
}

// Диалог добавления пользовательского задания
class _AddCustomTaskDialog extends StatefulWidget {
  @override
  State<_AddCustomTaskDialog> createState() => _AddCustomTaskDialogState();
}

class _AddCustomTaskDialogState extends State<_AddCustomTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _moneyController = TextEditingController();
  final _xpController = TextEditingController();
  int _difficulty = 1;
  bool _canRepeat = true;
  bool _requiresParent = false;
  int _cooldownHours = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _moneyController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.earningsLab_addCustomTask),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.earningsLab_taskName,
                hintText: AppLocalizations.of(context)!.earningsLab_taskNameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.earningsLab_description,
                hintText: AppLocalizations.of(context)!.earningsLab_descriptionHint,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.earningsLab_time,
                hintText: AppLocalizations.of(context)!.earningsLab_timeHint,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _moneyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.earningsLab_reward,
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _xpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.earningsLab_xp,
                      hintText: '10',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _difficulty,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.earningsLab_difficulty),
              items: [1, 2, 3]
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(
                        '$d ${d == 1
                            ? 'звезда'
                            : d == 2
                            ? 'звезды'
                            : 'звёзды'}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _difficulty = value ?? 1),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.earningsLab_canRepeat),
              value: _canRepeat,
              onChanged: (value) => setState(() => _canRepeat = value),
            ),
            SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.earningsLab_requiresParent),
              value: _requiresParent,
              onChanged: (value) => setState(() => _requiresParent = value),
            ),
            if (_canRepeat)
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cooldown (часов)',
                  hintText: '0',
                ),
                onChanged: (value) =>
                    setState(() => _cooldownHours = int.tryParse(value) ?? 0),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.common_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty || _timeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.earningsLab_fillRequiredFields)),
              );
              return;
            }
            final money = double.tryParse(_moneyController.text) ?? 0;
            if (money < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.earningsLab_amountCannotBeNegative),
                ),
              );
              return;
            }
            final timeMinutes =
                int.tryParse(
                  _timeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
                ) ??
                30;

            Navigator.pop(context, {
              'title': _titleController.text,
              'description': _descriptionController.text,
              'time': _timeController.text,
              'timeMinutes': timeMinutes,
              'money': money,
              'xp': int.tryParse(_xpController.text) ?? 10,
              'difficulty': _difficulty,
              'canRepeat': _canRepeat,
              'requiresParent': _requiresParent,
              'cooldownHours': _cooldownHours,
            });
          },
          child: Text(AppLocalizations.of(context)!.common_save),
        ),
      ],
    );
  }
}

// Кнопка "Новое задание"
class _NewTaskButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewTaskButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: AuroraTheme.glassCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Новое задание',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Придумай и заработай',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom Sheet для создания нового задания
class _NewTaskBottomSheet extends StatefulWidget {
  final Function(CustomTask) onSaved;

  const _NewTaskBottomSheet({required this.onSaved});

  @override
  State<_NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<_NewTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rewardController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Дом';
  RepeatType _repeatType = RepeatType.none;
  int _cooldownHours = 0;

  final List<String> _categories = ['Дом', 'Учёба', 'Спорт', 'Другое'];
  final List<int> _cooldownOptions = [0, 6, 12, 24, 48];

  @override
  void dispose() {
    _titleController.dispose();
    _rewardController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _titleController.text = preset['title'] as String;
      _selectedCategory = preset['category'] as String;
      _rewardController.text = (preset['reward'] as int).toString();
      _repeatType = preset['repeatType'] as RepeatType;
      _cooldownHours = preset['cooldownHours'] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AuroraTheme.spaceBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Новое задание',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Быстрые пресеты
              const Text(
                'Быстрый выбор',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetChip(
                    label: 'Убрать комнату',
                    onTap: () => _applyPreset({
                      'title': 'Убрать комнату',
                      'category': 'Дом',
                      'reward': 5,
                      'repeatType': RepeatType.none,
                      'cooldownHours': 24,
                    }),
                  ),
                  _PresetChip(
                    label: 'Помочь по дому',
                    onTap: () => _applyPreset({
                      'title': 'Помочь по дому',
                      'category': 'Дом',
                      'reward': 3,
                      'repeatType': RepeatType.daily,
                      'cooldownHours': 12,
                    }),
                  ),
                  _PresetChip(
                    label: 'Сделать уроки',
                    onTap: () => _applyPreset({
                      'title': 'Сделать уроки',
                      'category': 'Учёба',
                      'reward': 5,
                      'repeatType': RepeatType.daily,
                      'cooldownHours': 24,
                    }),
                  ),
                  _PresetChip(
                    label: 'Тренировка 20 минут',
                    onTap: () => _applyPreset({
                      'title': 'Тренировка 20 минут',
                      'category': 'Спорт',
                      'reward': 3,
                      'repeatType': RepeatType.weekly,
                      'cooldownHours': 24,
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Название задания
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.earningsLab_taskName.replaceAll(' *', ''),
                  hintText: AppLocalizations.of(context)!.earningsLab_taskNameHint,
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.earningsLab_taskNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Категория
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.planEvent_category,
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                dropdownColor: AuroraTheme.spaceBlue,
                style: const TextStyle(color: Colors.white),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Награда
              TextFormField(
                controller: _rewardController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.earningsLab_reward,
                  hintText: 'Например: 5',
                  helperText: AppLocalizations.of(context)!.earningsLab_rewardHelper,
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white38),
                  helperStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.earningsLab_rewardMustBePositive;
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return AppLocalizations.of(context)!.earningsLab_rewardMustBePositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Описание задания (необязательно)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.earningsLab_descriptionOptional,
                  hintText: AppLocalizations.of(context)!.earningsLab_descriptionOptionalHint,
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white38),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Повтор
              Text(
                AppLocalizations.of(context)!.earningsLab_repeat,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<RepeatType>(
                groupValue: _repeatType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _repeatType = value);
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile<RepeatType>(
                      title: Text(
                        'Нет',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: RepeatType.none,
                    ),
                    RadioListTile<RepeatType>(
                      title: Text(
                        'Ежедневно',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: RepeatType.daily,
                    ),
                    RadioListTile<RepeatType>(
                      title: Text(
                        'Еженедельно',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: RepeatType.weekly,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Перерыв
              const Text(
                'Перерыв',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<int>(
                groupValue: _cooldownHours,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _cooldownHours = value);
                  }
                },
                child: Column(
                  children: _cooldownOptions.map((hours) {
                    return RadioListTile<int>(
                      title: Text(
                        hours == 0 ? 'Нет' : '$hours часов',
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: hours,
                    );
                  }).toList(),
                ),
              ),
              if (_cooldownHours > 0) ...[
                const SizedBox(height: 8),
                const Text(
                  'Чтобы задание нельзя было делать слишком часто',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
              const SizedBox(height: 32),
              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.common_cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final descriptionText =
                              _descriptionController.text.trim().isEmpty
                              ? null
                              : _descriptionController.text.trim();
                          final task = CustomTask(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: _titleController.text.trim(),
                            category: _selectedCategory,
                            rewardAmountMinor:
                                (int.parse(_rewardController.text) * 100),
                            description: descriptionText,
                            repeatType: _repeatType,
                            cooldownHours: _cooldownHours,
                            createdAt: DateTime.now(),
                          );
                          widget.onSaved(task);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(AppLocalizations.of(context)!.common_save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Чип для пресета
class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

// Диалог выбора места для денег
class _EarningsDestinationDialog extends StatelessWidget {
  final int amount;

  const _EarningsDestinationDialog({required this.amount});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final currencyCode = CurrencyScope.of(context).currencyCode;
    final amountText = formatMoney(
      amountMinor: amount,
      currencyCode: currencyCode,
      locale: locale,
    );

    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      title: Text(
        'Куда добавить $amountText?',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
            ),
            title: const Text(
              'В кошелёк',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, 'wallet'),
          ),
          ListTile(
            leading: const Icon(Icons.savings, color: Colors.white),
            title: const Text(
              'В копилку',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, 'piggy'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

// Диалог выбора копилки
class _PiggyBankPickerDialog extends StatelessWidget {
  final List<PiggyBank> banks;

  const _PiggyBankPickerDialog({required this.banks});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      title: const Text(
        'Выбери копилку',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: banks.length,
          itemBuilder: (context, index) {
            final bank = banks[index];
            return ListTile(
              leading: Icon(_getIconData(bank.icon), color: Color(bank.color)),
              title: Text(
                bank.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${formatAmountUi(context, bank.currentAmount)} / ${formatAmountUi(context, bank.targetAmount)}',
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () => Navigator.pop(context, bank),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'toys':
        return Icons.toys;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'book':
        return Icons.book;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.savings;
    }
  }
}
