import 'package:flutter/material.dart';

import '../theme/aurora_theme.dart';

class AuroraCalculatorScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final List<String>? steps;
  final int? activeStep;
  final List<Widget> children;
  final Widget? floatingActionButton;

  const AuroraCalculatorScaffold({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.steps,
    this.activeStep,
    required this.children,
    this.floatingActionButton,
  });

  Widget _buildSteps(BuildContext context) {
    final s = steps;
    if (s == null || s.isEmpty) return const SizedBox.shrink();

    final a = activeStep ?? 0;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (int i = 0; i < s.length; i++)
            _StepChip(index: i, label: s[i], active: i <= a),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AuroraTheme.spaceBlue, AuroraTheme.inkBlue],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
        elevation: 0,
      ),
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 10),
                        child: child,
                      ),
                    );
                  },
                  child: AuroraTheme.glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AuroraTheme.neonBlue.withValues(alpha: 0.9),
                                  AuroraTheme.neonPurple.withValues(alpha: 0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AuroraTheme.neonBlue.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.black, size: 26),
                          ),
                          const SizedBox(width: 14),
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
                                if (subtitle != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                                _buildSteps(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final int index;
  final String label;
  final bool active;

  const _StepChip({
    required this.index,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? AuroraTheme.neonYellow.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.07);
    final border = active
        ? AuroraTheme.neonYellow.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.10);
    final fg = active ? AuroraTheme.neonYellow : Colors.white70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg.withValues(alpha: active ? 0.25 : 0.12),
              border: Border.all(color: fg.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
