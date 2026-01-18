import 'bari_context.dart';
import 'bari_models.dart';
import 'bari_intent.dart';
import 'providers/bari_provider.dart';
import 'providers/small_talk_provider.dart';
import 'providers/app_help_provider.dart';
import 'providers/app_features_provider.dart';
import 'providers/finance_coach_provider.dart';
import 'providers/smart_math_provider.dart';
import 'providers/goal_advisor_provider.dart';
import 'providers/spending_rules_provider.dart';
import 'providers/context_aware_provider.dart';
import 'providers/knowledge_pack_provider.dart';
import 'providers/online_reference_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/gemini_nano_provider.dart';
import 'providers/fallback_provider.dart';
import 'providers/system_assistant_provider.dart';
import 'storage/bari_settings_store.dart';
import 'package:flutter/foundation.dart';

class BariSmart {
  BariSmart._();
  static final instance = BariSmart._();

  late final BariSettingsStore settings;
  late final KnowledgePackProvider knowledge;
  late final GeminiNanoProvider geminiNano;
  // NOTE: Gemini Nano SDK пока не доступен публично.
  // Когда SDK станет доступен, раскомментировать строку ниже и использовать локальную модель.
  // final GeminiNanoService _geminiNanoService = GeminiNanoService();

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    settings = BariSettingsStore();
    await settings.load();
    knowledge = KnowledgePackProvider();
    await knowledge.init(); // loads assets/bari_knowledge/ru.json
    geminiNano = GeminiNanoProvider();
    _inited = true;
  }

  Future<BariResponse> respond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    await init();

    // Настройки могли измениться в SettingsScreen после инициализации.
    // Перечитываем перед каждым ответом, чтобы Online/Hybrid/AI режим работал без перезапуска.
    await settings.load();

    final text = message.trim();
    if (text.isEmpty) {
      return const BariResponse(
        meaning: 'Напиши вопрос 🙂',
        advice: 'Например: "можно ли купить за 20€" или "что такое инфляция"',
        actions: [
          BariAction(
            type: BariActionType.openScreen,
            label: 'Баланс',
            payload: 'balance',
          ),
          BariAction(
            type: BariActionType.openScreen,
            label: 'Копилки',
            payload: 'piggy_banks',
          ),
        ],
        confidence: 0.4,
      );
    }

    // Определяем intent для оптимизации порядка провайдеров
    final intent = BariIntentDetector.detect(text);

    if (kDebugMode) {
      debugPrint(
        '[BariSmart] mode=${settings.mode.name} aiEnabled=${settings.aiEnabled} onlineEnabled=${settings.onlineEnabled} forceOnline=$forceOnline intent=$intent msg="$text"',
      );
    }

    // === AI MODE: Если включён AI, сначала пробуем его ===
    if (settings.mode == BariMode.ai && settings.aiEnabled) {
      if (kDebugMode) {
        debugPrint('[BariSmart] Trying AiProvider (model=${settings.aiModel})');
      }

      final aiProvider = AiProvider(
        apiKey: settings.aiApiKey,
        baseUrl: settings.aiBaseUrl,
        model: settings.aiModel,
      );

      final aiRes = await aiProvider.tryRespond(text, ctx, forceOnline: true);
      if (aiRes != null) {
        if (kDebugMode) {
          debugPrint('[BariSmart] AiProvider ответил (confidence=${aiRes.confidence})');
        }
        return aiRes;
      }
      if (kDebugMode) {
        debugPrint('[BariSmart] AiProvider не дал ответа, fallback to offline');
      }
    }

    // Офлайн провайдеры (всегда доступны как fallback)
    // Порядок важен: от более специфичных к более общим
    final offlineProviders = <BariProvider>[
      SmallTalkProvider(settings: settings),  // Приветствия, болтовня
      AppFeaturesProvider(),                  // Знание всех функций приложения
      SmartMathProvider(),                     // Расчёты: %, умножение, прогнозы
      GoalAdvisorProvider(),                   // Персональные советы по копилкам
      SpendingRulesProvider(),                 // Rule-based анализ трат
      ContextAwareProvider(),                  // Умные ответы на основе контекста
      FinanceCoachProvider(),                  // Финансовые вопросы
      AppHelpProvider(),                       // Помощь по приложению
      knowledge,                               // База знаний
    ];

    // Пробуем офлайн провайдеры
    for (final p in offlineProviders) {
      final r = await p.tryRespond(text, ctx);
      if (r != null && r.confidence > 0.7) return r;
    }

    // TIER 2: Gemini Nano (on-device AI)
    // Пока отключено, так как SDK не доступен публично
    // Включить, когда появится реальный ML Kit GenAI SDK
    // final geminiNanoEnabled = await StorageService.getGeminiNanoEnabled();
    // if (geminiNanoEnabled) {
    //   final geminiNanoAvailable = await _geminiNanoService.checkAvailability();
    //   final geminiNanoDownloaded = await _geminiNanoService.checkDownloaded();
    //   
    //   if (geminiNanoAvailable && geminiNanoDownloaded) {
    //     if (kDebugMode) {
    //       debugPrint('[BariSmart] Trying GeminiNanoProvider');
    //     }
    //     
    //     final nanoRes = await geminiNano.tryRespond(text, ctx);
    //     if (nanoRes != null) {
    //       if (kDebugMode) {
    //         debugPrint('[BariSmart] GeminiNanoProvider ответил (confidence=${nanoRes.confidence})');
    //       }
    //       return nanoRes;
    //     }
    //     if (kDebugMode) {
    //       debugPrint('[BariSmart] GeminiNanoProvider не дал ответа');
    //     }
    //   }
    // }

    // Если hybrid или online режим, пробуем онлайн (Wikipedia, DuckDuckGo)
    final shouldTryOnline =
        forceOnline ||
        settings.mode == BariMode.online ||
        (settings.mode == BariMode.hybrid &&
            intent == BariIntent.onlineReference);

    if (shouldTryOnline && settings.onlineEnabled) {
      if (kDebugMode) {
        debugPrint(
          '[BariSmart] Trying OnlineReferenceProvider (shouldTryOnline=$shouldTryOnline)',
        );
      }

      // В hybrid-режиме OnlineReferenceProvider настроен как manualOnly.
      // Для интента onlineReference считаем это явным запросом справки и форсируем онлайн.
      final effectiveForceOnline =
          forceOnline ||
          (settings.mode == BariMode.hybrid &&
              intent == BariIntent.onlineReference);
      final onlineProvider = OnlineReferenceProvider(
        enabled: settings.onlineEnabled,
        showSources: settings.showSources,
        manualOnly:
            settings.mode == BariMode.hybrid, // В hybrid только по запросу
      );

      final onlineRes = await onlineProvider.tryRespond(
        text,
        ctx,
        forceOnline: effectiveForceOnline,
      );
      if (onlineRes != null) {
        if (kDebugMode) {
          debugPrint(
            '[BariSmart] OnlineReferenceProvider ответил (confidence=${onlineRes.confidence})',
          );
        }
        return onlineRes;
      }
      if (kDebugMode) {
        debugPrint('[BariSmart] OnlineReferenceProvider не дал ответа');
      }
    }

    // === SYSTEM ASSISTANT: Используем встроенный ассистент как fallback ===
    // Если все провайдеры не дали хорошего ответа или это общий вопрос
    // Создаем один экземпляр для переиспользования
    final systemAssistantProvider = settings.useSystemAssistant
        ? SystemAssistantProvider(
            enabled: settings.useSystemAssistant,
          )
        : null;
    
    if (systemAssistantProvider != null) {
      if (kDebugMode) {
        debugPrint('[BariSmart] Trying SystemAssistantProvider');
      }
      
      final systemRes = await systemAssistantProvider.tryRespond(
        text,
        ctx,
      );
      
      if (systemRes != null) {
        if (kDebugMode) {
          debugPrint('[BariSmart] SystemAssistantProvider ответил (confidence=${systemRes.confidence})');
        }
        return systemRes;
      }
      if (kDebugMode) {
        debugPrint('[BariSmart] SystemAssistantProvider не дал ответа');
      }
    }

    // Fallback всегда последний
    // Передаем системный ассистент в FallbackProvider для финальной попытки
    final fallback = FallbackProvider(systemAssistant: systemAssistantProvider);
      final fallbackRes = await fallback.tryRespond(
      text,
      ctx,
    );
    if (fallbackRes != null) return fallbackRes;

    // На всякий случай (FallbackProvider должен всегда вернуть ответ):
    return const BariResponse(
      meaning: 'Я не уверен, что ты имеешь в виду.',
      advice:
          'Попробуй спросить короче: "инфляция", "можно ли купить", "почему копилка не в балансе".',
      actions: [
        BariAction(
          type: BariActionType.openScreen,
          label: 'Баланс',
          payload: 'balance',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Копилки',
          payload: 'piggy_banks',
        ),
        BariAction(
          type: BariActionType.openScreen,
          label: 'Калькуляторы',
          payload: 'calculators',
        ),
        BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
      ],
      confidence: 0.45,
    );
  }
}
