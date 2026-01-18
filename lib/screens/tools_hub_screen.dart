import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/aurora_theme.dart';
import 'calculators_list_screen.dart';
import 'earnings_lab_screen.dart';
import 'minitrainers_screen.dart';
import 'bari_recommendations_screen.dart';
import 'calendar_forecast_screen.dart';
import 'notes_screen.dart';

class ToolsHubScreen extends StatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  State<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends State<ToolsHubScreen> {
  String? _contextualTip;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadContextualTip();
  }

  void _loadContextualTip() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final tips = [
      l10n.toolsHub_tipCalculators,
      l10n.toolsHub_tipEarningsLab,
      l10n.toolsHub_tipMiniTrainers,
      l10n.toolsHub_tipBariRecommendations,
      l10n.toolsHub_tipNotes,
    ];
    setState(() {
      _contextualTip = tips[DateTime.now().day % tips.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.common_tools),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AuroraTheme.blueGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.toolsHub_subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              if (_contextualTip != null)
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.face,
                          color: AuroraTheme.neonYellow,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.toolsHub_bariTipTitle,
                                style: const TextStyle(
                                  color: AuroraTheme.neonYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _contextualTip!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              _SectionCard(
                icon: Icons.trending_up,
                title: l10n.toolsHub_calendarForecastTitle,
                description: l10n.toolsHub_calendarForecastSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarForecastScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.calculate,
                title: l10n.toolsHub_calculatorsTitle,
                description: l10n.toolsHub_calculatorsSubtitle,
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
              _SectionCard(
                icon: Icons.work,
                title: l10n.toolsHub_earningsLabTitle,
                description: l10n.toolsHub_earningsLabSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EarningsLabScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.timer,
                title: l10n.toolsHub_miniTrainersTitle,
                description: l10n.toolsHub_miniTrainersSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MiniTrainersScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.lightbulb,
                title: l10n.toolsHub_recommendationsTitle,
                description: l10n.toolsHub_recommendationsSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BariRecommendationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.note,
                title: l10n.toolsHub_notesTitle,
                description: l10n.toolsHub_notesSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AuroraTheme.glassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AuroraTheme.neonBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
