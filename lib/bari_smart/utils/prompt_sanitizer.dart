import 'dart:math';
import 'package:flutter/foundation.dart';

/// Санитизатор промптов для защиты от инъекций в LLM
///
/// Удаляет специальные символы и конструкции, которые могут сломать промпт
/// или привести к нежелательному поведению LLM
class PromptSanitizer {
  /// Основной метод санитизации промпта
  static String sanitize(String input) {
    if (input.isEmpty) return input;

    var sanitized = input;

    // 1. Удаляем специальные символы, которые могут сломать промпт
    sanitized = _removeDangerousSymbols(sanitized);

    // 2. Экранируем кавычки для предотвращения инъекций
    sanitized = _escapeQuotes(sanitized);

    // 3. Ограничиваем длину (предотвращаем слишком длинные промпты)
    sanitized = _limitLength(sanitized);

    // 4. Удаляем потенциально опасные паттерны
    sanitized = _removeDangerousPatterns(sanitized);

    // 5. Нормализуем пробелы (предотвращаем атаки через whitespace)
    sanitized = _normalizeWhitespace(sanitized);

    if (kDebugMode && sanitized != input) {
      debugPrint(
        '[PromptSanitizer] Sanitized input: ${input.length} -> ${sanitized.length} chars',
      );
    }

    return sanitized;
  }

  /// Санитизация с контекстом (учитывает тип контекста)
  static String sanitizeWithContext(String input, PromptContext context) {
    var sanitized = sanitize(input);

    // Дополнительная обработка в зависимости от контекста
    switch (context) {
      case PromptContext.financialAdvice:
        // Для финансовых советов удаляем личную информацию
        sanitized = _removePersonalInfo(sanitized);
        break;
      case PromptContext.systemCommand:
        // Для системных команд более строгая проверка
        sanitized = _validateSystemCommand(sanitized);
        break;
      case PromptContext.userChat:
        // Для чата с пользователем оставляем больше свободы
        sanitized = _preserveEmojis(sanitized);
        break;
      case PromptContext.codeGeneration:
        // Для генерации кода разрешаем специальные символы
        sanitized = _allowCodeSymbols(sanitized);
        break;
    }

    return sanitized;
  }

  /// Проверка безопасности промпта без изменения
  static SanitizationResult validate(String input) {
    final issues = <SanitizationIssue>[];

    // Проверяем наличие опасных символов
    final dangerousSymbols = _findDangerousSymbols(input);
    if (dangerousSymbols.isNotEmpty) {
      issues.add(
        SanitizationIssue(
          type: IssueType.dangerousSymbols,
          description:
              'Найдены опасные символы: ${dangerousSymbols.join(", ")}',
          severity: Severity.warning,
        ),
      );
    }

    // Проверяем длину
    if (input.length > 1000) {
      issues.add(
        SanitizationIssue(
          type: IssueType.excessiveLength,
          description: 'Промпт слишком длинный (${input.length} символов)',
          severity: Severity.warning,
        ),
      );
    }

    // Проверяем наличие потенциально опасных паттернов
    final dangerousPatterns = _findDangerousPatterns(input);
    if (dangerousPatterns.isNotEmpty) {
      issues.add(
        SanitizationIssue(
          type: IssueType.dangerousPattern,
          description:
              'Найдены опасные паттерны: ${dangerousPatterns.join(", ")}',
          severity: Severity.high,
        ),
      );
    }

    // Проверяем наличие личной информации
    final personalInfo = _findPersonalInfo(input);
    if (personalInfo.isNotEmpty) {
      issues.add(
        SanitizationIssue(
          type: IssueType.personalInfo,
          description: 'Обнаружена потенциальная личная информация',
          severity: Severity.medium,
        ),
      );
    }

    return SanitizationResult(
      isSafe: issues.isEmpty || issues.every((i) => i.severity == Severity.low),
      issues: issues,
      sanitizedVersion: issues.isNotEmpty ? sanitize(input) : input,
    );
  }

  // Приватные методы санитизации

  static String _removeDangerousSymbols(String input) {
    // Удаляем символы, которые могут сломать JSON или промпт
    final dangerousPattern = RegExp(r'[{}\[\]\\<>]');
    return input.replaceAll(dangerousPattern, '');
  }

  static String _escapeQuotes(String input) {
    // Экранируем кавычки, но сохраняем их для читаемости
    return input.replaceAll('"', '\\"').replaceAll("'", "\\'");
  }

  static String _limitLength(String input) {
    const maxLength = 2000;
    if (input.length <= maxLength) return input;

    // Обрезаем, но стараемся сохранить целостность предложений
    final trimmed = input.substring(0, maxLength);
    final lastSentenceEnd = _findLastSentenceEnd(trimmed);

    return lastSentenceEnd > 100
        ? trimmed.substring(0, lastSentenceEnd)
        : trimmed;
  }

  static String _removeDangerousPatterns(String input) {
    var result = input;

    // Удаляем попытки инъекций команд
    final commandPattern = RegExp(
      r'(system|exec|eval|run|command|script)\\s*[:=]',
      caseSensitive: false,
    );
    result = result.replaceAll(commandPattern, '');

    // Удаляем попытки многострочных инъекций
    final multilinePattern = RegExp(r'```.*?```', dotAll: true);
    result = result.replaceAll(multilinePattern, '');

    return result;
  }

