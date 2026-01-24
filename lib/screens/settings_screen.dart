import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/currency_scope.dart';
import '../theme/aurora_theme.dart';
import '../domain/ux_detail_level.dart';
import 'tools_hub_screen.dart';
import 'export_import_screen.dart';
import 'deleted_events_screen.dart';
import 'calendar_sync_settings_screen.dart';
import 'test_data_screen.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';
import '../services/deleted_events_service.dart';
import '../services/bari_notification_service.dart';
import '../services/notification_service.dart';
import '../main.dart' show appKey;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'ru';
  String _theme = 'blue';
  bool _notificationsEnabled = true;
  bool _bariSmallTalkEnabled = true;
  UxDetailLevel _uxDetailLevel = UxDetailLevel.simple;
  
  // Notification settings
  bool _dailyExpenseReminderEnabled = true;
  bool _weeklyReviewEnabled = true;
  bool _levelUpNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final language = await StorageService.getLanguage();
    final theme = await StorageService.getTheme();
    final notifications = await StorageService.getNotificationsEnabled();
    final bariSmallTalkEnabled = await StorageService.getBariSmallTalkEnabled();
    final uxLevelRaw = await StorageService.getUxDetailLevel();
    
    // Notification settings
    final dailyReminder = await StorageService.getDailyExpenseReminderEnabled();
    final weeklyReview = await StorageService.getWeeklyReviewEnabled();
    final levelUpNotifications = await StorageService.getLevelUpNotificationsEnabled();
    
    setState(() {
      _language = language;
      _theme = theme;
      _notificationsEnabled = notifications;
      _bariSmallTalkEnabled = bariSmallTalkEnabled;
      _uxDetailLevel = UxDetailLevelX.fromStorage(uxLevelRaw);
      _dailyExpenseReminderEnabled = dailyReminder;
      _weeklyReviewEnabled = weeklyReview;
      _levelUpNotificationsEnabled = levelUpNotifications;
    });
  }

  LinearGradient _getGradient() {
    switch (_theme) {
      case 'purple':
        return AuroraTheme.purpleGradient;
      case 'mint':
        return AuroraTheme.mintGradient;
      default:
        return AuroraTheme.blueGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.common_settings)),
      body: Container(
        decoration: BoxDecoration(gradient: _getGradient()),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Внешний вид
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settings_appearance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.settings_language, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'ru', label: Text('RU')),
                        ButtonSegment(value: 'de', label: Text('DE')),
                        ButtonSegment(value: 'en', label: Text('EN')),
                      ],
                      selected: {_language},
                      onSelectionChanged: (Set<String> newSelection) async {
                        setState(() {
                          _language = newSelection.first;
                        });
                        await StorageService.setLanguage(_language);
                        appKey.currentState?.setLanguage(_language);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.settings_theme,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: 'blue',
                          label: Text(AppLocalizations.of(context)!.settings_themeBlue),
                        ),
                        ButtonSegment(
                          value: 'purple',
                          label: Text(
                            AppLocalizations.of(context)!.settings_themePurple,
                          ),
                        ),
                        ButtonSegment(
                          value: 'mint',
                          label: Text(AppLocalizations.of(context)!.settings_themeGreen),
                        ),
                      ],
                      selected: {_theme},
                      onSelectionChanged: (Set<String> newSelection) async {
                        setState(() {
                          _theme = newSelection.first;
                        });
                        await StorageService.setTheme(_theme);
                        // Тема обновится при следующем перезапуске приложения
                        // Или можно использовать Navigator.pop с результатом для обновления
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Режим объяснений (Simple/Pro)
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settings_explanationMode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.settings_howToExplain,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<UxDetailLevel>(
                      segments: [
                        ButtonSegment(
                          value: UxDetailLevel.simple,
                          label: Text(
                            AppLocalizations.of(context)!.settings_uxSimple,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ButtonSegment(
                          value: UxDetailLevel.pro,
                          label: Text(
                            AppLocalizations.of(context)!.settings_uxPro,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      selected: {_uxDetailLevel},
                      onSelectionChanged: (newSelection) async {
                        final v = newSelection.first;
                        setState(() => _uxDetailLevel = v);
                        await StorageService.setUxDetailLevel(v.storageValue);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _uxDetailLevel == UxDetailLevel.simple
                          ? AppLocalizations.of(context)!.settings_uxSimpleDescription
                          : AppLocalizations.of(context)!.settings_uxProDescription,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Валюта
            AuroraTheme.glassCard(
              child: ListTile(
                title: Text(
                      AppLocalizations.of(context)!.settings_currency,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  // Берём текущую валюту из контроллера
                  CurrencyScope.of(context).currencyCode,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showCurrencyPicker(),
              ),
            ),
            const SizedBox(height: 16),
            // Уведомления
            AuroraTheme.glassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.settings_notifications,
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      await StorageService.setNotificationsEnabled(value);
                    },
                  ),
                  if (_notificationsEnabled) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settings_dailyExpenseReminder,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settings_dailyExpenseReminderDescription,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: _dailyExpenseReminderEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _dailyExpenseReminderEnabled = value;
                        });
                        await StorageService.setDailyExpenseReminderEnabled(value);
                        // Перепланируем уведомления
                        if (value) {
                          await BariNotificationService.scheduleSmartReminders();
                        } else {
                          await NotificationService.cancel(1001);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settings_weeklyReview,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settings_weeklyReviewDescription,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: _weeklyReviewEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _weeklyReviewEnabled = value;
                        });
                        await StorageService.setWeeklyReviewEnabled(value);
                        // Перепланируем уведомления
                        if (value) {
                          await BariNotificationService.scheduleSmartReminders();
                        } else {
                          await NotificationService.cancel(1002);
                        }
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settings_levelUpNotifications,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settings_levelUpNotificationsDescription,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: _levelUpNotificationsEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _levelUpNotificationsEnabled = value;
                        });
                        await StorageService.setLevelUpNotificationsEnabled(value);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Бари
            AuroraTheme.glassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.settings_bari,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settings_smallTalk,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settings_smallTalkDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      value: _bariSmallTalkEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _bariSmallTalkEnabled = value;
                        });
                        await StorageService.setBariSmallTalkEnabled(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Родительская зона
            AuroraTheme.glassCard(
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.settings_parentZone,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.settings_parentZoneDescription,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pushNamed(context, '/parent-zone');
                },
              ),
            ),
            const SizedBox(height: 16),
            // Инструменты
            AuroraTheme.glassCard(
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context)!.settings_tools,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.settings_toolsDescription,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ToolsHubScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Синхронизация с календарём
            AuroraTheme.glassCard(
              child: ListTile(
                title: const Text(
                  'Синхронизация с календарём',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Настроить синхронизацию событий с системным календарём',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarSyncSettingsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Данные
            AuroraTheme.glassCard(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.settings_exportData,
                      style: const TextStyle(color: Colors.white),
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
                  const Divider(),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.settings_importData,
                      style: const TextStyle(color: Colors.white),
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
                  const Divider(),
                  // Генератор тестовых данных (только в debug режиме)
                  if (kDebugMode) ...[
                    ListTile(
                      title: const Text(
                        '🧪 Генератор тестовых данных',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Создать недельные данные для тестирования',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TestDataScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.deletedEvents_title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: FutureBuilder<int>(
                      future: DeletedEventsService.getDeletedEventsCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          count > 0 
                              ? l10n.deletedEvents_count(count)
                              : l10n.deletedEvents_empty,
                          style: const TextStyle(color: Colors.white70),
                        );
                      },
                    ),
                    trailing: FutureBuilder<int>(
                      future: DeletedEventsService.getDeletedEventsCount(),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return count > 0
                            ? Badge(
                                label: Text(count.toString()),
                                child: const Icon(Icons.arrow_forward_ios, size: 16),
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 16);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeletedEventsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.settings_resetProgress,
                      style: const TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showResetDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetDialog() async {
    if (!mounted) return;

    // Проверяем, установлен ли PIN
    final hasPin = await StorageService.hasParentPin();
    if (!mounted) return;

    if (!hasPin) {
      // Если PIN не установлен, показываем обычный диалог подтверждения
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.settings_resetProgress),
          content: Text(AppLocalizations.of(context)!.settings_resetProgressWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.settings_cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.reset),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await StorageService.resetAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.settings_progressReset),
            ),
          );
        }
      }
      return;
    }

    // Если PIN установлен, запрашиваем его
    final pinController = TextEditingController();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settings_resetProgress),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.settings_resetProgressWarning,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.settings_enterPinToConfirm),
            const SizedBox(height: 8),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'PIN',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.settings_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final isValid = await StorageService.verifyParentPin(
                pinController.text,
              );
              if (!context.mounted) return;
              if (isValid) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.settings_wrongPin),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.reset),
          ),
        ],
      ),
    );

    pinController.dispose();

    if (confirmed == true) {
      await StorageService.resetAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.settings_progressReset)),
        );
      }
    }
  }


  void _showCurrencyPicker() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final controller = CurrencyScope.of(context);
        final current = controller.currencyCode;
        final options = ['EUR', 'USD', 'CHF'];
        return Container(
          decoration: const BoxDecoration(
            color: AuroraTheme.spaceBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.settings_selectCurrency,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RadioGroup<String>(
                groupValue: current,
                onChanged: (value) async {
                  if (value == null) return;
                  await controller.setCurrency(value);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Column(
                  children: options
                      .map(
                        (code) => RadioListTile<String>(
                          title: Text(
                            code,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: code,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

}