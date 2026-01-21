import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'model_version_manager.dart';

// Callback определен в model_loader_progress_dialog.dart для избежания циклических зависимостей

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
  /// [onProgress] - callback для отслеживания прогресса (progress, stage, message)
  /// Возвращает путь к загруженному файлу модели
  Future<String> loadModel({
    int? akaVersion,
    bool forceReload = false,
    void Function(double progress, String stage, String? message)? onProgress,
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

      // Путь к локальному файлу модели (несжатая версия)
      final localModelPath = '${modelsDir.path}/model_v$version.bin';
      // Путь к сжатому файлу (временный)
      final compressedModelPath = '${modelsDir.path}/model_v$version.bin.xz';

      // Проверяем, существует ли уже локальная копия (несжатая)
      final localFile = File(localModelPath);
      if (await localFile.exists() && !forceReload) {
        if (kDebugMode) {
          debugPrint('[ModelLoader] Model already exists locally: $localModelPath');
        }
        _loadedModelPath = localModelPath;
        _loadedVersion = version;
        return localModelPath;
      }

      // Загружаем сжатую модель из assets
      onProgress?.call(0.1, 'loading', 'Loading model from assets...');
      
      if (kDebugMode) {
        debugPrint('[ModelLoader] Loading compressed model from assets...');
      }

      final byteData = await rootBundle.load(assetPath);
      final compressedFile = File(compressedModelPath);
      await compressedFile.writeAsBytes(byteData.buffer.asUint8List());

      onProgress?.call(0.3, 'loading', 'Model loaded, preparing to decompress...');

      if (kDebugMode) {
        final compressedSize = await compressedFile.length();
        debugPrint('[ModelLoader] Compressed model saved: $compressedModelPath ($compressedSize bytes)');
        debugPrint('[ModelLoader] Decompressing model...');
      }

      // Распаковываем модель
      if (metadata.compressed && metadata.compressionFormat == 'xz') {
        await _decompressXz(
          compressedFile,
          localFile,
          onProgress: (progress, stage, message) {
            // Прогресс распаковки: 0.3 - 0.9 (30% - 90% общего прогресса)
            final overallProgress = 0.3 + (progress * 0.6);
            onProgress?.call(overallProgress, stage, message);
          },
        );
        // Удаляем сжатую версию после распаковки
        await compressedFile.delete();
        if (kDebugMode) {
          debugPrint('[ModelLoader] Compressed file deleted: $compressedModelPath');
        }
      } else {
        // Если модель не сжата, просто копируем
        await compressedFile.copy(localModelPath);
        await compressedFile.delete();
      }

      onProgress?.call(1.0, 'complete', 'Model ready!');

      if (kDebugMode) {
        final fileSize = await localFile.length();
        debugPrint('[ModelLoader] Model decompressed successfully: $localModelPath ($fileSize bytes)');
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

  /// Распаковать xz архив
  /// 
  /// Использует системную утилиту xz для распаковки.
  /// На Android/iOS использует пакет archive.
  /// 
  /// [onProgress] - callback для прогресса распаковки (progress, stage, message)
  Future<void> _decompressXz(
    File compressedFile,
    File outputFile, {
    void Function(double progress, String stage, String? message)? onProgress,
  }) async {
    if (kDebugMode) {
      debugPrint('[ModelLoader] Decompressing xz file: ${compressedFile.path} -> ${outputFile.path}');
    }

    try {
      // Пытаемся использовать системную утилиту xz
      if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run(
          'xz',
          ['-d', '-c', compressedFile.path],
          runInShell: true,
        );

        if (result.exitCode != 0) {
          throw Exception('xz decompression failed: ${result.stderr}');
        }

        await outputFile.writeAsBytes(result.stdout as List<int>);
      } else if (Platform.isWindows) {
        // На Windows может потребоваться установленный xz или альтернатива
        // Пробуем найти xz в PATH
        try {
          final result = await Process.run(
            'xz',
            ['-d', '-c', compressedFile.path],
            runInShell: true,
          );

          if (result.exitCode != 0) {
            throw Exception('xz decompression failed: ${result.stderr}');
          }

          await outputFile.writeAsBytes(result.stdout as List<int>);
        } catch (e) {
          // Если xz не найден, пробуем использовать 7-Zip (если установлен)
          try {
            final result = await Process.run(
              '7z',
              ['x', '-so', compressedFile.path],
              runInShell: true,
            );

            if (result.exitCode != 0) {
              throw Exception('7z decompression failed: ${result.stderr}');
            }

            await outputFile.writeAsBytes(result.stdout as List<int>);
          } catch (e2) {
            throw Exception(
              'xz decompression failed. Please install xz or 7-Zip. '
              'Error: $e, $e2',
            );
          }
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        // На мобильных платформах используем пакет archive для распаковки xz
        if (kDebugMode) {
          debugPrint('[ModelLoader] Using archive package for xz decompression on ${Platform.operatingSystem}');
        }
        
        onProgress?.call(0.1, 'decompressing', 'Reading compressed file...');
        
        // Распаковываем с помощью XZDecoder
        // Используем файловый поток для эффективной обработки больших файлов
        final inputStream = InputFileStream(compressedFile.path);
        final decoder = XZDecoder();
        
        onProgress?.call(0.3, 'decompressing', 'Decompressing model (this may take a minute)...');
        
        final decompressedBytes = decoder.decodeBuffer(inputStream);
        
        onProgress?.call(0.8, 'decompressing', 'Saving decompressed model...');
        
        // Записываем распакованные данные порциями для отслеживания прогресса
        const chunkSize = 1024 * 1024; // 1MB chunks
        final outputSink = outputFile.openWrite();
        
        try {
          for (int i = 0; i < decompressedBytes.length; i += chunkSize) {
            final end = (i + chunkSize < decompressedBytes.length) 
                ? i + chunkSize 
                : decompressedBytes.length;
            outputSink.add(decompressedBytes.sublist(i, end));
            
            // Обновляем прогресс записи (0.8 - 0.95)
            final writeProgress = 0.8 + ((i / decompressedBytes.length) * 0.15);
            onProgress?.call(
              writeProgress,
              'decompressing',
              'Saving... ${((i / decompressedBytes.length) * 100).toStringAsFixed(0)}%',
            );
            
            // Позволяем UI обновиться
            await Future.delayed(const Duration(milliseconds: 10));
          }
        } finally {
          await outputSink.close();
        }
        
        onProgress?.call(1.0, 'decompressing', 'Decompression complete!');
        
        if (kDebugMode) {
          debugPrint('[ModelLoader] xz decompression completed using archive package');
          debugPrint('[ModelLoader] Decompressed size: ${decompressedBytes.length} bytes');
        }
      } else {
        throw UnsupportedError(
          'xz decompression not supported on ${Platform.operatingSystem}',
        );
      }

      if (kDebugMode) {
        debugPrint('[ModelLoader] xz decompression completed successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ModelLoader] Error decompressing xz: $e');
        debugPrint('[ModelLoader] Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
