import 'package:flutter/material.dart';
import '../theme/aurora_theme.dart';
import 'tools_hub_screen.dart';
import 'calculators_list_screen.dart';
import '../l10n/app_localizations.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToolsHubScreen();
  }
}

class EarningsLabScreen extends StatelessWidget {
  const EarningsLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final earnings = [
      {
        'title': 'Помочь по дому',
        'difficulty': 'Легко',
        'time': '30 мин',
        'xp': 10,
      },
      {
        'title': 'Выучить стих',
        'difficulty': 'Средне',
        'time': '1 час',
        'xp': 20,
      },
      {
        'title': 'Прочитать книгу',
        'difficulty': 'Средне',
        'time': '2 часа',
        'xp': 30,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.earningsLab_title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: earnings.length,
          itemBuilder: (context, index) {
            final earning = earnings[index];
            return AuroraTheme.glassCard(
              child: ListTile(
                leading: const Icon(Icons.star, color: AuroraTheme.neonYellow),
                title: Text(
                  earning['title'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${earning['difficulty']} • ${earning['time']} • +${earning['xp']} XP',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ToolsHubScreen(),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.earningsLab_schedule),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calculatorsList_title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CalculatorCard(
              title: 'Сколько накоплю за N дней',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculatorsListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _CalculatorCard(
              title: 'Если откладывать X в неделю',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculatorsListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _CalculatorCard(
              title: 'Цель копилки: сколько осталось',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalculatorsListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CalculatorCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AuroraTheme.glassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calculate, color: AuroraTheme.neonBlue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

