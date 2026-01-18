import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:bary3/widgets/skeleton_loader.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('TransactionSkeleton renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TransactionSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('ListSkeleton renders correct number of items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListSkeleton(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(TransactionSkeleton), findsNWidgets(3));
    });

    testWidgets('PiggyBankSkeleton renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PiggyBankSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('BalanceSkeleton renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BalanceSkeleton(),
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
