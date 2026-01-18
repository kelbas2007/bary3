import 'package:flutter_test/flutter_test.dart';
import 'package:bary3/utils/performance_utils.dart';

void main() {
  group('PerformanceUtils', () {
    test('memoize1 caches results', () {
      var callCount = 0;
      final fn = PerformanceUtils.memoize1<int, int>((x) {
        callCount++;
        return x * 2;
      });

      expect(fn(5), equals(10));
      expect(callCount, equals(1));

      expect(fn(5), equals(10));
      expect(callCount, equals(1)); // Should use cache

      expect(fn(10), equals(20));
      expect(callCount, equals(2));
    });

    test('memoize2 caches results for two arguments', () {
      var callCount = 0;
      final fn = PerformanceUtils.memoize2<int, int, int>((x, y) {
        callCount++;
        return x + y;
      });

      expect(fn(5, 10), equals(15));
      expect(callCount, equals(1));

      expect(fn(5, 10), equals(15));
      expect(callCount, equals(1)); // Should use cache

      expect(fn(5, 20), equals(25));
      expect(callCount, equals(2));
    });
  });
}
