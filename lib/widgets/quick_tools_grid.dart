import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/aurora_theme.dart';
import '../screens/calculators_list_screen.dart';
import '../screens/earnings_lab_screen.dart';
import '../screens/minitrainers_screen.dart';
import '../screens/bari_recommendations_screen.dart';
import '../screens/calendar_forecast_screen.dart';
import '../screens/notes_screen.dart';
import '../utils/page_transitions.dart';
import '../utils/haptic_feedback_util.dart';

/// Виджет с маленькими блоками-карточками для быстрого доступа к инструментам
class QuickToolsGrid extends StatelessWidget {
  const QuickToolsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final tools = [
      _ToolItem(
        icon: Icons.trending_up,
        label: l10n.toolsHub_calendarForecastTitle,
        color: AuroraTheme.neonBlue,
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            SlidePageRoute(page: const CalendarForecastScreen()),
          );
        },
      ),
      _ToolItem(
        icon: Icons.calculate,
        label: l10n.toolsHub_calculatorsTitle,
        color: AuroraTheme.neonPurple,
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            SlidePageRoute(page: const CalculatorsListScreen()),
          );
        },
      ),
      _ToolItem(
        icon: Icons.work,
        label: l10n.toolsHub_earningsLabTitle,
        color: AuroraTheme.neonYellow,
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            SlidePageRoute(page: const EarningsLabScreen()),
          );
        },
      ),
      _ToolItem(
        icon: Icons.timer,
        label: l10n.toolsHub_miniTrainersTitle,
        color: Colors.pinkAccent,
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            SlidePageRoute(page: const MiniTrainersScreen()),
          );
        },
      ),
      _ToolItem(
        icon: Icons.lightbulb,
        label: l10n.toolsHub_recommendationsTitle,
        color: Colors.cyanAccent,
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            SlidePageRoute(page: const BariRecommendationsScreen()),
          );
        },
      ),
      _ToolItem(
        icon: Icons.note,
        label: l10n.toolsHub_notesTitle,
        color: Colors.greenAccent,
        onTap: () {
          HapticFeedbackUtil.lightImpact();
          Navigator.push(
            context,
            SlidePageRoute(page: const NotesScreen()),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            l10n.common_tools,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return _ToolCard(tool: tools[index]);
          },
        ),
      ],
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _ToolCard extends StatefulWidget {
  final _ToolItem tool;

  const _ToolCard({required this.tool});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.tool.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AuroraTheme.glassCard(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.tool.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.tool.color.withValues(alpha: 0.25),
                        widget.tool.color.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.tool.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.tool.icon,
                    color: widget.tool.color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.tool.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
