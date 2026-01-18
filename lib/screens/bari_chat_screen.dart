import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/aurora_theme.dart';
import '../bari_smart/bari_smart.dart';
import '../bari_smart/bari_context_adapter.dart';
import '../bari_smart/bari_models.dart';
import '../screens/main_screen.dart';
import '../screens/calculators_list_screen.dart';
import '../screens/plan_event_screen.dart';
import '../screens/calculators/piggy_plan_calculator.dart';
import '../screens/calculators/goal_date_calculator.dart';
import '../screens/calculators/monthly_budget_calculator.dart';
import '../screens/calculators/subscriptions_calculator.dart';
import '../screens/calculators/can_i_buy_calculator.dart';
import '../screens/calculators/price_comparison_calculator.dart';
import '../screens/calculators/twenty_four_hour_rule_calculator.dart';
import '../screens/calculators/budget_50_30_20_calculator.dart';
import '../screens/calculators/calendar_forecast_calculator.dart';
import '../screens/tools_hub_screen.dart';
import '../screens/parent_statistics_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/calendar_forecast_screen.dart';
import '../screens/minitrainers_screen.dart';
import '../screens/bari_recommendations_screen.dart';
import '../screens/earnings_lab_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class BariChatScreen extends StatefulWidget {
  final String? contextType; // calculator, piggyBank, event, lesson
  final String? contextId;
  final String? topicTitle;
  final String? topicDescription;
  final String? topicDetails;

  const BariChatScreen({
    super.key,
    this.contextType,
    this.contextId,
    this.topicTitle,
    this.topicDescription,
    this.topicDetails,
  });

  @override
  State<BariChatScreen> createState() => _BariChatScreenState();
}

class ChatMessage {
  final String? title; // "что это значит"
  final String? advice; // "что делать"
  final List<BariAction> actions;
  final bool isSimpler;
  final bool isBari;
  final String? rawText; // Для старых сообщений
  BariResponse? originalResponse; // Для упрощённой версии

  ChatMessage({
    this.title,
    this.advice,
    this.actions = const [],
    this.isSimpler = false,
    required this.isBari,
    this.rawText,
    this.originalResponse,
  });
}

