import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сообщение в истории чата
class ChatMessage {
  final String userMessage;
  final String assistantResponse;
  final DateTime timestamp;

  ChatMessage({
    required this.userMessage,
    required this.assistantResponse,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'userMessage': userMessage,
        'assistantResponse': assistantResponse,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        userMessage: json['userMessage'] as String,
        assistantResponse: json['assistantResponse'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// Сервис для управления историей диалогов с Bari Smart
class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  static const String _keyChatHistory = 'chat_history';
  static const int _maxHistorySize = 20; // Максимум сообщений в истории

  List<ChatMessage> _history = [];
  bool _loaded = false;

  /// Загружает историю из хранилища
  Future<void> loadFromStorage() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyChatHistory);
      
      if (json == null) {
        _history = [];
        _loaded = true;
        return;
      }

      final List<dynamic> decoded = jsonDecode(json);
      _history = decoded
          .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
          .toList();
      
      // Ограничиваем размер истории
      if (_history.length > _maxHistorySize) {
        _history = _history.sublist(_history.length - _maxHistorySize);
      }
      
      _loaded = true;
    } catch (e) {
      debugPrint('[ChatHistoryService] Error loading history: $e');
      _history = [];
      _loaded = true;
    }
  }

  /// Сохраняет историю в хранилище
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_history.map((m) => m.toJson()).toList());
      await prefs.setString(_keyChatHistory, json);
    } catch (e) {
      debugPrint('[ChatHistoryService] Error saving history: $e');
    }
  }

  /// Добавляет сообщение в историю
  Future<void> addMessage(String userMessage, String assistantResponse) async {
    await loadFromStorage();
    
    _history.add(ChatMessage(
      userMessage: userMessage,
      assistantResponse: assistantResponse,
      timestamp: DateTime.now(),
    ));

    // Ограничиваем размер истории
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }

    await saveToStorage();
  }

  /// Получает последние N сообщений
  List<ChatMessage> getRecentHistory(int count) {
    if (!_loaded) {
      debugPrint('[ChatHistoryService] History not loaded yet');
      return [];
    }
    
    if (_history.length <= count) {
      return List.from(_history);
    }
    
    return _history.sublist(_history.length - count);
  }

  /// Получает все сообщения
  List<ChatMessage> getAllHistory() {
    if (!_loaded) {
      debugPrint('[ChatHistoryService] History not loaded yet');
      return [];
    }
    return List.from(_history);
  }

  /// Очищает историю
  Future<void> clearHistory() async {
    _history = [];
    await saveToStorage();
  }

  /// Форматирует историю для AI промпта
  String formatHistoryForPrompt(String locale, {int maxMessages = 5}) {
    if (!_loaded || _history.isEmpty) {
      return locale == 'ru' ? 'Нет предыдущих сообщений'
           : locale == 'en' ? 'No previous messages'
           : 'Keine vorherigen Nachrichten';
    }

    final recent = getRecentHistory(maxMessages);
    final lines = recent.map((msg) {
      final user = locale == 'ru' ? 'Пользователь' 
                 : locale == 'en' ? 'User'
                 : 'Benutzer';
      final assistant = locale == 'ru' ? 'Бари'
                     : locale == 'en' ? 'Bari'
                     : 'Bari';
      
      return '$user: ${msg.userMessage}\n$assistant: ${msg.assistantResponse}';
    }).join('\n\n');

    return locale == 'ru' 
        ? 'Предыдущий диалог:\n$lines'
        : locale == 'en'
        ? 'Previous conversation:\n$lines'
        : 'Vorheriges Gespräch:\n$lines';
  }

  /// Получает количество сообщений в истории
  int get historyLength => _loaded ? _history.length : 0;
}
