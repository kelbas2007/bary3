/// Тип медиа для слайдов
enum MediaType { none, image, svg, lottie }

/// Тип слайда
enum SlideType { info, quiz, action }

/// Модуль обучения
class LessonModule {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int minAge;
  final int maxAge;

  const LessonModule({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.minAge,
    required this.maxAge,
  });

  static const basics = LessonModule(
    id: 'basics',
    name: 'Основы',
    emoji: '📚',
    description: 'Личный бюджет и первые шаги',
    minAge: 12,
    maxAge: 13,
  );

  static const digital = LessonModule(
    id: 'digital',
    name: 'Цифра',
    emoji: '🌐',
    description: 'Безопасность и права в интернете',
    minAge: 13,
    maxAge: 15,
  );

  static const work = LessonModule(
    id: 'work',
    name: 'Работа',
    emoji: '💼',
    description: 'Заработок и банки',
    minAge: 15,
    maxAge: 16,
  );

  static const future = LessonModule(
    id: 'future',
    name: 'Будущее',
    emoji: '🚀',
    description: 'Инвестиции и долгосрочное планирование',
    minAge: 16,
    maxAge: 17,
  );

  static const trending = LessonModule(
    id: 'trending',
    name: 'Актуальное',
    emoji: '🔥',
    description: 'AI, NFT и современные тренды',
    minAge: 14,
    maxAge: 17,
  );

  static const List<LessonModule> all = [basics, digital, work, future, trending];

  static LessonModule? fromId(String id) {
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Базовый класс слайда
abstract class Slide {
  final SlideType type;
  final String? mediaUrl;
  final MediaType mediaType;

  const Slide({
    required this.type,
    this.mediaUrl,
    this.mediaType = MediaType.none,
  });

  Map<String, dynamic> toJson();

  factory Slide.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'info':
        return InfoSlide.fromJson(json);
      case 'quiz':
        return QuizSlide.fromJson(json);
      case 'action':
        return ActionSlide.fromJson(json);
      default:
        // Fallback для старого формата
        return InfoSlide(
          title: '',
          text: json['data'] as String? ?? '',
        );
    }
  }
}

/// Информационный слайд
class InfoSlide extends Slide {
  final String title;
  final String text;

  const InfoSlide({
    required this.title,
    required this.text,
    super.mediaUrl,
    super.mediaType = MediaType.svg,
  }) : super(type: SlideType.info);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'info',
        'title': title,
        'text': text,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType.name,
      };

  factory InfoSlide.fromJson(Map<String, dynamic> json) => InfoSlide(
        title: json['title'] as String? ?? '',
        text: json['text'] as String? ?? json['data'] as String? ?? '',
        mediaUrl: json['mediaUrl'] as String?,
        mediaType: _parseMediaType(json['mediaType']),
      );
}

/// Слайд с вопросом
class QuizSlide extends Slide {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizSlide({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    super.mediaUrl,
    super.mediaType = MediaType.none,
  }) : super(type: SlideType.quiz);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'quiz',
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType.name,
      };

  factory QuizSlide.fromJson(Map<String, dynamic> json) => QuizSlide(
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String?,
        mediaUrl: json['mediaUrl'] as String?,
        mediaType: _parseMediaType(json['mediaType']),
      );
}

/// Слайд с призывом к действию
class ActionSlide extends Slide {
  final String title;
  final String text;
  final String buttonText;
  final String targetScreen; // 'calculator_50_30_20', 'piggy_banks', etc.

  const ActionSlide({
    required this.title,
    required this.text,
    required this.buttonText,
    required this.targetScreen,
    super.mediaUrl,
    super.mediaType = MediaType.svg,
  }) : super(type: SlideType.action);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'action',
        'title': title,
        'text': text,
        'buttonText': buttonText,
        'targetScreen': targetScreen,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType.name,
      };

  factory ActionSlide.fromJson(Map<String, dynamic> json) => ActionSlide(
        title: json['title'] as String,
        text: json['text'] as String,
        buttonText: json['buttonText'] as String,
        targetScreen: json['targetScreen'] as String,
        mediaUrl: json['mediaUrl'] as String?,
        mediaType: _parseMediaType(json['mediaType']),
      );
}

MediaType _parseMediaType(dynamic value) {
  if (value == null) return MediaType.none;
  final str = value as String;
  switch (str) {
    case 'image':
      return MediaType.image;
    case 'svg':
      return MediaType.svg;
    case 'lottie':
      return MediaType.lottie;
    default:
      return MediaType.none;
  }
}

