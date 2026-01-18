import 'package:flutter/material.dart';
import '../models/bari_memory.dart';
import '../theme/aurora_theme.dart';

/// Анимированная реакция Bari с эмоциональным аватаром
class BariReaction extends StatefulWidget {
  final BariActionType actionType;
  final BariMood mood;
  final int? amount;
  final VoidCallback? onDismiss;

  const BariReaction({
    super.key,
    required this.actionType,
    required this.mood,
    this.amount,
    this.onDismiss,
  });

  @override
  State<BariReaction> createState() => _BariReactionState();
}

class _BariReactionState extends State<BariReaction> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getReactionText() {
    switch (widget.actionType) {
      case BariActionType.income:
        return 'Отлично! Хочешь часть в копилку?';
      case BariActionType.expense:
        return 'Ок, главное — помни цель';
      case BariActionType.planCreated:
        return 'Сильный ход, буду напоминать';
      case BariActionType.planCompleted:
        return 'Держишь слово — растёшь!';
      case BariActionType.piggyBankCreated:
        return 'Отличная цель!';
      case BariActionType.piggyBankCompleted:
        return 'Ачивка! Ты достиг цели!';
      case BariActionType.lessonCompleted:
        return '+XP, вот что ты понял…';
    }
  }

  /// Получаем эмодзи аватар на основе настроения и действия
  String _getAvatarEmoji() {
    // Сначала проверяем особые случаи
    switch (widget.actionType) {
      case BariActionType.piggyBankCompleted:
        return '🥳'; // Праздник!
      case BariActionType.income:
        return '😊'; // Радость
      case BariActionType.lessonCompleted:
        return '🤓'; // Умный
      case BariActionType.planCreated:
        return '💪'; // Сила
      case BariActionType.planCompleted:
        return '🌟'; // Звезда
      case BariActionType.piggyBankCreated:
        return '✨'; // Мечты
      case BariActionType.expense:
        // Зависит от настроения
        break;
    }
    
    // Для расходов и по умолчанию - зависит от настроения
    switch (widget.mood) {
      case BariMood.happy:
        return '😄';
      case BariMood.encouraging:
        return '🤔';
      case BariMood.neutral:
        return '😌';
    }
  }

  Color _getReactionColor() {
    switch (widget.mood) {
      case BariMood.happy:
        return AuroraTheme.neonYellow;
      case BariMood.encouraging:
        return AuroraTheme.neonMint;
      case BariMood.neutral:
        return AuroraTheme.neonBlue;
    }
  }

  Color _getAvatarBackgroundColor() {
    switch (widget.actionType) {
      case BariActionType.piggyBankCompleted:
        return Colors.amber;
      case BariActionType.income:
        return Colors.greenAccent;
      case BariActionType.expense:
        return Colors.orangeAccent;
      case BariActionType.planCreated:
      case BariActionType.planCompleted:
        return AuroraTheme.neonBlue;
      case BariActionType.piggyBankCreated:
        return Colors.pinkAccent;
      case BariActionType.lessonCompleted:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reactionColor = _getReactionColor();
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          margin: const EdgeInsets.only(bottom: 100, right: 16, left: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                reactionColor.withValues(alpha: 0.95),
                reactionColor.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: reactionColor.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Анимированный аватар Bari
              _BariAvatar(
                emoji: _getAvatarEmoji(),
                backgroundColor: _getAvatarBackgroundColor(),
              ),
              const SizedBox(width: 12),
              // Текст реакции
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bari',
                      style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getReactionText(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Кнопка закрытия
              if (widget.onDismiss != null)
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    color: Colors.black.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Круглый аватар Bari с эмодзи
class _BariAvatar extends StatelessWidget {
  final String emoji;
  final Color backgroundColor;

  const _BariAvatar({
    required this.emoji,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}


