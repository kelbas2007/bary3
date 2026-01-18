import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Утилиты для проверки контрастности цветов (WCAG)
class ColorContrast {
  /// Вычисляет относительную яркость цвета (0-1)
  static double _relativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Вычисляет контрастность между двумя цветами
  static double contrastRatio(Color color1, Color color2) {
    final l1 = _relativeLuminance(color1);
    final l2 = _relativeLuminance(color2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Проверяет соответствие WCAG AA (минимум 4.5:1 для обычного текста)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Проверяет соответствие WCAG AAA (минимум 7:1 для обычного текста)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Находит цвет с достаточной контрастностью
  static Color findContrastColor(
    Color foreground,
    Color background, {
    bool wcagAAA = false,
  }) {
    final targetRatio = wcagAAA ? 7.0 : 4.5;
    final currentRatio = contrastRatio(foreground, background);

    if (currentRatio >= targetRatio) {
      return foreground;
    }

    // Пробуем осветлить или затемнить цвет
    final luminance = _relativeLuminance(background);
    final needsLight = luminance < 0.5;

    Color testColor = foreground;
    double testRatio = currentRatio;

    // Итеративно ищем подходящий цвет
    for (int i = 0; i < 100; i++) {
      if (testRatio >= targetRatio) {
        break;
      }

      if (needsLight) {
        // Осветляем foreground
        testColor = Color.fromARGB(
          (foreground.a * 255.0).round().clamp(0, 255),
          ((foreground.r * 255.0).round() + 10).clamp(0, 255),
          ((foreground.g * 255.0).round() + 10).clamp(0, 255),
          ((foreground.b * 255.0).round() + 10).clamp(0, 255),
        );
      } else {
        // Затемняем foreground
        testColor = Color.fromARGB(
          (foreground.a * 255.0).round().clamp(0, 255),
          ((foreground.r * 255.0).round() - 10).clamp(0, 255),
          ((foreground.g * 255.0).round() - 10).clamp(0, 255),
          ((foreground.b * 255.0).round() - 10).clamp(0, 255),
        );
      }

      testRatio = contrastRatio(testColor, background);
    }

    return testColor;
  }
}

extension ColorContrastExtension on Color {
  /// Проверяет контрастность с другим цветом
  double contrastWith(Color other) {
    return ColorContrast.contrastRatio(this, other);
  }

  /// Проверяет соответствие WCAG AA
  bool meetsWCAGAAWith(Color background) {
    return ColorContrast.meetsWCAGAA(this, background);
  }
}
