import 'dart:io';
import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';
import 'system_assistant_provider.dart';

class FallbackProvider implements BariProvider {
  final SystemAssistantProvider? systemAssistant;
  
  FallbackProvider({this.systemAssistant});
  
  /// Извлекает язык из localeTag (ru_RU -> ru)
  String _extractLocale(String localeTag) {
    if (localeTag.startsWith('ru')) return 'ru';
    if (localeTag.startsWith('en')) return 'en';
    if (localeTag.startsWith('de')) return 'de';
    return 'ru'; // fallback
  }

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    final locale = _extractLocale(ctx.localeTag);
    
    // Сначала пробуем системный ассистент, если доступен
    if (systemAssistant != null) {
      final systemRes = await systemAssistant!.tryRespond(message, ctx);
      if (systemRes != null && systemRes.confidence > 0.6) {
        return systemRes;
      }
    }
    
    // Если системный ассистент не помог, возвращаем стандартный ответ
    final responses = _getResponses(locale);
    
    // Добавляем действие для запроса у системного ассистента
    final assistantName = Platform.isAndroid ? 'Google Assistant' : 'Siri';
    
    return BariResponse(
      meaning: responses.meaning,
      advice: '${responses.advice}\n\nИли спроси у $assistantName через системный ассистент.',
      actions: [
        ...responses.actions,
        BariAction(
          type: BariActionType.showMore,
          label: 'Спросить у $assistantName',
          payload: 'system_assistant',
        ),
      ],
      confidence: responses.confidence,
    );
  }

  BariResponse _getResponses(String locale) {
    final responses = {
      'ru': const BariResponse(
        meaning: 'Я не уверен, что ты имеешь в виду.',
        advice: 'Попробуй спросить короче: "инфляция", "можно ли купить", "почему копилка не в балансе".',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Баланс', payload: 'balance'),
          BariAction(type: BariActionType.openScreen, label: 'Копилки', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Калькуляторы', payload: 'calculators'),
          BariAction(type: BariActionType.explainSimpler, label: 'Объясни проще'),
        ],
        confidence: 0.45,
      ),
      'en': const BariResponse(
        meaning: 'I\'m not sure what you mean.',
        advice: 'Try asking shorter: "inflation", "can I buy", "why piggy bank not in balance".',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Balance', payload: 'balance'),
          BariAction(type: BariActionType.openScreen, label: 'Piggy Banks', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Calculators', payload: 'calculators'),
          BariAction(type: BariActionType.explainSimpler, label: 'Explain simpler'),
        ],
        confidence: 0.45,
      ),
      'de': const BariResponse(
        meaning: 'Ich bin mir nicht sicher, was du meinst.',
        advice: 'Versuche kürzer zu fragen: "Inflation", "kann ich kaufen", "warum Sparschwein nicht im Kontostand".',
        actions: [
          BariAction(type: BariActionType.openScreen, label: 'Kontostand', payload: 'balance'),
          BariAction(type: BariActionType.openScreen, label: 'Sparschweine', payload: 'piggy_banks'),
          BariAction(type: BariActionType.openScreen, label: 'Rechner', payload: 'calculators'),
          BariAction(type: BariActionType.explainSimpler, label: 'Einfacher erklären'),
        ],
        confidence: 0.45,
      ),
    };
    return responses[locale] ?? responses['ru']!;
  }
}






