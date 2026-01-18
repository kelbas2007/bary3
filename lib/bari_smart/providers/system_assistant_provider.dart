import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../bari_context.dart';
import '../bari_models.dart';
import 'bari_provider.dart';

/// Провайдер, который делегирует запросы системному ассистенту
/// (Google Assistant на Android, Siri на iOS)
class SystemAssistantProvider implements BariProvider {
  static const MethodChannel _channel = MethodChannel('com.bary3/system_assistant');
  
  final bool enabled;
  final double minConfidenceThreshold;
  
  SystemAssistantProvider({
    this.enabled = true,
    this.minConfidenceThreshold = 0.5,
  });

  @override
  Future<BariResponse?> tryRespond(
    String message,
    BariContext ctx, {
    bool forceOnline = false,
  }) async {
    if (!enabled) return null;
    
    final shouldDelegate = _shouldDelegateToSystemAssistant(message, ctx);
    if (!shouldDelegate && !forceOnline) return null;
    
    try {
      if (kDebugMode) {
        debugPrint('[SystemAssistantProvider] Delegating to system assistant: "$message"');
      }
      
      final response = await _querySystemAssistant(message, ctx);
      
      if (response != null) {
        return BariResponse(
          meaning: response['meaning'] ?? message,
          advice: response['advice'] ?? 'Попробуй спросить по-другому.',
          actions: _parseActions(response['actions']),
          confidence: (response['confidence'] as num?)?.toDouble() ?? 0.7,
          sourceTitle: response['source'] ?? (Platform.isAndroid ? 'Google Assistant' : 'Siri'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SystemAssistantProvider] Error: $e');
      }
    }
    
    return null;
  }
  
  bool _shouldDelegateToSystemAssistant(String message, BariContext ctx) {
    final lower = message.toLowerCase();
    
    // Не делегируем вопросы, связанные с приложением и финансами
    final appKeywords = [
      'копилк', 'деньг', 'рубл', 'евро', 'доллар',
      'транзакц', 'расход', 'доход', 'потратил', 'заработал',
      'инфляц', 'процент', 'накоп', 'цель', 'бюджет',
      'кошелёк', 'сбережен', 'планирован', 'событи',
      'бари', 'приложен', 'экран', 'калькулятор',
    ];
    
    // Если вопрос связан с приложением, не делегируем
    if (appKeywords.any((keyword) => lower.contains(keyword))) {
      return false;
    }
    
    // Делегируем общие вопросы, не связанные с приложением
    final generalQuestionPatterns = [
      'что такое', 'кто такой', 'когда', 'где', 'почему',
      'как работает', 'объясни', 'расскажи про',
      'сколько будет', 'вычисли', 'посчитай',
      'что значит', 'определение', 'что это',
      'кто изобрёл', 'история', 'когда появился',
    ];
    
    return generalQuestionPatterns.any((pattern) => lower.contains(pattern));
  }
  
  Future<Map<String, dynamic>?> _querySystemAssistant(
    String message,
    BariContext ctx,
  ) async {
    try {
      if (Platform.isAndroid) {
        return await _queryGoogleAssistant(message, ctx);
      } else if (Platform.isIOS) {
        return await _querySiri(message, ctx);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SystemAssistantProvider] Platform query error: $e');
      }
    }
    
    return null;
  }
  
  Future<Map<String, dynamic>?> _queryGoogleAssistant(
    String message,
    BariContext ctx,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'queryGoogleAssistant',
        {
          'query': message,
          'locale': ctx.localeTag,
          'context': {
            'appName': 'Бари',
            'userId': ctx.currentScreenId,
          },
        },
      );
      
      if (result != null) {
        return {
          'meaning': result['response'] ?? message,
          'advice': result['suggestion'] ?? 'Попробуй уточнить вопрос.',
          'confidence': (result['confidence'] as num?)?.toDouble() ?? 0.7,
          'source': 'Google Assistant',
          'actions': result['actions'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SystemAssistantProvider] Google Assistant error: $e');
      }
    }
    
    return null;
  }
  
  Future<Map<String, dynamic>?> _querySiri(
    String message,
    BariContext ctx,
  ) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'querySiri',
        {
          'query': message,
          'locale': ctx.localeTag,
        },
      );
      
      if (result != null) {
        return {
          'meaning': result['response'] ?? message,
          'advice': result['suggestion'] ?? 'Попробуй уточнить вопрос.',
          'confidence': (result['confidence'] as num?)?.toDouble() ?? 0.7,
          'source': 'Siri',
          'actions': result['actions'],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SystemAssistantProvider] Siri error: $e');
      }
    }
    
    return null;
  }
  
  List<BariAction> _parseActions(dynamic actionsData) {
    if (actionsData == null) return [];
    
    try {
      if (actionsData is List) {
        return actionsData.map((action) {
          if (action is Map) {
            return BariAction(
              type: BariActionType.openScreen,
              label: (action['label'] ?? action['title'] ?? 'Действие') as String,
              payload: action['payload']?.toString(),
            );
          }
          return const BariAction(
            type: BariActionType.openScreen,
            label: 'Действие',
          );
        }).toList();
      } else if (actionsData is Map) {
        // Если actionsData - это Map, преобразуем в список
        return [
          BariAction(
            type: BariActionType.openScreen,
            label: (actionsData['label'] ?? actionsData['title'] ?? 'Действие') as String,
            payload: actionsData['payload']?.toString(),
          ),
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SystemAssistantProvider] Parse actions error: $e');
      }
    }
    
    return [];
  }
}
