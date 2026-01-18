import 'package:flutter/foundation.dart';

/// Утилиты для оптимизации производительности
class PerformanceUtils {
  /// Выполняет тяжелые вычисления в isolate
  static Future<R> computeInIsolate<Q, R>(
    ComputeCallback<Q, R> callback,
    Q message,
  ) async {
    return await compute(callback, message);
  }

  /// Мемоизация функции с одним аргументом
  static R Function(T) memoize1<T, R>(R Function(T) fn) {
    final cache = <T, R>{};
    return (T arg) {
      final cached = cache[arg];
      if (cached != null) {
        return cached;
      }
      final result = fn(arg);
      cache[arg] = result;
      return result;
    };
  }

  /// Мемоизация функции с двумя аргументами
  static R Function(T1, T2) memoize2<T1, T2, R>(
    R Function(T1, T2) fn,
  ) {
    final cache = <String, R>{};
    return (T1 arg1, T2 arg2) {
      final key = '$arg1|$arg2';
      final cached = cache[key];
      if (cached != null) {
        return cached;
      }
      final result = fn(arg1, arg2);
      cache[key] = result;
      return result;
    };
  }
}
