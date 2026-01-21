import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../aca/local_llm/llama_ffi_binding.dart';
import '../aca/local_llm/model_loader.dart';
import '../../services/chat_history_service.dart';
import '../bari_context.dart';
import '../bari_models.dart';
import '../../models/lesson.dart';
import '../../models/transaction.dart';
import 'bari_provider.dart';

/// Провайдер для локального LLM (llama.cpp) - бесплатный on-device AI
/// 
/// Поддерживает 3 языка: ru, en, de
/// Работает полностью офлайн после загрузки модели
class LocalLLMProvider implements BariProvider {
  final LlamaFFIBinding _engine = LlamaFFIBinding();
  final ModelLoader _modelLoader = ModelLoader();
  final ChatHistoryService _chatHistory = ChatHistoryService();
  String? _loadedModelPath;
  bool _sessionInitialized = false;

  /// Проверяет доступность модели
  Future<bool> _checkModelAvailable() async {
    try {
      final modelPath = await _modelLoader.loadModel();
      _loadedModelPath = modelPath;
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Model not available: $e');
      }
      return false;
    }
  }

  /// Извлекает язык из localeTag (ru_RU -> ru)
  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }

  /// Строит системный промпт для указанного языка
  String _buildSystemPrompt(String locale, BariContext ctx) {
    final currency = ctx.currencyCode;
    final balance = (ctx.walletBalanceCents / 100).toStringAsFixed(2);
    final piggyTotal = (ctx.totalPiggyBanksSaved / 100).toStringAsFixed(2);
    final piggyCount = ctx.piggyBanksCount;
    final level = ctx.playerLevel;
    final xp = ctx.playerXp;
    final age = ctx.playerAge ?? 10;
    final lessonsCompleted = ctx.lessonsCompleted;
    
    // Форматируем транзакции и события
    final transactionsSummary = ctx.getRecentTransactionsSummary(locale);
    final eventsSummary = ctx.getUpcomingEventsSummary(locale);
    
    // Получаем few-shot примеры
    final fewShotExamples = _getFewShotExamples(locale, ctx);

    final prompts = {
      'ru': '''
Ты Бари — дружелюбный финансовый помощник для детей и подростков 8-16 лет в приложении Bary3.

ВАЖНЫЕ ПРАВИЛА:
1. Отвечай ТОЛЬКО на русском языке
2. Объясняй простым языком, как будто объясняешь ребёнку $age лет
3. Используй примеры из жизни подростка (карманные деньги, игры, сладости)
4. Будь позитивным и поддерживающим
5. Если вопрос НЕ связан с финансами, вежливо перенаправь к финансовым темам
6. Никогда не давай опасных советов (азартные игры, криптовалюты для детей и т.д.)
7. Ответ должен быть коротким — максимум 3-4 предложения

КОНТЕКСТ ПОЛЬЗОВАТЕЛЯ:
- Баланс кошелька: $balance $currency
- Всего в копилках: $piggyTotal $currency ($piggyCount копилок)
- Уровень игрока: $level (XP: $xp)
- Пройдено уроков: $lessonsCompleted

ПОСЛЕДНИЕ ТРАНЗАКЦИИ:
$transactionsSummary

БЛИЖАЙШИЕ СОБЫТИЯ:
$eventsSummary

ДОСТУПНЫЕ ФУНКЦИИ ПРИЛОЖЕНИЯ:
1. Калькуляторы: "Можно ли купить?", "Правило 24 часа", "Бюджет 50/30/20", "Подписки", "Сравнение цен", "Когда достигну цели"
2. Копилки: создание целей, отслеживание прогресса, пополнение
3. Календарь: планирование доходов и расходов
4. Лаборатория заработка: планирование задач за деньги
5. Уроки: обучение финансовой грамотности с квизами
6. Мини-тренажёры: практика финансовых навыков

ТЫ МОЖЕШЬ:
- Анализировать траты и давать советы
- Предлагать конкретные калькуляторы для решения задач
- Генерировать вопросы для квизов по урокам
- Объяснять финансовые понятия простым языком
- Помогать планировать покупки и цели
- Мотивировать к накоплениям

ПРИМЕРЫ ДИАЛОГОВ:
$fewShotExamples

ФОРМАТ ОТВЕТА:
Отвечай в формате JSON:
{
  "meaning": "Главная мысль или объяснение (1-2 предложения)",
  "advice": "Практический совет что делать (1 предложение)"
}
''',
      'en': '''
You are Bari — a friendly financial assistant for kids aged 8-16 in the Bary3 app.

IMPORTANT RULES:
1. Answer ONLY in English
2. Explain in simple language, as if explaining to a child aged $age
3. Use examples from a teenager's life (pocket money, games, treats)
4. Be positive and supportive
5. If the question is NOT about finances, politely redirect to financial topics
6. Never give dangerous advice (gambling, cryptocurrencies for kids, etc.)
7. Answer should be short — maximum 3-4 sentences

USER CONTEXT:
- Wallet balance: $balance $currency
- Total in piggy banks: $piggyTotal $currency ($piggyCount banks)
- Player level: $level (XP: $xp)
- Lessons completed: $lessonsCompleted

RECENT TRANSACTIONS:
$transactionsSummary

UPCOMING EVENTS:
$eventsSummary

AVAILABLE APP FEATURES:
1. Calculators: "Can I buy?", "24-hour rule", "50/30/20 budget", "Subscriptions", "Price comparison", "Goal date"
2. Piggy banks: create goals, track progress, top up
3. Calendar: plan income and expenses
4. Earnings Lab: plan tasks for money
5. Lessons: learn financial literacy with quizzes
6. Mini-trainers: practice financial skills

YOU CAN:
- Analyze spending and give advice
- Suggest specific calculators for solving tasks
- Generate quiz questions for lessons
- Explain financial concepts in simple language
- Help plan purchases and goals
- Motivate to save

EXAMPLE DIALOGUES:
$fewShotExamples

RESPONSE FORMAT:
Answer in JSON format:
{
  "meaning": "Main idea or explanation (1-2 sentences)",
  "advice": "Practical advice what to do (1 sentence)"
}
''',
      'de': '''
Du bist Bari — ein freundlicher Finanzassistent für Kinder im Alter von 8-16 Jahren in der Bary3-App.

WICHTIGE REGELN:
1. Antworte NUR auf Deutsch
2. Erkläre in einfacher Sprache, als würdest du einem $age-jährigen Kind erklären
3. Verwende Beispiele aus dem Leben eines Teenagers (Taschengeld, Spiele, Süßigkeiten)
4. Sei positiv und unterstützend
5. Wenn die Frage NICHT mit Finanzen zu tun hat, leite höflich zu Finanzthemen weiter
6. Gib niemals gefährliche Ratschläge (Glücksspiel, Kryptowährungen für Kinder usw.)
7. Die Antwort sollte kurz sein — maximal 3-4 Sätze

BENUTZERKONTEXT:
- Geldbörsen-Guthaben: $balance $currency
- Gesamt in Sparschweinen: $piggyTotal $currency ($piggyCount Sparschweine)
- Spieler-Level: $level (XP: $xp)
- Abgeschlossene Lektionen: $lessonsCompleted

LETZTE TRANSAKTIONEN:
$transactionsSummary

BEVORSTEHENDE EREIGNISSE:
$eventsSummary

VERFÜGBARE APP-FUNKTIONEN:
1. Rechner: "Kann ich kaufen?", "24-Stunden-Regel", "50/30/20 Budget", "Abonnements", "Preisvergleich", "Zieldatum"
2. Sparschweine: Ziele erstellen, Fortschritt verfolgen, aufladen
3. Kalender: Einnahmen und Ausgaben planen
4. Verdienstlabor: Aufgaben für Geld planen
5. Lektionen: Finanzkompetenz mit Quiz lernen
6. Mini-Trainer: Finanzfähigkeiten üben

DU KANNST:
- Ausgaben analysieren und Ratschläge geben
- Konkrete Rechner für Aufgaben vorschlagen
- Quiz-Fragen für Lektionen generieren
- Finanzkonzepte einfach erklären
- Beim Planen von Käufen und Zielen helfen
- Zum Sparen motivieren

BEISPIELDIALOGE:
$fewShotExamples

ANTWORTFORMAT:
Antworte im JSON-Format:
{
  "meaning": "Hauptgedanke oder Erklärung (1-2 Sätze)",
  "advice": "Praktischer Ratschlag, was zu tun ist (1 Satz)"
}
''',
    };

    return prompts[locale] ?? prompts['ru']!;
  }

  /// Получает few-shot примеры диалогов для обучения модели
  String _getFewShotExamples(String locale, BariContext ctx) {
    final balance = (ctx.walletBalanceCents / 100).toStringAsFixed(2);
    final currency = ctx.currencyCode;
    final symbol = _getCurrencySymbol(currency);
    final piggyTotal = (ctx.totalPiggyBanksSaved / 100).toStringAsFixed(2);
    
    final examples = {
      'ru': '''
Пользователь: "Можно ли купить игру за 50$symbol?"
Бари: {
  "meaning": "${ctx.walletBalanceCents >= 5000 ? 'Да, в кошельке $balance$symbol — хватит на покупку!' : 'Пока не хватает. В кошельке $balance$symbol, нужно ещё ${(5000 - ctx.walletBalanceCents) / 100}$symbol.'}",
  "advice": "${ctx.walletBalanceCents >= 5000 ? 'Подумай 24 часа перед покупкой — это "хочу" или "нужно"?' : 'Создай копилку на эту цель и откладывай понемногу.'}"
}

Пользователь: "Что такое инфляция?"
Бари: {
  "meaning": "Инфляция — это когда цены растут, а на те же деньги можно купить меньше. Например, если раньше мороженое стоило 2$symbol, а теперь 2.50$symbol.",
  "advice": "Поэтому важно копить и инвестировать — деньги должны работать, а не просто лежать."
}

Пользователь: "Куда уходят мои деньги?"
Бари: {
  "meaning": "Давай посмотрим на твои траты. Часто деньги уходят на мелочи: сладости, подписки, случайные покупки.",
  "advice": "Попробуй неделю записывать ВСЕ траты, даже маленькие. Увидишь, куда уходит больше всего!"
}

Пользователь: "Как копить на велосипед?"
Бари: {
  "meaning": "Отличная цель! Создай копилку в приложении и откладывай регулярно. У тебя уже $piggyTotal$symbol в копилках — хорошее начало!",
  "advice": "Попробуй откладывать 10-20% от карманных денег каждый раз. Используй калькулятор 'Когда достигну цели' для планирования."
}
''',
      'en': '''
User: "Can I buy a game for 50$symbol?"
Bari: {
  "meaning": "${ctx.walletBalanceCents >= 5000 ? 'Yes, you have $balance$symbol in wallet — enough for the purchase!' : 'Not enough yet. You have $balance$symbol, need ${(5000 - ctx.walletBalanceCents) / 100}$symbol more.'}",
  "advice": "${ctx.walletBalanceCents >= 5000 ? 'Think 24 hours before buying — is this a "want" or "need"?' : 'Create a piggy bank for this goal and save little by little.'}"
}

User: "What is inflation?"
Bari: {
  "meaning": "Inflation is when prices go up and you can buy less with the same money. For example, if ice cream used to cost 2$symbol, now it's 2.50$symbol.",
  "advice": "That's why it's important to save and invest — money should work, not just sit."
}

User: "Where does my money go?"
Bari: {
  "meaning": "Let's look at your spending. Money often goes to small things: treats, subscriptions, random purchases.",
  "advice": "Try writing down ALL expenses for a week, even small ones. You'll see where most goes!"
}

User: "How to save for a bicycle?"
Bari: {
  "meaning": "Great goal! Create a piggy bank in the app and save regularly. You already have $piggyTotal$symbol in piggy banks — good start!",
  "advice": "Try saving 10-20% of pocket money each time. Use the 'Goal date' calculator for planning."
}
''',
      'de': '''
Benutzer: "Kann ich ein Spiel für 50$symbol kaufen?"
Bari: {
  "meaning": "${ctx.walletBalanceCents >= 5000 ? 'Ja, du hast $balance$symbol in der Geldbörse — genug für den Kauf!' : 'Noch nicht genug. Du hast $balance$symbol, brauchst noch ${(5000 - ctx.walletBalanceCents) / 100}$symbol.'}",
  "advice": "${ctx.walletBalanceCents >= 5000 ? 'Denke 24 Stunden vor dem Kauf — ist das ein "Wunsch" oder "Bedarf"?' : 'Erstelle ein Sparschwein für dieses Ziel und spare nach und nach.'}"
}

Benutzer: "Was ist Inflation?"
Bari: {
  "meaning": "Inflation ist, wenn die Preise steigen und man mit dem gleichen Geld weniger kaufen kann. Zum Beispiel, wenn Eis früher 2$symbol kostete, jetzt 2.50$symbol.",
  "advice": "Deshalb ist es wichtig zu sparen und zu investieren — Geld sollte arbeiten, nicht nur liegen."
}

Benutzer: "Wohin geht mein Geld?"
Bari: {
  "meaning": "Lass uns deine Ausgaben ansehen. Geld geht oft für kleine Dinge: Süßigkeiten, Abonnements, zufällige Käufe.",
  "advice": "Versuche eine Woche lang ALLE Ausgaben aufzuschreiben, auch kleine. Du wirst sehen, wohin das meiste geht!"
}

Benutzer: "Wie spare ich für ein Fahrrad?"
Bari: {
  "meaning": "Großartiges Ziel! Erstelle ein Sparschwein in der App und spare regelmäßig. Du hast bereits $piggyTotal$symbol in Sparschweinen — guter Start!",
  "advice": "Versuche jedes Mal 10-20% des Taschengelds zu sparen. Nutze den 'Zieldatum' Rechner für die Planung."
}
''',
    };
    
    return examples[locale] ?? examples['ru']!;
  }

  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'EUR': return '€';
      case 'USD': return '\$';
      case 'RUB': return '₽';
      case 'CHF': return 'CHF';
      case 'GBP': return '£';
      default: return code;
    }
  }

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
    BuildContext? context, // Контекст для показа диалога загрузки
  }) async {
    // Проверяем доступность модели
    if (!await _checkModelAvailable()) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Model not available');
      }
      return null;
    }

    // Загружаем историю диалогов
    await _chatHistory.loadFromStorage();
    
    // Инициализируем движок если нужно
    if (!_engine.isInitialized || !_sessionInitialized) {
      final locale = _extractLocale(ctx.localeTag);
      final systemPrompt = _buildSystemPrompt(locale, ctx);
      
      final initialized = await _engine.initialize(_loadedModelPath!, systemPrompt);
      if (!initialized) {
        if (kDebugMode) {
          debugPrint('[LocalLLM] Failed to initialize engine');
        }
        return null;
      }
      _sessionInitialized = true;
    }

    try {
      final locale = _extractLocale(ctx.localeTag);
      
      // Строим промпт с историей диалогов
      final promptWithHistory = _buildPromptWithHistory(message, locale);
      
      final response = await _engine.generate(
        promptWithHistory,
        maxTokens: 500,
      );
      
      if (response == null || response.isEmpty) {
        return null;
      }

      // Парсим JSON ответ
      final bariResponse = _parseResponse(response, locale);
      
      // Сохраняем в историю
      await _chatHistory.addMessage(
        message,
        '${bariResponse.meaning}\n${bariResponse.advice}',
      );
      
      return bariResponse;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Error generating response: $e');
      }
      return null;
    }
  }

  /// Строит промпт с историей диалогов
  String _buildPromptWithHistory(String message, String locale) {
    final history = _chatHistory.formatHistoryForPrompt(locale);
    
    if (history.contains('Нет предыдущих') || 
        history.contains('No previous') || 
        history.contains('Keine vorherigen')) {
      // Нет истории, просто возвращаем сообщение
      return message;
    }
    
    // Добавляем историю перед текущим вопросом
    return '$history\n\nТекущий вопрос: $message\n\nОтветь на текущий вопрос, учитывая контекст предыдущего диалога.';
  }

  /// Парсит JSON ответ от локального LLM
  BariResponse _parseResponse(String response, String locale) {
    try {
      // Пытаемся извлечь JSON из ответа
      String jsonStr = response.trim();
      
      // Убираем markdown code blocks если есть
      if (jsonStr.contains('```')) {
        final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(1)?.trim() ?? jsonStr;
        }
      }
      
      // Ищем JSON объект
      final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonStr);
      if (jsonObjMatch != null) {
        jsonStr = jsonObjMatch.group(0) ?? jsonStr;
      }

      // Парсим JSON
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      final meaning = json['meaning']?.toString() ?? response;
      final advice = json['advice']?.toString() ?? _getDefaultAdvice(locale);

      // Создаём действия
      final actions = <BariAction>[
        BariAction(
          type: BariActionType.explainSimpler,
          label: _getExplainSimplerLabel(locale),
        ),
      ];

      return BariResponse(
        meaning: meaning,
        advice: advice,
        actions: actions,
        confidence: 0.85,
        sourceTitle: 'AI (On-Device)',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] JSON parse error: $e');
        debugPrint('[LocalLLM] Raw response: $response');
      }
      
      // Fallback: используем сырой ответ
      return BariResponse(
        meaning: response.length > 300 ? '${response.substring(0, 300)}...' : response,
        advice: _getDefaultAdvice(locale),
        actions: [
          BariAction(
            type: BariActionType.explainSimpler,
            label: _getExplainSimplerLabel(locale),
          ),
        ],
        confidence: 0.75,
        sourceTitle: 'AI (On-Device)',
      );
    }
  }

  String _getDefaultAdvice(String locale) {
    final advices = {
      'ru': 'Если что-то непонятно — спрашивай!',
      'en': 'If something is unclear — just ask!',
      'de': 'Wenn etwas unklar ist — frag einfach!',
    };
    return advices[locale] ?? advices['ru']!;
  }

  String _getExplainSimplerLabel(String locale) {
    final labels = {
      'ru': 'Объясни проще',
      'en': 'Explain simpler',
      'de': 'Einfacher erklären',
    };
    return labels[locale] ?? labels['ru']!;
  }

  /// Генерирует вопросы для квиза по тексту урока
  /// 
  /// [lessonText] - текст урока (можно объединить все InfoSlide.text)
  /// [locale] - язык
  /// [ctx] - контекст пользователя
  Future<List<QuizSlide>?> generateQuizQuestions(
    String lessonText,
    String locale,
    BariContext ctx,
  ) async {
    // Проверяем доступность модели
    if (!await _checkModelAvailable()) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Model not available for quiz generation');
      }
      return null;
    }

    // Инициализируем движок если нужно
    if (!_engine.isInitialized || !_sessionInitialized) {
      final systemPrompt = _buildSystemPrompt(locale, ctx);
      final initialized = await _engine.initialize(_loadedModelPath!, systemPrompt);
      if (!initialized) {
        return null;
      }
      _sessionInitialized = true;
    }

    try {
      final prompt = _buildQuizPrompt(lessonText, locale, ctx);
      final response = await _engine.generate(
        prompt,
        maxTokens: 800,
      );
      
      if (response == null || response.isEmpty) {
        return null;
      }

      return _parseQuizQuestions(response, locale);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Error generating quiz: $e');
      }
      return null;
    }
  }

  /// Строит промпт для генерации квиза
  String _buildQuizPrompt(String lessonText, String locale, BariContext ctx) {
    final age = ctx.playerAge ?? 10;
    final level = ctx.playerLevel;
    
    final prompts = {
      'ru': '''
Создай 5 вопросов с 3 вариантами ответа для квиза по следующему уроку.
Уровень сложности: для ребёнка $level уровня ($age лет).

Текст урока:
$lessonText

ВАЖНО:
- Вопросы должны проверять понимание материала
- Варианты ответов должны быть понятными для ребёнка
- Правильный ответ должен быть очевидным после прочтения урока
- Объяснение должно быть коротким (1 предложение)

Формат ответа (JSON):
{
  "questions": [
    {
      "question": "Вопрос",
      "options": ["Вариант 1", "Вариант 2", "Вариант 3"],
      "correctIndex": 0,
      "explanation": "Почему правильный ответ"
    }
  ]
}
''',
      'en': '''
Create 5 questions with 3 answer options for a quiz based on the following lesson.
Difficulty level: for a child at level $level (age $age).

Lesson text:
$lessonText

IMPORTANT:
- Questions should test understanding of the material
- Answer options should be clear for a child
- Correct answer should be obvious after reading the lesson
- Explanation should be short (1 sentence)

Response format (JSON):
{
  "questions": [
    {
      "question": "Question",
      "options": ["Option 1", "Option 2", "Option 3"],
      "correctIndex": 0,
      "explanation": "Why the correct answer"
    }
  ]
}
''',
      'de': '''
Erstelle 5 Fragen mit 3 Antwortoptionen für ein Quiz basierend auf der folgenden Lektion.
Schwierigkeitsgrad: für ein Kind auf Level $level (Alter $age).

Lektionstext:
$lessonText

WICHTIG:
- Fragen sollten das Verständnis des Materials testen
- Antwortoptionen sollten für ein Kind klar sein
- Richtige Antwort sollte nach dem Lesen der Lektion offensichtlich sein
- Erklärung sollte kurz sein (1 Satz)

Antwortformat (JSON):
{
  "questions": [
    {
      "question": "Frage",
      "options": ["Option 1", "Option 2", "Option 3"],
      "correctIndex": 0,
      "explanation": "Warum die richtige Antwort"
    }
  ]
}
''',
    };
    
    return prompts[locale] ?? prompts['ru']!;
  }

  /// Парсит JSON ответ с вопросами квиза
  List<QuizSlide>? _parseQuizQuestions(String response, String locale) {
    try {
      // Извлекаем JSON из ответа
      String jsonStr = response.trim();
      
      if (jsonStr.contains('```')) {
        final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(1)?.trim() ?? jsonStr;
        }
      }
      
      final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonStr);
      if (jsonObjMatch != null) {
        jsonStr = jsonObjMatch.group(0) ?? jsonStr;
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final questionsJson = json['questions'] as List<dynamic>?;
      
      if (questionsJson == null || questionsJson.isEmpty) {
        return null;
      }

      final questions = <QuizSlide>[];
      
      for (final q in questionsJson) {
        final questionMap = q as Map<String, dynamic>;
        final question = questionMap['question']?.toString() ?? '';
        final optionsJson = questionMap['options'] as List<dynamic>?;
        final correctIndex = questionMap['correctIndex'] as int? ?? 0;
        final explanation = questionMap['explanation']?.toString();
        
        if (question.isEmpty || optionsJson == null || optionsJson.length < 3) {
          continue;
        }
        
        final options = optionsJson.map((o) => o.toString()).toList();
        
        questions.add(QuizSlide(
          question: question,
          options: options,
          correctIndex: correctIndex.clamp(0, options.length - 1),
          explanation: explanation,
        ));
      }
      
      return questions.isEmpty ? null : questions;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Quiz parse error: $e');
        debugPrint('[LocalLLM] Raw response: $response');
      }
      return null;
    }
  }

  /// Анализирует траты пользователя и даёт советы
  /// 
  /// [transactions] - список транзакций для анализа
  /// [locale] - язык
  /// [ctx] - контекст пользователя
  Future<SpendingAnalysis?> analyzeSpending(
    List<Transaction> transactions,
    String locale,
    BariContext ctx,
  ) async {
    // Проверяем доступность модели
    if (!await _checkModelAvailable()) {
      return null;
    }

    // Инициализируем движок если нужно
    if (!_engine.isInitialized || !_sessionInitialized) {
      final systemPrompt = _buildSystemPrompt(locale, ctx);
      final initialized = await _engine.initialize(_loadedModelPath!, systemPrompt);
      if (!initialized) {
        return null;
      }
      _sessionInitialized = true;
    }

    try {
      final prompt = _buildSpendingAnalysisPrompt(transactions, locale, ctx);
      final response = await _engine.generate(
        prompt,
        maxTokens: 400,
        temperature: 0.6,
      );
      
      if (response == null || response.isEmpty) {
        return null;
      }

      return _parseSpendingAnalysis(response, locale);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Error analyzing spending: $e');
      }
      return null;
    }
  }

  /// Строит промпт для анализа трат
  String _buildSpendingAnalysisPrompt(
    List<Transaction> transactions,
    String locale,
    BariContext ctx,
  ) {
    // Фильтруем только расходы за последнюю неделю
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentExpenses = transactions
        .where((t) => 
            t.type == TransactionType.expense &&
            t.date.isAfter(weekAgo) &&
            t.parentApproved == true &&
            t.affectsWallet == true)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (recentExpenses.isEmpty) {
      return locale == 'ru'
          ? 'Нет трат за последнюю неделю для анализа'
          : locale == 'en'
          ? 'No expenses in the last week to analyze'
          : 'Keine Ausgaben in der letzten Woche zum Analysieren';
    }

    final symbol = _getCurrencySymbol(ctx.currencyCode);
    final transactionSummary = recentExpenses.take(10).map((t) {
      final amount = (t.amount / 100).toStringAsFixed(2);
      final category = t.category ?? 'Другое';
      final date = t.date.toString().substring(0, 10);
      final note = t.note != null && t.note!.isNotEmpty ? ' (${t.note})' : '';
      return '$date: $amount$symbol - $category$note';
    }).join('\n');

    final totalSpent = recentExpenses.fold<int>(0, (sum, t) => sum + t.amount);
    final totalSpentFormatted = (totalSpent / 100).toStringAsFixed(2);
    final balance = (ctx.walletBalanceCents / 100).toStringAsFixed(2);
    final piggyTotal = (ctx.totalPiggyBanksSaved / 100).toStringAsFixed(2);

    final prompts = {
      'ru': '''
Проанализируй траты пользователя за последнюю неделю и дай добрый совет.

ТРАНЗАКЦИИ:
$transactionSummary

ИТОГО ПОТРАЧЕНО: $totalSpentFormatted$symbol
БАЛАНС: $balance$symbol
В КОПИЛКАХ: $piggyTotal$symbol

Дай совет в формате JSON:
{
  "observation": "Что заметил в тратах (максимум 2 предложения)",
  "suggestion": "Что можно улучшить (1 предложение)",
  "motivation": "Мотивирующее сообщение (1 предложение)"
}
''',
      'en': '''
Analyze the user's spending for the last week and give friendly advice.

TRANSACTIONS:
$transactionSummary

TOTAL SPENT: $totalSpentFormatted$symbol
BALANCE: $balance$symbol
IN PIGGY BANKS: $piggyTotal$symbol

Give advice in JSON format:
{
  "observation": "What you noticed in spending (max 2 sentences)",
  "suggestion": "What can be improved (1 sentence)",
  "motivation": "Motivational message (1 sentence)"
}
''',
      'de': '''
Analysiere die Ausgaben des Benutzers für die letzte Woche und gib freundlichen Rat.

TRANSAKTIONEN:
$transactionSummary

GESAMT AUSGEGEBEN: $totalSpentFormatted$symbol
KONTOSTAND: $balance$symbol
IN SPARSCHWEINEN: $piggyTotal$symbol

Gib Ratschlag im JSON-Format:
{
  "observation": "Was du bei den Ausgaben bemerkt hast (max 2 Sätze)",
  "suggestion": "Was verbessert werden kann (1 Satz)",
  "motivation": "Motivierende Nachricht (1 Satz)"
}
''',
    };
    
    return prompts[locale] ?? prompts['ru']!;
  }

  /// Парсит JSON ответ с анализом трат
  SpendingAnalysis? _parseSpendingAnalysis(String response, String locale) {
    try {
      String jsonStr = response.trim();
      
      if (jsonStr.contains('```')) {
        final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
        if (jsonMatch != null) {
          jsonStr = jsonMatch.group(1)?.trim() ?? jsonStr;
        }
      }
      
      final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonStr);
      if (jsonObjMatch != null) {
        jsonStr = jsonObjMatch.group(0) ?? jsonStr;
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      final observation = json['observation']?.toString() ?? '';
      final suggestion = json['suggestion']?.toString() ?? '';
      final motivation = json['motivation']?.toString() ?? '';
      
      if (observation.isEmpty || suggestion.isEmpty || motivation.isEmpty) {
        return null;
      }
      
      return SpendingAnalysis(
        observation: observation,
        suggestion: suggestion,
        motivation: motivation,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Spending analysis parse error: $e');
        debugPrint('[LocalLLM] Raw response: $response');
      }
      return null;
    }
  }

  /// Генерирует саммари для родителей о прогрессе ребёнка
  /// 
  /// [ctx] - контекст пользователя
  /// [startDate] - начало периода
  /// [endDate] - конец периода
  /// [locale] - язык
  /// [additionalData] - дополнительные данные (доходы, расходы, статистика)
  Future<String?> generateParentSummary(
    BariContext ctx,
    DateTime startDate,
    DateTime endDate,
    String locale, {
    Map<String, dynamic>? additionalData,
  }) async {
    // Проверяем доступность модели
    if (!await _checkModelAvailable()) {
      return null;
    }

    // Инициализируем движок если нужно
    if (!_engine.isInitialized || !_sessionInitialized) {
      final systemPrompt = _buildSystemPrompt(locale, ctx);
      final initialized = await _engine.initialize(_loadedModelPath!, systemPrompt);
      if (!initialized) {
        return null;
      }
      _sessionInitialized = true;
    }

    try {
      final prompt = _buildSummaryPrompt(ctx, startDate, endDate, locale, additionalData);
      final response = await _engine.generate(
        prompt,
        maxTokens: 600,
      );
      
      if (response == null || response.isEmpty) {
        return null;
      }

      // Убираем JSON обёртку если есть
      String summary = response.trim();
      if (summary.contains('```')) {
        final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(summary);
        if (jsonMatch != null) {
          summary = jsonMatch.group(1)?.trim() ?? summary;
        }
      }
      
      // Пытаемся извлечь текст из JSON если ответ в формате JSON
      try {
        final json = jsonDecode(summary) as Map<String, dynamic>;
        summary = json['summary']?.toString() ?? 
                 json['text']?.toString() ?? 
                 summary;
      } catch (e) {
        // Не JSON, используем как есть
      }
      
      return summary;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LocalLLM] Error generating parent summary: $e');
      }
      return null;
    }
  }

  /// Строит промпт для генерации саммари
  String _buildSummaryPrompt(
    BariContext ctx,
    DateTime startDate,
    DateTime endDate,
    String locale,
    Map<String, dynamic>? additionalData,
  ) {
    final balance = (ctx.walletBalanceCents / 100).toStringAsFixed(2);
    final totalSaved = (ctx.totalPiggyBanksSaved / 100).toStringAsFixed(2);
    final currency = ctx.currencyCode;
    final symbol = _getCurrencySymbol(currency);
    final level = ctx.playerLevel;
    final xp = ctx.playerXp;
    final lessonsCompleted = ctx.lessonsCompleted;
    final piggyCount = ctx.piggyBanksCount;
    
    final totalIncome = additionalData?['totalIncome'] as int? ?? 0;
    final totalExpense = additionalData?['totalExpense'] as int? ?? 0;
    final completedPlans = additionalData?['completedPlans'] as int? ?? 0;
    final totalPlans = additionalData?['totalPlans'] as int? ?? 0;
    final streak = additionalData?['streak'] as int? ?? 0;
    final selfControlScore = additionalData?['selfControlScore'] as int? ?? 50;
    
    final incomeFormatted = (totalIncome / 100).toStringAsFixed(2);
    final expenseFormatted = (totalExpense / 100).toStringAsFixed(2);
    
    final period = '${startDate.toString().substring(0, 10)} - ${endDate.toString().substring(0, 10)}';

    final prompts = {
      'ru': '''
Создай краткий дружелюбный отчёт для родителей о прогрессе ребёнка в приложении Bary3.

ПЕРИОД: $period

ДАННЫЕ:
- Баланс: $balance$symbol
- В копилках: $totalSaved$symbol ($piggyCount копилок)
- Уровень: $level (XP: $xp)
- Уроков пройдено: $lessonsCompleted
- Общий доход: $incomeFormatted$symbol
- Общий расход: $expenseFormatted$symbol
- Запланировано событий: $totalPlans (выполнено: $completedPlans)
- Серия дней: $streak
- Самоконтроль: $selfControlScore/100

Создай дружелюбный отчёт (3-4 предложения):
1. Что хорошо получается
2. На что обратить внимание
3. Мотивирующее завершение

Формат: обычный текст, без JSON. Обращайся к родителям на "вы".
''',
      'en': '''
Create a brief friendly report for parents about the child's progress in the Bary3 app.

PERIOD: $period

DATA:
- Balance: $balance$symbol
- In piggy banks: $totalSaved$symbol ($piggyCount banks)
- Level: $level (XP: $xp)
- Lessons completed: $lessonsCompleted
- Total income: $incomeFormatted$symbol
- Total expense: $expenseFormatted$symbol
- Planned events: $totalPlans (completed: $completedPlans)
- Streak days: $streak
- Self-control: $selfControlScore/100

Create a friendly report (3-4 sentences):
1. What's going well
2. What to pay attention to
3. Motivational closing

Format: plain text, no JSON. Address parents as "you".
''',
      'de': '''
Erstelle einen kurzen freundlichen Bericht für Eltern über den Fortschritt des Kindes in der Bary3-App.

ZEITRAUM: $period

DATEN:
- Kontostand: $balance$symbol
- In Sparschweinen: $totalSaved$symbol ($piggyCount Sparschweine)
- Level: $level (XP: $xp)
- Abgeschlossene Lektionen: $lessonsCompleted
- Gesamteinnahmen: $incomeFormatted$symbol
- Gesamtausgaben: $expenseFormatted$symbol
- Geplante Ereignisse: $totalPlans (abgeschlossen: $completedPlans)
- Serientage: $streak
- Selbstkontrolle: $selfControlScore/100

Erstelle einen freundlichen Bericht (3-4 Sätze):
1. Was gut läuft
2. Worauf zu achten ist
3. Motivierender Abschluss

Format: Klartext, kein JSON. Sprechen Sie die Eltern mit "Sie" an.
''',
    };
    
    return prompts[locale] ?? prompts['ru']!;
  }

  /// Сбрасывает инициализацию (например, при изменении языка)
  Future<void> reset() async {
    _sessionInitialized = false;
    await _engine.dispose();
  }
}
