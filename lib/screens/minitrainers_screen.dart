import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';

class MiniTrainersScreen extends StatelessWidget {
  const MiniTrainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trainers = [
      {
        'title': l10n.minitrainers_findExtraPurchase,
        'icon': Icons.search,
        'screen': const FindExtraPurchaseTrainer(),
      },
      {
        'title': l10n.minitrainers_buildBudget,
        'icon': Icons.account_balance_wallet,
        'screen': const BuildBudgetTrainer(),
      },
      {
        'title': l10n.minitrainers_discountOrTrap,
        'icon': Icons.local_offer,
        'screen': const DiscountTrapTrainer(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.minitrainers_60seconds),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            final trainer = trainers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AuroraTheme.glassCard(
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      trainer['icon'] as IconData,
                      color: AuroraTheme.neonYellow,
                    ),
                  ),
                  title: Text(
                    trainer['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'До 60 секунд',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => trainer['screen'] as Widget,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FindExtraPurchaseTrainer extends StatefulWidget {
  const FindExtraPurchaseTrainer({super.key});

  @override
  State<FindExtraPurchaseTrainer> createState() =>
      _FindExtraPurchaseTrainerState();
}

class _FindExtraPurchaseTrainerState
    extends State<FindExtraPurchaseTrainer> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  int _score = 0;

  final _questions = [
    {
      'items': ['Хлеб', 'Молоко', 'Игрушка', 'Яйца'],
      'correct': 2,
      'hint': 'Что не относится к еде?',
    },
    {
      'items': ['Учебник', 'Тетрадь', 'Ручка', 'Конфеты'],
      'correct': 3,
      'hint': 'Что не нужно для учёбы?',
    },
  ];

  void _checkAnswer() {
    if (_selectedAnswer == _questions[_currentQuestion]['correct']) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final xp = _score * 10;
    final profile = await StorageService.getPlayerProfile();
    await StorageService.savePlayerProfile(
      profile.copyWith(xp: profile.xp + xp),
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.minitrainers_result),
          content: Text(AppLocalizations.of(context)!.minitrainers_correctAnswers(_score, _questions.length, xp)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.minitrainers_great),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion >= _questions.length) {
      return const SizedBox();
    }

    final question = _questions[_currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.minitrainers_findExtraPurchase),
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
                  Text(
                    question['hint'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  RadioGroup<int>(
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
                    child: Column(
                      children:
                          (question['items'] as List<String>).asMap().entries.map(
                        (entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RadioListTile<int>(
                              title: Text(entry.value),
                              value: entry.key,
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedAnswer != null ? _checkAnswer : null,
                    child: Text(AppLocalizations.of(context)!.minitrainers_answer),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BuildBudgetTrainer extends StatefulWidget {
  const BuildBudgetTrainer({super.key});

  @override
  State<BuildBudgetTrainer> createState() => _BuildBudgetTrainerState();
}

class _BuildBudgetTrainerState extends State<BuildBudgetTrainer> {
  final _items = ['Хлеб', 'Игрушка', 'Учебник'];
  final _categories = ['Нужное', 'Желания', 'Коплю'];
  final Map<String, String> _assignments = {};

  Future<void> _check() async {
    // Простая проверка
    final correct = _assignments['Хлеб'] == 'Нужное' &&
        _assignments['Игрушка'] == 'Желания' &&
        _assignments['Учебник'] == 'Нужное';

    final xp = correct ? 20 : 10;
    final profile = await StorageService.getPlayerProfile();
    await StorageService.savePlayerProfile(
      profile.copyWith(xp: profile.xp + xp),
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(correct ? AppLocalizations.of(context)!.minitrainers_correct : AppLocalizations.of(context)!.minitrainers_goodTry),
          content: Text(AppLocalizations.of(context)!.minitrainers_xpEarned(xp)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.minitrainers_great),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.minitrainers_buildBudget),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Распредели покупки по категориям',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ..._items.map((item) => AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RadioGroup<String>(
                            groupValue: _assignments[item],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _assignments[item] = value;
                              });
                            },
                            child: Column(
                              children: _categories
                                  .map(
                                    (cat) => RadioListTile<String>(
                                      title: Text(cat),
                                      value: cat,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _assignments.length == _items.length ? _check : null,
                child: Text(AppLocalizations.of(context)!.minitrainers_check),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscountTrapTrainer extends StatefulWidget {
  const DiscountTrapTrainer({super.key});

  @override
  State<DiscountTrapTrainer> createState() => _DiscountTrapTrainerState();
}

class _DiscountTrapTrainerState extends State<DiscountTrapTrainer> {
  int _currentQuestion = 0;
  bool? _selectedAnswer;

  final _questions = [
    {
      'text': 'Скидка 50% на товар, который тебе не нужен — это выгодно?',
      'correct': false,
    },
    {
      'text': 'Купить 2 по цене 1, если нужно только 1 — это выгодно?',
      'correct': false,
    },
  ];

  void _checkAnswer() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final profile = await StorageService.getPlayerProfile();
    await StorageService.savePlayerProfile(
      profile.copyWith(xp: profile.xp + 15),
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.minitrainers_wellDone),
          content: Text(AppLocalizations.of(context)!.minitrainers_xp15),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.minitrainers_great),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion >= _questions.length) {
      return const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.minitrainers_discountOrTrap),
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
                  Text(
                    _questions[_currentQuestion]['text'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  RadioGroup<bool>(
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: Text(AppLocalizations.of(context)!.minitrainers_yes),
                          value: true,
                        ),
                        RadioListTile<bool>(
                          title: Text(AppLocalizations.of(context)!.minitrainers_no),
                          value: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _selectedAnswer != null ? _checkAnswer : null,
                    child: Text(AppLocalizations.of(context)!.minitrainers_answer),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


