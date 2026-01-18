import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/gemini_nano_service.dart';
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
  String _bariMode = 'offline';
  bool _bariShowSources = true;
  bool _bariSmallTalkEnabled = true;
  UxDetailLevel _uxDetailLevel = UxDetailLevel.simple;
  
  // AI Settings
  String? _aiApiKey;
  // ignore: unused_field - Reserved for future custom API endpoint support
  final String _aiBaseUrl = 'https://api.openai.com/v1';
  String _aiModel = 'gpt-4o-mini';
  final TextEditingController _aiApiKeyController = TextEditingController();

  // Gemini Nano Settings
  // ignore: unused_field - Reserved for future use
  bool _geminiNanoEnabled = false;
  bool _geminiNanoAvailable = false;
  bool _geminiNanoDownloaded = false;
  final bool _geminiNanoDownloading = false;
  final double _geminiNanoDownloadProgress = 0.0;
  final GeminiNanoService _geminiNanoService = GeminiNanoService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  @override
  void dispose() {
    _aiApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final language = await StorageService.getLanguage();
    final theme = await StorageService.getTheme();
    final notifications = await StorageService.getNotificationsEnabled();
    final bariMode = await StorageService.getBariMode();
    final bariShowSources = await StorageService.getBariShowSources();
    final bariSmallTalkEnabled = await StorageService.getBariSmallTalkEnabled();
    final uxLevelRaw = await StorageService.getUxDetailLevel();
    
    // AI Settings
    final aiApiKey = await StorageService.getAiApiKey();
    final aiModel = await StorageService.getAiModel();
    
    // Gemini Nano Settings
    final geminiNanoEnabled = await StorageService.getGeminiNanoEnabled();
    final geminiNanoAvailable = await _geminiNanoService.checkAvailability();
    final geminiNanoDownloaded = await _geminiNanoService.checkDownloaded();
    
    setState(() {
      _language = language;
      _theme = theme;
      _notificationsEnabled = notifications;
      _bariMode = bariMode;
      _bariShowSources = bariShowSources;
      _bariSmallTalkEnabled = bariSmallTalkEnabled;
      _uxDetailLevel = UxDetailLevelX.fromStorage(uxLevelRaw);
      _aiApiKey = aiApiKey;
      _aiModel = aiModel ?? 'gpt-4o-mini';
      _aiApiKeyController.text = aiApiKey ?? '';
      _geminiNanoEnabled = geminiNanoEnabled;
      _geminiNanoAvailable = geminiNanoAvailable;
      _geminiNanoDownloaded = geminiNanoDownloaded;
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
              child: SwitchListTile(
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
                    Text(
                      AppLocalizations.of(context)!.settings_bariMode,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.settings_bariModeOffline),
                          selected: _bariMode == 'offline',
                          onSelected: (selected) async {
                            if (selected) {
                              setState(() => _bariMode = 'offline');
                              await StorageService.setBariMode('offline');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.settings_bariModeOnline),
                          selected: _bariMode == 'online',
                          onSelected: (selected) async {
                            if (selected) {
                              setState(() => _bariMode = 'online');
                              await StorageService.setBariMode('online');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text(AppLocalizations.of(context)!.settings_bariModeHybrid),
                          selected: _bariMode == 'hybrid',
                          onSelected: (selected) async {
                            if (selected) {
                              setState(() => _bariMode = 'hybrid');
                              await StorageService.setBariMode('hybrid');
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('🤖 AI'),
                          selected: _bariMode == 'ai',
                          selectedColor: AuroraTheme.neonPurple,
                          onSelected: (selected) async {
                            if (selected) {
                              setState(() => _bariMode = 'ai');
                              await StorageService.setBariMode('ai');
                            }
                          },
                        ),
                      ],
                    ),
                    
                    // AI API Settings (показываем только если выбран AI режим)
                    if (_bariMode == 'ai') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AuroraTheme.neonPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AuroraTheme.neonPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology, color: Colors.white70, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'AI Настройки',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (_aiApiKey != null && _aiApiKey!.isNotEmpty)
                                  const Icon(Icons.check_circle, color: Colors.green, size: 18)
                                else
                                  const Icon(Icons.warning, color: Colors.orange, size: 18),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _aiApiKeyController,
                              decoration: InputDecoration(
                                labelText: 'API Ключ (OpenAI)',
                                hintText: 'sk-...',
                                labelStyle: const TextStyle(color: Colors.white70),
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.help_outline, size: 18),
                                  color: Colors.white54,
                                  onPressed: () => _showApiKeyHelp(),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              onChanged: (value) async {
                                setState(() => _aiApiKey = value.isEmpty ? null : value);
                                await StorageService.setAiApiKey(value.isEmpty ? null : value);
                              },
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white24),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _aiModel,
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: AuroraTheme.spaceBlue,
                                style: const TextStyle(color: Colors.white),
                                items: [
                                  DropdownMenuItem(
                                    value: 'gpt-4o-mini',
                                    child: Text(AppLocalizations.of(context)!.settings_aiModelGpt4oMini),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gpt-4o',
                                    child: Text(AppLocalizations.of(context)!.settings_aiModelGpt4o),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gpt-4-turbo',
                                    child: Text(AppLocalizations.of(context)!.settings_aiModelGpt4Turbo),
                                  ),
                                  DropdownMenuItem(
                                    value: 'gpt-3.5-turbo',
                                    child: Text(AppLocalizations.of(context)!.settings_aiModelGpt35),
                                  ),
                                ],
                                onChanged: (value) async {
                                  if (value != null) {
                                    setState(() => _aiModel = value);
                                    await StorageService.setAiModel(value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _aiApiKey == null || _aiApiKey!.isEmpty
                                  ? '⚠️ Введите API ключ для работы AI'
                                  : '✓ AI готов к работе',
                              style: TextStyle(
                                color: _aiApiKey == null || _aiApiKey!.isEmpty
                                    ? Colors.orange
                                    : Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Gemini Nano Settings (показываем всегда)
                    const SizedBox(height: 16),
                    _buildGeminiNanoSection(),
                    
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.settings_showSources,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.settings_showSourcesDescription,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      value: _bariShowSources,
                      onChanged: (value) async {
                        setState(() {
                          _bariShowSources = value;
                        });
                        await StorageService.setBariShowSources(value);
                      },
                    ),
                    const SizedBox(height: 8),
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

  void _showApiKeyHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.white),
            SizedBox(width: 8),
            Text('Как получить API ключ?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Зайдите на platform.openai.com',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '2. Создайте аккаунт или войдите',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '3. Перейдите в API Keys',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '4. Нажмите "Create new secret key"',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '5. Скопируйте ключ и вставьте сюда',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                '💡 Рекомендуем модель gpt-4o-mini — она быстрая и недорогая (примерно \$0.001 за ответ).',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                '🔒 API ключ хранится только на вашем устройстве и никуда не передаётся.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.common_understand),
          ),
        ],
      ),
    );
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

  Widget _buildGeminiNanoSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuroraTheme.neonPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AuroraTheme.neonPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.settings_geminiNano,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_geminiNanoDownloaded)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else if (!_geminiNanoAvailable)
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settings_geminiNanoDescription,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          
          // Статус
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.settings_geminiNanoStatus,
                  style: const TextStyle(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getGeminiNanoStatusText(),
                style: TextStyle(
                  color: _getGeminiNanoStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          if (!_geminiNanoAvailable) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Требования:',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.settings_geminiNanoRequirement1,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.settings_geminiNanoRequirement2,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            
            // Прогресс скачивания
            if (_geminiNanoDownloading) ...[
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _geminiNanoDownloadProgress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_geminiNanoDownloadProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Кнопки действий
            if (!_geminiNanoDownloaded && !_geminiNanoDownloading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Временная заглушка - функция в разработке
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.settings_geminiNanoDownload} — функция в разработке'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: Text('${l10n.settings_geminiNanoDownload} (скоро)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white70,
                  ),
                ),
              )
            else if (_geminiNanoDownloaded)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showGeminiNanoDeleteDialog(),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.settings_geminiNanoDelete),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Кнопка "Преимущества"
            TextButton.icon(
              onPressed: () => _showGeminiNanoAdvantages(),
              icon: const Icon(Icons.info_outline, size: 18),
              label: Text(l10n.settings_geminiNanoAdvantages),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getGeminiNanoStatusText() {
    final l10n = AppLocalizations.of(context)!;
    // Всегда честно говорим, что функция в разработке
    return '${l10n.settings_geminiNanoNotAvailable} — функция в разработке';
  }

  Color _getGeminiNanoStatusColor() {
    if (!_geminiNanoAvailable) return Colors.orange;
    if (_geminiNanoDownloaded) return Colors.green;
    return Colors.white70;
  }

  // NOTE: Gemini Nano SDK пока не доступен публично. Методы _showGeminiNanoDownloadDialog
  // и _downloadGeminiNano будут реализованы, когда SDK станет доступен.
  // Следите за обновлениями ML Kit GenAI на https://developers.google.com/ml-kit/genai

  Future<void> _showGeminiNanoDeleteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(l10n.settings_geminiNanoDeleteConfirm),
        content: Text(l10n.settings_geminiNanoDeleteConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.settings_geminiNanoDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteGeminiNano();
    }
  }

  Future<void> _deleteGeminiNano() async {
    final l10n = AppLocalizations.of(context)!;
    final success = await _geminiNanoService.deleteModel();

    if (mounted) {
      setState(() {
        _geminiNanoDownloaded = !success;
      });

      if (success) {
        await StorageService.setGeminiNanoDownloaded(false);
        await StorageService.setGeminiNanoEnabled(false);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settings_geminiNanoSuccessDelete),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settings_geminiNanoErrorDelete),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGeminiNanoAdvantages() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              l10n.settings_geminiNanoAdvantagesTitle,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAdvantageItem(
                Icons.attach_money,
                Colors.green,
                l10n.settings_geminiNanoAdvantage1,
              ),
              const SizedBox(height: 12),
              _buildAdvantageItem(
                Icons.flash_on,
                Colors.amber,
                l10n.settings_geminiNanoAdvantage2,
              ),
              const SizedBox(height: 12),
              _buildAdvantageItem(
                Icons.lock,
                Colors.blue,
                l10n.settings_geminiNanoAdvantage3,
              ),
              const SizedBox(height: 12),
              _buildAdvantageItem(
                Icons.phone_android,
                Colors.purple,
                l10n.settings_geminiNanoAdvantage4,
              ),
              const SizedBox(height: 12),
              _buildAdvantageItem(
                Icons.language,
                Colors.teal,
                l10n.settings_geminiNanoAdvantage5,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                l10n.settings_geminiNanoRequirements,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.settings_geminiNanoRequirement1,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settings_geminiNanoRequirement2,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settings_geminiNanoRequirement3,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_understand),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantageItem(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}