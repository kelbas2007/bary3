import 'package:flutter/services.dart';

/// Утилита для haptic feedback
class HapticFeedbackUtil {
  /// Легкая вибрация для обычных действий
  static Future<void> lightImpact() async {
    HapticFeedback.lightImpact();
  }

  /// Средняя вибрация для важных действий
  static Future<void> mediumImpact() async {
    HapticFeedback.mediumImpact();
  }

  /// Сильная вибрация для критических действий
  static Future<void> heavyImpact() async {
    HapticFeedback.heavyImpact();
  }

  /// Вибрация для выбора
  static Future<void> selection() async {
    HapticFeedback.selectionClick();
  }

  /// Вибрация для успешного действия
  static Future<void> success() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.lightImpact();
  }

  /// Вибрация для ошибки
  static Future<void> error() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Вибрация для предупреждения
  static Future<void> warning() async {
    HapticFeedback.mediumImpact();
  }
}
