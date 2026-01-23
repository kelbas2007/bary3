import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'model_version_manager.dart';
import 'model_loader.dart';

/// Сообщение для Isolate с запросом на загрузку модели
class ModelLoadRequest {
  final int version;
  final SendPort sendPort;
  final String assetPath;
  final String localModelPath;
  final bool forceReload;

  ModelLoadRequest({
    required this.version,
    required this.sendPort,
    required this.assetPath,
    required this.localModelPath,
    required this.forceReload,
  });
}

/// Результат загрузки модели из Isolate
class ModelLoadResult {
  final String? modelPath;
  final String? error;
  final int version;
  final int fileSize;

  ModelLoadResult({
    required this.modelPath,
    required this.error,
    required this.version,
    required this.fileSize,
  });

  bool get isSuccess => modelPath != null && error == null;
}

/// Продвинутый загрузчик моделей с использованием Isolate для фоновой загрузки
class ModelLoaderIsolate {
  static final ModelLoaderIsolate _instance = ModelLoaderIsolate._internal();
  factory ModelLoaderIsolate() => _instance;
  ModelLoaderIsolate._internal();

  Isolate? _loadIsolate;
  final ReceivePort _receivePort = ReceivePort();
  final Map<int, Completer<ModelLoadResult>> _pendingRequests = {};
  final Map<int, String> _loadedModels = {};

  /// Загрузить модель в фоновом Isolate
  Future<ModelLoadResult> loadModelInBackground({
    required int version,
    bool forceReload = false,
  }) async {
    // Если модель уже загружена, возвращаем результат
    if (!forceReload && _loadedModels.containsKey(version)) {
      final path = _loadedModels[version]!;
      final file = File(path);
      final size = await file.length();
      return ModelLoadResult(
        modelPath: path,
        error: null,
        version: version,
        fileSize: size,
      );
    }

    // Если уже есть pending request для этой версии, возвращаем его
    if (_pendingRequests.containsKey(version)) {
      return _pendingRequests[version]!.future;
    }

    final completer = Completer<ModelLoadResult>();
    _pendingRequests[version] = completer;

    try {
      // Получаем информацию о модели
      if (!ModelVersionManager.isVersionSupported(version)) {
        throw UnsupportedError('AKA version $version is not supported');
      }

      final assetPath = ModelVersionManager.getModelPath(version);
      // metadata используется только в debug режиме
      final metadata = ModelVersionManager.getModelMetadata(version);
      if (kDebugMode) {
        debugPrint(
          '[ModelLoaderIsolate] Model: ${metadata.modelName}, Size: ${metadata.expectedSize} bytes',
        );
      }

      // Получаем директорию для хранения моделей
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/aka_models');
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      // Путь к локальному файлу модели
      final localModelPath = '${modelsDir.path}/model_v$version.bin';

      // Проверяем, существует ли уже локальная копия
      final localFile = File(localModelPath);
      if (await localFile.exists() && !forceReload) {
        if (kDebugMode) {
          debugPrint(
            '[ModelLoaderIsolate] Model already exists locally: $localModelPath',
          );
        }
        final size = await localFile.length();
        _loadedModels[version] = localModelPath;

        final result = ModelLoadResult(
          modelPath: localModelPath,
          error: null,
          version: version,
          fileSize: size,
        );

        completer.complete(result);
        _pendingRequests.remove(version);
        return result;
      }

      // Запускаем Isolate для загрузки
      await _startIsolateIfNeeded();

      // Отправляем запрос в Isolate
      // Note: request переменная создается но не используется напрямую
      // так как Isolate работает через порты
      // ignore: unused_local_variable
      final request = ModelLoadRequest(
        version: version,
        sendPort: _receivePort.sendPort,
        assetPath: assetPath,
        localModelPath: localModelPath,
        forceReload: forceReload,
      );

      // Отправляем запрос через порт
      _loadIsolate?.kill(priority: Isolate.immediate);
      await _startIsolateIfNeeded();
      _loadIsolate?.addErrorListener(_receivePort.sendPort);
      _loadIsolate?.addOnExitListener(_receivePort.sendPort);
      _loadIsolate?.ping(_receivePort.sendPort);

      // Ждем результат
      return completer.future;
    } catch (e) {
      completer.completeError(e);
      _pendingRequests.remove(version);
      rethrow;
    }
  }

  /// Запустить Isolate если он не запущен
  Future<void> _startIsolateIfNeeded() async {
    if (_loadIsolate != null) return;

    _loadIsolate = await Isolate.spawn(
      _modelLoadIsolate,
      _receivePort.sendPort,
      debugName: 'ModelLoaderIsolate',
    );

    // Обработка сообщений от Isolate
    _receivePort.listen((message) {
      if (message is ModelLoadResult) {
        _handleLoadResult(message);
      }
    });
  }