  static String _normalizeWhitespace(String input) {
    // Заменяем множественные пробелы на один
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _removePersonalInfo(String input) {
    // Простая эвристика для обнаружения личной информации
    final personalPatterns = [
      RegExp(r'\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b'), // Номер карты
      RegExp(r'\b\d{3}[- ]?\d{3}[- ]?\d{3}\b'), // Номер телефона
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email
    ];

    var result = input;
    for (final pattern in personalPatterns) {
      result = result.replaceAll(pattern, '[СКРЫТО]');
    }

    return result;
  }

  static String _validateSystemCommand(String input) {
    // Разрешаем только безопасные команды
    final allowedCommands = [
      'help',
      'справка',
      'info',
      'информация',
      'settings',
      'настройки',
      'config',
      'конфиг',
    ];

    final lowerInput = input.toLowerCase();
    final isAllowed = allowedCommands.any((cmd) => lowerInput.contains(cmd));

    return isAllowed ? input : '';
  }

  static String _preserveEmojis(String input) {
    // Сохраняем эмодзи для чата
    final emojiPattern = RegExp(
      r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}]',
      unicode: true,
    );

    // Удаляем опасные символы, но сохраняем эмодзи
    final dangerousPattern = RegExp(r'[{}\[\]\\<>]');
    return input.replaceAllMapped(dangerousPattern, (match) {
      // Проверяем, не является ли это частью эмодзи
      final context = match.input.substring(
        max(0, match.start - 2),
        min(match.input.length, match.end + 2),
      );

      return emojiPattern.hasMatch(context) ? match.group(0)! : '';
    });
  }

  static String _allowCodeSymbols(String input) {
    // Для генерации кода разрешаем специальные символы
    // но все равно удаляем опасные конструкции
    final dangerousConstructs = RegExp(
      r'(system\(|exec\(|eval\()',
      caseSensitive: false,
    );
    return input.replaceAll(dangerousConstructs, '');
  }

  // Вспомогательные методы

  static int _findLastSentenceEnd(String text) {
    final sentenceEnders = ['.', '!', '?', '。', '！', '？'];

    for (int i = text.length - 1; i >= 0; i--) {
      if (sentenceEnders.contains(text[i])) {
        return i + 1;
      }
    }

    return text.length;
  }

  static List<String> _findDangerousSymbols(String input) {
    final dangerous = <String>[];
    final pattern = RegExp(r'[{}\[\]\\<>]');

    final matches = pattern.allMatches(input);
    for (final match in matches) {
      dangerous.add(match.group(0)!);
    }

    return dangerous.toSet().toList();
  }

  static List<String> _findDangerousPatterns(String input) {
    final patterns = <String>[];

    // Проверяем на инъекции команд
    final commandPattern = RegExp(
      r'(system|exec|eval|run)\(.*?\)',
      caseSensitive: false,
    );
    if (commandPattern.hasMatch(input)) {
      patterns.add('command_injection');
    }

    // Проверяем на попытки многострочных инъекций
    final multilinePattern = RegExp(r'```.*?```', dotAll: true);
    if (multilinePattern.hasMatch(input)) {
      patterns.add('multiline_injection');
    }

    return patterns;
  }

  static List<String> _findPersonalInfo(String input) {
    final info = <String>[];

    // Проверяем номер карты
    final cardPattern = RegExp(r'\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?\d{4}\b');
    if (cardPattern.hasMatch(input)) {
      info.add('credit_card');
    }

    // Проверяем email
    final emailPattern = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    );
    if (emailPattern.hasMatch(input)) {
      info.add('email');
    }

    return info;
  }
}

/// Контекст промпта для адаптивной санитизации
enum PromptContext {
  financialAdvice, // Финансовые советы
  systemCommand, // Системные команды
  userChat, // Чат с пользователем
  codeGeneration, // Генерация кода
}

/// Результат валидации промпта
class SanitizationResult {
  final bool isSafe;
  final List<SanitizationIssue> issues;
  final String sanitizedVersion;

  SanitizationResult({
    required this.isSafe,
    required this.issues,
    required this.sanitizedVersion,
  });

  /// Проверяет, есть ли критические проблемы
  bool get hasCriticalIssues =>
      issues.any((issue) => issue.severity == Severity.high);

  /// Получает сводку проблем
  String get summary {
    if (issues.isEmpty) return 'Промпт безопасен';

    final critical = issues.where((i) => i.severity == Severity.high).length;
    final warningCount = issues
        .where((i) => i.severity == Severity.warning)
        .length;

    return 'Найдено проблем: $critical критических, $warningCount предупреждений';
  }
}

/// Проблема санитизации
class SanitizationIssue {
  final IssueType type;
  final String description;
  final Severity severity;

  SanitizationIssue({
    required this.type,
    required this.description,
    required this.severity,
  });

  @override
  String toString() => '[${severity.name.toUpperCase()}] $type: $description';
}

/// Тип проблемы
enum IssueType {
  dangerousSymbols, // Опасные символы
  dangerousPattern, // Опасные паттерны
  excessiveLength, // Чрезмерная длина
  personalInfo, // Личная информация
  other, // Другие проблемы
}

/// Уровень серьезности
enum Severity {
  low, // Низкая (информация)
  medium, // Средняя (предупреждение)
  high, // Высокая (опасность)
  warning, // Предупреждение (устаревшее, используйте medium)
}

// Для совместимости
extension SeverityExtension on Severity {
  String get name {
    switch (this) {
      case Severity.low:
        return 'low';
      case Severity.medium:
        return 'medium';
      case Severity.high:
        return 'high';
      case Severity.warning:
        return 'warning';
    }
  }
}
