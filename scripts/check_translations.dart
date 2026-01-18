#!/usr/bin/env dart
/// Скрипт для проверки полноты переводов
/// 
/// Использование:
///   dart scripts/check_translations.dart
/// 
/// Проверяет, что все ключи из app_ru.arb присутствуют в app_en.arb и app_de.arb

import 'dart:io';
import 'dart:convert';

void main() {
  final projectRoot = Directory.current;
  final l10nDir = Directory('${projectRoot.path}/lib/l10n');
  
  if (!l10nDir.existsSync()) {
    print('Ошибка: директория lib/l10n не найдена');
    exit(1);
  }

  print('🔍 Проверка полноты переводов...\n');
  
  final ruFile = File('${l10nDir.path}/app_ru.arb');
  final enFile = File('${l10nDir.path}/app_en.arb');
  final deFile = File('${l10nDir.path}/app_de.arb');
  
  if (!ruFile.existsSync() || !enFile.existsSync() || !deFile.existsSync()) {
    print('Ошибка: не найдены ARB файлы');
    exit(1);
  }

  final ruKeys = _extractKeys(ruFile);
  final enKeys = _extractKeys(enFile);
  final deKeys = _extractKeys(deFile);
  
  final missingInEn = ruKeys.difference(enKeys);
  final missingInDe = ruKeys.difference(deKeys);
  
  // Проверяем параметры только для ключей, которые имеют параметры в RU
  final paramIssues = <String>[];
  for (final key in ruKeys) {
    if (enKeys.contains(key) && deKeys.contains(key)) {
      final ruParams = _extractPlaceholders(ruFile, key);
      // Проверяем только если в RU есть параметры
      if (ruParams.isNotEmpty) {
        final enParams = _extractPlaceholders(enFile, key);
        final deParams = _extractPlaceholders(deFile, key);
        
        // Сравниваем множества параметров
        final ruParamsSorted = ruParams.toList()..sort();
        final enParamsSorted = enParams.toList()..sort();
        final deParamsSorted = deParams.toList()..sort();
        
        if (ruParamsSorted.toString() != enParamsSorted.toString()) {
          paramIssues.add('$key: параметры в EN не совпадают с RU (RU: ${ruParamsSorted.join(", ")}, EN: ${enParamsSorted.join(", ")})');
        }
        if (ruParamsSorted.toString() != deParamsSorted.toString()) {
          paramIssues.add('$key: параметры в DE не совпадают с RU (RU: ${ruParamsSorted.join(", ")}, DE: ${deParamsSorted.join(", ")})');
        }
      }
    }
  }
  
  if (missingInEn.isEmpty && missingInDe.isEmpty && paramIssues.isEmpty) {
    print('✅ Все переводы полные и корректные!');
    print('   Всего ключей: ${ruKeys.length}');
    exit(0);
  }
  
  if (missingInEn.isNotEmpty) {
    print('⚠️  Отсутствующие ключи в app_en.arb (${missingInEn.length}):');
    for (final key in missingInEn) {
      print('   - $key');
    }
    print('');
  }
  
  if (missingInDe.isNotEmpty) {
    print('⚠️  Отсутствующие ключи в app_de.arb (${missingInDe.length}):');
    for (final key in missingInDe) {
      print('   - $key');
    }
    print('');
  }
  
  if (paramIssues.isNotEmpty) {
    print('⚠️  Проблемы с параметрами (${paramIssues.length}):');
    for (final issue in paramIssues) {
      print('   - $issue');
    }
    print('');
  }
  
  print('Всего ключей в RU: ${ruKeys.length}');
  print('Всего ключей в EN: ${enKeys.length}');
  print('Всего ключей в DE: ${deKeys.length}');
  
  exit(1);
}

Set<String> _extractKeys(File file) {
  final content = file.readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  
  final keys = <String>{};
  for (final key in json.keys) {
    // Пропускаем метаданные (@@locale, @key)
    if (!key.startsWith('@') && !key.startsWith('@@')) {
      keys.add(key);
    }
  }
  
  return keys;
}

Set<String> _extractPlaceholders(File file, String key) {
  final content = file.readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  
  final metadataKey = '@$key';
  if (!json.containsKey(metadataKey)) {
    return {};
  }
  
  final metadata = json[metadataKey] as Map<String, dynamic>?;
  if (metadata == null) {
    return {};
  }
  
  final placeholders = metadata['placeholders'] as Map<String, dynamic>?;
  if (placeholders == null) {
    return {};
  }
  
  return placeholders.keys.toSet();
}
