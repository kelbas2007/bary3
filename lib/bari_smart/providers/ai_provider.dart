import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

/// AI Provider that uses OpenAI API (or compatible) for intelligent responses
class AiProvider implements BariProvider {
  final String? apiKey;
  final String baseUrl;
  final String model;
  final bool enabled;
  final Duration timeout;

  AiProvider({
    this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-4o-mini', // Cheaper and faster, good for kids app
    this.enabled = true,
    this.timeout = const Duration(seconds: 30),
  });

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    if (!enabled || apiKey == null || apiKey!.isEmpty) {
      if (kDebugMode) {
        debugPrint('[AiProvider] disabled or no API key');
      }
      return null;
    }

    try {
      final systemPrompt = _buildSystemPrompt(ctx);
      final userMessage = _buildUserMessage(message, ctx);

      if (kDebugMode) {
        debugPrint('[AiProvider] Sending request to $baseUrl');
        debugPrint('[AiProvider] Model: $model');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      ).timeout(timeout);

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('[AiProvider] Error: ${response.statusCode} ${response.body}');
        }
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = json['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;

      final content = choices[0]['message']['content'] as String? ?? '';
      if (content.isEmpty) return null;

      // Parse the structured response
      return _parseAiResponse(content, message);
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[AiProvider] Exception: $e');
        debugPrint('[AiProvider] Stack: $stack');
      }
      return null;
    }
  }

  String _buildSystemPrompt(BariContext ctx) {
    final currency = ctx.currencyCode;
    final balance = (ctx.walletBalanceCents / 100).toStringAsFixed(2);
    final piggyTotal = (ctx.totalPiggyBanksSaved / 100).toStringAsFixed(2);
    final piggyCount = ctx.piggyBanksCount;
    final level = ctx.playerLevel;
    final xp = ctx.playerXp;
    final screen = ctx.currentScreenId ?? 'balance';
    
    return '''
Ты Бари — дружелюбный финансовый помощник для детей и подростков 8-16 лет в приложении BargeldKids.

ВАЖНЫЕ ПРАВИЛА:
1. Отвечай ТОЛЬКО на русском языке
2. Объясняй простым языком, как будто объясняешь ребёнку
3. Используй примеры из жизни подростка (карманные деньги, игры, сладости)
4. Будь позитивным и поддерживающим
5. Если вопрос НЕ связан с финансами, вежливо перенаправь к финансовым темам
6. Никогда не давай опасных советов (азартные игры, криптовалюты для детей и т.д.)
7. Ответ должен быть коротким — максимум 3-4 предложения

КОНТЕКСТ ПОЛЬЗОВАТЕЛЯ:
- Баланс кошелька: $balance $currency
- Всего в копилках: $piggyTotal $currency ($piggyCount копилок)
- Уровень игрока: $level (XP: $xp)
- Язык: ${ctx.localeTag}
- Текущий экран: $screen

ФОРМАТ ОТВЕТА:
Отвечай в формате JSON:
{
  "meaning": "Главная мысль или объяснение (1-2 предложения)",
  "advice": "Практический совет что делать (1 предложение)",
  "action": "balance|piggy_banks|calendar|lessons|calculators|null"
}

Поле "action" — куда можно направить пользователя (или null если не нужно).
''';
  }

  String _buildUserMessage(String message, BariContext ctx) {
    // Add extra context if available
    final extraContext = <String>[];
    
    if (ctx.upcomingEventsCount > 0) {
      extraContext.add('У пользователя ${ctx.upcomingEventsCount} запланированных событий');
    }
    
    if (ctx.lessonsCompletedCount > 0) {
      extraContext.add('Пройдено уроков: ${ctx.lessonsCompletedCount}');
    }

    if (extraContext.isNotEmpty) {
      return '$message\n\n[Дополнительный контекст: ${extraContext.join(", ")}]';
    }
    
    return message;
  }

  BariResponse _parseAiResponse(String content, String originalQuestion) {
    try {
      // Try to extract JSON from the response
      String jsonStr = content;
      
      // Handle markdown code blocks
      final jsonMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(content);
      if (jsonMatch != null) {
        jsonStr = jsonMatch.group(1)?.trim() ?? content;
      }
      
      // Try to find JSON object
      final jsonObjMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonStr);
      if (jsonObjMatch != null) {
        jsonStr = jsonObjMatch.group(0) ?? jsonStr;
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      final meaning = json['meaning']?.toString() ?? content;
      final advice = json['advice']?.toString();
      final actionTarget = json['action']?.toString();

      final actions = <BariAction>[
        const BariAction(
          type: BariActionType.explainSimpler,
          label: 'Объясни ещё проще',
        ),
      ];

      // Add navigation action if specified
      if (actionTarget != null && actionTarget != 'null') {
        String label;
        switch (actionTarget) {
          case 'balance':
            label = 'Баланс';
            break;
          case 'piggy_banks':
            label = 'Копилки';
            break;
          case 'calendar':
            label = 'Календарь';
            break;
          case 'lessons':
            label = 'Уроки';
            break;
          case 'calculators':
            label = 'Калькуляторы';
            break;
          default:
            label = actionTarget;
        }
        
        actions.insert(0, BariAction(
          type: BariActionType.openScreen,
          label: label,
          payload: actionTarget,
        ));
      }

      return BariResponse(
        meaning: meaning,
        advice: advice ?? 'Если что-то непонятно — спрашивай!',
        actions: actions,
        confidence: 0.95,
        sourceTitle: 'AI',
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AiProvider] JSON parse error: $e');
        debugPrint('[AiProvider] Raw content: $content');
      }
      
      // Fallback: use raw content as response
      return BariResponse(
        meaning: content.length > 300 ? '${content.substring(0, 300)}...' : content,
        advice: 'Спрашивай ещё — я помогу!',
        actions: const [
          BariAction(
            type: BariActionType.explainSimpler,
            label: 'Объясни проще',
          ),
        ],
        confidence: 0.85,
        sourceTitle: 'AI',
      );
    }
  }
}
