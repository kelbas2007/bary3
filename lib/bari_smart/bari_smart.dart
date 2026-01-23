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
import 'providers/local_llm_provider.dart';
import 'providers/fallback_provider.dart';
import 'providers/system_assistant_provider.dart';
import 'storage/bari_settings_store.dart';
import 'utils/prompt_sanitizer.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class BariSmart {
  BariSmart._();
  static final instance = BariSmart._();

  late final BariSettingsStore settings;
  late final KnowledgePackProvider knowledge;
  late final LocalLLMProvider localLLM;

  bool _inited = false;

  Future<void> init() async {
    if (_inited) return;
    settings = BariSettingsStore();
    await settings.load();
    knowledge = KnowledgePackProvider();
    await knowledge.init(); // loads assets/bari_knowledge/ru.json
    localLLM = LocalLLMProvider();
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

    // Санитизация входящего сообщения для защиты от инъекций
    final sanitizedMessage = PromptSanitizer.sanitize(message);
    final text = sanitizedMessage.trim();

    // Валидация промпта для отладки
    if (kDebugMode) {
      final validation = PromptSanitizer.validate(text);
      if (!validation.isSafe) {
        debugPrint(
          '[BariSmart] Prompt validation issues: ${validation.summary}',
        );
      }
    }
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
        '[BariSmart] mode=${settings.mode.name} onlineEnabled=${settings.onlineEnabled} forceOnline=$forceOnline intent=$intent msg="$text"',
      );
    }

    // Офлайн провайдеры (всегда доступны как fallback)
    // Порядок важен: от более специфичных к более общим
    final offlineProviders = <BariProvider>[
      SmallTalkProvider(settings: settings), // Приветствия, болтовня
      AppFeaturesProvider(), // Знание всех функций приложения
      SmartMathProvider(), // Расчёты: %, умножение, прогнозы
      GoalAdvisorProvider(), // Персональные советы по копилкам
      SpendingRulesProvider(), // Rule-based анализ трат
      ContextAwareProvider(), // Умные ответы на основе контекста
      FinanceCoachProvider(), // Финансовые вопросы
      AppHelpProvider(), // Помощь по приложению
      knowledge, // База знаний
    ];

    // Пробуем офлайн провайдеры с timeout
    for (final p in offlineProviders) {
      try {
        final r = await p
            .tryRespond(text, ctx)
            .timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint('[BariSmart] Provider ${p.runtimeType} timeout');
                }
                return null;
              },
            );
        if (r != null && r.confidence > 0.7) return r;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BariSmart] Provider ${p.runtimeType} error: $e');
        }
        continue;
      }
    }

    // TIER 2: Local LLM (on-device AI через llama.cpp) с timeout
    if (kDebugMode) {
      debugPrint('[BariSmart] Trying LocalLLMProvider');
    }

    try {
      final localLLMRes = await localLLM
          .tryRespond(text, ctx)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('[BariSmart] LocalLLMProvider timeout (10s)');
              }
              return null;
            },
          );

      if (localLLMRes != null) {
        if (kDebugMode) {
          debugPrint(
            '[BariSmart] LocalLLMProvider ответил (confidence=${localLLMRes.confidence})',
          );
        }
        return localLLMRes;
      }
      if (kDebugMode) {
        debugPrint('[BariSmart] LocalLLMProvider не дал ответа');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BariSmart] LocalLLMProvider error: $e');
      }
    }

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

      try {
        final onlineRes = await onlineProvider
            .tryRespond(text, ctx, forceOnline: effectiveForceOnline)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '[BariSmart] OnlineReferenceProvider timeout (5s)',
                  );
                }
                return null;
              },
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
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BariSmart] OnlineReferenceProvider error: $e');
        }
      }
    }

    // === SYSTEM ASSISTANT: Используем встроенный ассистент как fallback ===
    // Если все провайдеры не дали хорошего ответа или это общий вопрос
    // Создаем один экземпляр для переиспользования
    final systemAssistantProvider = settings.useSystemAssistant
        ? SystemAssistantProvider(enabled: settings.useSystemAssistant)
        : null;

    if (systemAssistantProvider != null) {
      if (kDebugMode) {
        debugPrint('[BariSmart] Trying SystemAssistantProvider');
      }

      try {
        final systemRes = await systemAssistantProvider
            .tryRespond(text, ctx)
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint(
                    '[BariSmart] SystemAssistantProvider timeout (3s)',
                  );
                }
                return null;
              },
            );

        if (systemRes != null) {
          if (kDebugMode) {
            debugPrint(
              '[BariSmart] SystemAssistantProvider ответил (confidence=${systemRes.confidence})',
            );
          }
          return systemRes;
        }
        if (kDebugMode) {
          debugPrint('[BariSmart] SystemAssistantProvider не дал ответа');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BariSmart] SystemAssistantProvider error: $e');
        }
      }
    }

    // Fallback всегда последний
    // Передаем системный ассистент в FallbackProvider для финальной попытки
    final fallback = FallbackProvider(systemAssistant: systemAssistantProvider);
    try {
      final fallbackRes = await fallback
          .tryRespond(text, ctx)
          .timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('[BariSmart] FallbackProvider timeout (2s)');
              }
              return null;
            },
          );

      if (fallbackRes != null) return fallbackRes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BariSmart] FallbackProvider error: $e');
      }
    }

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
