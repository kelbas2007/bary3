import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Утилиты для проверки контрастности цветов (WCAG AA)
class ColorContrastUtils {
  /// Вычисляет относительную яркость цвета (0-1)
  static double _getRelativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Вычисляет контрастность между двумя цветами
  static double getContrastRatio(Color color1, Color color2) {
    final lum1 = _getRelativeLuminance(color1);
    final lum2 = _getRelativeLuminance(color2);
    final lighter = lum1 > lum2 ? lum1 : lum2;
    final darker = lum1 > lum2 ? lum2 : lum1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Проверяет соответствие WCAG AA (контрастность >= 4.5:1 для обычного текста)
  static bool meetsWCAGAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  /// Проверяет соответствие WCAG AAA (контрастность >= 7:1 для обычного текста)
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }

  /// Находит цвет с достаточной контрастностью
  static Color ensureContrast(
    Color foreground,
    Color background, {
    double minContrast = 4.5,
  }) {
    if (getContrastRatio(foreground, background) >= minContrast) {
      return foreground;
    }

    // Пробуем инвертировать цвет
    final inverted = Color.fromRGBO(
      (255.0 - (foreground.r * 255.0)).round().clamp(0, 255),
      (255.0 - (foreground.g * 255.0)).round().clamp(0, 255),
      (255.0 - (foreground.b * 255.0)).round().clamp(0, 255),
      foreground.a,
    );

    if (getContrastRatio(inverted, background) >= minContrast) {
      return inverted;
    }

    // Если не помогает, используем белый или черный
    final bgLum = _getRelativeLuminance(background);
    return bgLum > 0.5 ? Colors.black : Colors.white;
  }

  /// Получает безопасный цвет текста для фона
  static Color getTextColorForBackground(Color background) {
    final bgLum = _getRelativeLuminance(background);
    return bgLum > 0.5 ? Colors.black : Colors.white;
  }
}

extension ColorExtension on Color {
  /// Проверяет контрастность с другим цветом
  double contrastRatioWith(Color other) {
    return ColorContrastUtils.getContrastRatio(this, other);
  }

  /// Проверяет соответствие WCAG AA
  bool meetsWCAGAAWith(Color background) {
    return ColorContrastUtils.meetsWCAGAA(this, background);
  }

  /// Получает безопасный цвет для текста на этом фоне
  Color getTextColor() {
    return ColorContrastUtils.getTextColorForBackground(this);
  }
}
