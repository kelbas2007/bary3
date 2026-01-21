import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/planned_event.dart';
import '../services/storage_service.dart';
import '../services/money_ui.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import '../bari_smart/bari_context_adapter.dart';
import '../bari_smart/providers/local_llm_provider.dart';
import '../bari_smart/aca/local_llm/model_loader.dart';

class ParentStatisticsScreen extends StatefulWidget {
  const ParentStatisticsScreen({super.key});

  @override
  State<ParentStatisticsScreen> createState() => _ParentStatisticsScreenState();
}

class _ParentStatisticsScreenState extends State<ParentStatisticsScreen> {
  bool _isGeneratingSummary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.parentZone_statistics)),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadStatistics(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatCard(
                    title: 'Доходы / Расходы',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Доходы',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatAmount(context, stats['totalIncome'] as int),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Расходы',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatAmount(context, stats['totalExpense'] as int),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: 'Выполненные планы',
                    child: Text(
                      '${stats['completedPlans']} из ${stats['totalPlans']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: 'Уроки',
                    child: Text(
                      'Пройдено: ${stats['completedLessons']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: 'Привычки',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Серия дней',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Flexible(
                              child: Text(
                                '${stats['streak']}',
                                style: const TextStyle(
                                  color: AuroraTheme.neonYellow,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Самоконтроль',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Flexible(
                              child: Text(
                                '${stats['selfControl']}/100',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Кнопка генерации AI-саммари
                  ElevatedButton.icon(
                    onPressed: _isGeneratingSummary ? null : _generateAISummary,
                    icon: _isGeneratingSummary
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGeneratingSummary ? 'Генерация...' : 'Сгенерировать AI-саммари'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                      foregroundColor: AuroraTheme.neonYellow,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _generateAISummary() async {
    // Проверяем доступность локальной модели
    final modelLoader = ModelLoader();
    try {
      await modelLoader.loadModel();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.parentZone_modelNotAvailable ?? 'Локальная модель недоступна. Скачайте модель в настройках.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      // Загружаем статистику и контекст
      final stats = await _loadStatistics();
      final ctx = await BariContextAdapter.build(currentScreenId: 'parent_statistics');
      
      // Определяем период (последний месяц)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      // Определяем язык
      final locale = await StorageService.getLanguage();
      final localeCode = locale.startsWith('ru') ? 'ru' 
                       : locale.startsWith('en') ? 'en'
                       : 'de';
      
      // Генерируем саммари
      final provider = LocalLLMProvider();
      final summary = await provider.generateParentSummary(
        ctx,
        startDate,
        endDate,
        localeCode,
        additionalData: stats,
      );

      setState(() {
        _isGeneratingSummary = false;
      });

      if (summary == null || summary.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.parentZone_summaryGenerationFailed ?? 'Не удалось сгенерировать саммари. Попробуйте позже.',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return;
      }

      // Показываем диалог с саммари
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              l10n.parentZone_aiSummaryTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Text(
                summary,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.parentZone_close),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingSummary = false;
      });
      
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.parentZone_summaryGenerationFailed ?? 'Ошибка: $e',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _loadStatistics() async {
    final transactions = await StorageService.getTransactions();
    final events = await StorageService.getPlannedEvents();
    final progress = await StorageService.getLessonProgress();
    final profile = await StorageService.getPlayerProfile();

    int totalIncome = 0;
    int totalExpense = 0;
    for (var t in transactions) {
      // Считаем только одобренные операции, которые реально влияют на кошелёк
      if (!t.parentApproved || !t.affectsWallet) {
        continue;
      }
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    final completedPlans = events
        .where((e) => e.status == PlannedEventStatus.completed)
        .length;
    final totalPlans = events.length;
    final completedLessons = progress.where((p) => p.completed).length;

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'completedPlans': completedPlans,
      'totalPlans': totalPlans,
      'completedLessons': completedLessons,
      'streak': profile.streakDays,
      'selfControl': profile.selfControlScore,
    };
  }

  String _formatAmount(BuildContext context, int cents) {
    return formatAmountUi(context, cents);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _StatCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuroraTheme.glassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
