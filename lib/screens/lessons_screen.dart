import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../models/lesson.dart';
import '../models/player_profile.dart';
import '../services/storage_service.dart';
import '../theme/aurora_theme.dart';
import '../widgets/stories_player.dart';
import '../widgets/victory_screen.dart';
import 'main_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with SingleTickerProviderStateMixin {
  List<Lesson> _lessons = [];
  List<LessonProgress> _progress = [];
  PlayerProfile? _profile;
  late TabController _tabController;
  bool _isLoading = true;
  bool _isNavigating = false; // Защита от повторных навигаций

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LessonModule.all.length,
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final progress = await StorageService.getLessonProgress();
    final profile = await StorageService.getPlayerProfile();
    final lessons = await _loadAllLessons();

    if (mounted) {
      setState(() {
        _lessons = lessons;
        _progress = progress;
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<List<Lesson>> _loadAllLessons() async {
    final language = await StorageService.getLanguage();

    // Загружаем объединённый файл уроков
    var lessons = await _loadLessonsFile(
      'assets/lessons/$language/lessons.json',
    );

    // Fallback на русский, если нет уроков
    if (lessons.isEmpty && language != 'ru') {
      lessons = await _loadLessonsFile('assets/lessons/ru/lessons.json');
    }

    return lessons;
  }

  Future<List<Lesson>> _loadLessonsFile(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      if (jsonString.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((j) => Lesson.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  List<Lesson> _getLessonsForModule(String moduleId) {
    return _lessons.where((l) => l.moduleId == moduleId).toList();
  }

  LessonProgress? _getProgress(String lessonId) {
    try {
      return _progress.firstWhere((p) => p.lessonId == lessonId);
    } catch (e) {
      return null;
    }
  }

  int _getCompletedCount(String moduleId) {
    final moduleLessons = _getLessonsForModule(moduleId);
    return moduleLessons
        .where((l) => _getProgress(l.id)?.completed ?? false)
        .length;
  }

  bool _isLessonAvailable(Lesson lesson, List<Lesson> moduleLessons) {
    final index = moduleLessons.indexOf(lesson);
    if (index == 0) return true;
    final previousLesson = moduleLessons[index - 1];
    return _getProgress(previousLesson.id)?.completed ?? false;
  }

  void _openLesson(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoriesPlayer(
          lesson: lesson,
          onComplete: () => _onLessonComplete(lesson),
          onActionTap: (targetScreen) => _handleActionTap(targetScreen),
        ),
      ),
    );
  }

  Future<void> _onLessonComplete(Lesson lesson) async {
    // Сохраняем прогресс
    final newProgress = LessonProgress(
      lessonId: lesson.id,
      completed: true,
      score: 100,
      completedAt: DateTime.now(),
      earnedXp: lesson.xpReward,
    );

    // Обновляем список прогресса
    final updatedProgress = List<LessonProgress>.from(_progress);
    final existingIndex = updatedProgress.indexWhere(
      (p) => p.lessonId == lesson.id,
    );
    if (existingIndex >= 0) {
      updatedProgress[existingIndex] = newProgress;
    } else {
      updatedProgress.add(newProgress);
    }
    await StorageService.saveLessonProgress(updatedProgress);

    // Добавляем XP
    if (_profile != null) {
      final updatedProfile = _profile!.copyWith(
        xp: _profile!.xp + lesson.xpReward,
      );
      await StorageService.savePlayerProfile(updatedProfile);
    }

    // Перезагружаем данные
    await _loadData();

    if (!mounted) return;

    // Определяем следующий урок
    final moduleLessons = _getLessonsForModule(lesson.moduleId);
    final currentIndex = moduleLessons.indexWhere((l) => l.id == lesson.id);
    final nextLesson = currentIndex < moduleLessons.length - 1
        ? moduleLessons[currentIndex + 1]
        : null;

    // Показываем Victory Screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => VictoryScreen(
          lessonTitle: lesson.title,
          xpEarned: lesson.xpReward,
          score: 100,
          isModuleComplete: nextLesson == null,
          nextLessonTitle: nextLesson?.title,
          onContinue: nextLesson != null
              ? () {
                  // Используем pushReplacement для плавного перехода
                  Navigator.pushReplacement(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => StoriesPlayer(
                        lesson: nextLesson,
                        onComplete: () => _onLessonComplete(nextLesson),
                        onActionTap: _handleActionTap,
                      ),
                    ),
                  );
                }
              : null,
          onBackToLessons: () {
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  void _handleActionTap(String targetScreen) {
    if (_isNavigating) return; // Предотвращаем повторные вызовы
    _isNavigating = true;
    
    // Для переключения вкладок сначала возвращаемся на главный экран
    // Для открытия новых экранов просто открываем их поверх текущего
    switch (targetScreen) {
      case 'piggy_banks':
      case 'balance':
      case 'calendar':
        // Для переключения вкладок: закрываем StoriesPlayer и переключаем вкладку
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            _isNavigating = false;
            return;
          }
          try {
            // Закрываем StoriesPlayer
            Navigator.of(context).pop();
          } catch (e) {
            _isNavigating = false;
            return;
          }
          // Переключаем вкладку после закрытия
          Future.delayed(const Duration(milliseconds: 100), () {
            if (!mounted) {
              _isNavigating = false;
              return;
            }
            switch (targetScreen) {
              case 'piggy_banks':
                MainScreen.tabNotifier.value = 1;
                break;
              case 'balance':
                MainScreen.tabNotifier.value = 0;
                break;
              case 'calendar':
                MainScreen.tabNotifier.value = 2;
                break;
            }
            _isNavigating = false;
          });
        });
        break;
      case 'calculator_50_30_20':
      case 'calculator_24h':
      case 'calculator_can_i_buy':
      case 'calculator_subscriptions':
      case 'calculator_goal_date':
      case 'calculator_monthly_budget':
      case 'calculator_price_comparison':
      case 'calculator_piggy_plan':
      case 'parent_zone':
        // Для открытия новых экранов: открываем поверх StoriesPlayer без pop
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            _isNavigating = false;
            return;
          }
          try {
            switch (targetScreen) {
              case 'calculator_50_30_20':
                Navigator.pushNamed(context, '/calculator-50-30-20')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_24h':
                Navigator.pushNamed(context, '/calculator-24h')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_can_i_buy':
                Navigator.pushNamed(context, '/calculator-can-i-buy')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_subscriptions':
                Navigator.pushNamed(context, '/calculator-subscriptions')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_goal_date':
                Navigator.pushNamed(context, '/calculator-goal-date')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_monthly_budget':
                Navigator.pushNamed(context, '/calculator-monthly-budget')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_price_comparison':
                Navigator.pushNamed(context, '/calculator-price-comparison')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'calculator_piggy_plan':
                Navigator.pushNamed(context, '/calculator-piggy-plan')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
              case 'parent_zone':
                Navigator.pushNamed(context, '/parent-zone')
                    .then((_) => _isNavigating = false)
                    .catchError((_) => _isNavigating = false);
                break;
            }
          } catch (e) {
            _isNavigating = false;
          }
        });
        break;
      case 'lessons':
      default:
        // Уже на экране уроков, ничего не делаем
        _isNavigating = false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок и прогресс
              _buildHeader(),

              // Табы модулей
              _buildModuleTabs(),

              // Список уроков
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: LessonModule.all.map((module) {
                    return _buildModuleContent(module);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalCompleted = _progress.where((p) => p.completed).length;
    final totalLessons = _lessons.length;
    final totalXp = _progress.fold<int>(0, (sum, p) => sum + p.earnedXp);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '📚 Уроки',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // XP badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '$totalXp XP',
                      style: const TextStyle(
                        color: AuroraTheme.neonYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Общий прогресс
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalLessons > 0 ? totalCompleted / totalLessons : 0,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AuroraTheme.neonBlue,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalCompleted из $totalLessons уроков пройдено',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AuroraTheme.neonBlue,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        tabs: LessonModule.all.map((module) {
          final completed = _getCompletedCount(module.id);
          final total = _getLessonsForModule(module.id).length;
          final isComplete = completed == total && total > 0;

          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(module.emoji),
                const SizedBox(width: 4),
                Text(module.name),
                if (isComplete) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.greenAccent,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModuleContent(LessonModule module) {
    final lessons = _getLessonsForModule(module.id);
    final completed = _getCompletedCount(module.id);

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(module.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text(
              'Скоро появятся новые уроки!',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Информация о модуле
        _ModuleInfoCard(
          module: module,
          completedCount: completed,
          totalCount: lessons.length,
        ),
        const SizedBox(height: 16),

        // Список уроков
        ...lessons.asMap().entries.map((entry) {
          final index = entry.key;
          final lesson = entry.value;
          final isCompleted = _getProgress(lesson.id)?.completed ?? false;
          final isAvailable = _isLessonAvailable(lesson, lessons);

          return _LessonCard(
            lesson: lesson,
            lessonNumber: index + 1,
            isCompleted: isCompleted,
            isAvailable: isAvailable,
            onTap: isAvailable ? () => _openLesson(lesson) : null,
          );
        }),

        const SizedBox(height: 80),
      ],
    );
  }
}

/// Информационная карточка модуля
class _ModuleInfoCard extends StatelessWidget {
  final LessonModule module;
  final int completedCount;
  final int totalCount;

  const _ModuleInfoCard({
    required this.module,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isComplete = completedCount == totalCount && totalCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AuroraTheme.neonPurple.withValues(alpha: 0.3),
            AuroraTheme.neonBlue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? Colors.greenAccent
              : AuroraTheme.neonPurple.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(module.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      module.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isComplete)
                const Icon(Icons.verified, color: Colors.greenAccent, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                '${module.minAge}-${module.maxAge} лет',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  color: isComplete ? Colors.greenAccent : Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.greenAccent : AuroraTheme.neonBlue,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка урока
class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int lessonNumber;
  final bool isCompleted;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _LessonCard({
    required this.lesson,
    required this.lessonNumber,
    required this.isCompleted,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isAvailable && !isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? Colors.greenAccent.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  // Номер/статус
                  _buildStatusBadge(),
                  const SizedBox(width: 12),

                  // Информация об уроке
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            color: isDisabled ? Colors.white54 : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.description,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson.readTimeMinutes} мин',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('⚡', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 2),
                            Text(
                              '+${lesson.xpReward} XP',
                              style: const TextStyle(
                                color: AuroraTheme.neonYellow,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (lesson.slides
                                .whereType<QuizSlide>()
                                .isNotEmpty) ...[
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.quiz_outlined,
                                size: 12,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${lesson.slides.whereType<QuizSlide>().length}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Стрелка
                  if (!isDisabled)
                    Icon(
                      isCompleted ? Icons.replay : Icons.arrow_forward_ios,
                      color: isCompleted ? Colors.greenAccent : Colors.white54,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.greenAccent.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent, width: 2),
        ),
        child: const Icon(Icons.check, color: Colors.greenAccent, size: 20),
      );
    }

    if (!isAvailable) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: const Icon(Icons.lock, color: Colors.white38, size: 18),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AuroraTheme.neonBlue, width: 2),
      ),
      child: Center(
        child: Text(
          '$lessonNumber',
          style: const TextStyle(
            color: AuroraTheme.neonBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
