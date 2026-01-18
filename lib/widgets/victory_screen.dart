import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/aurora_theme.dart';

/// Экран победы после завершения урока
class VictoryScreen extends StatefulWidget {
  final String lessonTitle;
  final int xpEarned;
  final int? score; // Процент правильных ответов (0-100)
  final bool isModuleComplete;
  final String? nextLessonTitle;
  final VoidCallback? onContinue;
  final VoidCallback? onBackToLessons;

  const VictoryScreen({
    super.key,
    required this.lessonTitle,
    required this.xpEarned,
    this.score,
    this.isModuleComplete = false,
    this.nextLessonTitle,
    this.onContinue,
    this.onBackToLessons,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _xpController;
  late AnimationController _bounceController;
  
  late Animation<double> _starScale;
  late Animation<double> _xpValue;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Анимация звезды
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _starScale = CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    );

    // Анимация XP
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _xpValue = Tween<double>(
      begin: 0,
      end: widget.xpEarned.toDouble(),
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.easeOutCubic,
    ));

    // Bounce анимация для кнопок
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );

    // Запускаем анимации последовательно
    _startAnimations();
  }

  void _startAnimations() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    _starController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _xpController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _bounceController.forward();
  }

  @override
  void dispose() {
    _starController.dispose();
    _xpController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  String get _emoji {
    if (widget.isModuleComplete) return '🏆';
    if (widget.score != null) {
      if (widget.score! >= 90) return '🌟';
      if (widget.score! >= 70) return '⭐';
      if (widget.score! >= 50) return '👍';
      return '💪';
    }
    return '✨';
  }

  String get _title {
    if (widget.isModuleComplete) return 'Модуль завершён!';
    if (widget.score != null) {
      if (widget.score! >= 90) return 'Отлично!';
      if (widget.score! >= 70) return 'Хорошо!';
      if (widget.score! >= 50) return 'Неплохо!';
      return 'Урок пройден!';
    }
    return 'Урок пройден!';
  }

  Color get _accentColor {
    if (widget.isModuleComplete) return AuroraTheme.neonYellow;
    if (widget.score != null && widget.score! >= 70) return Colors.greenAccent;
    return AuroraTheme.neonBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фон
          Container(
            decoration: const BoxDecoration(
              gradient: AuroraTheme.purpleGradient,
            ),
          ),
          
          // Конфетти
          ...List.generate(20, (index) => _ConfettiParticle(
            delay: Duration(milliseconds: index * 100),
            color: [
              AuroraTheme.neonBlue,
              AuroraTheme.neonPurple,
              AuroraTheme.neonYellow,
              Colors.greenAccent,
              Colors.pinkAccent,
            ][index % 5],
          )),
          
          // Контент
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Звезда/Трофей
                    ScaleTransition(
                    scale: _starScale,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accentColor.withValues(alpha: 0.3),
                            _accentColor.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _accentColor.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        _emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Заголовок
                  Text(
                    _title,
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Название урока
                  Text(
                    widget.lessonTitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // XP награда
                  AnimatedBuilder(
                    animation: _xpValue,
                    builder: (context, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AuroraTheme.neonYellow.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '⚡',
                              style: TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '+${_xpValue.value.toInt()} XP',
                              style: const TextStyle(
                                color: AuroraTheme.neonYellow,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Процент правильных ответов
                  if (widget.score != null) ...[
                    const SizedBox(height: 24),
                    _buildScoreCard(),
                  ],

                  const SizedBox(height: 48),

                  // Кнопки
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Column(
                      children: [
                        // Следующий урок
                        if (widget.nextLessonTitle != null && widget.onContinue != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                widget.onContinue!();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Следующий урок',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // К списку уроков
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (widget.onBackToLessons != null) {
                              widget.onBackToLessons!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text(
                            'К списку уроков',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = widget.score!;
    Color scoreColor;
    String scoreEmoji;
    String scoreText;

    if (score >= 90) {
      scoreColor = Colors.greenAccent;
      scoreEmoji = '🎯';
      scoreText = 'Превосходно!';
    } else if (score >= 70) {
      scoreColor = Colors.lightGreenAccent;
      scoreEmoji = '👏';
      scoreText = 'Хороший результат';
    } else if (score >= 50) {
      scoreColor = Colors.orangeAccent;
      scoreEmoji = '📚';
      scoreText = 'Есть над чем поработать';
    } else {
      scoreColor = Colors.redAccent;
      scoreEmoji = '💪';
      scoreText = 'Попробуй ещё раз!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(scoreEmoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                '$score%',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scoreText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Частица конфетти
class _ConfettiParticle extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _ConfettiParticle({
    required this.delay,
    required this.color,
  });

  @override
  State<_ConfettiParticle> createState() => _ConfettiParticleState();
}

class _ConfettiParticleState extends State<_ConfettiParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fallAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  
  late double _startX;
  late double _endX;
  late double _size;

  @override
  void initState() {
    super.initState();
    
    final random = Random();
    _startX = random.nextDouble();
    _endX = _startX + (random.nextDouble() - 0.5) * 0.3;
    _size = 8 + random.nextDouble() * 8;
    
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + random.nextInt(1500)),
    );
    
    _fallAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(_controller);
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final x = (_startX + (_endX - _startX) * _fallAnimation.value) * screenSize.width;
        final y = _fallAnimation.value * screenSize.height;
        
        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
