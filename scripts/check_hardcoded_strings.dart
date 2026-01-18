#!/usr/bin/env dart
/// Скрипт для проверки хардкодных строк в коде
/// 
/// Использование:
///   dart scripts/check_hardcoded_strings.dart
/// 
/// Ищет строки на русском языке в Dart файлах, которые должны быть локализованы

import 'dart:io';

void main() {
  final projectRoot = Directory.current;
  final libDir = Directory('${projectRoot.path}/lib');
  
  if (!libDir.existsSync()) {
    print('Ошибка: директория lib не найдена');
    exit(1);
  }

  print('🔍 Поиск хардкодных строк на русском языке...\n');
  
  final issues = <String, List<String>>{};
  final dartFiles = _findDartFiles(libDir);
  
  // Паттерны для поиска строк в кавычках (без проверки языка в regex)
  final patterns = [
    // Text виджеты
    RegExp("Text\\(['\"]([^'\"]+)['\"]\\)"),
    // const Text
    RegExp("const\\s+Text\\(['\"]([^'\"]+)['\"]\\)"),
    // SnackBar с content
    RegExp("SnackBar\\([^)]*content:\\s*Text\\(['\"]([^'\"]+)['\"]\\)"),
    // AlertDialog с title или content
    RegExp("(title|content):\\s*Text\\(['\"]([^'\"]+)['\"]\\)"),
    // label с Text
    RegExp("label:\\s*Text\\(['\"]([^'\"]+)['\"]\\)"),
  ];

  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Пропускаем комментарии и строки с AppLocalizations
      if (line.trim().startsWith('//') || 
          line.contains('AppLocalizations') ||
          line.contains('l10n.') ||
          line.contains('// ignore:')) {
        continue;
      }
      
      for (final pattern in patterns) {
        final matches = pattern.allMatches(line);
        for (final match in matches) {
          final text = match.group(1) ?? match.group(2) ?? '';
          
          // Пропускаем очень короткие строки (эмодзи, символы)
          if (text.length < 3) continue;
          
          // Проверяем, что это действительно русские буквы (коды 1025-1105)
          final hasRussian = text.codeUnits.any((code) => 
            code == 1025 || code == 1105 || // Ё, ё
            (code >= 1040 && code <= 1071) || // А-Я
            (code >= 1072 && code <= 1103)    // а-я
          );
          
          if (!hasRussian) continue;
          
          // Пропускаем если это уже локализованная строка
          if (line.contains('AppLocalizations') || 
              line.contains('l10n.') ||
              (text.contains('{') && text.contains('}'))) {
            continue;
          }
          
          final filePath = file.path.replaceAll(projectRoot.path, '');
          if (!issues.containsKey(filePath)) {
            issues[filePath] = [];
          }
          issues[filePath]!.add('  Строка ${i + 1}: $text');
        }
      }
    }
  }

  if (issues.isEmpty) {
    print('✅ Хардкодных строк не найдено!');
    exit(0);
  }

  print('⚠️  Найдено хардкодных строк:\n');
  issues.forEach((file, strings) {
    print('📄 $file');
    for (final str in strings) {
      print(str);
    }
    print('');
  });

  print('Всего файлов с проблемами: ${issues.length}');
  exit(1);
}

List<File> _findDartFiles(Directory dir) {
  final files = <File>[];
  
  try {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        // Пропускаем сгенерированные файлы
        if (!entity.path.contains('.g.dart') &&
            !entity.path.contains('app_localizations') &&
            !entity.path.contains('app_localizations_')) {
          files.add(entity);
        }
      }
    }
  } catch (e) {
    print('Ошибка при сканировании: $e');
  }
  
  return files;
}