class _BariChatScreenState extends State<BariChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isNavigating = false; // Защита от повторных навигаций

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    // Приветственное сообщение будет добавлено в build, когда context доступен
  }

  String _getWelcomeText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.contextType != null) {
      switch (widget.contextType) {
        case 'calculator':
          return l10n.bariChat_welcomeCalculator;
        case 'piggyBank':
          return l10n.bariChat_welcomePiggyBank;
        case 'event':
          return l10n.bariChat_welcomePlannedEvent;
        case 'lesson':
          return l10n.bariChat_welcomeLesson;
        case 'earningsTask':
          final title = widget.topicTitle ?? l10n.bariChat_task;
          return l10n.bariChat_welcomeTask(title);
      }
    }
    return l10n.bariChat_welcomeDefault;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    _messages.add(ChatMessage(rawText: text, isBari: false));
    _messageController.clear();
    setState(() {});

    setState(() {
      _isLoading = true;
    });

    try {
      // Определяем текущий экран
      String currentScreen = 'balance';
      final route = ModalRoute.of(context);
      if (route != null) {
        final name = route.settings.name ?? '';
        if (name.contains('balance') || name.isEmpty) {
          currentScreen = 'balance';
        } else if (name.contains('piggy')) {
          currentScreen = 'piggies';
        } else if (name.contains('calendar')) {
          currentScreen = 'calendar';
        } else if (name.contains('earnings') || name.contains('lab')) {
          currentScreen = 'earnings_lab';
        } else if (name.contains('lesson')) {
          currentScreen = 'lessons';
        } else if (name.contains('setting')) {
          currentScreen = 'settings';
        } else if (name.contains('parent')) {
          currentScreen = 'parent_zone';
        }
      }

      final ctx = await BariContextAdapter.build(
        currentScreenId: currentScreen,
      );
      final response = await BariSmart.instance.respond(text, ctx);

      if (!mounted) return;

      _messages.add(
        ChatMessage(
          title: response.meaning,
          advice: response.advice,
          actions: response.actions,
          isBari: true,
          originalResponse: response,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _messages.add(
        ChatMessage(rawText: l10n.bariChat_fallbackResponse, isBari: true),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSimpler(int messageIndex) {
    final message = _messages[messageIndex];
    if (message.originalResponse == null) return;

    setState(() {
      final simplerResponse = message.originalResponse!.simpler();
      _messages[messageIndex] = ChatMessage(
        title: simplerResponse.meaning,
        advice: simplerResponse.advice,
        actions: simplerResponse.actions,
        isSimpler: true,
        isBari: true,
        originalResponse: message.originalResponse,
      );
    });
  }

  void _handleAction(BariAction action, int messageIndex) async {
    if (action.type == BariActionType.explainSimpler) {
      _toggleSimpler(messageIndex);
      return;
    }

    if (action.type == BariActionType.showSource) {
      if (action.payload != null) {
        final uri = Uri.parse(action.payload!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context)!;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.bariChat_source),
              content: SelectableText(action.payload!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.bariChat_close),
                ),
              ],
            ),
          );
        }
      }
      return;
    }

    if (action.type == BariActionType.runOnlineSearch) {
      final ctx = await BariContextAdapter.build(currentScreenId: 'balance');
      final response = await BariSmart.instance.respond(
        action.payload ?? '',
        ctx,
        forceOnline: true,
      );
      if (!mounted) return;
      _messages.add(
        ChatMessage(
          title: response.meaning,
          advice: response.advice,
          actions: response.actions,
          isBari: true,
          originalResponse: response,
        ),
      );
      setState(() {});
      return;
    }

    // Обработка действий
    switch (action.type) {
      case BariActionType.openScreen:
        if (_isNavigating) return; // Предотвращаем повторные вызовы
        _isNavigating = true;

        if (action.payload != null) {
          // Для открытия новых экранов не нужно popUntil - просто открываем экран
          // Для переключения вкладок используем tabNotifier без навигации
          switch (action.payload) {
            case 'balance':
            case 'piggies':
            case 'piggy_banks':
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
                    case 'piggies':
                    case 'piggy_banks':
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
            case 'notes':
            case 'tools':
            case 'calendar_forecast':
            case 'mini_trainers':
            case 'bari_recommendations':
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
                    case 'notes':
                      targetScreen = const NotesScreen();
                      break;
                    case 'tools':
                      targetScreen = const ToolsHubScreen();
                      break;
                    case 'calendar_forecast':
                      targetScreen = const CalendarForecastScreen();
                      break;
                    case 'mini_trainers':
                      targetScreen = const MiniTrainersScreen();
                      break;
                    case 'bari_recommendations':
                      targetScreen = const BariRecommendationsScreen();
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

      case BariActionType.openCalculator:
        if (_isNavigating) return;
        _isNavigating = true;
        // Отложить навигацию для безопасности
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            _isNavigating = false;
            return;
          }
          try {
            Widget? targetCalculator;
            
            // Если указан конкретный калькулятор, открываем его
            if (action.payload != null) {
              switch (action.payload) {
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
            }
            
            // Если калькулятор не найден или payload пустой, открываем список
            final screen = targetCalculator ?? const CalculatorsListScreen();
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            ).then((_) => _isNavigating = false)
             .catchError((_) => _isNavigating = false);
          } catch (e) {
            _isNavigating = false;
          }
        });
        break;

      case BariActionType.createPlan:
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

      case BariActionType.showMore:
        if (action.payload != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(action.payload!)));
        }
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Добавляем приветственное сообщение при первом build
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(rawText: _getWelcomeText(context), isBari: true),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bariChat_title)),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _LoadingIndicator(
                      thinkingText: l10n.bariChat_thinking,
                    );
                  }
                  final message = _messages[index];
                  return _ChatBubble(
                    message: message,
                    onSimpler: () => _toggleSimpler(index),
                    onAction: (action) => _handleAction(action, index),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuroraTheme.spaceBlue.withValues(alpha: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: l10n.bariChat_inputHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      onSubmitted: _sendMessage,
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading
                        ? null
                        : () => _sendMessage(_messageController.text),
                    icon: const Icon(Icons.send),
                    color: AuroraTheme.neonBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onSimpler;
  final Function(BariAction) onAction;

  const _ChatBubble({
    required this.message,
    required this.onSimpler,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isBari ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: message.isBari
              ? AuroraTheme.neonBlue.withValues(alpha: 0.3)
              : AuroraTheme.spaceBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: message.rawText != null
            ? Text(
                message.rawText!,
                style: const TextStyle(color: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.title != null) ...[
                    Text(
                      message.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (message.advice != null) ...[
                    Text(
                      message.advice!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (message.actions.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: message.actions.map((action) {
                        return ActionChip(
                          label: Text(action.label),
                          avatar: Icon(_getActionIcon(action.type), size: 18),
                          onPressed: () => onAction(action),
                          backgroundColor: AuroraTheme.spaceBlue.withValues(
                            alpha: 0.5,
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  IconData _getActionIcon(BariActionType type) {
    switch (type) {
      case BariActionType.openScreen:
        return Icons.open_in_new;
      case BariActionType.openCalculator:
        return Icons.calculate;
      case BariActionType.createPlan:
        return Icons.calendar_today;
      case BariActionType.explainSimpler:
        return Icons.lightbulb_outline;
      case BariActionType.showMore:
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }
}

class _LoadingIndicator extends StatelessWidget {
  final String thinkingText;

  const _LoadingIndicator({required this.thinkingText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AuroraTheme.neonBlue.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(thinkingText, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
