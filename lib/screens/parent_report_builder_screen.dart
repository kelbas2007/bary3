import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/planned_event.dart';
import '../models/piggy_bank.dart';
import '../models/player_profile.dart';
import '../models/lesson.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../services/note_service.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import 'note_editor_screen.dart';

class ParentReportBuilderScreen extends ConsumerStatefulWidget {
  const ParentReportBuilderScreen({super.key});

  @override
  ConsumerState<ParentReportBuilderScreen> createState() =>
      _ParentReportBuilderScreenState();
}

class _ParentReportBuilderScreenState
    extends ConsumerState<ParentReportBuilderScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.week;
  final Set<ReportSection> _selectedSections = {
    ReportSection.finances,
    ReportSection.activity,
    ReportSection.achievements,
  };
  bool _includeEarningsLab = true;
  bool _includeLessons = true;
  bool _includePiggyBanks = true;
  bool _includeEvents = true;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notes_templateParentReport),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Период отчета
                    _buildPeriodSelector(l10n),
                    const SizedBox(height: 24),
                    // Разделы отчета
                    _buildSectionsSelector(l10n),
                    const SizedBox(height: 24),
                    // Дополнительные опции
                    _buildAdditionalOptions(l10n),
                  ],
                ),
              ),
            ),
            // Кнопка генерации
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuroraTheme.spaceBlue.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuroraTheme.neonBlue,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Создать отчет',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Период отчета',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PeriodChip(
                label: 'День',
                period: ReportPeriod.day,
                selected: _selectedPeriod == ReportPeriod.day,
                onTap: () => setState(() => _selectedPeriod = ReportPeriod.day),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PeriodChip(
                label: 'Неделя',
                period: ReportPeriod.week,
                selected: _selectedPeriod == ReportPeriod.week,
                onTap: () => setState(() => _selectedPeriod = ReportPeriod.week),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PeriodChip(
                label: 'Месяц',
                period: ReportPeriod.month,
                selected: _selectedPeriod == ReportPeriod.month,
                onTap: () =>
                    setState(() => _selectedPeriod = ReportPeriod.month),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionsSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Что включить в отчет',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _SectionCheckbox(
          title: '💰 Финансы',
          subtitle: 'Доходы, расходы, баланс',
          value: _selectedSections.contains(ReportSection.finances),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedSections.add(ReportSection.finances);
              } else {
                _selectedSections.remove(ReportSection.finances);
              }
            });
          },
        ),
        const SizedBox(height: 8),
        _SectionCheckbox(
          title: '📊 Активность',
          subtitle: 'Выполненные планы и задачи',
          value: _selectedSections.contains(ReportSection.activity),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedSections.add(ReportSection.activity);
              } else {
                _selectedSections.remove(ReportSection.activity);
              }
            });
          },
        ),
        const SizedBox(height: 8),
        _SectionCheckbox(
          title: '🏆 Достижения',
          subtitle: 'Уроки, серии, прогресс',
          value: _selectedSections.contains(ReportSection.achievements),
          onChanged: (value) {
            setState(() {
              if (value) {
                _selectedSections.add(ReportSection.achievements);
              } else {
                _selectedSections.remove(ReportSection.achievements);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дополнительно',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _OptionSwitch(
          title: '💼 Задания из Лаборатории заработка',
          value: _includeEarningsLab,
          onChanged: (value) =>
              setState(() => _includeEarningsLab = value),
        ),
        const SizedBox(height: 8),
        _OptionSwitch(
          title: '📚 Пройденные уроки',
          value: _includeLessons,
          onChanged: (value) => setState(() => _includeLessons = value),
        ),
        const SizedBox(height: 8),
        _OptionSwitch(
          title: '🐷 Копилки и цели',
          value: _includePiggyBanks,
          onChanged: (value) =>
              setState(() => _includePiggyBanks = value),
        ),
        const SizedBox(height: 8),
        _OptionSwitch(
          title: '📅 Запланированные события',
          value: _includeEvents,
          onChanged: (value) => setState(() => _includeEvents = value),
        ),
      ],
    );
  }

  Future<void> _generateReport() async {
    if (_selectedSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.parentReport_selectSectionError),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final report = await _buildReport();
      
      if (!mounted) return;

      // Создаем заметку с отчетом
      final noteService = NoteService();
      final note = await noteService.createNote(
        title: _getReportTitle(),
        content: report,
        type: NoteType.rich,
        color: Colors.teal,
        tags: ['отчет', 'родителям', _selectedPeriod.name],
      );

      if (!mounted) return;

      // Открываем редактор с созданной заметкой
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(note: note),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.parentReport_createError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _getReportTitle() {
    final now = DateTime.now();
    String periodText;
    switch (_selectedPeriod) {
      case ReportPeriod.day:
        periodText = DateFormat('dd MMMM yyyy', 'ru').format(now);
        break;
      case ReportPeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        periodText =
            '${DateFormat('dd MMM', 'ru').format(weekStart)} - ${DateFormat('dd MMM yyyy', 'ru').format(weekEnd)}';
        break;
      case ReportPeriod.month:
        periodText = DateFormat('MMMM yyyy', 'ru').format(now);
        break;
    }
    return 'Отчет для родителей: $periodText';
  }

  Future<String> _buildReport() async {
    final now = DateTime.now();
    DateTime startDate;
    String periodName;

    switch (_selectedPeriod) {
      case ReportPeriod.day:
        startDate = DateTime(now.year, now.month, now.day);
        periodName = 'сегодня';
        break;
      case ReportPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        periodName = 'за эту неделю';
        break;
      case ReportPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        periodName = 'за этот месяц';
        break;
    }

    final report = StringBuffer();
    report.writeln('📊 Отчет для родителей\n');
    report.writeln('📅 Период: $periodName');
    report.writeln('📆 Дата создания: ${DateFormat('dd MMMM yyyy', 'ru').format(now)} в ${DateFormat('HH:mm', 'ru').format(now)}\n');
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Загружаем данные
    final transactions = await StorageService.getTransactions();
    final events = await StorageService.getPlannedEvents();
    final piggyBanks = await StorageService.getPiggyBanks();
    final profile = await StorageService.getPlayerProfile();
      final lessonProgress =
          await StorageService.getLessonProgress();

    // Фильтруем данные по периоду
    final periodTransactions = transactions.where((t) =>
        t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        t.parentApproved &&
        t.affectsWallet).toList();

    // Генерируем разделы
    if (_selectedSections.contains(ReportSection.finances)) {
      report.writeln(_generateFinancesStory(periodTransactions, periodName));
      report.writeln('\n');
    }

    if (_selectedSections.contains(ReportSection.activity)) {
      report.writeln(_generateActivityStory(
        periodTransactions,
        events,
        periodName,
      ));
      report.writeln('\n');
    }

    if (_selectedSections.contains(ReportSection.achievements)) {
      report.writeln(_generateAchievementsStory(
        lessonProgress,
        profile,
        piggyBanks,
        periodName,
      ));
      report.writeln('\n');
    }

    // Дополнительные разделы
    if (_includeEarningsLab) {
      report.writeln(_generateEarningsLabStory(periodTransactions, periodName));
      report.writeln('\n');
    }

    if (_includePiggyBanks) {
      report.writeln(_generatePiggyBanksStory(piggyBanks));
      report.writeln('\n');
    }

    if (_includeEvents) {
      report.writeln(_generateEventsStory(events, startDate));
      report.writeln('\n');
    }

    // Заключение
    report.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    report.writeln(_generateConclusion(periodTransactions, events, profile));

    return report.toString();
  }

  String _generateFinancesStory(
      List<Transaction> transactions, String periodName) {
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    final story = StringBuffer();
    story.writeln('💰 ФИНАНСОВЫЕ ДОСТИЖЕНИЯ $periodName\n');

    if (income > 0) {
      final incomeCount = transactions.where((t) => t.type == TransactionType.income).length;
      story.writeln(
          '✨ За этот период было заработано ${_formatMoney(income)}. ');
      if (incomeCount > 1) {
        story.writeln(
            'Это $incomeCount ${_pluralize(incomeCount, 'разное поступление', 'разных поступления', 'разных поступлений')} - видно, что ребенок активно работает над заработком!');
      } else {
        story.writeln('Отличное начало! Каждая монета приближает к цели.');
      }
      story.writeln();
    } else {
      story.writeln('💰 В этот период не было доходов. ');
      story.writeln('Возможно, стоит обсудить новые способы заработка или постановку финансовых целей.');
      story.writeln();
    }

    if (expense > 0) {
      final expenseCount = transactions.where((t) => t.type == TransactionType.expense).length;
      story.writeln(
          '💸 Было потрачено ${_formatMoney(expense)} на $expenseCount ${_pluralize(expenseCount, 'покупку', 'покупки', 'покупок')}. ');
      final categories = <String, int>{};
      for (var t in transactions.where((t) => t.type == TransactionType.expense)) {
        final cat = t.category ?? 'Другое';
        categories[cat] = (categories[cat] ?? 0) + t.amount;
      }
      if (categories.isNotEmpty) {
        final sortedCategories = categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topCategory = sortedCategories.first;
        story.writeln(
            'Больше всего потрачено на "${topCategory.key}" - ${_formatMoney(topCategory.value)}. ');
        if (sortedCategories.length > 1) {
          story.writeln(
              'Также были траты на: ${sortedCategories.skip(1).take(2).map((e) => '"${e.key}"').join(', ')}.');
        }
      }
      story.writeln();
    } else {
      story.writeln('💸 В этот период не было трат. ');
      story.writeln('Отличная дисциплина - ребенок умеет контролировать свои желания!');
      story.writeln();
    }

    if (balance > 0 && income > 0) {
      story.writeln(
          '🎉 Отличный результат! Удалось накопить ${_formatMoney(balance)}. ');
      final savingsRate = (balance / income * 100).toStringAsFixed(0);
      story.writeln(
          'Это $savingsRate% от всех доходов - прекрасный показатель финансовой дисциплины! ');
      if (int.parse(savingsRate) >= 30) {
        story.writeln('Ребенок показывает зрелый подход к управлению деньгами - откладывает значительную часть заработанного.');
      } else if (int.parse(savingsRate) >= 10) {
        story.writeln('Хорошая привычка к накоплениям уже формируется!');
      }
    } else if (balance < 0) {
      story.writeln(
          '⚠️ Расходы превысили доходы на ${_formatMoney(-balance)}. ');
      story.writeln(
          'Это хороший повод обсудить планирование бюджета и приоритеты в тратах. ');
      story.writeln('Важно научить ребенка жить по средствам и планировать расходы заранее.');
    } else if (income == 0 && expense == 0) {
      story.writeln('💰 В этот период не было финансовой активности.');
    } else {
      story.writeln('💰 Доходы и расходы сбалансированы - ребенок тратит ровно столько, сколько зарабатывает.');
    }

    return story.toString();
  }

  String _generateActivityStory(
      List<Transaction> transactions,
      List<PlannedEvent> events,
      String periodName) {
    final story = StringBuffer();
    story.writeln('📊 АКТИВНОСТЬ $periodName\n');

    final completedEvents = events
        .where((e) =>
            e.status == PlannedEventStatus.completed &&
            e.dateTime.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .length;

    if (completedEvents > 0) {
      story.writeln(
          '✅ Выполнено $completedEvents ${_pluralize(completedEvents, 'запланированное событие', 'запланированных события', 'запланированных событий')}. ');
      story.writeln(
          'Это показывает, что ребенок умеет планировать и следовать своим планам - важный навык для взрослой жизни! ');
      if (completedEvents >= 5) {
        story.writeln('Очень ответственный подход к выполнению обязательств!');
      }
      story.writeln();
    } else {
      story.writeln('📅 В этот период не было выполненных запланированных событий. ');
      story.writeln('Возможно, стоит обсудить важность планирования и выполнения планов.');
      story.writeln();
    }

    final totalTransactions = transactions.length;
    if (totalTransactions > 0) {
      story.writeln(
          '📝 Всего было $totalTransactions ${_pluralize(totalTransactions, 'финансовая операция', 'финансовые операции', 'финансовых операций')}. ');
      if (totalTransactions > 10) {
        story.writeln(
            'Очень активная финансовая деятельность - ребенок учится управлять деньгами на практике!');
      } else if (totalTransactions > 5) {
        story.writeln('Хорошая активность в управлении финансами.');
      }
      story.writeln();
    }

    return story.toString();
  }

  String _generateAchievementsStory(
      List<LessonProgress> lessonProgress,
      PlayerProfile profile,
      List<PiggyBank> piggyBanks,
      String periodName) {
    final story = StringBuffer();
    story.writeln('🏆 ДОСТИЖЕНИЯ И ПРОГРЕСС\n');

    final completedLessons = lessonProgress.where((p) => p.completed).length;
    if (completedLessons > 0 && _includeLessons) {
      story.writeln(
          '📚 Пройдено $completedLessons ${_pluralize(completedLessons, 'урок', 'урока', 'уроков')} по финансовой грамотности. ');
      story.writeln(
          'Каждый урок - это шаг к пониманию того, как работают деньги в реальном мире. ');
      if (completedLessons >= 3) {
        story.writeln('Отличная мотивация к обучению! Знания о финансах - это инвестиция в будущее.');
      }
      story.writeln();
    } else if (_includeLessons) {
      story.writeln('📚 В этот период не было пройдено уроков. ');
      story.writeln('Обучение финансовой грамотности помогает принимать правильные решения с деньгами.');
      story.writeln();
    }

    if (profile.streakDays > 0) {
      story.writeln('🔥 Текущая серия дней активности: ${profile.streakDays}. ');
      if (profile.streakDays >= 7) {
        story.writeln(
            'Отличная последовательность! Регулярность - ключ к успеху в управлении финансами.');
      }
      story.writeln();
    }

    if (profile.selfControlScore > 0) {
      story.writeln(
          '💪 Оценка самоконтроля: ${profile.selfControlScore}/100. ');
      if (profile.selfControlScore >= 70) {
        story.writeln(
            'Высокий уровень самоконтроля - ребенок умеет откладывать сиюминутные желания ради больших целей.');
      } else if (profile.selfControlScore >= 50) {
        story.writeln(
            'Хороший уровень, есть куда расти. Продолжайте практиковаться!');
      }
      story.writeln();
    }

    return story.toString();
  }

  String _generateEarningsLabStory(
      List<Transaction> transactions, String periodName) {
    final earnings = transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.source == TransactionSource.earningsLab &&
            t.parentApproved)
        .toList();

    if (earnings.isEmpty) {
      return '';
    }

    final story = StringBuffer();
    story.writeln('💼 ЛАБОРАТОРИЯ ЗАРАБОТКА $periodName\n');

    final totalEarned = earnings.fold<int>(0, (sum, t) => sum + t.amount);
    story.writeln(
        '✨ За этот период было выполнено ${earnings.length} ${_pluralize(earnings.length, 'задание', 'задания', 'заданий')} из Лаборатории заработка. ');
    story.writeln('Общая сумма заработка: ${_formatMoney(totalEarned)}. ');
    if (earnings.length >= 5) {
      story.writeln('Очень активная работа - ребенок проявляет инициативу и ответственность!');
    } else if (earnings.length >= 2) {
      story.writeln('Хорошая активность в выполнении заданий.');
    }
    story.writeln();

    // Группируем по заданиям
    final tasks = <String, List<Transaction>>{};
    for (var e in earnings) {
      final taskName = e.note ?? 'Задание без названия';
      tasks.putIfAbsent(taskName, () => []).add(e);
    }

    if (tasks.length <= 3) {
      story.writeln('Выполненные задания:');
      for (var entry in tasks.entries) {
        final taskEarnings = entry.value.fold<int>(0, (sum, t) => sum + t.amount);
        story.writeln('  • ${entry.key} - ${_formatMoney(taskEarnings)}');
      }
    } else {
      story.writeln(
          'Самое популярное задание: "${tasks.entries.first.key}" - выполнено ${tasks.entries.first.value.length} раз.');
    }

    story.writeln();
    story.writeln(
        'Это показывает инициативность и желание зарабатывать самостоятельно - отличные качества!');

    return story.toString();
  }

  String _generatePiggyBanksStory(List<PiggyBank> piggyBanks) {
    if (piggyBanks.isEmpty) {
      return '';
    }

    final story = StringBuffer();
    story.writeln('🐷 КОПИЛКИ И ЦЕЛИ\n');

    final activeBanks = piggyBanks.where((b) => b.targetAmount > 0).toList();
    if (activeBanks.isEmpty) {
      return '';
    }

    story.writeln(
        'У ребенка ${activeBanks.length} ${_pluralize(activeBanks.length, 'активная копилка', 'активные копилки', 'активных копилок')}:\n');

    for (var bank in activeBanks) {
      final progress = (bank.currentAmount / bank.targetAmount * 100)
          .toStringAsFixed(0);
      story.writeln('🎯 "${bank.name}"');
      story.writeln(
          '   Прогресс: ${_formatMoney(bank.currentAmount)} из ${_formatMoney(bank.targetAmount)} ($progress%)');
      if (bank.currentAmount >= bank.targetAmount) {
        story.writeln('   ✅ Цель достигнута! Поздравляем!');
      } else if (int.parse(progress) >= 80) {
        story.writeln('   🎉 Почти у цели! Осталось совсем немного!');
      }
      story.writeln();
    }

    return story.toString();
  }

  String _generateEventsStory(
      List<PlannedEvent> events, DateTime startDate) {
    final upcomingEvents = events
        .where((e) =>
            e.status == PlannedEventStatus.planned &&
            e.dateTime.isAfter(startDate) &&
            e.dateTime.isBefore(DateTime.now().add(const Duration(days: 30))))
        .toList();

    if (upcomingEvents.isEmpty) {
      return '';
    }

    final story = StringBuffer();
    story.writeln('📅 ПЛАНИРОВАНИЕ НА БУДУЩЕЕ\n');

    story.writeln(
        'Запланировано ${upcomingEvents.length} ${_pluralize(upcomingEvents.length, 'событие', 'события', 'событий')} на ближайший месяц:\n');

    upcomingEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    for (var event in upcomingEvents.take(5)) {
      final date = DateFormat('dd.MM', 'ru').format(event.dateTime);
      story.writeln(
          '  📌 $date: ${event.name ?? "Событие"} - ${_formatMoney(event.amount)}');
    }

    story.writeln();
    story.writeln(
        'Планирование будущих трат - важный навык финансовой грамотности!');

    return story.toString();
  }

  String _generateConclusion(List<Transaction> transactions,
      List<PlannedEvent> events, PlayerProfile profile) {
    final story = StringBuffer();
    story.writeln('💭 ЗАКЛЮЧЕНИЕ\n');

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    if (balance > 0 && income > 0) {
      story.writeln(
          'Ребенок показывает отличные результаты в управлении финансами! ');
      story.writeln(
          'Удалось не только заработать ${_formatMoney(income)}, но и сохранить ${_formatMoney(balance)}. ');
      story.writeln(
          'Это говорит о развивающемся финансовом мышлении и умении откладывать на важные цели.');
    } else if (income > 0) {
      story.writeln(
          'Активная работа над заработком - это уже большой успех! ');
      story.writeln(
          'Сейчас важно учиться планировать траты и откладывать на будущее.');
    } else {
      story.writeln(
          'Этот период был спокойным в плане финансов. ');
      story.writeln(
          'Возможно, стоит обсудить новые способы заработка или постановку финансовых целей.');
    }

    story.writeln();
    story.writeln(
        'Продолжайте поддерживать интерес ребенка к финансовой грамотности - это инвестиция в его будущее! 💪');

    return story.toString();
  }

  String _formatMoney(int cents) {
    final rubles = cents / 100;
    if (rubles == rubles.toInt()) {
      return '${rubles.toInt()} руб.';
    }
    return '${rubles.toStringAsFixed(2)} руб.';
  }

  String _pluralize(int count, String one, String few, String many) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 19) {
      return many;
    }
    if (mod10 == 1) {
      return one;
    }
    if (mod10 >= 2 && mod10 <= 4) {
      return few;
    }
    return many;
  }
}

enum ReportPeriod { day, week, month }

enum ReportSection { finances, activity, achievements }

class _PeriodChip extends StatelessWidget {
  final String label;
  final ReportPeriod period;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.period,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AuroraTheme.neonBlue.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AuroraTheme.neonBlue
                : Colors.white.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AuroraTheme.neonBlue : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SectionCheckbox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SectionCheckbox({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? AuroraTheme.neonBlue
                : Colors.white.withValues(alpha: 0.1),
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (val) => onChanged(val ?? false),
              fillColor: WidgetStateProperty.all(AuroraTheme.neonBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
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

class _OptionSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OptionSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AuroraTheme.neonBlue,
          ),
        ],
      ),
    );
  }
}
