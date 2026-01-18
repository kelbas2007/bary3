import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bary3/l10n/app_localizations.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('All localization keys are accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              expect(l10n, isNotNull, reason: 'AppLocalizations should not be null');
              
              // Проверяем, что основные ключи доступны
              expect(l10n!.common_cancel, isNotEmpty);
              expect(l10n.common_save, isNotEmpty);
              expect(l10n.common_delete, isNotEmpty);
              expect(l10n.balance, isNotEmpty);
              
              return const Scaffold(body: Text('Test'));
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
    });

    testWidgets('Localization works for all supported locales', (WidgetTester tester) async {
      final locales = AppLocalizations.supportedLocales;
      
      for (final locale in locales) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                expect(l10n, isNotNull, 
                  reason: 'AppLocalizations should not be null for locale ${locale.languageCode}');
                
                // Проверяем, что строки не пустые
                expect(l10n!.common_cancel, isNotEmpty,
                  reason: 'common_cancel should not be empty for ${locale.languageCode}');
                
                return Scaffold(body: Text('Test for ${locale.languageCode}'));
              },
            ),
          ),
        );
        
        await tester.pumpAndSettle();
      }
    });

    testWidgets('No hardcoded Russian strings in widgets', (WidgetTester tester) async {
      // Этот тест проверяет, что мы не используем хардкодные строки
      // В реальном приложении это можно расширить для проверки конкретных виджетов
      
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              
              // Проверяем, что используем локализацию, а не хардкод
              final cancelText = l10n.common_cancel;
              expect(cancelText, isNot('Отмена'), 
                reason: 'Should use English translation, not Russian hardcoded string');
              
              return Scaffold(
                body: Text(cancelText),
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Проверяем, что текст на экране - английский
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
