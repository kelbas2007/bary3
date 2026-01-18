import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/bari_memory.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';

class BariRecommendationsScreen extends StatefulWidget {
  const BariRecommendationsScreen({super.key});

  @override
  State<BariRecommendationsScreen> createState() =>
      _BariRecommendationsScreenState();
}

class _BariRecommendationsScreenState extends State<BariRecommendationsScreen> {
  BariMemory? _memory;
  final List<String> _tips = [
    'Помни: каждая монета приближает тебя к цели!',
    'Планирование расходов — отличная привычка!',
    'Копилки помогают достигать целей быстрее.',
    'Перед покупкой спроси себя: "Действительно ли мне это нужно?"',
    'Маленькие регулярные взносы лучше больших разовых.',
    'Уроки помогут тебе стать финансово грамотным.',
    'Сравнивай цены перед покупкой — это экономит деньги.',
    'Правило 24 часов помогает не делать импульсные покупки.',
    'Бюджет 50/30/20 — простой способ управлять деньгами.',
    'Календарь событий помогает не забывать о планах.',
  ];

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  Future<void> _loadMemory() async {
    final memory = await StorageService.getBariMemory();
    setState(() {
      _memory = memory;
    });
  }

  String _getTipOfDay() {
    if (_memory != null && _memory!.recentTips.isNotEmpty) {
      return _memory!.recentTips.first;
    }
    return _tips[DateTime.now().day % _tips.length];
  }

  Future<void> _addNewTip() async {
    final newTip = _tips[DateTime.now().millisecond % _tips.length];
    if (_memory != null) {
      _memory!.addTip(newTip);
      await StorageService.saveBariMemory(_memory!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.toolsHub_recommendationsTitle),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: AuroraTheme.neonYellow,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Совет дня от Бари',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getTipOfDay(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Все советы',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AuroraTheme.glassCard(
                      child: ListTile(
                        leading: const Icon(
                          Icons.tips_and_updates,
                          color: AuroraTheme.neonYellow,
                        ),
                        title: Text(
                          tip,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addNewTip,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.recommendations_newTip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