/// Урок
class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final String locale;
  final bool isPremium;
  final int readTimeMinutes;
  final int xpReward;
  final String? unlocksLessonId;
  final List<String> tags;
  final List<Slide> slides;
  final String? summary;

  // Legacy поддержка
  final int durationSeconds;
  final List<LessonContent> content;
  final List<QuizQuestion> quiz;

  Lesson({
    required this.id,
    this.moduleId = 'basics',
    required this.title,
    this.description = '',
    this.locale = 'ru',
    this.isPremium = false,
    this.readTimeMinutes = 2,
    this.xpReward = 50,
    this.unlocksLessonId,
    this.tags = const [],
    this.slides = const [],
    this.summary,
    // Legacy
    int? durationSeconds,
    this.content = const [],
    this.quiz = const [],
  }) : durationSeconds = durationSeconds ?? readTimeMinutes * 60;

  /// Проверяет, использует ли урок новый формат слайдов
  bool get usesNewFormat => slides.isNotEmpty;

  /// Получить все quiz-слайды
  List<QuizSlide> get quizSlides =>
      slides.whereType<QuizSlide>().toList();

  /// Получить все action-слайды
  List<ActionSlide> get actionSlides =>
      slides.whereType<ActionSlide>().toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'description': description,
        'locale': locale,
        'isPremium': isPremium,
        'readTimeMinutes': readTimeMinutes,
        'xpReward': xpReward,
        'unlocksLessonId': unlocksLessonId,
        'tags': tags,
        'slides': slides.map((s) => s.toJson()).toList(),
        'summary': summary,
        // Legacy
        'durationSeconds': durationSeconds,
        'content': content.map((c) => c.toJson()).toList(),
        'quiz': quiz.map((q) => q.toJson()).toList(),
      };

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Проверяем, есть ли новый формат slides
    final slidesList = json['slides'] as List<dynamic>?;
    final hasNewFormat = slidesList != null && slidesList.isNotEmpty;

    return Lesson(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String? ?? _inferModuleId(json['id'] as String),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      locale: json['locale'] as String? ?? 'ru',
      isPremium: json['isPremium'] as bool? ?? false,
      readTimeMinutes: json['readTimeMinutes'] as int? ?? 
          ((json['durationSeconds'] as int? ?? 90) ~/ 60),
      xpReward: json['xpReward'] as int? ?? 50,
      unlocksLessonId: json['unlocksLessonId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      slides: hasNewFormat
          ? slidesList.map((s) => Slide.fromJson(s as Map<String, dynamic>)).toList()
          : [],
      summary: json['summary'] as String?,
      // Legacy
      durationSeconds: json['durationSeconds'] as int?,
      content: (json['content'] as List<dynamic>?)
              ?.map((c) => LessonContent.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      quiz: (json['quiz'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Определяет moduleId по id урока для обратной совместимости
  static String _inferModuleId(String lessonId) {
    if (lessonId.startsWith('m1_') || lessonId.startsWith('free_')) {
      return 'basics';
    } else if (lessonId.startsWith('m2_')) {
      return 'digital';
    } else if (lessonId.startsWith('m3_')) {
      return 'work';
    } else if (lessonId.startsWith('m4_')) {
      return 'future';
    } else if (lessonId.startsWith('m5_')) {
      return 'trending';
    } else if (lessonId.startsWith('premium_')) {
      return 'future';
    }
    return 'basics';
  }
}

/// Legacy: Контент урока (для обратной совместимости)
class LessonContent {
  final String type; // text, image, video
  final String data;

  LessonContent({required this.type, required this.data});

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };

  factory LessonContent.fromJson(Map<String, dynamic> json) => LessonContent(
        type: json['type'] as String,
        data: json['data'] as String,
      );
}

/// Legacy: Вопрос викторины (для обратной совместимости)
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
      );
}

/// Прогресс урока
class LessonProgress {
  final String lessonId;
  final bool completed;
  final int? score; // процент правильных ответов
  final DateTime? completedAt;
  final int earnedXp;

  LessonProgress({
    required this.lessonId,
    this.completed = false,
    this.score,
    this.completedAt,
    this.earnedXp = 0,
  });

  Map<String, dynamic> toJson() => {
        'lessonId': lessonId,
        'completed': completed,
        'score': score,
        'completedAt': completedAt?.toIso8601String(),
        'earnedXp': earnedXp,
      };

  factory LessonProgress.fromJson(Map<String, dynamic> json) => LessonProgress(
        lessonId: json['lessonId'] as String,
        completed: json['completed'] as bool? ?? false,
        score: json['score'] as int?,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        earnedXp: json['earnedXp'] as int? ?? 0,
      );
}
