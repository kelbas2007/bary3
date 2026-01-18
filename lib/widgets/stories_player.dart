import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../theme/aurora_theme.dart';

/// Stories-плеер в стиле Instagram для уроков
class StoriesPlayer extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onComplete;
  final Function(String targetScreen)? onActionTap;

  const StoriesPlayer({
    super.key,
    required this.lesson,
    this.onComplete,
    this.onActionTap,
  });

  @override
  State<StoriesPlayer> createState() => _StoriesPlayerState();
}

class _StoriesPlayerState extends State<StoriesPlayer>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _progressController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  // Quiz state
  int? _selectedAnswer;
  bool _answerSubmitted = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..addStatusListener(_onProgressComplete);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _startProgress();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  List<Slide> get _slides => widget.lesson.usesNewFormat
      ? widget.lesson.slides
      : _convertLegacyContent();

  /// Конвертирует старый формат контента в слайды
  List<Slide> _convertLegacyContent() {
    final slides = <Slide>[];

    // Добавляем info-слайды из content
    for (final content in widget.lesson.content) {
      slides.add(InfoSlide(
        title: '',
        text: content.data,
      ));
    }

    // Добавляем quiz-слайды
    for (final quiz in widget.lesson.quiz) {
      slides.add(QuizSlide(
        question: quiz.question,
        options: quiz.options,
        correctIndex: quiz.correctIndex,
      ));
    }

    return slides;
  }

  void _startProgress() {
    final slide = _slides[_currentIndex];
    // Пауза на quiz-слайдах
    if (slide is QuizSlide && !_answerSubmitted) {
      _progressController.stop();
    } else {
      _progressController.forward(from: 0);
    }
  }

  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNext();
    }
  }

  void _goToNext() {
    if (_currentIndex < _slides.length - 1) {
      setState(() {
        _currentIndex++;
        _resetQuizState();
      });
      _animateSlideTransition();
      _startProgress();
    } else {
      _completeLesson();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _resetQuizState();
      });
      _animateSlideTransition();
      _startProgress();
    }
  }

  void _resetQuizState() {
    _selectedAnswer = null;
    _answerSubmitted = false;
    _isCorrect = false;
  }

  void _animateSlideTransition() {
    _slideController.forward(from: 0);
  }

  void _completeLesson() {
    HapticFeedback.mediumImpact();
    widget.onComplete?.call();
  }

  void _onTapLeft() {
    HapticFeedback.lightImpact();
    _goToPrevious();
  }

  void _onTapRight() {
    HapticFeedback.lightImpact();
    final slide = _slides[_currentIndex];
    if (slide is QuizSlide && !_answerSubmitted) {
      // На quiz-слайде нужно сначала ответить
      return;
    }
    _goToNext();
  }

  void _onAnswerSelected(int index) {
    if (_answerSubmitted) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    final slide = _slides[_currentIndex] as QuizSlide;
    HapticFeedback.mediumImpact();
    setState(() {
      _answerSubmitted = true;
      _isCorrect = _selectedAnswer == slide.correctIndex;
    });

    // Продолжаем через 2 секунды
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _goToNext();
      }
    });
  }

  void _onActionTap(String targetScreen) {
    HapticFeedback.mediumImpact();
    widget.onActionTap?.call(targetScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuroraTheme.spaceBlue,
      body: Stack(
        children: [
          // Фоновый градиент
          Container(
            decoration: const BoxDecoration(
              gradient: AuroraTheme.purpleGradient,
            ),
          ),

          // Контент слайда
          GestureDetector(
            onTapUp: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.localPosition.dx < screenWidth / 3) {
                _onTapLeft();
              } else if (details.localPosition.dx > screenWidth * 2 / 3) {
                _onTapRight();
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  // Прогресс-бар
                  _buildProgressBar(),
                  const SizedBox(height: 16),

                  // Заголовок
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Контент слайда
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _slideAnimation,
                          child: _buildSlideContent(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Кнопка закрытия
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_slides.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _ProgressSegment(
                isActive: index == _currentIndex,
                isCompleted: index < _currentIndex,
                progress: index == _currentIndex
                    ? _progressController
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Номер урока
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AuroraTheme.neonPurple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1}/${_slides.length}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Название урока
          Expanded(
            child: Text(
              widget.lesson.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // XP награда
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AuroraTheme.neonYellow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '+${widget.lesson.xpReward} XP',
                  style: const TextStyle(
                    color: AuroraTheme.neonYellow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideContent() {
    final slide = _slides[_currentIndex];

    if (slide is InfoSlide) {
      return _buildInfoSlide(slide);
    } else if (slide is QuizSlide) {
      return _buildQuizSlide(slide);
    } else if (slide is ActionSlide) {
      return _buildActionSlide(slide);
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoSlide(InfoSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Изображение (если есть)
          if (slide.mediaUrl != null) ...[
            Expanded(
              flex: 2,
              child: _buildMedia(slide.mediaUrl!, slide.mediaType),
            ),
            const SizedBox(height: 24),
          ],

          // Заголовок (если есть)
          if (slide.title.isNotEmpty) ...[
            Text(
              slide.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // Текст
          Expanded(
            flex: slide.mediaUrl != null ? 1 : 2,
            child: SingleChildScrollView(
              child: Text(
                slide.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Подсказка навигации
          const SizedBox(height: 24),
          _buildNavigationHint(),
        ],
      ),
    );
  }

  Widget _buildQuizSlide(QuizSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка вопроса
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🤔', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 24),

          // Вопрос
          Text(
            slide.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Варианты ответов
          ...List.generate(slide.options.length, (index) {
            final isSelected = _selectedAnswer == index;
            final isCorrectAnswer = index == slide.correctIndex;

            Color backgroundColor;
            Color borderColor;

            if (_answerSubmitted) {
              if (isCorrectAnswer) {
                backgroundColor = Colors.green.withValues(alpha: 0.3);
                borderColor = Colors.greenAccent;
              } else if (isSelected && !isCorrectAnswer) {
                backgroundColor = Colors.red.withValues(alpha: 0.3);
                borderColor = Colors.redAccent;
              } else {
                backgroundColor = Colors.white.withValues(alpha: 0.1);
                borderColor = Colors.white24;
              }
            } else {
              backgroundColor = isSelected
                  ? AuroraTheme.neonBlue.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1);
              borderColor = isSelected ? AuroraTheme.neonBlue : Colors.white24;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _answerSubmitted ? null : () => _onAnswerSelected(index),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Row(
                      children: [
                        // Буква варианта
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: borderColor.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: borderColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Текст варианта
                        Expanded(
                          child: Text(
                            slide.options[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Иконка результата
                        if (_answerSubmitted) ...[
                          Icon(
                            isCorrectAnswer
                                ? Icons.check_circle
                                : (isSelected ? Icons.cancel : null),
                            color: isCorrectAnswer
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Кнопка отправки ответа
          if (!_answerSubmitted && _selectedAnswer != null)
            ElevatedButton(
              onPressed: _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AuroraTheme.neonBlue,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Проверить',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Объяснение после ответа
          if (_answerSubmitted && slide.explanation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    _isCorrect ? '✅' : '💡',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      slide.explanation!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSlide(ActionSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Изображение (если есть)
          if (slide.mediaUrl != null) ...[
            Expanded(
              flex: 2,
              child: _buildMedia(slide.mediaUrl!, slide.mediaType),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Иконка действия
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AuroraTheme.neonBlue.withValues(alpha: 0.3),
                    AuroraTheme.neonPurple.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Text('🎯', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 32),
          ],

          // Заголовок
          Text(
            slide.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Описание
          Text(
            slide.text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Кнопка действия
          ElevatedButton(
            onPressed: () => _onActionTap(slide.targetScreen),
            style: ElevatedButton.styleFrom(
              backgroundColor: AuroraTheme.neonBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slide.buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Подсказка "или продолжить"
          TextButton(
            onPressed: _goToNext,
            child: const Text(
              'Пропустить →',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(String url, MediaType type) {
    // Пока используем placeholder с emoji
    // В будущем здесь будет flutter_svg для SVG
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Text(
          '📖',
          style: TextStyle(fontSize: 80),
        ),
      ),
    );
  }

  Widget _buildNavigationHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.touch_app, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Text(
          'Нажми справа, чтобы продолжить',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Сегмент прогресс-бара
class _ProgressSegment extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  final AnimationController? progress;

  const _ProgressSegment({
    required this.isActive,
    required this.isCompleted,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: isCompleted
            ? Container(color: Colors.white)
            : isActive && progress != null
                ? AnimatedBuilder(
                    animation: progress!,
                    builder: (context, _) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress!.value,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AuroraTheme.neonBlue,
                                AuroraTheme.neonPurple,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : null,
      ),
    );
  }
}
