import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Мониторинг производительности приложения
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<double> _fpsHistory = [];
  final List<Duration> _loadTimes = [];
  Timer? _fpsTimer;
  int _frameCount = 0;
  DateTime? _lastFrameTime;

  /// Начать мониторинг FPS
  void startFpsMonitoring() {
    if (kDebugMode) {
      _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_lastFrameTime != null) {
          final fps = _frameCount / 1.0;
          _fpsHistory.add(fps);
          if (_fpsHistory.length > 60) {
            _fpsHistory.removeAt(0);
          }
          debugPrint('[PerformanceMonitor] FPS: ${fps.toStringAsFixed(1)}');
        }
        _frameCount = 0;
      });

      SchedulerBinding.instance.addPostFrameCallback(_onFrame);
    }
  }

  void _onFrame(Duration timestamp) {
    _frameCount++;
    _lastFrameTime = DateTime.now();
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Остановить мониторинг FPS
  void stopFpsMonitoring() {
    _fpsTimer?.cancel();
    _fpsTimer = null;
  }

  /// Получить средний FPS
  double getAverageFps() {
    if (_fpsHistory.isEmpty) return 0;
    return _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
  }

  /// Записать время загрузки экрана
  void recordLoadTime(String screenName, Duration loadTime) {
    if (kDebugMode) {
      _loadTimes.add(loadTime);
      debugPrint(
        '[PerformanceMonitor] $screenName loaded in ${loadTime.inMilliseconds}ms',
      );
    }
  }

  /// Получить среднее время загрузки
  Duration getAverageLoadTime() {
    if (_loadTimes.isEmpty) return Duration.zero;
    final total = _loadTimes
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    return Duration(milliseconds: total ~/ _loadTimes.length);
  }

  /// Очистить историю
  void clearHistory() {
    _fpsHistory.clear();
    _loadTimes.clear();
  }
}
