import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/bari_memory.dart';
import '../theme/aurora_theme.dart';
import '../bari_smart/bari_models.dart' as bari_models;

class BariOverlay extends StatefulWidget {
  final BariMemory memory;
  final VoidCallback? onChatTap;
  final VoidCallback? onMoreTipsTap;
  final bari_models.BariResponse? proactiveHint; // Проактивная подсказка от Бари
  final Function(bari_models.BariAction)? onHintAction; // Обработчик действия из подсказки

  const BariOverlay({
    super.key,
    required this.memory,
    this.onChatTap,
    this.onMoreTipsTap,
    this.proactiveHint,
    this.onHintAction,
  });

  @override
  State<BariOverlay> createState() => _BariOverlayState();
}

class _BariOverlayState extends State<BariOverlay>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Animation for the panel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Bounce animation for the avatar (soft sway)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -6.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -6.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 1,
      ),
    ]).animate(_bounceController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _openChat() {
    // Open chat directly
    if (widget.onChatTap != null && mounted) {
      widget.onChatTap!();
    }
  }

  // Get avatar emoji based on mood
  String _getAvatarEmoji(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.memory.mood) {
      case BariMood.happy:
        return l10n.bariAvatar_happy;
      case BariMood.encouraging:
        return l10n.bariAvatar_encouraging;
      case BariMood.neutral:
        return l10n.bariAvatar_neutral;
    }
  }

  String _getTipOfDay(BuildContext context) {
    final tips = widget.memory.recentTips;
    if (tips.isNotEmpty) {
      return tips.first;
    }
    return AppLocalizations.of(context)!.bariOverlay_defaultTip;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      bottom: 80,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Проактивная подсказка Бари (если есть)
          if (widget.proactiveHint != null)
            _ProactiveHintCard(
              hint: widget.proactiveHint!,
              onAction: widget.onHintAction,
              onDismiss: () {
                // Можно добавить логику скрытия подсказки
              },
            ),
          if (widget.proactiveHint != null) const SizedBox(height: 12),
          // Mini-panel (expandable)
          if (_isExpanded)
            ScaleTransition(
              scale: _scaleAnimation,
              child: AuroraTheme.glassCard(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lightbulb,
                              color: AuroraTheme.neonYellow,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.bariOverlay_tipOfDay,
                              style: const TextStyle(
                                color: AuroraTheme.neonYellow,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTipOfDay(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.bariOverlay_instructions,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onChatTap,
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: Text(
                                l10n.bariOverlay_openChat,
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AuroraTheme.neonBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onMoreTipsTap,
                              icon: const Icon(Icons.tips_and_updates_outlined, size: 18),
                              label: Text(
                                l10n.bariOverlay_moreTips,
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AuroraTheme.neonBlue),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Animated Bari avatar with bounce effect
          GestureDetector(
            onTap: _toggleExpanded,
            onDoubleTap: _openChat,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AuroraTheme.neonBlue, AuroraTheme.neonPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AuroraTheme.neonBlue.withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AuroraTheme.neonPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getAvatarEmoji(context),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка проактивной подсказки Бари
class _ProactiveHintCard extends StatefulWidget {
  final bari_models.BariResponse hint;
  final Function(bari_models.BariAction)? onAction;
  final VoidCallback? onDismiss;

  const _ProactiveHintCard({
    required this.hint,
    this.onAction,
    this.onDismiss,
  });

  @override
  State<_ProactiveHintCard> createState() => _ProactiveHintCardState();
}

class _ProactiveHintCardState extends State<_ProactiveHintCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isDismissed = false;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
    
    // Автоматическое закрытие через 8 секунд
    _autoDismissTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isDismissed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissed) return;
    setState(() {
      _isDismissed = true;
    });
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: 300,
            child: AuroraTheme.glassCard(
              child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AuroraTheme.neonBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AuroraTheme.neonBlue,
                              AuroraTheme.neonPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Подсказка Бари',
                          style: TextStyle(
                            color: AuroraTheme.neonYellow,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.white70,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _dismiss,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.hint.meaning,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.hint.advice,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  if (widget.hint.actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onAction?.call(widget.hint.actions.first);
                          _dismiss();
                        },
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: Text(
                          widget.hint.actions.first.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuroraTheme.neonBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
