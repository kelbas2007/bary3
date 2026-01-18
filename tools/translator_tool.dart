#!/usr/bin/env dart
/// Простой инструмент для переводчиков
/// 
/// Использование:
///   dart tools/translator_tool.dart
/// 
/// Позволяет просматривать и редактировать переводы в интерактивном режиме

import 'dart:io';
import 'dart:convert';

void main() {
  print('🌍 Инструмент для переводчиков Bary3\n');
  print('Выберите действие:');
  print('1. Просмотреть все ключи');
  print('2. Найти ключ');
  print('3. Проверить отсутствующие переводы');
  print('4. Экспортировать ключи для перевода');
  print('5. Выход');
  
  stdout.write('\nВаш выбор: ');
  final choice = stdin.readLineSync();
  
  switch (choice) {
    case '1':
      _listAllKeys();
      break;
    case '2':
      _findKey();
      break;
    case '3':
      _checkMissing();
      break;
    case '4':
      _exportForTranslation();
      break;
    case '5':
      print('До свидания!');
      exit(0);
    default:
      print('Неверный выбор');
      exit(1);
  }
}

void _listAllKeys() {
  final ruFile = File('lib/l10n/app_ru.arb');
  if (!ruFile.existsSync()) {
    print('Ошибка: файл app_ru.arb не найден');
    exit(1);
  }
  
  final content = ruFile.readAsStringSync();
  final json = jsonDecode(content) as Map<String, dynamic>;
  
  print('\n📋 Все ключи локализации:\n');
  int index = 1;
  for (final key in json.keys) {
    if (!key.startsWith('@') && !key.startsWith('@@')) {
      final value = json[key] as String;
      print('$index. $key: ${value.length > 50 ? value.substring(0, 50) + "..." : value}');
      index++;
    }
  }
  
  print('\nВсего ключей: ${index - 1}');
}

void _findKey() {
  stdout.write('\nВведите ключ для поиска: ');
  final searchKey = stdin.readLineSync();
  
  if (searchKey == null || searchKey.isEmpty) {
    print('Ключ не может быть пустым');
    exit(1);
  }
  
  final ruFile = File('lib/l10n/app_ru.arb');
  final enFile = File('lib/l10n/app_en.arb');
  final deFile = File('lib/l10n/app_de.arb');
  
  if (!ruFile.existsSync() || !enFile.existsSync() || !deFile.existsSync()) {
    print('Ошибка: ARB файлы не найдены');
    exit(1);
  }
  
  final ruJson = jsonDecode(ruFile.readAsStringSync()) as Map<String, dynamic>;
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final deJson = jsonDecode(deFile.readAsStringSync()) as Map<String, dynamic>;
  
  print('\n🔍 Результаты поиска для "$searchKey":\n');
  
  if (ruJson.containsKey(searchKey)) {
    print('🇷🇺 RU: ${ruJson[searchKey]}');
  } else {
    print('🇷🇺 RU: ❌ Не найдено');
  }
  
  if (enJson.containsKey(searchKey)) {
    print('🇬🇧 EN: ${enJson[searchKey]}');
  } else {
    print('🇬🇧 EN: ❌ Не найдено');
  }
  
  if (deJson.containsKey(searchKey)) {
    print('🇩🇪 DE: ${deJson[searchKey]}');
  } else {
    print('🇩🇪 DE: ❌ Не найдено');
  }
}

void _checkMissing() {
  print('\n🔍 Проверка отсутствующих переводов...\n');
  
  final ruFile = File('lib/l10n/app_ru.arb');
  final enFile = File('lib/l10n/app_en.arb');
  final deFile = File('lib/l10n/app_de.arb');
  
  final ruJson = jsonDecode(ruFile.readAsStringSync()) as Map<String, dynamic>;
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  final deJson = jsonDecode(deFile.readAsStringSync()) as Map<String, dynamic>;
  
  final ruKeys = ruJson.keys.where((k) => !k.startsWith('@')).toSet();
  final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
  final deKeys = deJson.keys.where((k) => !k.startsWith('@')).toSet();
  
  final missingInEn = ruKeys.difference(enKeys);
  final missingInDe = ruKeys.difference(deKeys);
  
  if (missingInEn.isEmpty && missingInDe.isEmpty) {
    print('✅ Все переводы присутствуют!');
  } else {
    if (missingInEn.isNotEmpty) {
      print('⚠️  Отсутствует в EN (${missingInEn.length}):');
      for (final key in missingInEn) {
        print('   - $key');
      }
    }
    
    if (missingInDe.isNotEmpty) {
      print('\n⚠️  Отсутствует в DE (${missingInDe.length}):');
      for (final key in missingInDe) {
        print('   - $key');
      }
    }
  }
}

void _exportForTranslation() {
  print('\n📤 Экспорт ключей для перевода...\n');
  
  final ruFile = File('lib/l10n/app_ru.arb');
  final enFile = File('lib/l10n/app_en.arb');
  
  final ruJson = jsonDecode(ruFile.readAsStringSync()) as Map<String, dynamic>;
  final enJson = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
  
  final ruKeys = ruJson.keys.where((k) => !k.startsWith('@')).toSet();
  final enKeys = enJson.keys.where((k) => !k.startsWith('@')).toSet();
  
  final missingInEn = ruKeys.difference(enKeys);
  
  if (missingInEn.isEmpty) {
    print('✅ Все ключи переведены!');
    return;
  }
  
  print('Ключи, требующие перевода на английский:\n');
  for (final key in missingInEn) {
    print('$key: ${ruJson[key]}');
  }
  
  final outputFile = File('translation_export.txt');
  final buffer = StringBuffer();
  buffer.writeln('Ключи для перевода на английский:\n');
  for (final key in missingInEn) {
    buffer.writeln('$key: ${ruJson[key]}');
    buffer.writeln('');
  }
  
  outputFile.writeAsStringSync(buffer.toString());
  print('\n✅ Экспортировано в ${outputFile.path}');
}
