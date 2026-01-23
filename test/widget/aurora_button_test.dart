import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bary3/widgets/aurora_button.dart';

void main() {
  group('AuroraButton', () {
    testWidgets('renders button with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraButton(text: 'Test Button', onPressed: null),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AuroraButton(
                text: 'Test Button',
                onPressed: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Используем find.byType для поиска кнопки и tap с warnIfMissed: false
      final buttonFinder = find.byType(AuroraButton);
      expect(buttonFinder, findsOneWidget);

      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuroraButton(
              text: 'Test Button',
              icon: Icons.add,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