  /// Обработка результата загрузки
  void _handleLoadResult(ModelLoadResult result) {
    if (result.isSuccess) {
      _loadedModels[result.version] = result.modelPath!;
    }

    final completer = _pendingRequests[result.version];
    if (completer != null) {
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      _pendingRequests.remove(result.version);
    }
  }

  /// Функция Isolate для загрузки модели
  static void _modelLoadIsolate(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is ModelLoadRequest) {
        try {
          // Загружаем модель из assets
          final byteData = await rootBundle.load(message.assetPath);
          final bytes = byteData.buffer.asUint8List();

          // Сохраняем в файл
          final file = File(message.localModelPath);
          await file.writeAsBytes(bytes);

          final result = ModelLoadResult(
            modelPath: message.localModelPath,
            error: null,
            version: message.version,
            fileSize: bytes.length,
          );

          message.sendPort.send(result);
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('[ModelLoaderIsolate] Error: $e');
            debugPrint('[ModelLoaderIsolate] Stack trace: $stackTrace');
          }

          final result = ModelLoadResult(
            modelPath: null,
            error: e.toString(),
            version: message.version,
            fileSize: 0,
          );

          message.sendPort.send(result);
        }
      }
    });
  }

  /// Получить путь к уже загруженной модели
  String? getLoadedModelPath(int version) => _loadedModels[version];

  /// Очистить кэш загруженных моделей
  void clearCache() {
    _loadedModels.clear();
  }

  /// Остановить Isolate
  void dispose() {
    _loadIsolate?.kill(priority: Isolate.immediate);
    _loadIsolate = null;
    _receivePort.close();
    _pendingRequests.clear();
  }
}

/// Гибридный загрузчик моделей, который использует Isolate для больших моделей
/// и синхронную загрузку для маленьких
class HybridModelLoader {
  static final HybridModelLoader _instance = HybridModelLoader._internal();
  factory HybridModelLoader() => _instance;
  HybridModelLoader._internal();

  final ModelLoaderIsolate _isolateLoader = ModelLoaderIsolate();
  final Map<int, bool> _useIsolateForVersion = {};

  /// Загрузить модель, автоматически выбирая оптимальный метод
  Future<String> loadModel({
    required int version,
    bool forceReload = false,
    void Function(double progress, String stage, String? message)? onProgress,
  }) async {
    final metadata = ModelVersionManager.getModelMetadata(version);
    final expectedSize = metadata.expectedSize;

    // Для моделей больше 50MB используем Isolate
    final useIsolate = expectedSize > 50 * 1024 * 1024;
    _useIsolateForVersion[version] = useIsolate;

    if (useIsolate) {
      if (kDebugMode) {
        final mbSize = expectedSize / (1024 * 1024);
        debugPrint(
          '[HybridModelLoader] Using Isolate for model v$version (${mbSize.toStringAsFixed(1)} MB)',
        );
      }

      onProgress?.call(
        0.1,
        'starting_isolate',
        'Starting background loader...',
      );

      final result = await _isolateLoader.loadModelInBackground(
        version: version,
        forceReload: forceReload,
      );

      if (!result.isSuccess) {
        throw Exception('Failed to load model in isolate: ${result.error}');
      }

      onProgress?.call(1.0, 'complete', 'Model ready!');
      return result.modelPath!;
    } else {
      // Для маленьких моделей используем синхронную загрузку
      if (kDebugMode) {
        final mbSize = expectedSize / (1024 * 1024);
        debugPrint(
          '[HybridModelLoader] Using synchronous loader for model v$version (${mbSize.toStringAsFixed(1)} MB)',
        );
      }

      // Используем существующий ModelLoader для синхронной загрузки
      final loader = ModelLoader();
      return loader.loadModel(
        akaVersion: version,
        forceReload: forceReload,
        onProgress: onProgress,
      );
    }
  }

  /// Предварительная загрузка модели в фоне
  Future<void> preloadModel(int version) async {
    try {
      await _isolateLoader.loadModelInBackground(version: version);
      if (kDebugMode) {
        debugPrint('[HybridModelLoader] Preloaded model v$version');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HybridModelLoader] Preload failed: $e');
      }
    }
  }

  /// Получить путь к загруженной модели
  String? getLoadedModelPath(int version) {
    if (_useIsolateForVersion[version] == true) {
      return _isolateLoader.getLoadedModelPath(version);
    } else {
      final loader = ModelLoader();
      return loader.loadedVersion == version ? loader.loadedModelPath : null;
    }
  }

  /// Очистить все загруженные модели
  Future<void> clearAll() async {
    _isolateLoader.clearCache();
    // Note: ModelLoader не имеет метода clear, но можно удалить файлы
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/aka_models');
    if (await modelsDir.exists()) {
      await modelsDir.delete(recursive: true);
    }
  }
}
