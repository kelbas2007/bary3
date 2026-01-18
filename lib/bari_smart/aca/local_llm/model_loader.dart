import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'model_version_manager.dart';

/// Загрузчик моделей с поддержкой версий
/// 
/// Загружает модель из assets в локальное хранилище устройства
/// и предоставляет путь к файлу для LLM движка
class ModelLoader {
  static final ModelLoader _instance = ModelLoader._internal();
  factory ModelLoader() => _instance;
  ModelLoader._internal();

  String? _loadedModelPath;
  int? _loadedVersion;

  /// Загрузить модель для указанной версии АКА
  /// 
  /// [akaVersion] - версия АКА (по умолчанию текущая)
  /// [forceReload] - принудительно перезагрузить модель
  /// Возвращает путь к загруженному файлу модели
  Future<String> loadModel({
    int? akaVersion,
    bool forceReload = false,
  }) async {
    final version = akaVersion ?? ModelVersionManager.currentAkaVersion;

    // Если модель уже загружена и версия совпадает, возвращаем существующий путь
    if (!forceReload &&
        _loadedModelPath != null &&
        _loadedVersion == version) {
      if (kDebugMode) {
        debugPrint('[ModelLoader] Model v$version already loaded: $_loadedModelPath');
      }
      return _loadedModelPath!;
    }

    if (!ModelVersionManager.isVersionSupported(version)) {
      throw UnsupportedError('AKA version $version is not supported');
    }

    final assetPath = ModelVersionManager.getModelPath(version);
    final metadata = ModelVersionManager.getModelMetadata(version);

    if (kDebugMode) {
      debugPrint('[ModelLoader] Loading model v$version from $assetPath');
      debugPrint('[ModelLoader] Model: ${metadata.modelName}, Size: ${metadata.expectedSize} bytes');
    }

    try {
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
          debugPrint('[ModelLoader] Model already exists locally: $localModelPath');
        }
        _loadedModelPath = localModelPath;
        _loadedVersion = version;
        return localModelPath;
      }

      // Загружаем модель из assets
      if (kDebugMode) {
        debugPrint('[ModelLoader] Loading model from assets...');
      }

      final byteData = await rootBundle.load(assetPath);
      await localFile.writeAsBytes(byteData.buffer.asUint8List());

      if (kDebugMode) {
        final fileSize = await localFile.length();
        debugPrint('[ModelLoader] Model loaded successfully: $localModelPath ($fileSize bytes)');
      }

      _loadedModelPath = localModelPath;
      _loadedVersion = version;
      return localModelPath;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ModelLoader] Error loading model: $e');
        debugPrint('[ModelLoader] Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Получить путь к уже загруженной модели
  String? get loadedModelPath => _loadedModelPath;

  /// Получить версию загруженной модели
  int? get loadedVersion => _loadedVersion;

  /// Удалить загруженную модель с устройства
  Future<void> deleteModel(int version) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDir.path}/aka_models/model_v$version.bin';
      final file = File(modelPath);

      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          debugPrint('[ModelLoader] Model v$version deleted: $modelPath');
        }
      }

      // Если удаляемая модель была загружена, сбрасываем состояние
      if (_loadedVersion == version) {
        _loadedModelPath = null;
        _loadedVersion = null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ModelLoader] Error deleting model: $e');
      }
    }
  }

  /// Получить размер модели на устройстве
  Future<int?> getModelSize(int version) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelPath = '${appDir.path}/aka_models/model_v$version.bin';
      final file = File(modelPath);

      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ModelLoader] Error getting model size: $e');
      }
      return null;
    }
  }
}
